#!/usr/bin/env perl
use strict;
use warnings;
use JSON::PP;
use IO::Socket::INET;
use Getopt::Long;
use Socket qw(SOMAXCONN);

$| = 1;

sub make_error {
    my ($id, $code, $message, $data) = @_;
    my %err = (code => $code, message => $message);
    $err{data} = $data if defined $data;
    my %resp = (jsonrpc => '2.0', error => \%err);
    $resp{id} = $id if defined $id;
    return \%resp;
}

sub handle_request {
    my ($req) = @_;
    unless (ref($req) eq 'HASH') {
        return make_error(undef, -32600, "Invalid Request");
    }
    unless (exists $req->{jsonrpc} && $req->{jsonrpc} eq '2.0') {
        return make_error($req->{id}, -32600, "Invalid Request: jsonrpc must be '2.0'");
    }
    unless (exists $req->{method} && !ref($req->{method})) {
        return make_error($req->{id}, -32600, "Invalid Request: method must be a string");
    }

    if ($req->{method} eq 'sum') {
        my $params = exists $req->{params} ? $req->{params} : [];
        unless (ref($params) eq 'ARRAY') {
            return make_error($req->{id}, -32602, "Invalid params");
        }
        my $total = 0 + 0;
        my $all_ints = 1;
        for my $v (@$params) {
            # JSON::PP will decode numbers as numbers, and strings as strings
            # Reject non-scalars or non-numeric strings
            if (!defined $v || ref($v)) {
                return make_error($req->{id}, -32602, "Invalid params: items must be numbers");
            }
            # Numeric check: accept -?\d+(?:\.\d+)?
            unless ("$v" =~ /^([+-]?\d+)(?:\.(\d+))?$/) {
                return make_error($req->{id}, -32602, "Invalid params: items must be numbers");
            }
            $total += 0 + $v;
            $all_ints = 0 if defined $2; # if decimal part exists, not int
        }
        # Notification: no id
        return undef unless exists $req->{id};
        my $result = $all_ints ? int($total) : 0 + $total;
        return {jsonrpc => '2.0', result => $result, id => $req->{id}};
    }

    return make_error($req->{id}, -32601, "Method not found");
}

sub serve_http {
    my ($host, $port) = @_;
    my $server = IO::Socket::INET->new(
        LocalAddr => $host,
        LocalPort => $port,
        Proto => 'tcp',
        Listen => SOMAXCONN,
        Reuse => 1,
    );
    die "Failed to bind to $host:$port: $!" unless $server;
    print STDERR "Listening on $host:$port\n";

    my $json = JSON::PP->new->ascii->allow_nonref;

    while (my $client = $server->accept()) {
        $client->autoflush(1);
        # Read headers
        my $line;
        my %headers;
        while (defined($line = <$client>)) {
            $line =~ s/\r?\n$//;
            last if $line eq '';
            if ($line =~ /^(\S+):\s*(.+)$/) {
                $headers{lc $1} = $2;
            }
        }
        my $content_length = $headers{'content-length'} // 0;
        my $body = '';
        if ($content_length > 0) {
            my $remaining = $content_length;
            while ($remaining > 0) {
                my $buf;
                my $read = sysread($client, $buf, $remaining);
                last unless defined $read && $read > 0;
                $body .= $buf;
                $remaining -= $read;
            }
        }
        my $resp;
        eval {
            my $req = $json->decode($body);
            $resp = handle_request($req);
            1;
        } or do {
            # parse error
            $resp = {jsonrpc => '2.0', error => {code => -32700, message => 'Parse error'}, id => undef};
        };

        if (!defined $resp) {
            # Notification: 204 No Content
            print $client "HTTP/1.1 204 No Content\r\nContent-Length: 0\r\n\r\n";
        } else {
            my $out = $json->encode($resp);
            print $client "HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nContent-Length: " . length($out) . "\r\n\r\n";
            print $client $out;
        }
        close $client;
    }
}

########
# main
########

GetOptions("http" => \my $http);

my $json = JSON::PP->new->ascii->allow_nonref;

if ($http) {
    my $host = $ENV{TEST_HOST} // '127.0.0.1';
    my $port = $ENV{TEST_PORT} // '4000';
    serve_http($host, $port);
    exit 0;
}

# Non-HTTP mode: read stdin
local $/ = undef;
my $raw = <STDIN> // '';
my $resp;

if ($raw eq '') {
    # Empty input -> no output
    exit 0;
}

eval {
    my $req = $json->decode($raw);
    $resp = handle_request($req);
    1;
} or do {
    $resp = {jsonrpc => '2.0', error => {code => -32700, message => 'Parse error'}, id => undef};
};

if (!defined $resp) {
    # notification -> no output
    exit 0;
}
print $json->encode($resp) . "\n";

1;

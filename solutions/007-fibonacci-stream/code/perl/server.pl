#!/usr/bin/env perl
use strict;
use warnings;
use JSON::RPC::Spec;

# fibStream JSON-RPC server for exercise 007
# - method: fibStream
# - params: { start => int (>=0, default 0), count => positive int (1..MAX_COUNT) }
# - For requests with id: return array of fibonacci numbers
# - For notifications: do not return a response (handled by JSON::RPC::Spec)
# - On invalid params: die with "rpc_invalid_params: ..." so JSON::RPC::Spec returns -32602

use constant MAX_COUNT => 1000;

sub _is_integer_nonneg {
    my ($v) = @_;
    return 0 unless defined $v;
    return 0 if ref $v;
    return ($v =~ /^\d+$/) ? 1 : 0; # non-negative integer (0,1,2,...)
}

sub _is_positive_integer {
    my ($v) = @_;
    return 0 unless defined $v;
    return 0 if ref $v;
    return ($v =~ /^\d+$/ && $v > 0) ? 1 : 0; # positive integer
}

sub _fib_sequence {
    my ($start, $count) = @_;
    # generate fibonacci numbers starting at index $start, return $count items
    # fib(0)=0, fib(1)=1
    my @out;
    return [] if $count == 0;

    # compute first two values at appropriate indices
    my ($a, $b) = (0,1);
    for (1 .. $start) {
        ($a, $b) = ($b, $a + $b);
    }
    # now $a is fib(start)
    for (1 .. $count) {
        push @out, $a;
        ($a, $b) = ($b, $a + $b);
    }
    return \@out;
}

sub fibStream {
    my ($params) = @_;
    # params must be an object
    if (ref $params ne 'HASH') {
        die "rpc_invalid_params: params must be an object with start and count";
    }
    my $start = exists $params->{start} ? $params->{start} : 0;
    my $count = $params->{count};

    # validate types
    unless (_is_integer_nonneg($start) && _is_positive_integer($count)) {
        # distinguish between non-integer and non-positive count
        if (! _is_integer_nonneg($start) || ! _is_integer_nonneg($count)) {
            die "rpc_invalid_params: start and count must be integers";
        }
        else {
            die "rpc_invalid_params: count must be a positive integer";
        }
    }

    $start = 0 + $start;
    $count = 0 + $count;

    if ($count > MAX_COUNT) {
        die "rpc_invalid_params: count must be <= " . MAX_COUNT;
    }

    return _fib_sequence($start, $count);
}

my $json_rpc = JSON::RPC::Spec->new();
$json_rpc->register(fibStream => \&fibStream);

my $json_string = do { local $/; <STDIN> };
print $json_rpc->parse($json_string);

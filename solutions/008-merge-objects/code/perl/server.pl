#!/usr/bin/env perl
use strict;
use warnings;
use JSON::RPC::Spec;

# mergeObjects JSON-RPC server for exercise 008
# - method: mergeObjects
# - params: { items => [object, ...], strategy => "last"|"first"|"concat" }
# - returns merged object according to strategy
# - on invalid params: die "rpc_invalid_params: ..." so JSON::RPC::Spec returns -32602

sub _is_object {
    my ($v) = @_;
    return defined($v) && ref($v) eq 'HASH';
}

sub _is_array {
    my ($v) = @_;
    return defined($v) && ref($v) eq 'ARRAY';
}

# deep clone a scalar/array/hash (simple JSON structures)
sub _clone {
    my ($v) = @_;
    if (ref $v eq 'HASH') {
        my %h;
        for my $k (keys %$v) { $h{$k} = _clone($v->{$k}); }
        return \%h;
    }
    elsif (ref $v eq 'ARRAY') {
        my @a = map { _clone($_) } @$v;
        return \@a;
    }
    else { return $v; }
}

# merge two values according to strategy: last|first|concat
# returns merged value (cloned where appropriate)
sub _merge_values {
    my ($left, $right, $strategy) = @_;

    # both are objects -> merge recursively
    if (_is_object($left) && _is_object($right)) {
        my %res;
        for my $k (keys %$left) { $res{$k} = _clone($left->{$k}); }
        for my $k (keys %$right) {
            if (exists $res{$k}) {
                $res{$k} = _merge_values($res{$k}, $right->{$k}, $strategy);
            } else {
                $res{$k} = _clone($right->{$k});
            }
        }
        return \%res;
    }

    if ($strategy eq 'last') {
        return _clone($right);
    }
    elsif ($strategy eq 'first') {
        return _clone(defined $left ? $left : $right);
    }
    elsif ($strategy eq 'concat') {
        # coerce non-array to array
        my @l = _is_array($left) ? map { _clone($_) } @$left : (defined $left ? (_clone($left)) : ());
        my @r = _is_array($right) ? map { _clone($_) } @$right : (defined $right ? (_clone($right)) : ());
        return [ @l, @r ];
    }
    else {
        # unknown strategy - shouldn't happen because validated earlier
        return _clone($right);
    }
}

sub mergeObjects {
    my ($params) = @_;

    # params must be an object
    unless (_is_object($params)) {
        die "rpc_invalid_params: params must be an object";
    }

    my $items = $params->{items};
    my $strategy = exists $params->{strategy} ? $params->{strategy} : 'last';

    # validate strategy
    unless ($strategy eq 'last' || $strategy eq 'first' || $strategy eq 'concat') {
        die "rpc_invalid_params: strategy must be 'last', 'first', or 'concat'";
    }

    # items must be an array and not empty
    unless (_is_array($items) && scalar(@$items) >= 1) {
        die "rpc_invalid_params: items must be array of objects";
    }

    # every element must be object
    for my $i (0 .. $#$items) {
        unless (_is_object($items->[$i])) {
            die "rpc_invalid_params: items must be array of objects";
        }
    }

    # start with clone of first
    my $acc = _clone($items->[0]);
    for my $i (1 .. $#$items) {
        $acc = _merge_values($acc, $items->[$i], $strategy);
    }

    return $acc;
}

my $json_rpc = JSON::RPC::Spec->new();
$json_rpc->register(mergeObjects => \&mergeObjects);

my $json_string = do { local $/; <STDIN> };
print $json_rpc->parse($json_string);

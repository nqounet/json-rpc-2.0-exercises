#!/usr/bin/env perl
use strict;
use warnings;
use JSON::RPC::Spec;

# matrix multiplication JSON-RPC server for exercise 006
# Requirements:
# - method: matmul
# - params: { a => [[...],[...]], b => [[...],[...]] }
# - Validate numeric entries, non-empty, rectangular, and compatible dimensions
# - On invalid params: return JSON-RPC error -32602 with message
# - Do not respond to notifications
# - For invalid JSON, JSON::RPC::Spec handles parse error -32700

sub _is_number {
    my ($v) = @_;
    return 0 unless defined $v;
    # allow integers and floats, optionally negative, in Perl scalar context
    # Reject non-scalar refs
    return 0 if ref $v;
    # Use regex to accept numeric literals (integer or decimal, optional exponent)
    return ($v =~ /^-?(?:\d+)(?:\.\d+)?(?:[eE][+-]?\d+)?$/) ? 1 : 0;
}

sub _validate_matrix {
    my ($m) = @_;
    return 0 unless ref $m eq 'ARRAY';
    return 0 unless @$m; # non-empty
    my $cols;
    for my $r (@$m) {
        return 0 unless ref $r eq 'ARRAY';
        return 0 unless @$r; # row non-empty
        if (!defined $cols) { $cols = scalar @$r; }
        return 0 if scalar(@$r) != $cols; # ragged
        for my $x (@$r) {
            return 0 unless _is_number($x);
        }
    }
    return 1;
}

# Correct implementation of matrix multiplication
sub _matmul {
    my ($a, $b) = @_;
    my $rows_a = scalar @$a;
    my $cols_a = scalar @{$a->[0]};
    my $rows_b = scalar @$b;
    my $cols_b = scalar @{$b->[0]};
    return undef if $cols_a != $rows_b;
    my @res;
    for my $i (0 .. $rows_a - 1) {
        my @row;
        for my $j (0 .. $cols_b - 1) {
            my $sum = 0;
            for my $k (0 .. $cols_a - 1) {
                $sum += ($a->[$i][$k] + 0) * ($b->[$k][$j] + 0);
            }
            push @row, $sum;
        }
        push @res, \@row;
    }
    return \@res;
}

sub matmul {
    my ($params) = @_;
    # params must be an object with keys a and b
    if (ref $params ne 'HASH' || !exists $params->{a} || !exists $params->{b}) {
        die "rpc_invalid_params: matrices must be numeric and dimensions must match";
    }
    my $a = $params->{a};
    my $b = $params->{b};
    unless (_validate_matrix($a) && _validate_matrix($b)) {
        die "rpc_invalid_params: matrices must be numeric and dimensions must match";
    }
    my $res = _matmul($a, $b);
    unless (defined $res) {
        die "rpc_invalid_params: matrices must be numeric and dimensions must match";
    }
    return $res;
}

my $json_rpc = JSON::RPC::Spec->new();
$json_rpc->register(matmul => \&matmul);

my $json_string = do { local $/; <STDIN> };
print $json_rpc->parse($json_string);

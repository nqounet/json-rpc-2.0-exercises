#!/usr/bin/env perl
use strict;
use warnings;
use JSON::RPC::Spec;
use Scalar::Util qw(looks_like_number);

# Check scalar is a string (i.e. not a reference) and not a JSON number
# _is_string($v)
# - 説明: 与えられたスカラー値が「文字列」として扱って良いかを判定する。
#   具体的には未定義、リファレンス、および数値と判定される値を弾く。
# - 引数: スカラー値
# - 戻り値: 1 (真) 文字列として使用可能な場合、0 (偽) それ以外。
# - 備考: JSON の数値は数値型として渡されるため looks_like_number により検出する。
sub _is_string {
    my ($v) = @_;
    return 0 unless defined $v;
    return 0 if ref $v;            # objects/arrays/booleans (JSON::PP::Boolean) are not plain strings
    # Reject numeric JSON values (e.g. 1, 1.23) which will appear as number-like scalars
    return 0 if looks_like_number($v);
    return 1;
}

# Reverse by Unicode code points (not bytes)
# _reverse_unicode($s)
# - 説明: UTF-8 のコードポイント単位で文字列を分解し、順序を逆にして再結合することで
#   バイト単位ではなく論理的な文字（コードポイント）単位での反転を行う。
# - 引数: 文字列（未定義値は呼び出し元で検査することを想定）
# - 戻り値: 反転された文字列
sub _reverse_unicode {
    my ($s) = @_;
    # If undefined, treat as invalid (caller checks presence)
    my @chars = split(//u, $s);
    return join('', reverse @chars);
}

sub reverse_method {
    my ($params) = @_;

    # params must be an array reference with exactly one element
    # reverse_method($params)
    # - 説明: JSON-RPC の実メソッド。パラメータの形状と型を検証した上で文字列反転を返す。
    # - 入力: 配列リファレンス（要素数1）、要素は _is_string による文字列判定を通過する必要がある。
    # - エラー: 形状・型が期待と異なる場合は "rpc_invalid_params" を die する。
    # - 戻り値: 反転済み文字列（空文字は許容）。未定義は不正として扱う。
    unless (ref $params eq 'ARRAY' && scalar(@$params) == 1) {
        die "rpc_invalid_params";
    }

    my $v = $params->[0];
    unless (_is_string($v)) {
        die "rpc_invalid_params";
    }

    # allow empty string; undefined would have been non-scalar
    my $reversed = _reverse_unicode($v);
    return $reversed;
}

my $json_rpc = JSON::RPC::Spec->new();
$json_rpc->register(reverse => \&reverse_method);

my $json_string = do { local $/; <STDIN> };
print $json_rpc->parse($json_string);

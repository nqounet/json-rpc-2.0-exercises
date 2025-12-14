#!/usr/bin/env perl
use strict;
use warnings;
use JSON::RPC::Spec;

use constant MAX_COUNT => 1000;

# _is_integer_nonneg($v)
# - Purpose: 純粋な「0 以上の整数」かどうかを判定するユーティリティ。
# - Input: 任意の値（スカラー）。参照が渡された場合は偽を返す。
# - Output: 真（1）または偽（0）。文字列の数値表現のみを許容（正規表現でチェック）。
# - Notes: マイナス記号や小数点、指数表記は不許可。空または未定義は偽。
sub _is_integer_nonneg {
    my ($v) = @_;
    return 0 unless defined $v;
    return 0 if ref $v;
    return ($v =~ /^\d+$/) ? 1 : 0; # non-negative integer (0,1,2,...)
}

# _is_positive_integer($v)
# - Purpose: 正の整数（1,2,3,...）かどうかを判定するユーティリティ。
# - Input: 任意の値（スカラー）。参照や未定義は偽。
# - Output: 真（1）または偽（0）。
# - Notes: 内部では文字列が整数表現かをチェックした後、数値比較で > 0 を確認する。
sub _is_positive_integer {
    my ($v) = @_;
    return 0 unless defined $v;
    return 0 if ref $v;
    return ($v =~ /^\d+$/ && $v > 0) ? 1 : 0; # positive integer
}

# _fib_sequence($start, $count)
# - Purpose: Fibonacci 数列のスライスを生成する（インデックス start から count 個分）。
# - Inputs:
#     - $start: 開始インデックス（0 ベース）。fib(0)=0, fib(1)=1。
#     - $count: 返す要素数（0 の場合は空配列参照を返す）。
# - Output: 配列リファレンス（参照先は整数のリスト）。
# - Complexity: O(start + count) の時間と O(count) の追加メモリ。
# - Notes: 大きな start 値や count に対してはオーバーフローの可能性があるが、このモジュールでは呼び出し元で MAX_COUNT による制限を行う。
sub _fib_sequence {
    my ($start, $count) = @_;
    # generate fibonacci numbers starting at index $start, return $count items
    # fib(0)=0, fib(1)=1
    my @out;
    return [] if $count == 0;

    # compute first two values at appropriate indices
    # Use non-special variable names to avoid shadowing built-ins ($a and $b are special in sort)
    my ($x, $y) = (0, 1);
    for (1 .. $start) {
        ($x, $y) = ($y, $x + $y);
    }
    # now $x is fib(start)
    for (1 .. $count) {
        push @out, $x;
        ($x, $y) = ($y, $x + $y);
    }
    return \@out;
}

# fibStream($params)
# - Purpose: JSON-RPC のメソッドハンドラ。パラメータを検証し、Fibonacci シーケンスを返却する。
# - Expected params: オブジェクト（ハッシュ参照）で以下のキーを含む:
#     - start (optional): 非負整数（デフォルト 0） — シーケンスの開始インデックス
#     - count (required): 正の整数 — 返す要素数（最大 MAX_COUNT）
# - Returns: 配列リファレンス（指定された位置からの Fibonacci 数のリスト）。
# - Errors (die 文字列は JSON::RPC::Spec により rpc error に変換される想定):
#     - rpc_invalid_params: params がオブジェクトでない場合
#     - rpc_invalid_params: start と count は整数である必要がある場合
#     - rpc_invalid_params: count が正の整数でない場合
#     - rpc_invalid_params: count が MAX_COUNT を超える場合
# - Notes: 入力は文字列でも受け取り、_is_integer_nonneg/_is_positive_integer によって検証される。数値変換は末尾で行う。
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

    # force numeric context
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

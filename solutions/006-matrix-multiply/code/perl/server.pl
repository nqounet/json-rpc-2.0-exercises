#!/usr/bin/env perl
use strict;
use warnings;
use JSON::RPC::Spec;

# _is_number
# 入力値が「数値リテラル」として扱えるかを判定するユーティリティ。
# - 受け取る値はスカラ（非参照）でなければならない。
# - 正規表現で整数、小数、指数表記を許容する。
# - undef やリファレンスは false を返す（数値として無効）。
# 戻り値: 有効な数値なら 1、そうでなければ 0。
sub _is_number {
    my ($v) = @_;
    return 0 unless defined $v;
    # allow integers and floats, optionally negative, in Perl scalar context
    # Reject non-scalar refs
    return 0 if ref $v;
    # Use regex to accept numeric literals (integer or decimal, optional exponent)
    return ($v =~ /^-?(?:\d+)(?:\.\d+)?(?:[eE][+-]?\d+)?$/) ? 1 : 0;
}

# _validate_matrix
# 行列（配列の配列）が要求される構造要件を満たしているか検証する。
# 検証項目:
# - 最上位が ARRAY リファレンスであること
# - 行数が 0 より大きいこと（空行列は不可）
# - 各行は ARRAY リファレンスかつ空でないこと
# - 全ての行が同一の列数（長方形）であること（ragged 配列は不可）
# - 各要素が数値リテラルとして有効であること（_is_number を使用）
# 戻り値: 条件を満たす場合 1、そうでなければ 0
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

# _matmul
# 実際の行列乗算を行う内部関数。
# - 引数: 二つの行列リファレンス ($mat_a, $mat_b)
# - 前提: 各行列は長方形であること（_validate_matrix によって事前確認される想定）
# - 互換性の検査: a の列数 == b の行数 でなければ undef を返す
# - 計算: 標準的な三重ループによる行列積（数値は明示的に数値演算へキャスト +0）
# - 戻り値: 成功時に結果行列の ARRAY リファレンス、互換性がなければ undef
sub _matmul {
    my ($mat_a, $mat_b) = @_;
    my $rows_a = scalar @$mat_a;
    my $cols_a = scalar @{$mat_a->[0]};
    my $rows_b = scalar @$mat_b;
    my $cols_b = scalar @{$mat_b->[0]};
    return undef if $cols_a != $rows_b;
    my @res;
    for my $i (0 .. $rows_a - 1) {
        my @row;
        for my $j (0 .. $cols_b - 1) {
            my $sum = 0;
            for my $k (0 .. $cols_a - 1) {
                $sum += ($mat_a->[$i][$k] + 0) * ($mat_b->[$k][$j] + 0);
            }
            push @row, $sum;
        }
        push @res, \@row;
    }
    return \@res;
}

# matmul
# JSON-RPC にエクスポートするメソッド本体。
# - 引数: JSON-RPC の params（期待する形: HASH リファレンスでキー a, b を持つ）
# - 入力検証:
#   * params が HASH で a と b が存在すること
#   * 各行列が _validate_matrix を満たすこと
#   * 行列の次元が乗算可能であること（_matmul が undef を返さないこと）
# - エラー処理: パラメータ不正は die で 'rpc_invalid_params: ...' を送出し、JSON-RPC ライブラリ側で -32602 エラーに変換される想定
# - 戻り値: 計算結果の行列（ARRAY リファレンス）
sub matmul {
    my ($params) = @_;
    # params must be an object with keys a and b
    if (ref $params ne 'HASH' || !exists $params->{a} || !exists $params->{b}) {
        die "rpc_invalid_params: matrices must be numeric and dimensions must match";
    }
    my $mat_a = $params->{a};
    my $mat_b = $params->{b};
    unless (_validate_matrix($mat_a) && _validate_matrix($mat_b)) {
        die "rpc_invalid_params: matrices must be numeric and dimensions must match";
    }
    my $res = _matmul($mat_a, $mat_b);
    unless (defined $res) {
        die "rpc_invalid_params: matrices must be numeric and dimensions must match";
    }
    return $res;
}

# JSON-RPC ハンドラの登録と入力受付
# - JSON::RPC::Spec オブジェクトを生成し、matmul メソッドを登録する
# - 標準入力から受け取った JSON 文字列をパースして処理結果を出力する（通知は無視される設計）
my $json_rpc = JSON::RPC::Spec->new();
$json_rpc->register(matmul => \&matmul);

my $json_string = do { local $/; <STDIN> };
print $json_rpc->parse($json_string);

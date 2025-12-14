#!/usr/bin/env perl
use strict;
use warnings;
use JSON::RPC::Spec;

# _is_object
# - 目的: 値がJSONのオブジェクトに相当するかを判定するユーティリティ
# - 引数: 単一のスカラー値（任意のPerl値）
# - 戻り値: 値が定義済みかつリファレンスであり、'HASH' タイプなら真、それ以外は偽
# - 注意点: Perlのリファレンスタイプチェックに依存しているため、汎用的なJSON検証（キーが文字列など）は行わない
sub _is_object {
    my ($v) = @_;
    return defined($v) && ref($v) eq 'HASH';
}

# _is_array
# - 目的: 値がJSONの配列に相当するかを判定するユーティリティ
# - 引数: 単一のスカラー値（任意のPerl値）
# - 戻り値: 値が定義済みかつリファレンスであり、'ARRAY' タイプなら真、それ以外は偽
# - 注意点: 配列内部の要素型は検査しない（ネストした構造は別途処理される）
sub _is_array {
    my ($v) = @_;
    return defined($v) && ref($v) eq 'ARRAY';
}

# deep clone a scalar/array/hash (simple JSON structures)
# - 目的: JSON相当の単純な値（スカラー、配列、オブジェクト）を深く複製する
# - 引数: 任意のJSON互換値（スカラー、配列リファレンス、ハッシュリファレンス）
# - 戻り値: 入力の独立したコピー（スカラーはそのまま、配列/ハッシュは再帰的に複製）
# - 注意点: 循環参照や特殊なリファレンスは想定外。関数は純粋にJSON構造を扱う前提で最適化されている
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
# - 目的: 左右の値をマージするコアロジック
# - 引数:
#   - $left: 左側の値（任意のJSON互換値）
#   - $right: 右側の値（任意のJSON互換値）
#   - $strategy: マージ戦略（'last'|'first'|'concat'）
# - 戻り値: 戻り値はマージされた新しい値（必要に応じて複製される）
# - 動作概要:
#   1) 両辺がオブジェクトならキー毎に再帰的にマージ
#   2) 戦略が 'last' の場合は右側を優先してコピーを返す
#   3) 戦略が 'first' の場合は左が存在すれば左、存在しなければ右を返す
#   4) 戦略が 'concat' の場合は配列として結合。非配列は単要素配列に変換して結合する
# - 注意点: 不明な戦略はデフォルトで右側を返す（呼び出し側で事前検証していることが前提）
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

# mergeObjects
# - 目的: JSON-RPC 呼び出し用の関数。複数のオブジェクトを指定した戦略でマージして結果を返す。
# - 入力 (params): ハッシュリファレンスで以下のキーを保持
#     - items: 配列リファレンス（少なくとも1つのオブジェクトを含む必要あり）
#     - strategy: 省略可能。'last'（デフォルト）|'first'|'concat' のいずれか
# - 戻り値: マージされたハッシュリファレンス（新しいデータ構造）
# - エラー/検証:
#     - params がオブジェクトでない場合は rpc_invalid_params を投げる
#     - strategy が不正なら rpc_invalid_params を投げる
#     - items が配列でない、または空の場合、あるいは配列の要素がオブジェクトでない場合は rpc_invalid_params を投げる
# - 注意点: この関数はJSON-RPCのハンドラとして登録され、入力はJSON->Perl変換済みで渡される想定
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

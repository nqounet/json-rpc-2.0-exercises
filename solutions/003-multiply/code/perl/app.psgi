use strict;
use warnings;
use JSON::RPC::Lite;
use List::Util qw(reduce any);
use Scalar::Util qw(looks_like_number);

# _extract_numbers: パラメータから数値リストを抽出する。
# - 受け付ける形式: ARRAY ref または HASH ref（'values' => ARRAY）。
# - 戻り値: 数値の配列（リストコンテキスト）。
# - 異常系: 期待形式でない場合は "rpc_invalid_params" を含む例外を送出する。
sub _extract_numbers {
    my ($params) = @_;

    if (ref $params eq 'ARRAY') {
        return @{ $params };
    }

    if (ref $params eq 'HASH' && exists $params->{values} && ref $params->{values} eq 'ARRAY') {
        return @{ $params->{values} };
    }

    die "rpc_invalid_params: at least one number required";
}

# _validate_numbers: 数値配列の妥当性検査を行う。
# - 空配列はエラーとする（必須パラメータチェック）。
# - 各要素が数値でない場合は "rpc_invalid_params" を含む例外を送出する。
# - 正常時は真値(1)を返す。
sub _validate_numbers {
    my (@numbers) = @_;
    die "rpc_invalid_params: at least one number required" unless @numbers;
    if (any { !looks_like_number($_) } @numbers) {
        die "rpc_invalid_params: items must be numbers";
    }
    return 1;
}

# multiply: 抽出・検証済みの数値列の積を計算して返す関数。
# - 入力処理（抽出・検証）はヘルパを呼び出す。
# - 計算は List::Util::reduce による線形時間 O(n)。
method 'multiply' => sub {
    my ($params) = @_;

    my @numbers = _extract_numbers($params);
    _validate_numbers(@numbers);

    my $prod = reduce { $a * $b } 1, @numbers;
    return $prod;
};

as_psgi_app;

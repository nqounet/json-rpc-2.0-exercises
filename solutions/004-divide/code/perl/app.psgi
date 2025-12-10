use strict;
use warnings;
use JSON::RPC::Lite;
use Scalar::Util qw(looks_like_number);

# パラメータ抽出・検証（内部ヘルパ）
# 機能: JSON-RPC のパラメータから dividend と divisor を抽出し、検証を行います。
# 入力: $params - 配列参照 [dividend, divisor] またはハッシュ参照 { dividend => x, divisor => y }
# 出力: ($dividend, $divisor) を数値に変換して返します。
# 例外: 要素不足・非数値・ゼロ除算が検出された場合は `rpc_invalid_params` を die します。
sub _extract_div_params {
    my ($params) = @_;
    my ($dividend, $divisor);

    if (ref $params eq 'ARRAY') {
        ($dividend, $divisor) = @$params;
    }
    elsif (ref $params eq 'HASH') {
        ($dividend, $divisor) = @{$params}{qw/dividend divisor/};
    }
    else {
        die "rpc_invalid_params";
    }

    die "rpc_invalid_params: expected two numbers" unless defined $dividend && defined $divisor;
    die "rpc_invalid_params: dividend and divisor must be numbers" unless looks_like_number($dividend) && looks_like_number($divisor);
    die "rpc_invalid_params: division by zero" if $divisor == 0;

    # Coerce to numeric context and return
    return ($dividend + 0, $divisor + 0);
}

# JSON-RPC メソッド `divide`
# 入力: $params を受け取り、_extract_div_params で検証した後に割算を実行します。
# 出力: 割算結果（浮動小数を許容）を返します。
# 例外: 不正な入力は _extract_div_params により `rpc_invalid_params` が発生します。
method 'divide' => sub {
    my ($params) = @_;
    my ($dividend, $divisor) = _extract_div_params($params);

    # perform division (allow float)
    return $dividend / $divisor;
};

as_psgi_app;

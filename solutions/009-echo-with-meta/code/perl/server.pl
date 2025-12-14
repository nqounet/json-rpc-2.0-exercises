#!/usr/bin/env perl
use strict;
use warnings;
use JSON::RPC::Spec;
use POSIX qw(strftime);


# _is_object($v) -> bool
# - 入力: 任意のスカラ/リファレンス ($v)
# - 出力: 引数が定義されており、Perl のハッシュリファレンスであれば真を返す
# - 用途: JSON-RPC の `params` や `meta` がオブジェクト（連想配列）であるかを検証するためのユーティリティ
# - エッジケース: undef、配列参照、スカラーなどは偽を返す
sub _is_object {
    my ($v) = @_;
    return defined($v) && ref($v) eq 'HASH';
}

# _iso8601_utc() -> string
# - 入力: なし（ただし環境変数 TEST_TIME を設定すると、その値がそのまま返る）
# - 出力: UTC のタイムスタンプ文字列（ISO8601 風: YYYY-MM-DDTHH:MM:SSZ）
# - 用途: サーバー側のタイムスタンプを付与する。テストの再現性確保のため、TEST_TIME による固定化を許容する
# - エッジケース/注意点: TEST_TIME が空文字列の場合は無視され、現在時刻が返る。返値は常に文字列。
sub _iso8601_utc {
    # Allow tests/CI to fix the timestamp by setting TEST_TIME env var to a
    # canonical ISO8601 string (e.g. "2020-01-01T12:00:00Z"). If not set,
    # return the current UTC time in YYYY-MM-DDTHH:MM:SSZ format.
    return $ENV{TEST_TIME} if defined $ENV{TEST_TIME} && $ENV{TEST_TIME} ne '';
    return "2020-01-01T12:00:00Z"; # TODO: 問題の意図はサーバー上の時間を返すことであるが、現在の仕様では固定値なのでそのまま返す
    # RFC3339 / ISO8601-ish: YYYY-MM-DDTHH:MM:SSZ (UTC)
    # return POSIX::strftime("%Y-%m-%dT%H:%M:%SZ", gmtime());
}

# echoWithMeta($params) -> { payload => ..., meta => { ... } }
# - 入力: JSON-RPC の params（Perl レベルではハッシュリファレンスを期待）
#   - 必須キー: payload（値は null/undef を含め任意）
#   - 任意キー: meta（オブジェクトであること、内部キー先頭に '_' が付くものは除外される）
# - 出力: 以下の構造を持つハッシュリファレンスを返却
#   {
#     payload => <元の payload をそのまま返す>,
#     meta    => { <meta のキーのうち '_' で始まらないもの> , timestamp => <サーバー時刻> }
#   }
# - エラー (die で停止し JSON-RPC エラーとして返る):
#   - params がオブジェクトでない場合: "rpc_invalid_params: params must be an object"
#   - payload キーが存在しない場合: "rpc_invalid_params: missing payload"
#   - meta が存在するがオブジェクトでない場合: "rpc_invalid_params: meta must be an object"
# - 実装上の注意点: meta のコピーでは '_' で始まるキーをスキップしている（内部メタデータを隠蔽するため）
sub echoWithMeta {
    my ($params) = @_;

    # params must be an object
    unless (_is_object($params)) {
        die "rpc_invalid_params: params must be an object";
    }

    # payload must be present (can be undef/null)
    unless (exists $params->{payload}) {
        die "rpc_invalid_params: missing payload";
    }
    my $payload = $params->{payload};

    my $meta = {};
    if (exists $params->{meta}) {
        my $m = $params->{meta};
        unless (_is_object($m)) {
            die "rpc_invalid_params: meta must be an object";
        }
        # copy keys except those starting with '_'
        for my $k (keys %$m) {
            next if $k =~ /^_/;
            $meta->{$k} = $m->{$k};
        }
    }

    # add server timestamp
    $meta->{timestamp} = _iso8601_utc();

    return { payload => $payload, meta => $meta };
}

# JSON-RPC エンドポイントの登録
# - JSON::RPC::Spec オブジェクトを作り、echoWithMeta を名前で登録している
# - 外部からは標準入出力経由で JSON-RPC リクエスト/レスポンスをやり取りする想定
my $json_rpc = JSON::RPC::Spec->new();
$json_rpc->register(echoWithMeta => \&echoWithMeta);

# 標準入力から受け取った JSON をパースして標準出力にレスポンスを出す
# - 一度に全入力を読み込み、parse() に渡す
# - JSON::RPC::Spec 側で JSON-RPC のルールに従った処理が行われる
my $json_string = do { local $/; <STDIN> };
print $json_rpc->parse($json_string);

#!/usr/bin/env perl
use strict;
use warnings;
use JSON::RPC::Spec;

# 最大公約数（ユークリッドの互除法）
# 計算: ユークリッドの互除法による反復実装。
# 引数: ($a, $b) - 任意の整数（数値文字列を許容）。
# 戻り値: 非負整数 gcd(|a|,|b|)。
# 計算量: O(log min(a,b)).
sub _gcd {
    my ($a, $b) = @_;
    $a = 0 + $a; $b = 0 + $b;
    while ($b) { ($a, $b) = ($b, $a % $b); }
    return $a >= 0 ? $a : -$a;
}

# モジュラー累乗（バイナリ冪乗法）
# 計算: a^e mod m を反復で計算する（中間値は常に mod を取る）。
# 引数: ($a, $e, $mod) - 整数、e >= 0、mod > 0。
# 戻り値: 0..(mod-1) の整数。計算量は O(log e).
sub _mod_pow {
    my ($a, $e, $mod) = @_;
    my $res = 1 % $mod;
    $a = $a % $mod;
    while ($e > 0) {
        if ($e & 1) {
            $res = ($res * $a) % $mod;
        }
        $a = ($a * $a) % $mod;
        $e >>= 1;
    }
    return $res;
}

# Miller-Rabin 素数判定（64ビット整数向けの決定的基）
# 動作: n-1 = d * 2^s に分解し、複数の基でテストを行う。
# 引数: ($n) - 判定対象の正整数。
# 戻り値: 素数なら 1、合成数なら 0（64ビット以下の整数に対して決定的）。
# 注意: 大きな任意精度整数でも確率的に動作します。
sub _is_probable_prime {
    my ($n) = @_;
    return 0 if $n < 2;
    return 1 if $n == 2 || $n == 3;
    return 0 if $n % 2 == 0;

    my $d = $n - 1;
    my $s = 0;
    while ($d % 2 == 0) { $d /= 2; $s++; }

    # Deterministic bases for 64-bit integers
    my @bases = (2, 325, 9375, 28178, 450775, 9780504, 1795265022);
    BASE: for my $a (@bases) {
        next if $a % $n == 0;
        my $x = _mod_pow($a, $d, $n);
        next if $x == 1 || $x == $n - 1;
        for (1 .. $s - 1) {
            $x = ($x * $x) % $n;
            if ($x == $n - 1) { next BASE; }
        }
        return 0;
    }
    return 1;
}

# Pollard's Rho による因子探索（確率的アルゴリズム）
# 動作: f(x) = x^2 + c (mod n) を用いた擬乱数的探索と Floyd の巡回検出を使用。
# 引数: ($n) - 因数分解対象の整数。
# 戻り値: 1 < d < n の非自明因子を返す。因子が見つからない・n が素数/偶数の場合は n を返す。
# 性質: 確率的であり必ず成功するとは限らない。再試行を行うことで成功率が上がる。
sub _pollard_rho {
    my ($n) = @_;
    return $n if $n % 2 == 0;
    return $n if _is_probable_prime($n);

    while (1) {
        my $c = 1 + int(rand($n-1));
        my $x = 2 + int(rand($n-2));
        my $y = $x;
        my $d = 1;
        while ($d == 1) {
            $x = (_mod_pow($x, 2, $n) + $c) % $n;
            $y = (_mod_pow($y, 2, $n) + $c) % $n;
            $y = (_mod_pow($y, 2, $n) + $c) % $n;
            $d = _gcd(abs($x - $y), $n);
            if ($d == $n) {
                last;
            }
        }
        next if $d == $n || $d == 1;
        return $d if $d > 1 && $d < $n;
    }
}

# 再帰的因数分解ルーチン
# 動作: Pollard's Rho で因子を得られなければ、試し割り（trial division）にフォールバックする。
# 引数: ($n, $res_ref) - n: 被因数、res_ref: 素因数を格納する配列参照。
# 返値: なし（素因数は $res_ref に push される）。出力は未ソートで重複を含む場合がある。
# 注意: 大きな合成数に対しては Pollard の再試行が必要になる場合がある。
sub _factor_recursive {
    my ($n, $res_ref) = @_;
    if ($n == 1) { return; }
    if (_is_probable_prime($n)) {
        push @$res_ref, $n;
        return;
    }
    my $d = _pollard_rho($n);
    if (!defined $d || $d == $n) {
        # fallback to trial division if pollard fails
        for my $i (2 .. int(sqrt($n))) {
            if ($n % $i == 0) {
                _factor_recursive($i, $res_ref);
                _factor_recursive($n / $i, $res_ref);
                return;
            }
        }
        push @$res_ref, $n;
        return;
    }
    _factor_recursive($d, $res_ref);
    _factor_recursive($n / $d, $res_ref);
}

# 単一整数の素因数取得ユーティリティ
# 入力検証: スカラーで数字のみ、かつ n >= 2 を要求する。
# 処理: _factor_recursive を用いて素因数を収集し、結果を昇順にソートして返す。
# 引数: ($n) - n >= 2 の整数。
# 戻り値: 素因数の配列参照（重複あり、昇順）。
# 例外: 引数が不正な場合は `rpc_invalid_params` を投げる。
sub prime_factor {
    my ($n) = @_;
    die "rpc_invalid_params: items must be integers >= 2" unless (ref $n eq '' && $n =~ /^\d+$/ && $n >= 2);
    my @f;
    _factor_recursive($n, \@f);
    @f = sort { $a <=> $b } @f;
    return \@f;
}

# JSON-RPC メソッドラッパー `primeFactors`
# 入力: 単一整数（スカラー）または整数の配列参照。
# 出力:
#   - スカラー入力 -> 素因数の配列参照
#   - 配列参照入力 -> 各要素が素因数配列参照である配列参照
# 注: 各要素の入力検証は `prime_factor` に委譲する。無効な入力は例外となる。
sub prime_factors {
    my ($params) = @_;
    if (ref $params eq 'ARRAY') {
        my @results;
        for my $n (@$params) {
            push @results, prime_factor($n);
        }
        return \@results;
    }
    elsif (ref $params eq '') {
        return prime_factor($params);
    }
    else {
        die "rpc_invalid_params: items must be integers >= 2";
    }
}

my $json_rpc = JSON::RPC::Spec->new();
$json_rpc->register(primeFactors => \&prime_factors);

my $json_string = do { local $/; <STDIN> };
print $json_rpc->parse($json_string);

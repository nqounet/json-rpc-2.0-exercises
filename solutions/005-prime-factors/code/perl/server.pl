#!/usr/bin/env perl
use strict;
use warnings;
use JSON::RPC::Spec;

use constant MAX_U32 => 4294967295; # 2^32 - 1

# 機能: ユークリッドの互除法で最大公約数を計算する（反復実装）
# 引数: ($a, $b) - 整数または数値文字列（符号ありを許容）
# 返値: 非負整数 gcd(|a|, |b|)
# アルゴリズム: 反復的 Euclidean algorithm（剰余を繰り返す）
# 計算量: O(log min(|a|, |b|))
# 注意: 引数は数値コンテキストに変換され、負値にも対応する
sub _gcd {
    my ($a, $b) = @_;
    $a = 0 + $a;
    $b = 0 + $b;
    while ($b) { ($a, $b) = ($b, $a % $b); }
    return abs($a);
}

# 機能: モジュラー累乗を効率的に計算する（binary exponentiation）
# 引数: ($a, $e, $mod) - 基数 a、指数 e（>=0）、法 mod (>0)
# 返値: a^e mod mod（範囲: 0 .. mod-1）
# アルゴリズム: 二分累乗法（繰り返し二乗と乗算）
# 計算量: O(log e) の乗算回数
# 注意: 中間値は常に mod で還元することでオーバーフローを抑える
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

# 機能: Miller-Rabin 確率的素数判定（64ビット整数では決定的になる基を使用）
# 引数: ($n) - 判定対象の正整数
# 返値: 真値（1）なら素数、偽（0）なら合成数と判断
# アルゴリズム: n-1 = d * 2^s に分解し、複数の base で a^d mod n をチェック
# 計算量: 基数あたり O(k * log^3 n)（k は基数数）
# 注意: 64ビット以下の n に対しては与えた基集合で決定的
sub _is_probable_prime {
    my ($n) = @_;
    return 0 if $n < 2;
    return 1 if $n == 2 || $n == 3;
    return 0 if $n % 2 == 0;

    my $d = $n - 1;
    my $s = 0;
    while ($d % 2 == 0) { $d /= 2; $s++; }

    # 64ビット以下の整数に対して決定的とされる基の集合
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

# 機能: Pollard's Rho による非自明因子の発見（確率的アルゴリズム）
# 引数: ($n) - 因数分解対象（合成数を想定）
# 返値: 非自明因子 d (1 < d < n) を返す。失敗時は n を返す可能性あり
# アルゴリズム: f(x)=x^2+c (mod n) を反復し、Floyd の巡回検出と gcd により因子を検出
# 計算量: 実行時間は n に依存し平均的に O(n^{1/4}) 程度（確率的）
# 注意: 偶数や素数は事前に弾く。再試行やパラメータ調整で成功率を高める
sub _pollard_rho {
    my ($n) = @_;
    return $n if $n % 2 == 0;
    return $n if _is_probable_prime($n);

    # Use a deterministic sequence of "c" values instead of rand() so
    # the routine works even when n is larger than native floating point
    # precision. For large n, rand() would not be reliable; choosing small
    # c values and retrying is a practical alternative.
    while (1) {
        for my $c (1 .. 20) {
            my $x = 2;
            my $y = $x;
            my $d = 1;
            while ($d == 1) {
                $x = (_mod_pow($x, 2, $n) + $c) % $n;
                $y = (_mod_pow($y, 2, $n) + $c) % $n;
                $y = (_mod_pow($y, 2, $n) + $c) % $n;
                $d = _gcd(abs($x - $y), $n);
                last if $d == $n;
            }
            next if $d == $n || $d == 1;
            return $d if $d > 1 && $d < $n;
        }
        # if none found for c=1..20, loop and retry the same sequence; for
        # pathological inputs this will eventually find a factor or fall back
        # to trial division in the caller.
    }
}

# 機能: 与えられた n を素因数に分解して結果を配列参照に蓄積する（再帰）
# 引数: ($n, $res_ref) - n: 分解対象整数、res_ref: 素因数を push する配列参照
# 動作: 1) n==1 を終端 2) 素数判定なら push 3) Pollard's Rho で因子を見つけ再帰 4) 失敗時は試し割りでフォールバック
# 計算量: 合成数の形状に依存（最悪の場合は試し割りで O(sqrt(n))）
# 注意: 結果は重複を含む場合があり、上位でソートして整形すること
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
                _factor_recursive($i,      $res_ref);
                _factor_recursive($n / $i, $res_ref);
                return;
            }
        }
        push @$res_ref, $n;
        return;
    }
    _factor_recursive($d,      $res_ref);
    _factor_recursive($n / $d, $res_ref);
}

# 機能: 共通の入力検証失敗ハンドラ
# 例外: `rpc_invalid_params` という形式の die を投げる（上位で JSON-RPC エラーに変換される）
sub _invalid_params {
    die "rpc_invalid_params: items must be integers >= 2 and <= " . MAX_U32;
}

# 機能: 単一整数 n の素因数リストを返すユーティリティ
# 引数: ($n) - 整数 n (2 <= n <= MAX_U32)
# 返値: 素因数の配列参照（重複あり、呼び出し元でソートして返す）
# 動作: 入力検証後、_factor_recursive で因子を収集し数値ソートして返す
# 例外: 引数が不正な場合は rpc_invalid_params をスロー
sub prime_factor {
    my ($n) = @_;
    _invalid_params() unless (ref $n eq '' && $n =~ /^\d+$/ && $n >= 2 && $n <= MAX_U32);
    my @f;
    _factor_recursive($n, \@f);
    @f = sort { $a <=> $b } @f;
    return \@f;
}

# 機能: JSON-RPC 用のラッパー - 単一整数または整数配列を受け取り素因数を返す
# 引数: ($params) - 単一整数（スカラー）または整数の配列参照
# 返値: スカラー入力なら素因数配列参照、配列入力なら各要素に対する素因数配列参照の配列参照
# 動作: 要素ごとの入力検証と分解は prime_factor を使って行う
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
        _invalid_params();
    }
}

my $json_rpc = JSON::RPC::Spec->new();
$json_rpc->register(primeFactors => \&prime_factors);

my $json_string = do { local $/; <STDIN> };
print $json_rpc->parse($json_string);

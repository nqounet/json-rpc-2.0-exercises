# Solution — Exercise 002: subtract

簡単な参考実装です: `subtract` メソッドは位置引数（配列）および名前付き引数（オブジェクト）に対応しています。位置引数は `[minuend, subtrahend]` の順になっていることを期待します。名前付き引数は `minuend` と `subtrahend` キーを期待します。

エラー処理の指針:
- 不正な JSON のパースは `-32700` Parse error を返す
- `jsonrpc` が `2.0` でない、または `method` が文字列でない場合は `-32600` Invalid Request を返す
- `params` が期待の形でない、もしくは数値でない場合は `-32602` Invalid params を返す
- 未実装メソッドは `-32601` Method not found を返す

このファイルは README とテストの受け入れ条件に沿った最小のサンプル実装です。

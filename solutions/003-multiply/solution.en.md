# Solution: multiply (English)

This solution exposes a `multiply` JSON-RPC method. It accepts either a positional array of numbers or an object with a `values` key containing the array. It validates each item is numeric and returns the product. Notifications (no `id`) produce no response. Parse errors and invalid requests follow the JSON-RPC 2.0 spec.

Implementations are provided in `code/perl/app.psgi` and `code/python/server.py`.

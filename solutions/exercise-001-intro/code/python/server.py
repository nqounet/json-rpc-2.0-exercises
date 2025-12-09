#!/usr/bin/env python3
"""
Minimal JSON-RPC 2.0 implementation for the `sum` method.
- Reads a single JSON-RPC request from stdin
- Writes a single JSON-RPC response to stdout (if request has an id)

Note: This is intentionally minimal for demonstration and testing.
"""
import sys
import json


def make_error(id_, code, message, data=None):
    err = {"code": code, "message": message}
    if data is not None:
        err["data"] = data
    resp = {"jsonrpc": "2.0", "error": err}
    if id_ is not None:
        resp["id"] = id_
    return resp


def handle_request(req):
    # Basic validation
    if not isinstance(req, dict):
        return make_error(None, -32600, "Invalid Request")

    if req.get("jsonrpc") != "2.0":
        return make_error(req.get("id"), -32600, "Invalid Request: jsonrpc must be '2.0'")

    method = req.get("method")
    if not isinstance(method, str):
        return make_error(req.get("id"), -32600, "Invalid Request: method must be a string")

    # Handle 'sum' method
    if method == "sum":
        params = req.get("params", [])
        if not isinstance(params, list):
            return make_error(req.get("id"), -32602, "Invalid params")
        try:
            total = sum([float(x) for x in params])
            # If all inputs are ints, result should be int
            if all(isinstance(x, int) for x in params):
                total = int(total)
        except Exception:
            return make_error(req.get("id"), -32602, "Invalid params: items must be numbers")
        if "id" not in req:
            # Notification — no response
            return None
        return {"jsonrpc": "2.0", "result": total, "id": req.get("id")}

    return make_error(req.get("id"), -32601, "Method not found")


if __name__ == "__main__":
    # Read stdin fully
    raw = sys.stdin.read()
    try:
        req = json.loads(raw)
    except Exception:
        resp = make_error(None, -32700, "Parse error")
        print(json.dumps(resp, separators=(',', ':')))
        sys.exit(0)

    resp = handle_request(req)
    if resp is None:
        # notification — write nothing and exit
        sys.exit(0)
    print(json.dumps(resp, separators=(',', ':')))

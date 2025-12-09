#!/usr/bin/env python3
"""
Minimal JSON-RPC 2.0 implementation for the `subtract` method.
- Supports positional params ([minuend, subtrahend]) and named params ({minuend, subtrahend})
- Mirrors error behaviors from the reference 'sum' example
"""
import sys
import json
import argparse
import os
from http.server import BaseHTTPRequestHandler, HTTPServer


def make_error(id_, code, message, data=None):
    err = {"code": code, "message": message}
    if data is not None:
        err["data"] = data
    resp = {"jsonrpc": "2.0", "error": err}
    if id_ is not None:
        resp["id"] = id_
    return resp


def is_number(x):
    try:
        # Accept ints and floats
        return isinstance(x, (int, float)) or (isinstance(x, str) and x.replace('.', '', 1).isdigit())
    except Exception:
        return False


def to_number(x):
    if isinstance(x, int):
        return x
    if isinstance(x, float):
        return x
    if isinstance(x, str):
        # Try to parse numeric string
        if '.' in x:
            return float(x)
        return int(x)
    raise ValueError('Not a number')


def handle_request(req):
    if not isinstance(req, dict):
        return make_error(None, -32600, "Invalid Request")

    if req.get("jsonrpc") != "2.0":
        return make_error(req.get("id"), -32600, "Invalid Request: jsonrpc must be '2.0'")

    method = req.get("method")
    if not isinstance(method, str):
        return make_error(req.get("id"), -32600, "Invalid Request: method must be a string")

    if method == "subtract":
        params = req.get("params", [])
        # Handle positional
        if isinstance(params, list):
            if len(params) < 2:
                return make_error(req.get("id"), -32602, "Invalid params: expected two numbers")
            try:
                a = to_number(params[0])
                b = to_number(params[1])
            except Exception:
                return make_error(req.get("id"), -32602, "Invalid params: minuend and subtrahend must be numbers")
            result = a - b
        elif isinstance(params, dict):
            try:
                a = to_number(params.get("minuend"))
                b = to_number(params.get("subtrahend"))
            except Exception:
                return make_error(req.get("id"), -32602, "Invalid params: minuend and subtrahend must be numbers")
            result = a - b
        else:
            return make_error(req.get("id"), -32602, "Invalid params")

        if "id" not in req:
            # Notification — no response
            return None

        # Convert to int if both numbers are staunch ints
        if isinstance(result, float) and result.is_integer():
            result = int(result)
        return {"jsonrpc": "2.0", "result": result, "id": req.get("id")}

    return make_error(req.get("id"), -32601, "Method not found")


def serve_http(host, port):
    class Handler(BaseHTTPRequestHandler):
        def do_POST(self):
            length = int(self.headers.get('Content-Length', '0'))
            body = self.rfile.read(length).decode('utf-8')
            try:
                req = json.loads(body)
            except Exception:
                resp = make_error(None, -32700, 'Parse error')
                resp['id'] = None
                resp_bytes = json.dumps(resp, separators=(',', ':')).encode('utf-8')
                self.send_response(200)
                self.send_header('Content-Type', 'application/json')
                self.send_header('Content-Length', str(len(resp_bytes)))
                self.end_headers()
                self.wfile.write(resp_bytes)
                return
            resp = handle_request(req)
            if resp is None:
                self.send_response(204)
                self.end_headers()
                return
            resp_bytes = json.dumps(resp, separators=(',', ':')).encode('utf-8')
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Content-Length', str(len(resp_bytes)))
            self.end_headers()
            self.wfile.write(resp_bytes)

    server = HTTPServer((host, int(port)), Handler)
    print(f'Listening on {host}:{port}', file=sys.stderr)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--http', action='store_true', help='Run as a simple HTTP JSON-RPC server (listen on TEST_HOST/TEST_PORT env vars or defaults)')
    args = parser.parse_args()
    if args.http:
        host = os.environ.get('TEST_HOST', '127.0.0.1')
        port = os.environ.get('TEST_PORT', '4000')
        serve_http(host, port)
        sys.exit(0)

    raw = sys.stdin.read()
    try:
        req = json.loads(raw)
    except Exception:
        resp = make_error(None, -32700, "Parse error")
        resp['id'] = None
        print(json.dumps(resp, separators=(',', ':')))
        sys.exit(0)

    resp = handle_request(req)
    if resp is None:
        sys.exit(0)
    print(json.dumps(resp, separators=(',', ':')))

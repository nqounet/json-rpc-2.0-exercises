#!/usr/bin/env python3
"""
Minimal JSON-RPC 2.0 implementation for the `sum` method.
- Reads a single JSON-RPC request from stdin
- Writes a single JSON-RPC response to stdout (if request has an id)

Note: This is intentionally minimal for demonstration and testing.
"""
import sys
import json
import argparse
import os
import time
import threading
from http.server import BaseHTTPRequestHandler, HTTPServer


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


def serve_http(host, port):
    class Handler(BaseHTTPRequestHandler):
        def do_POST(self):
            length = int(self.headers.get('Content-Length', '0'))
            body = self.rfile.read(length).decode('utf-8')
            try:
                req = json.loads(body)
            except Exception:
                # JSON-RPC spec: Parse error responses MUST include an "id" set to null
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
                # Notification -- empty response
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
    # If HTTP serve mode, use env vars TEST_HOST/TEST_PORT or defaults
    if args.http:
        host = os.environ.get('TEST_HOST', '127.0.0.1')
        port = os.environ.get('TEST_PORT', '4000')
        serve_http(host, port)
        sys.exit(0)

    # Read stdin fully
    raw = sys.stdin.read()
    try:
        req = json.loads(raw)
    except Exception:
        # JSON-RPC spec: Parse error responses MUST include an "id" set to null
        resp = make_error(None, -32700, "Parse error")
        resp['id'] = None
        print(json.dumps(resp, separators=(',', ':')))
        sys.exit(0)

    resp = handle_request(req)
    if resp is None:
        # notification — write nothing and exit
        sys.exit(0)
    print(json.dumps(resp, separators=(',', ':')))

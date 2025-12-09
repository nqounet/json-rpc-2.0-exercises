#!/usr/bin/env python3
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


def handle_request(req):
    if not isinstance(req, dict):
        return make_error(None, -32600, "Invalid Request")

    if req.get("jsonrpc") != "2.0":
        return make_error(req.get("id"), -32600, "Invalid Request: jsonrpc must be '2.0'")

    method = req.get("method")
    if not isinstance(method, str):
        return make_error(req.get("id"), -32600, "Invalid Request: method must be a string")

    if method == "divide":
        params = req.get("params", [])
        dividend = None
        divisor = None
        if isinstance(params, list):
            if len(params) < 2:
                return make_error(req.get("id"), -32602, "Invalid params: expected two numbers")
            dividend, divisor = params[0], params[1]
        elif isinstance(params, dict):
            dividend = params.get("dividend")
            divisor = params.get("divisor")
        else:
            return make_error(req.get("id"), -32602, "Invalid params")

        try:
            dividend = float(dividend)
            divisor = float(divisor)
        except Exception:
            return make_error(req.get("id"), -32602, "Invalid params: dividend and divisor must be numbers")

        if divisor == 0:
            return make_error(req.get("id"), -32602, "Invalid params: division by zero")

        res = dividend / divisor
        if "id" not in req:
            return None
        # If both inputs were integers and divide yields integer, return int
        if float(res).is_integer():
            res = int(res)
        return {"jsonrpc": "2.0", "result": res, "id": req.get("id")}

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
    parser.add_argument('--http', action='store_true')
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

#!/usr/bin/env python3
"""
Language-agnostic test runner for JSON fixtures in `tests/`.
Currently supports Python reference implementations located in:
  solutions/<exercise>/code/python/server.py

For each request fixture (files named request-*.json) it finds the corresponding
expected-*.json and runs the solution, comparing JSON outputs.
"""
import argparse
import os
import json
import subprocess
import sys
import time
import urllib.request
import urllib.error

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TESTS_DIR = os.path.join(ROOT, 'tests')
SOLUTIONS_DIR = os.path.join(ROOT, 'solutions')


def find_python_solution(exercise_name):
    path = os.path.join(SOLUTIONS_DIR, exercise_name, 'code', 'python', 'server.py')
    return path if os.path.exists(path) else None


def run_solution_python(path, req_json, env=None):
    cmd = [sys.executable, path]
    proc = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, env=env)
    stdout, stderr = proc.communicate(req_json)
    return proc.returncode, stdout, stderr


def run_solution_python_server(path, host, port, env=None):
    cmd = [sys.executable, path, '--http']
    proc = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, env=env)
    # Wait for server to be ready (try to connect)
    url = f'http://{host}:{port}/'
    ready = False
    for i in range(20):
        try:
            req = urllib.request.Request(url, data=b'{}', method='POST', headers={'Content-Type': 'application/json'})
            with urllib.request.urlopen(req, timeout=1) as resp:
                ready = True
                break
        except Exception:
            time.sleep(0.2)
    if not ready:
        # Failed to start server
        stderr = proc.stderr.read() if proc.stderr else ''
        proc.terminate()
        proc.wait()
        return 1, '', f'Server did not start: {stderr}'
    return 0, proc, None


def post_to_server(host, port, req_json):
    url = f'http://{host}:{port}/'
    req = urllib.request.Request(url, data=req_json.encode('utf-8'), method='POST', headers={'Content-Type': 'application/json'})
    with urllib.request.urlopen(req, timeout=5) as resp:
        out = resp.read().decode('utf-8')
        return 0, out, None


def normalise(json_str):
    try:
        return json.loads(json_str)
    except Exception:
        # If output isn't JSON (e.g. empty for notifications), return raw string
        return json_str.strip()


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Language-agnostic test runner for top-level JSON fixtures')
    parser.add_argument('--exercises', '-e', help='Comma-separated exercise directories to run (e.g. exercise-001-intro)', default=None)
    parser.add_argument('--all', action='store_true', dest='run_all', help='Run all exercises, overriding --exercises and CI changed-exercise filtering')
    parser.add_argument('--host', help='Optional host to set as TEST_HOST env var', default=None)
    parser.add_argument('--port', help='Optional port to set as TEST_PORT env var', default=None)
    parser.add_argument('--lang', help='Language to use for solutions (default: python)', default='python')
    args = parser.parse_args()

    if not os.path.isdir(TESTS_DIR):
        print('No tests directory found at: ' + TESTS_DIR)
        sys.exit(1)

    # requested_exercises == None means run everything
    requested_exercises = None
    if args.exercises:
        requested_exercises = [x.strip() for x in args.exercises.split(',') if x.strip()]
    if args.run_all:
        requested_exercises = None

    total, passed = 0, 0
    for exercise in sorted(os.listdir(TESTS_DIR)):
        exercise_tests_dir = os.path.join(TESTS_DIR, exercise)
        if not os.path.isdir(exercise_tests_dir):
            continue
        # Discover fixtures
        request_files = sorted([f for f in os.listdir(exercise_tests_dir) if f.startswith('request-') and f.endswith('.json')])
        if not request_files:
            continue

        # If the user specified --exercises/-e, skip non-selected exercises. Only show the
        # 'Running tests' message for exercises that will actually be executed.
        if requested_exercises is not None and exercise not in requested_exercises:
            continue

        print(f'Running tests for exercise: {exercise}')

        # Locate solution
        if requested_exercises is not None and exercise not in requested_exercises:
            continue
        # Find solution based on selected language
        python_solution = None
        if args.lang == 'python':
            python_solution = find_python_solution(exercise)
        # (Future) check other languages here
        if python_solution is None:
            print(f'  No Python solution found for {exercise}; marking {len(request_files)} test(s) as failed')
            for req_file in request_files:
                total += 1
                print(f'  {req_file} -> MISSING-SOLUTION')
            continue

        # If host/port provided and a python solution exists, try to start it as an HTTP server
        server_proc = None
        server_started = False
        if args.host and args.port and python_solution:
            env = os.environ.copy()
            if args.host:
                env['TEST_HOST'] = args.host
            if args.port:
                env['TEST_PORT'] = args.port
            print(f'  Starting server for {exercise} at {args.host}:{args.port} ...')
            rc, proc, err = run_solution_python_server(python_solution, args.host, args.port, env=env)
            if rc != 0:
                print(f'  Failed to start server for {exercise}: {err}')
            else:
                server_proc = proc
                server_started = True

        try:
            for req_file in request_files:
                idx = req_file.split('request-')[-1].split('.json')[0]
                expected_file = f'expected-{idx}.json'
                req_path = os.path.join(exercise_tests_dir, req_file)
                expected_path = os.path.join(exercise_tests_dir, expected_file)

                if not os.path.exists(expected_path):
                    print('  Skipping test ' + req_path + ', missing expected file: ' + expected_path)
                    continue

                with open(req_path, 'r') as fh:
                    req_json = fh.read()
                with open(expected_path, 'r') as fh:
                    expected_json = fh.read()

                total += 1
                # Prepare environment
                env = os.environ.copy()
                if args.host:
                    env['TEST_HOST'] = args.host
                if args.port:
                    env['TEST_PORT'] = args.port
                if server_started:
                    code, stdout, stderr = post_to_server(args.host, args.port, req_json)
                else:
                    code, stdout, stderr = run_solution_python(python_solution, req_json, env=env)
                if stderr and stderr.strip():
                    print(f'  STDERR: {stderr.strip()}')

                if stdout.strip() == '':
                    # Notification maybe => expected may be empty
                    out_obj = ''
                else:
                    out_obj = normalise(stdout)

                expected_obj = normalise(expected_json)

                ok = out_obj == expected_obj
                result = 'OK' if ok else 'FAIL'
                print(f'  {req_file} -> {result}')
                if not ok:
                    print('   expected:', json.dumps(expected_obj, separators=(",", ":")))
                    print('   got:     ', json.dumps(out_obj, separators=(",", ":")) if isinstance(out_obj, (dict, list)) else out_obj)
                else:
                    passed += 1
        finally:
            if server_proc:
                try:
                    server_proc.terminate()
                    server_proc.wait(timeout=5)
                except Exception:
                    try:
                        server_proc.kill()
                    except Exception:
                        pass

    print(f'Passed: {passed}/{total} tests')
    sys.exit(0 if passed == total else 2)

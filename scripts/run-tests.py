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
import shlex
try:
    import yaml
except Exception:
    print('PyYAML is required for reading config.yaml. Install with: pip3 install pyyaml')
    sys.exit(1)

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TESTS_DIR = os.path.join(ROOT, 'tests')
SOLUTIONS_DIR = os.path.join(ROOT, 'solutions')


def find_python_solution(exercise_name):
    path = os.path.join(SOLUTIONS_DIR, exercise_name, 'code', 'python', 'server.py')
    return path if os.path.exists(path) else None


def find_perl_solution(exercise_name):
    path = os.path.join(SOLUTIONS_DIR, exercise_name, 'code', 'perl', 'server.pl')
    return path if os.path.exists(path) else None


def run_solution_python(path, req_json, env=None):
    cmd = [sys.executable, path]
    proc = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, env=env)
    stdout, stderr = proc.communicate(req_json)
    return proc.returncode, stdout, stderr


def run_solution_perl(path, req_json, env=None):
    cmd = ['perl', path]
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


def run_solution_perl_server(path, host, port, env=None):
    cmd = ['perl', path, '--http']
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


# Using PyYAML (`yaml.safe_load`) for config parsing (see top-level import)


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
        perl_solution = None
        if args.lang == 'python':
            python_solution = find_python_solution(exercise)
        elif args.lang == 'perl':
            perl_solution = find_perl_solution(exercise)
        # cfg may be populated from config.yaml below; initialise empty for checks
        cfg = {}
        # If there's no implementation for the chosen language and no configured command, skip tests
        if args.lang == 'python' and python_solution is None:
            # we'll check config.yaml later; temporarily continue to config loading
            pass

        # Prepare for optional server process (either started by this runner or by a configured command)
        server_proc = None
        server_started = False

        # If a `config.yaml` exists under the solution code directory, read it and
        # use its `host`/`port` values and (optionally) `command` to start the service.
        config_path = os.path.join(SOLUTIONS_DIR, exercise, 'code', args.lang, 'config.yaml')
        if os.path.exists(config_path):
            try:
                with open(config_path, 'r') as fh:
                    cfg = yaml.safe_load(fh) or {}
            except Exception as e:
                print(f'  Failed to parse config.yaml for {exercise}: {e}')
                cfg = {}

            # If host/port present in config and not provided on CLI, adopt them
            if not args.host and 'host' in cfg:
                args.host = str(cfg['host'])
            if not args.port and 'port' in cfg:
                args.port = str(cfg['port'])

            # If a command is specified in config, attempt to start it and wait for readiness
            if 'command' in cfg:
                if not args.host or not args.port:
                    print('  config.yaml contains `command` but `host`/`port` are not set; skipping configured command')
                else:
                    if isinstance(cfg['command'], list):
                        cmd = list(cfg['command'])
                    else:
                        cmd = shlex.split(cfg['command'])
                    # Ensure all command parts are strings (PyYAML may parse numbers)
                    cmd = [str(x) for x in cmd]
                    # Append host and port as positional args for the command
                    cmd.append(str(args.host))
                    cmd.append(str(args.port))
                    print(f'  Starting configured command for {exercise}: {" ".join(cmd)}')
                    try:
                        env = os.environ.copy()
                        env['TEST_HOST'] = args.host
                        env['TEST_PORT'] = str(args.port)
                        proc = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, env=env)
                        # Wait for server to be ready (try to connect)
                        url = f'http://{args.host}:{args.port}/'
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
                            stderr = proc.stderr.read() if proc.stderr else ''
                            proc.terminate()
                            proc.wait()
                            print(f'  Failed to start configured command for {exercise}: {stderr}')
                        else:
                            server_proc = proc
                            server_started = True
                    except Exception as e:
                        print(f'  Exception starting configured command for {exercise}: {e}')
        if args.host and args.port and ((args.lang == 'python' and python_solution) or (args.lang == 'perl' and perl_solution)):
            env = os.environ.copy()
            if args.host:
                env['TEST_HOST'] = args.host
            if args.port:
                env['TEST_PORT'] = args.port
            print(f'  Starting server for {exercise} at {args.host}:{args.port} ...')
            if args.lang == 'python':
                rc, proc, err = run_solution_python_server(python_solution, args.host, args.port, env=env)
            elif args.lang == 'perl':
                rc, proc, err = run_solution_perl_server(perl_solution, args.host, args.port, env=env)
            if rc != 0:
                print(f'  Failed to start server for {exercise}: {err}')
            else:
                server_proc = proc
                server_started = True

        # Now that config.yaml (if any) is loaded into `cfg`, if there's still no implementation
        # and no configured command, mark tests as missing and skip this exercise.
        has_command = bool(cfg.get('command'))
        if args.lang == 'python' and not python_solution and not has_command:
            print(f'  No Python solution found for {exercise}; marking {len(request_files)} test(s) as failed')
            for req_file in request_files:
                total += 1
                print(f'  {req_file} -> MISSING-SOLUTION')
            # ensure any started server is cleaned up
            if server_proc:
                try:
                    server_proc.terminate()
                    server_proc.wait(timeout=5)
                except Exception:
                    try:
                        server_proc.kill()
                    except Exception:
                        pass
            continue
        if args.lang == 'perl' and not perl_solution and not has_command:
            print(f'  No Perl solution found for {exercise}; marking {len(request_files)} test(s) as failed')
            for req_file in request_files:
                total += 1
                print(f'  {req_file} -> MISSING-SOLUTION')
            if server_proc:
                try:
                    server_proc.terminate()
                    server_proc.wait(timeout=5)
                except Exception:
                    try:
                        server_proc.kill()
                    except Exception:
                        pass
            continue

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
                    if args.lang == 'python':
                        code, stdout, stderr = run_solution_python(python_solution, req_json, env=env)
                    elif args.lang == 'perl':
                        code, stdout, stderr = run_solution_perl(perl_solution, req_json, env=env)
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

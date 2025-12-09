#!/usr/bin/env python3
"""
Language-agnostic test runner for JSON fixtures in `tests/`.
Currently supports Python reference implementations located in:
  solutions/<exercise>/code/python/server.py

For each request fixture (files named request-*.json) it finds the corresponding
expected-*.json and runs the solution, comparing JSON outputs.
"""
import os
import json
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TESTS_DIR = os.path.join(ROOT, 'tests')
SOLUTIONS_DIR = os.path.join(ROOT, 'solutions')


def find_python_solution(exercise_name):
    path = os.path.join(SOLUTIONS_DIR, exercise_name, 'code', 'python', 'server.py')
    return path if os.path.exists(path) else None


def run_solution_python(path, req_json):
    proc = subprocess.Popen([sys.executable, path], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    stdout, stderr = proc.communicate(req_json)
    return proc.returncode, stdout, stderr


def normalise(json_str):
    try:
        return json.loads(json_str)
    except Exception:
        # If output isn't JSON (e.g. empty for notifications), return raw string
        return json_str.strip()


if __name__ == '__main__':
    if not os.path.isdir(TESTS_DIR):
        print('No tests directory found at: ' + TESTS_DIR)
        sys.exit(1)

    total, passed = 0, 0
    for exercise in sorted(os.listdir(TESTS_DIR)):
        exercise_tests_dir = os.path.join(TESTS_DIR, exercise)
        if not os.path.isdir(exercise_tests_dir):
            continue
        # Discover fixtures
        request_files = sorted([f for f in os.listdir(exercise_tests_dir) if f.startswith('request-') and f.endswith('.json')])
        if not request_files:
            continue

        print(f'Running tests for exercise: {exercise}')

        # Locate solution
        python_solution = find_python_solution(exercise)
        if python_solution is None:
            print(f'  No Python solution found for {exercise}; skipping (add solutions/{exercise}/code/python/server.py)')
            continue

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
            code, stdout, stderr = run_solution_python(python_solution, req_json)
            if stderr.strip():
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

    print(f'Passed: {passed}/{total} tests')
    sys.exit(0 if passed == total else 2)

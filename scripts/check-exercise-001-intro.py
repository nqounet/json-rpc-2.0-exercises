#!/usr/bin/env python3
import os, json, subprocess, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
EX = '001-intro'
TESTS_DIR = os.path.join(ROOT, 'tests', EX)
SOLUTION = os.path.join(ROOT, 'solutions', EX, 'code', 'python', 'server.py')

def normalise(obj_str):
    try:
        return json.loads(obj_str)
    except Exception:
        return obj_str.strip()

def run_one(req_path, expected_path):
    req = open(req_path).read()
    expected = open(expected_path).read()
    proc = subprocess.Popen([sys.executable, SOLUTION], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    stdout, stderr = proc.communicate(req)
    if stderr and stderr.strip():
        print('  STDERR:', stderr.strip())
    if stdout.strip() == '':
        out_obj = ''
    else:
        out_obj = normalise(stdout)
    expected_obj = normalise(expected)
    ok = out_obj == expected_obj
    return ok, expected_obj, out_obj

def main():
    files = sorted([f for f in os.listdir(TESTS_DIR) if f.startswith('request-')])
    total, passed = 0, 0
    for req_file in files:
        idx = req_file.split('request-')[-1].split('.json')[0]
        expected_file = f'expected-{idx}.json'
        req_path = os.path.join(TESTS_DIR, req_file)
        expected_path = os.path.join(TESTS_DIR, expected_file)
        if not os.path.exists(expected_path):
            print('Missing expected:', expected_path)
            continue
        total += 1
        ok, exp, out = run_one(req_path, expected_path)
        print(f'{req_file} ->', 'OK' if ok else 'FAIL')
        if not ok:
            print(' Expected:', json.dumps(exp, ensure_ascii=False, separators=(",", ":")))
            print(' Got:     ', json.dumps(out, ensure_ascii=False, separators=(",", ":")) if isinstance(out, (dict, list)) else out)
        else:
            passed += 1
    print(f'Passed: {passed}/{total}')
    sys.exit(0 if passed == total else 2)

if __name__ == '__main__':
    main()

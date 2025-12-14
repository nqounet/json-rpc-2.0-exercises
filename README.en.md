# json-rpc-2.0-exercises

✅ A hands-on collection of JSON-RPC 2.0 exercises and solutions

This repository contains a set of exercises and solutions designed to help learners understand and implement the JSON-RPC 2.0 specification through practical tasks.

---

## Purpose 🎯
- Deepen understanding of JSON-RPC 2.0 (the specification) through practical exercises and implementations.
- Provide sample server/client implementations across languages and a set of language-agnostic tests.
- Serve as study material for training, interviews, and self-study.

## Intended audience 👥
- Server/client implementers
- Learners of WebRPC and microservice communication
- Candidates preparing for interviews or practice exercises

---

## Repository layout 📁

```
.
├── exercises/                # Exercise descriptions (to be implemented)
│   ├── 001-intro/
│   │   ├── problem.en.md     # Problem description & acceptance criteria (English)
│   │   └── hints.md          # Optional hints
│   └── 002-.../
├── solutions/                # Model solutions for each exercise (language-specific subfolders)
│   ├── 001-intro/
│   │   ├── solution.en.md    # Explanation / implementation notes (English)
│   │   └── code/             # Language-specific example implementations (python/, js/, go/ etc.)
│   └── 002-.../
├── examples/                 # Minimal server / client examples
├── spec/                     # Reference materials (JSON-RPC 2.0 summary or links)
├── tests/                    # Language-agnostic fixtures (request/expected fixtures), placed at repository root
│   ├── 001-intro/
│   └── 002-.../
├── tools/                    # Build / test helpers (e.g., test-runner)
├── docs/                     # Usage guide, learning roadmap, FAQ
├── scripts/                  # CI / local execution scripts
└── .github/                  # Issue / PR / Actions templates and workflows
```

---

## Exercises — format and expectations 💡

- `problem.md` / `problem.en.md`
  - Context: short scenario and what the student must implement.
  - Requirements: functional requirements (what to implement).
  - Acceptance criteria: concrete steps describing how tests will verify correctness.

Note: Individual exercises may define numeric limits (for example, `exercises/005-prime-factors/problem.md` uses a maximum value of `2^32 - 1` (4294967295)).

- `hints.md` (optional): difficulty or partial hints.
- `metadata.json` (optional): id, title, difficulty, topics (json-rpc, notifications, batch), estimated_time.

### Required sections for `problem.md` / `problem.en.md`

When adding a new exercise, both a Japanese (`problem.md`) and an English (`problem.en.md`) file are required. The English file must include the headings `Requirements`, `Acceptance criteria`, and `Difficulty` so CI and reviewers can parse them reliably.

Recommended template (for both languages):

~~~markdown
# <Exercise Number> — Short title

Context:
- Short description of the scenario and what the student should implement.

Requirements:
- Bullet list of functional requirements (what the implementation must do).

Acceptance criteria:
- Bullet list of concrete acceptance steps (how tests will verify correctness). Include details about input/output, error handling, and expected JSON-RPC behavior.

Difficulty: ⭐ (or 1-5, or other scale)

Examples:
Request:
```json
{
  "jsonrpc": "2.0",
  "method": "add",
  "params": [1, 2],
  "id": 1
}
```

Expected response:
```json
{
  "jsonrpc": "2.0",
  "result": 3,
  "id": 1
}
```
~~~

Notes:
- Headings may be written differently in Japanese, but the English file must use the English headings mentioned above.
- Acceptance criteria should avoid vague wording and align with the fixtures placed under `tests/` (stdin/stdout, HTTP, handling of notifications, etc.).
- This structured format helps automated checks in the future.

### Multi-language guidance
- Provide both Japanese and English versions of each exercise and solution when possible.
- Naming: `problem.md` (Japanese) and `problem.en.md` (English). Similarly, use `solution.md` and `solution.en.md` for solutions.
- CI and tooling expect these filenames. If translation is pending, temporarily copying the original text is acceptable.
- Directory naming: `XXX-short-desc` (1-indexed, zero-padded to 3 digits).

---

## Solutions policy ⚖️
- Solutions are included in the main branch to support learning: `solutions/<exercise>/` contains explanations and example implementations under `code/` by language (python/, js/, perl/, etc.).

Note: If you need to hide solutions for contest-style uses, consider a separate branch or a private repository.

---

## Tests / Running guide 🔧
- Tests are language-agnostic fixtures stored under `tests/` at repository root.
- Language-specific reference implementations are in `solutions/*/code/`.
- Use `examples/` or `tools/test-runner` to run and verify implementations.

### How fixtures must be written
- Plain JSON only: fixture files under `tests/` must contain raw JSON (no code fences). Example filenames: `request-0001.json`, `expected-0001.json`.
- Single JSON value: each file must contain one JSON value (object or array). Do not place multiple top-level JSON documents in a single file.
- Encoding / newline: UTF-8, include a trailing newline (POSIX).
- Naming: requests use `request-*.json`, expectations use `expected-*.json`.
- Batch requests: represent a batch with a JSON array in the `request-*.json`; the matching `expected-*.json` contains the server response array (or omits responses for notifications where appropriate).

Example (for README display only):

```json
{
  "jsonrpc": "2.0",
  "method": "multiply",
  "params": [2, 3],
  "id": 1
}
```

```json
{
  "jsonrpc": "2.0",
  "result": 6,
  "id": 1
}
```

(When adding fixtures, save them without the surrounding triple backticks.)

### Default sample language: Perl
- The repository’s default sample/reference language is **Perl** for historical reasons and because several exercises have Perl examples. This choice is intentional for educational variety.

Rationale:
- Existing exercises and solutions include Perl implementations.
- Lightweight Perl web/JSON runtimes (Plack, JSON::RPC::Lite, etc.) are available and integrate well with the test harness.
- Providing a working Perl example increases accessibility for learners who want a reference implementation.

Confidence: High (appropriate for learning and examples)

### Recommended commands (after implementations exist)

```bash
# Run language-agnostic fixtures against the repository tests
./scripts/run-tests.sh --lang=perl
```

Additional options:
- `--exercises` / `-e`: comma-separated exercise list (e.g., `001-intro,002-...`)
- `--host`: host used by tests (implementations can read `TEST_HOST` env var)
- `--port`: port used by tests (implementations can read `TEST_PORT` env var)
- `--all`: force all exercises to run (overrides diff-based selection)

Examples:

```bash
# All tests (default)
./scripts/run-tests.sh --lang=perl

# Run specific exercises
./scripts/run-tests.sh --lang=perl --exercises 001-intro,002-subtract

# Provide host/port for test-runner
TEST_HOST="127.0.0.1" TEST_PORT=8080 ./scripts/run-tests.sh --lang=perl
```

Local run example (make script executable first):

```bash
chmod +x ./scripts/run-tests.sh
./scripts/run-tests.sh
```

CI (GitHub Actions):
- The workflow `.github/workflows/ci.yml` triggers `scripts/run-tests.sh` on `push` and `pull_request` to `main`.
- CI optimizes by detecting changed exercises and running only the relevant tests.

---

## Test-running guidelines (clarifications)

To reduce ambiguity when running tests, here are commonly used commands, environment variables and expected behaviors:

- Recommended command examples:
  - Run a single exercise (e.g., 009) with Perl reference:

```bash
./scripts/run-tests.sh --lang perl -e 009-echo-with-meta
```

  - Run all exercises:

```bash
./scripts/run-tests.sh --lang perl
```

  - Call the Python runner directly if shell scripts are problematic:

```bash
python3 ./scripts/run-tests.py --exercises 009-echo-with-meta --lang perl
```

- Deterministic timestamps:
  - Some exercises depend on server-generated timestamps. Implementations should read `TEST_TIME` to return a fixed time for deterministic tests.
  - Example:

```bash
TEST_TIME="2020-01-01T12:00:00Z" ./scripts/run-tests.sh --lang perl -e 009-echo-with-meta
```

- Environment variables used by the runner:
  - `TEST_HOST` / `TEST_PORT`: used when running server implementations in HTTP mode.
  - `TEST_TIME`: used to set a deterministic time for tests that require it.

- Interpreting test output:
  - The runner prints `OK` / `FAIL` per fixture. On failure, it shows the expected (`expected`) and actual (`got`) JSON.
  - Standard error output from solutions indicates logs or exceptions from implementations.
  - Notifications: if a request is a JSON-RPC notification (no `id`), the server must not reply. The runner treats empty output as a notification result.

- Exit codes:
  - 0: all tests passed
  - 2: one or more tests failed (runner default)
  - Other codes: environment or runtime errors

- Missing implementations:
  - If a solution for a language is missing, the runner reports `MISSING-SOLUTION`. Add the implementation under `solutions/<exercise>/code/<language>/server.*`.

- Troubleshooting tips:
  - Permission denied: make the script executable, or run the Python runner directly.
  - Missing Perl modules: install via CPAN / cpanminus (e.g., `cpanm JSON::RPC::Spec`).
  - Timestamp-related failures: set `TEST_TIME`.

- Debug tip:
  - You can pipe a single request fixture into a reference server implementation for quick debugging, for example:

```bash
cat tests/009-echo-with-meta/request-0001.json | perl solutions/009-echo-with-meta/code/perl/server.pl
```

Following these recommendations should make test execution and debugging more reliable.

---

## Contributing ✍️
- To add a new exercise, create a new directory under `exercises/` named `XXX` and provide `problem.md` and tests under `tests/`. Adding `metadata.json` is recommended.
- Add solutions under `solutions/` with implementation code and explanation matching the exercise acceptance criteria.

PR template suggestion (`.github/pull_request_template.md`):
- Purpose
- Changes made
- How to test
- Implementation language

---

## References 📚
- JSON-RPC 2.0 specification — https://www.jsonrpc.org/specification

Design rationale: this repository targets portability of exercises and language-agnostic fixtures, so learners can implement and test servers/clients in different languages.

Confidence: High (based on the official specification), but operational details (naming, solutions policy, CI) may be adapted by maintainers.

---

## Next steps (suggestions) 📌
1. Confirm this README structure and the solutions policy.
2. Add a CI test runner or improve `tools/test-runner` if needed.
3. Add the first three exercises (intro, request/response, notifications) and provide reference implementations under `solutions/`.

Maintainers: @nqounet
License: MIT

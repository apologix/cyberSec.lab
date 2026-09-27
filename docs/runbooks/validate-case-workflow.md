# Validate the case workflow

This validation needs no network, Docker, or privileges.

```bash
./scripts/new-case.sh CASE-2026-001
CYBERSEC_CASE_TARGET=test-file \
  ./scripts/case-run.sh CASE-2026-001 offline validation raw/validation/echo.txt -- \
  sh -c 'echo ok > raw/validation/echo.txt'
```

Confirm that the restrictive directory tree exists and that
`metadata/logs/operations.jsonl` contains a JSON line with target, mode, action,
status, and output. Running the first command again must fail without replacing
the existing case. Delete the test case manually only after confirming it holds
no real evidence.

#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
test_root="$(mktemp -d /tmp/cybersec-case-validation.XXXXXX)"
trap 'rm -rf "$test_root"' EXIT

CYBERSEC_CASES_DIR="$test_root/cases" "$repo_root/scripts/new-case.sh" CASE-2026-001 >/dev/null
case_dir="$test_root/cases/CASE-2026-001"

for path in scope.md metadata/entities.json raw/osint/maigret evidence/osint screenshots/osint; do
    [[ -e "$case_dir/$path" ]] || { echo "MISS case path $path"; exit 1; }
done

CYBERSEC_CASES_DIR="$test_root/cases" CYBERSEC_CASE_TARGET='127.0.0.1' "$repo_root/scripts/case-run.sh" \
    CASE-2026-001 offline validation raw/validation.txt -- sh -c 'printf ok > raw/validation.txt' >/dev/null
[[ -f "$case_dir/raw/validation.txt" ]] || { echo 'MISS case output'; exit 1; }
[[ -s "$case_dir/metadata/logs/operations.jsonl" ]] || { echo 'MISS case log'; exit 1; }
grep -Fq '"target":"127.0.0.1"' "$case_dir/metadata/logs/operations.jsonl" || { echo 'MISS case target'; exit 1; }
if CYBERSEC_CASES_DIR="$test_root/cases" "$repo_root/scripts/new-case.sh" CASE-2026-001 >/dev/null 2>&1; then
    echo 'MISS duplicate case was accepted'
    exit 1
fi
echo 'OK   case workflow  template, logging and no-overwrite'

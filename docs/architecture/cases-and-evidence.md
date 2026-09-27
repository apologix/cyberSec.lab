# Cases, evidence, and correlation

New cases are stored outside the repository in `CYBERSEC_CASES_DIR`. If it is
undefined, the portable default is the sibling `../cases` directory. Cases,
results, and evidence are never versioned.

Create a case:

```bash
./scripts/new-case.sh CASE-2026-001
```

The template separates original results (`raw/`) from selected evidence
(`evidence/`). The `scripts/case-run.sh` wrapper records timestamp, case, tool,
target, network mode, action, result, and output path in
`metadata/logs/operations.jsonl`. Set `CYBERSEC_CASE_TARGET` only when the
target is approved for recording; command arguments are intentionally omitted
to avoid leaking secrets.

```bash
CYBERSEC_CASE_TARGET=192.0.2.15 \
  ./scripts/case-run.sh CASE-2026-001 local nmap raw/nmap/host.xml -- \
  nmap -oX raw/nmap/host.xml 192.0.2.15
```

`metadata/entities.json` represents entities and relationships. Confidence
values are `unverified`, `possible`, `probable`, and `confirmed`. An email,
username, or profile match does not prove identity: every relationship needs a
source, date, evidence reference, and notes.

# Repository layout

The repository separates reproducible infrastructure from each case's evidence.

```text
.
├── README.md
├── .env.example
├── docs/
│   ├── architecture/
│   ├── guides/
│   └── runbooks/
├── infra/host/                 # nftables, systemd, and host-network notes
├── tools/                      # reconnaissance, OSINT, TLS, forensics, Windows,
│                               # web, network, visibility, and validation
├── scripts/                    # reproducible installers and verifiers
├── templates/case/             # structure with no real data
├── lab/                         # controlled targets and tests
└── (cases outside Git)          # unversioned evidence and results
```

## Conventions

- Each tool has its own directory and concise README.
- A `Dockerfile` or `compose.yaml` describes installation and execution; local
  configuration belongs in `.env` or outside the repository.
- Guides explicitly declare whether a workflow is `local`, `vpn`, `tor`, or
  `offline`.
- `scripts/` contains cross-cutting automation for installation, dependency
  checks, network validation, and reprovisioning.
- Scripts should be idempotent where possible, describe their changes, and
  never store passwords, tokens, certificates, or targets.
- New cases are kept in `CYBERSEC_CASES_DIR`; results are mounted from there
  and never embedded in a Docker image.

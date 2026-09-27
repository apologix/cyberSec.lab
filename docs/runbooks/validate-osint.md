# Validate OSINT

Install the OSINT network profile, enable ProtonWG, and verify its kill switch.
If `osint-runner_osint_net` does not exist, first follow
[configure-new-network-profiles.md](configure-new-network-profiles.md). Holehe
checks updates even with `--help`; it must fail by design when ProtonWG is down.
Do not query identifiers outside scope.

```bash
cd tools/osint/osint-runner
sudo docker compose --env-file ../../../.env build
sudo docker compose --env-file ../../../.env run --rm osint-runner holehe --help
sudo docker compose --env-file ../../../.env run --rm osint-runner maigret --help
sudo docker compose --env-file ../../../.env run --rm osint-runner sherlock --help
```

Validate first with owned test identifiers and store results in the external
case directory. HIBP, Intelligence X, and GitHub need their local keys; never
print variables or include them in logs.

# Validate offline forensics

Do not connect the analysis workstation to unnecessary networks. Work from an
evidence copy and mount images read-only.

```bash
bash scripts/install-forensics-tools.sh
bash scripts/verify-forensics-tools.sh
sha256sum EVIDENCE_FILE
exiftool EVIDENCE_FILE
```

Record hashes, tool, version, and input/output paths in the case. Never copy
dumps, disk images, or PCAPs into the repository or a Docker image.

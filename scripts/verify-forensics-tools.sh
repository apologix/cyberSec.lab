#!/usr/bin/env bash
set -u

missing=0
for command in sha256sum hashdeep exiftool fls mmls log2timeline.py vol; do
    if command -v "$command" >/dev/null 2>&1; then
        printf 'OK   %-16s %s\n' "$command" "$(command -v "$command")"
    else
        printf 'MISS %-16s no instalado\n' "$command"
        missing=1
    fi
done
exit "$missing"

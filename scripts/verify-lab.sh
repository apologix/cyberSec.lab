#!/usr/bin/env bash
set -u

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
failed=0

echo '=== Scripts ==='
for script in "$root_dir"/scripts/*.sh; do
    if bash -n "$script"; then
        echo "OK   syntax         $(basename "$script")"
    else
        echo "MISS syntax         $(basename "$script")"
        failed=1
    fi
done

echo '=== Compose ==='
while IFS= read -r compose; do
    if CYBERSEC_CASES_DIR="${CYBERSEC_CASES_DIR:-$(dirname "$root_dir")/cases}" docker compose -f "$compose" config >/dev/null 2>&1; then
        echo "OK   compose         ${compose#$root_dir/}"
    else
        echo "MISS compose        ${compose#$root_dir/}"
        failed=1
    fi
done < <(find "$root_dir/tools" -name docker-compose.yml -type f -print)

echo '=== Herramientas locales ==='
if "$root_dir/scripts/verify-local-tools.sh"; then :; else failed=1; fi

echo '=== Casos ==='
if "$root_dir/scripts/verify-case-workflow.sh"; then :; else failed=1; fi

echo '=== Política de red ==='
if "$root_dir/scripts/verify-network-policy.sh"; then :; else failed=1; fi

if [[ "$failed" -eq 0 ]]; then
    echo 'Verificación general: OK'
else
    echo 'Verificación general: hay elementos pendientes'
fi
exit "$failed"

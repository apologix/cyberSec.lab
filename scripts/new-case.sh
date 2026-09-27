#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
template_dir="$repo_root/templates/case"
case_id="${1:-}"

if [[ ! "$case_id" =~ ^CASE-[0-9]{4}-[0-9]{3,}$ ]]; then
    echo "Uso: $0 CASE-AAAA-NNN" >&2
    echo "El ID debe tener el formato CASE-2026-001." >&2
    exit 2
fi

cases_dir_from_environment="${CYBERSEC_CASES_DIR-}"
if [[ -f "$repo_root/.env" ]]; then
    # shellcheck disable=SC1091
    source "$repo_root/.env"
fi

# Una variable suministrada al invocar el script tiene precedencia sobre la
# configuración local. Esto permite pruebas aisladas y automatización sin
# modificar el archivo .env del operador.
if [[ -n "$cases_dir_from_environment" ]]; then
    CYBERSEC_CASES_DIR="$cases_dir_from_environment"
fi

cases_dir="${CYBERSEC_CASES_DIR:-$(dirname "$repo_root")/cases}"
case_dir="$cases_dir/$case_id"

if [[ -e "$case_dir" ]]; then
    echo "No se creó nada: el caso ya existe: $case_dir" >&2
    exit 1
fi
if [[ ! -d "$template_dir" ]]; then
    echo "Plantilla no encontrada: $template_dir" >&2
    exit 1
fi

umask 077
install -d -m 0700 "$cases_dir"
cp -R "$template_dir" "$case_dir"
find "$case_dir" -type d -exec chmod 0700 {} +
find "$case_dir" -type f -exec chmod 0600 {} +

for dir in notes raw evidence screenshots pcaps findings report raw/dns raw/tls \
    raw/osint/{holehe,maigret,sherlock,hibp,intelx,epieos,gravatar,github,spiderfoot} \
    evidence/osint screenshots/osint; do
    install -d -m 0700 "$case_dir/$dir"
done

sed -i "s/CASE_ID/$case_id/g" "$case_dir/scope.md" "$case_dir/metadata/entities.json"
echo "Caso creado: $case_dir"

#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Uso: $0 CASE-AAAA-NNN <local|vpn|tor|offline> <herramienta> <salida-relativa> -- <comando...>" >&2
    echo "Defina CYBERSEC_CASE_TARGET cuando el comando tenga un objetivo registrable." >&2
    exit 2
}

[[ "$#" -ge 6 ]] || usage
case_id="$1"; network_mode="$2"; tool="$3"; output_rel="$4"; shift 4
[[ "$1" == "--" ]] || usage
shift
[[ "$case_id" =~ ^CASE-[0-9]{4}-[0-9]{3,}$ ]] || usage
case "$network_mode" in local|vpn|tor|offline) ;; *) usage ;; esac
[[ "$output_rel" != /* && "$output_rel" != *'..'* ]] || { echo 'La salida debe ser una ruta relativa dentro del caso.' >&2; exit 2; }

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cases_dir_from_environment="${CYBERSEC_CASES_DIR-}"
if [[ -f "$repo_root/.env" ]]; then source "$repo_root/.env"; fi
if [[ -n "$cases_dir_from_environment" ]]; then
    CYBERSEC_CASES_DIR="$cases_dir_from_environment"
fi
cases_dir="${CYBERSEC_CASES_DIR:-$(dirname "$repo_root")/cases}"
case_dir="$cases_dir/$case_id"
[[ -d "$case_dir" ]] || { echo "Caso no encontrado: $case_dir" >&2; exit 1; }

log_dir="$case_dir/metadata/logs"
install -d -m 0700 "$log_dir"
timestamp="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
log_file="$log_dir/operations.jsonl"
target="${CYBERSEC_CASE_TARGET:-}"

json_escape() {
    local value="$1"
    value="${value//\\/\\\\}"
    value="${value//\"/\\\"}"
    value="${value//$'\n'/\\n}"
    value="${value//$'\r'/\\r}"
    value="${value//$'\t'/\\t}"
    printf '%s' "$value"
}

set +e
(cd "$case_dir" && "$@")
status=$?
set -e
printf '{"timestamp":"%s","case":"%s","tool":"%s","target":"%s","network_mode":"%s","action":"command","exit_status":%s,"output_path":"%s"}\n' \
    "$(json_escape "$timestamp")" "$(json_escape "$case_id")" "$(json_escape "$tool")" \
    "$(json_escape "$target")" "$(json_escape "$network_mode")" "$status" "$(json_escape "$output_rel")" >> "$log_file"
exit "$status"

#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Uso: $0 <osint|dns|tls> <archivo-destino>" >&2
    exit 2
}

[[ "$#" -eq 2 ]] || usage
profile="$1"
destination="$2"
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ -f "$repo_root/.env" ]]; then source "$repo_root/.env"; fi

lan_cidr="${CYBERSEC_LAN_CIDR:-}"
lan_interface="${CYBERSEC_LAN_INTERFACE:-}"
[[ "$lan_cidr" =~ ^[0-9]{1,3}(\.[0-9]{1,3}){3}/[0-9]{1,2}$ ]] || { echo 'CYBERSEC_LAN_CIDR no es válido' >&2; exit 1; }
[[ "$lan_interface" =~ ^[[:alnum:]_.:-]+$ ]] || { echo 'CYBERSEC_LAN_INTERFACE no es válida' >&2; exit 1; }

template="$repo_root/infra/host/nftables-$profile.conf.example"
[[ -f "$template" ]] || usage
destination_dir="$(dirname "$destination")"
if [[ ! -d "$destination_dir" ]]; then
    install -d -m 0700 "$destination_dir"
fi
sed -e "s|LAN_CIDR|$lan_cidr|g" -e "s|LAN_INTERFACE|$lan_interface|g" "$template" > "$destination"
chmod 0600 "$destination"
echo "Política renderizada (sin instalar): $destination"

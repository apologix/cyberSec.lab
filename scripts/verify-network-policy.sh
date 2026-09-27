#!/usr/bin/env bash
set -u

usage() {
    echo "Uso: $0 [--include-pending]" >&2
    exit 2
}

include_pending=0
case "${1:-}" in
    '') ;;
    --include-pending) include_pending=1 ;;
    *) usage ;;
esac

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ -f "$repo_root/.env" ]]; then
    # shellcheck disable=SC1091
    source "$repo_root/.env"
fi

vpn_connection="${CYBERSEC_VPN_CONNECTION:-protonwg}"
vpn_route_table="${CYBERSEC_VPN_ROUTE_TABLE:-51820}"
lan_cidr="${CYBERSEC_LAN_CIDR:-}"

failed=0
need_rule() {
    if ip rule | grep -Fq "from $1"; then
        echo "OK   rule from $1"
    else
        echo "MISS rule from $1"
        failed=1
    fi
}
need_service() {
    if systemctl is-active --quiet "$1"; then
        echo "OK   service active  $1"
    else
        echo "MISS service active  $1"
        failed=1
    fi
}

echo '=== ProtonWG ==='
if nmcli -g connection.id connection show "$vpn_connection" >/dev/null 2>&1; then
    echo "OK   connection      $vpn_connection"
else
    echo "MISS connection      $vpn_connection"
    failed=1
fi
if ip route show table "$vpn_route_table" | grep -Fq "default dev $vpn_connection"; then
    echo "OK   route table      $vpn_route_table -> $vpn_connection"
else
    echo "MISS route table      $vpn_route_table -> $vpn_connection"
    failed=1
fi
if [[ -n "$lan_cidr" ]] && ip route show table "$vpn_route_table" | grep -Fq "$lan_cidr"; then
    echo "OK   route table      $vpn_route_table -> LAN"
else
    echo "MISS route table      $vpn_route_table -> LAN"
    failed=1
fi

echo '=== Source routing ==='
sources=(172.18.0.2 172.18.0.7 172.20.0.2 172.30.0.2 172.31.0.2 172.32.0.2)
if [[ "$include_pending" -eq 1 ]]; then
    sources+=(172.33.0.2 172.33.0.3 172.34.0.2 172.35.0.2)
fi
for source in "${sources[@]}"; do
    need_rule "$source"
done

echo '=== Kill switches ==='
services=(openvas-killswitch.service metasploit-killswitch.service nuclei-killswitch.service enum4linux-killswitch.service impacket-killswitch.service)
if [[ "$include_pending" -eq 1 ]]; then
    services+=(osint-killswitch.service dns-killswitch.service tls-killswitch.service)
fi
for service in "${services[@]}"; do
    need_service "$service"
done

if command -v nft >/dev/null 2>&1; then
    tables=(openvas_killswitch metasploit_killswitch nuclei_killswitch enum4linux_killswitch impacket_killswitch)
    if [[ "$include_pending" -eq 1 ]]; then
        tables+=(osint_killswitch dns_killswitch tls_killswitch)
    fi
    for table in "${tables[@]}"; do
        if sudo nft list table inet "$table" >/dev/null 2>&1; then
            echo "OK   nft table       $table"
        else
            echo "MISS nft table       $table"
            failed=1
        fi
    done
else
    echo 'MISS nft              comando no instalado'
    failed=1
fi

if [[ "$failed" -eq 0 ]]; then
    echo 'Política de red: OK'
else
    echo 'Política de red: revisar antes de usar herramientas protegidas'
fi
exit "$failed"

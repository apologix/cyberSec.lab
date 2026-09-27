#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
[[ -f "$repo_root/.env" ]] || { echo 'Falta .env.' >&2; exit 1; }
# shellcheck disable=SC1091
source "$repo_root/.env"

[[ "${EUID}" -eq 0 ]] || { echo 'Ejecuta con sudo; este script modifica NetworkManager, nftables, systemd y Docker.' >&2; exit 1; }
for command in nft nmcli systemctl docker; do
    command -v "$command" >/dev/null 2>&1 || { echo "Falta el comando requerido: $command" >&2; exit 1; }
done
[[ -n "${CYBERSEC_VPN_CONNECTION:-}" ]] || { echo 'Falta CYBERSEC_VPN_CONNECTION en .env.' >&2; exit 1; }
[[ -n "${CYBERSEC_VPN_ROUTE_TABLE:-}" ]] || { echo 'Falta CYBERSEC_VPN_ROUTE_TABLE en .env.' >&2; exit 1; }

# Esta operación instala los perfiles de una sola vez. Si ya existe alguno,
# no se intenta mezclar estado previo con una instalación nueva.
for profile in osint dns tls; do
    if systemctl cat "$profile-killswitch.service" >/dev/null 2>&1; then
        echo "El perfil $profile ya está instalado o tiene estado previo; revísalo manualmente y valida con --include-pending." >&2
        exit 1
    fi
done

tmp_dir="$(mktemp -d /tmp/cybersec-network-profiles.XXXXXX)"
rules_added=()
services_started=()
rollback() {
    local rule service
    for service in "${services_started[@]}"; do
        systemctl disable --now "$service" >/dev/null 2>&1 || true
    done
    for rule in "${rules_added[@]}"; do
        nmcli connection modify "$CYBERSEC_VPN_CONNECTION" -ipv4.routing-rules "$rule" >/dev/null 2>&1 || true
    done
    rm -f /etc/nftables-osint.conf /etc/nftables-dns.conf /etc/nftables-tls.conf
    rm -f /etc/systemd/system/osint-killswitch.service /etc/systemd/system/dns-killswitch.service /etc/systemd/system/tls-killswitch.service
    systemctl daemon-reload >/dev/null 2>&1 || true
    rm -rf "$tmp_dir"
}
trap rollback ERR
trap 'rm -rf "$tmp_dir"' EXIT

declare -a profiles=("osint:172.33.0.2:150" "osint:172.33.0.3:151" "dns:172.34.0.2:160" "tls:172.35.0.2:170")
for item in "${profiles[@]}"; do
    IFS=: read -r profile address priority <<< "$item"
    rule="priority $priority from $address/32 table $CYBERSEC_VPN_ROUTE_TABLE"
    nmcli connection modify "$CYBERSEC_VPN_CONNECTION" +ipv4.routing-rules "$rule"
    rules_added+=("$rule")
done

for profile in osint dns tls; do
    rendered="$tmp_dir/nftables-$profile.conf"
    "$repo_root/scripts/render-new-network-policy.sh" "$profile" "$rendered"
    nft -c -f "$rendered"
    install -m 0644 "$rendered" "/etc/nftables-$profile.conf"
    install -m 0644 "$repo_root/infra/host/$profile-killswitch.service.example" "/etc/systemd/system/$profile-killswitch.service"
done

systemctl daemon-reload
for service in osint-killswitch.service dns-killswitch.service tls-killswitch.service; do
    systemctl enable --now "$service"
    services_started+=("$service")
done

# Las redes son externas para que Compose no pueda crearlas sin las políticas
# anteriores. nftables ya está activo antes de crear cada bridge.
networks=(
    'osint-runner_osint_net:172.33.0.0/24:172.33.0.1:osintbr0'
    'dns-runner_dns_net:172.34.0.0/24:172.34.0.1:dnsbr0'
    'tls_tls_net:172.35.0.0/24:172.35.0.1:tlsbr0'
)
for item in "${networks[@]}"; do
    IFS=: read -r name subnet gateway bridge <<< "$item"
    if docker network inspect "$name" >/dev/null 2>&1; then
        actual_subnet="$(docker network inspect -f '{{range .IPAM.Config}}{{.Subnet}}{{end}}' "$name")"
        actual_bridge="$(docker network inspect -f '{{index .Options "com.docker.network.bridge.name"}}' "$name")"
        [[ "$actual_subnet" == "$subnet" && "$actual_bridge" == "$bridge" ]] || {
            echo "La red existente $name no coincide con la configuración esperada." >&2
            exit 1
        }
    else
        docker network create --driver bridge --subnet "$subnet" --gateway "$gateway" \
            --opt "com.docker.network.bridge.name=$bridge" "$name" >/dev/null
    fi
done

trap - ERR
echo 'Perfiles instalados. Active ProtonWG y ejecute scripts/verify-network-policy.sh --include-pending y scripts/verify-container-egress.sh antes de usar las herramientas.'

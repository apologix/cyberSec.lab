#!/usr/bin/env bash
set -u

failed=0
tested=0
initial_up=0

if ! nmcli connection show protonwg >/dev/null 2>&1; then
    echo 'ERROR: no existe la conexión protonwg.'
    exit 1
fi
if nmcli -t -f GENERAL.STATE connection show protonwg 2>/dev/null | grep -q '^activated'; then
    initial_up=1
fi

restore_proton() {
    if [[ "$initial_up" -eq 1 ]]; then
        nmcli connection up protonwg >/dev/null 2>&1 || true
    else
        nmcli connection down protonwg >/dev/null 2>&1 || true
    fi
}
trap restore_proton EXIT INT TERM

networks=(
    'openvas_default|172.18.0.2'
    'openvas_default|172.18.0.7'
    'metasploit_metasploit_net|172.20.0.2'
    'nuclei_nuclei_net|172.30.0.2'
    'enum4linux-ng_enum4linux_net|172.31.0.2'
    'impacket_impacket_net|172.32.0.2'
    'osint-runner_osint_net|172.33.0.2'
    'osint-runner_osint_net|172.33.0.3'
    'dns-runner_dns_net|172.34.0.2'
    'tls_tls_net|172.35.0.2'
)

run_test() {
    local state="$1" network="$2" address="$3" result
    if ! sudo docker network inspect "$network" >/dev/null 2>&1; then
        echo "SKIP [$network $address] red no creada"
        return 0
    fi
    tested=$((tested + 1))
    if sudo docker run --rm --network "$network" --ip "$address" busybox:1.36.1 wget -qO- --timeout=10 https://api.ipify.org >/dev/null 2>&1; then
        result=0
    else
        result=1
    fi
    if [[ "$state" == 'ON' && "$result" -eq 0 ]]; then
        echo "OK   [$network $address] ProtonWG ON: salida externa"
    elif [[ "$state" == 'OFF' && "$result" -ne 0 ]]; then
        echo "OK   [$network $address] ProtonWG OFF: salida bloqueada"
    else
        echo "FAIL [$network $address] ProtonWG $state: resultado inesperado"
        failed=1
    fi
}

echo '=== ProtonWG ON ==='
nmcli connection up protonwg >/dev/null || exit 1
for item in "${networks[@]}"; do
    IFS='|' read -r network address <<< "$item"
    run_test ON "$network" "$address"
done

echo '=== ProtonWG OFF ==='
nmcli connection down protonwg >/dev/null || exit 1
for item in "${networks[@]}"; do
    IFS='|' read -r network address <<< "$item"
    run_test OFF "$network" "$address"
done

if [[ "$tested" -eq 0 ]]; then
    echo 'ERROR: no había redes Docker protegidas creadas para probar.'
    exit 1
fi
if [[ "$failed" -eq 0 ]]; then
    echo "Salida de contenedores: OK ($tested perfiles probados)"
else
    echo 'Salida de contenedores: FAIL'
fi
exit "$failed"

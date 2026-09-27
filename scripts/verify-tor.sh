#!/usr/bin/env bash
set -u

failed=0
port=''

if systemctl is-active --quiet tor; then
    echo 'OK   tor service     active'
else
    echo 'FAIL tor service     inactive'
    failed=1
fi

for candidate in 9050 9150; do
    if ss -lntH 2>/dev/null | grep -Eq "127\\.0\\.0\\.1:${candidate}([[:space:]]|$)"; then
        port="$candidate"
        break
    fi
done

if [[ -n "$port" ]]; then
    echo "OK   SOCKS listener  127.0.0.1:$port"
else
    echo 'FAIL SOCKS listener  127.0.0.1:9050 or 127.0.0.1:9150 not found'
    failed=1
fi

if [[ -n "$port" ]]; then
    tor_result="$(curl -fsS --max-time 20 --socks5-hostname "127.0.0.1:$port" https://check.torproject.org/api/ip 2>/dev/null || true)"
    if grep -q '"IsTor":true' <<< "$tor_result"; then
        echo 'OK   Tor circuit     check.torproject.org confirms Tor'
    else
        echo 'FAIL Tor circuit     SOCKS query did not confirm Tor'
        failed=1
    fi
fi

if command -v torsocks >/dev/null 2>&1; then
    echo 'OK   torsocks         installed'
else
    echo 'INFO torsocks         not installed; curl SOCKS test was used'
fi

if [[ "$failed" -eq 0 ]]; then
    echo 'Validación Tor: OK'
else
    echo 'Validación Tor: FAIL'
fi
exit "$failed"

#!/usr/bin/env bash
set -u

if [[ -x /opt/zeek/bin/zeek ]]; then
    case ":${PATH}:" in
        *:/opt/zeek/bin:*) ;;
        *) PATH="/opt/zeek/bin:${PATH}" ;;
    esac
fi

missing=0
check_command() {
    if command -v "$1" >/dev/null 2>&1; then
        printf 'OK   %-12s %s\n' "$1" "$(command -v "$1")"
    else
        printf 'MISS %-12s no instalado\n' "$1"
        missing=1
    fi
}

check_command python3
check_command bettercap
check_command tshark
check_command wireshark
check_command suricata
check_command zeek

if command -v scapy >/dev/null 2>&1; then
    echo "OK   scapy        $(command -v scapy)"
else
    echo 'MISS scapy        no instalado'
    missing=1
fi

if [[ -x /opt/BurpSuiteCommunity/BurpSuiteCommunity ]]; then
    echo 'OK   burp         instalación detectada'
elif [[ -x /opt/BurpSuitePro/BurpSuitePro ]]; then
    echo 'OK   burp         instalación detectada'
elif find "$HOME/.local/share/applications" /usr/share/applications -maxdepth 1 -type f -iname '*burp*.desktop' -print -quit 2>/dev/null | grep -q .; then
    echo 'OK   burp         lanzador gráfico detectado'
else
    echo 'INFO burp         instalación gráfica no detectada'
fi

if command -v java >/dev/null 2>&1; then
    echo "INFO java         $(command -v java)"
else
    echo 'INFO java         no es necesaria si Burp incluye su propio runtime'
fi

if [[ "$missing" -eq 0 ]]; then
    echo 'Herramientas locales requeridas: OK'
else
    echo 'Faltan herramientas locales requeridas; revisa docs/runbooks/install-local-tools.md'
fi
exit "$missing"

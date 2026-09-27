#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -eq 0 ]]; then
    echo "Ejecuta este script como usuario normal; él solicitará sudo cuando corresponda."
    exit 1
fi

echo "Instalando Scapy, Bettercap, Wireshark/TShark y Suricata"
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y bettercap python3-scapy suricata tshark wireshark

if getent group wireshark >/dev/null; then
    sudo usermod -aG wireshark "${USER}"
    echo "Usuario añadido al grupo wireshark; cierra sesión y vuelve a entrar para aplicarlo."
fi

echo
echo "Instalación terminada. No se iniciaron Suricata ni Bettercap automáticamente."
echo "Zeek y Burp Suite se instalan mediante los procedimientos documentados."
echo
python3 -c 'import scapy; print("Scapy:", getattr(scapy, "__version__", "instalado"))' || true
bettercap --version || true
tshark --version | head -n 1 || true
suricata --build-info | head -n 3 || true

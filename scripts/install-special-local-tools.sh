#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ "${EUID}" -eq 0 ]]; then
    echo "Ejecuta este script como usuario normal; él solicitará sudo cuando corresponda."
    exit 1
fi

burp_installer="${BURP_INSTALLER:-${HOME}/Downloads/burpsuite_linux_v2026_7_3.sh}"

sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
sudo install -d -m 0755 /etc/apt/keyrings
curl -fsSL 'https://download.opensuse.org/repositories/security:/zeek/Debian_13/Release.key' \
    | gpg --dearmor \
    | sudo tee /etc/apt/keyrings/zeek.gpg >/dev/null

echo 'deb [signed-by=/etc/apt/keyrings/zeek.gpg] https://download.opensuse.org/repositories/security:/zeek/Debian_13/ /' \
    | sudo tee /etc/apt/sources.list.d/security-zeek.list >/dev/null

sudo apt-get update
sudo apt-get install -y zeek
sudo install -m 0644 "$repo_root/infra/host/zeek-path.sh" /etc/profile.d/zeek.sh

if [[ ! -x /opt/zeek/bin/zeek ]]; then
    echo 'Zeek se instaló, pero no se encontró /opt/zeek/bin/zeek.' >&2
    exit 1
fi
echo 'Zeek instalado. Abre una terminal nueva o ejecuta: source /etc/profile.d/zeek.sh'

if [[ ! -f "${burp_installer}" ]]; then
    echo "No se encontró el instalador de Burp: ${burp_installer}"
    echo "Zeek sí quedó instalado. Define BURP_INSTALLER con la ruta correcta y vuelve a ejecutar."
    exit 0
fi

chmod u+x "${burp_installer}"
echo "Abriendo el instalador de Burp Suite..."
"${burp_installer}"

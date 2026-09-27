#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -eq 0 ]]; then
    echo "Ejecuta este script como usuario normal; solicitará sudo solo para APT." >&2
    exit 1
fi

echo 'Instalando herramientas forenses offline desde APT.'
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y exiftool hashdeep sleuthkit plaso volatility3
echo 'Instalación terminada. No se inició ningún servicio ni se accedió a evidencia.'

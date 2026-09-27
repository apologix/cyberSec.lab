# Validación de Zeek

Zeek se ejecuta localmente para visibilidad de la LAN autorizada y análisis de
PCAP. No usa ProtonWG ni Tor.

Si `zeek` no existe todavía, desde la raíz del repositorio ejecute
`bash scripts/install-special-local-tools.sh`. El script usa el repositorio
oficial de Zeek para Debian 13 con HTTPS y un keyring `signed-by`; no copie una
clave al keyring global de APT. Abra una terminal nueva después, o ejecute
`source /etc/profile.d/zeek.sh`, porque el paquete instala Zeek bajo
`/opt/zeek/bin`.

```bash
zeek --version
zeek -N | head
```

No iniciar monitoreo permanente hasta definir interfaz, ubicación de logs y
retención. La primera prueba debe usar un PCAP autorizado o una interfaz de
laboratorio.

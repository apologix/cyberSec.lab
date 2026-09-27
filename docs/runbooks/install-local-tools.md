# Instalación de herramientas locales

## Alcance

Este procedimiento instala las herramientas que operan sobre la propia PC o
la LAN autorizada. No configura perfiles remotos, ProtonWG, Tor ni ProxyChains
para Scapy, Bettercap, Wireshark, TShark, Suricata o Zeek.

## Instalación agrupada desde APT

Desde la raíz del repositorio:

```bash
cd .
bash scripts/install-local-tools.sh
```

El script instala `python3-scapy`, `bettercap`, `wireshark`, `tshark` y
`suricata`. No activa servicios ni inicia capturas automáticamente. La
pertenencia al grupo `wireshark` puede requerir cerrar sesión y volver a entrar.

## Verificación posterior

```bash
scapy
bettercap --version
tshark --version | head -n 1
suricata --build-info | head -n 3
wireshark --version | head -n 1
```

Salir de Scapy con `exit`. El aviso sobre PyX únicamente afecta las
exportaciones gráficas `psdump()` y `pdfdump()`; no limita la creación o
análisis normal de paquetes. La prueba no envía tráfico.

## Procedimientos separados

### Burp Suite y Zeek

Para instalar Zeek desde el repositorio oficial de paquetes y abrir el
instalador local de Burp:

```bash
cd .
bash scripts/install-special-local-tools.sh
```

El instalador espera Burp en
`~/Downloads/burpsuite_linux_v2026_7_3.sh`. Si la ruta cambia:

```bash
BURP_INSTALLER='/ruta/al/instalador/burpsuite.sh' bash scripts/install-special-local-tools.sh
```

Burp requiere elegir Community o Professional y aceptar su licencia en la
interfaz gráfica. Si ya está instalado mediante un lanzador de escritorio, no
es necesario ejecutar de nuevo su instalador. Zeek se instala desde el
repositorio oficial de paquetes para Debian 13; el script usa HTTPS y un
keyring dedicado con `signed-by`, en vez de añadir una clave global de APT.

### Zeek

Zeek ya tiene un procedimiento reproducible en el script anterior. Se instala
en `/opt/zeek/bin` y el script registra esa ruta en `/etc/profile.d/zeek.sh`.
Abra una terminal nueva después de la instalación, o ejecute
`source /etc/profile.d/zeek.sh`. No se habilita ninguna captura ni servicio
automáticamente.

## Política de uso

- Scapy: host/LAN y laboratorio local de MITM autorizado.
- Bettercap: host/LAN, con privilegios mínimos y laboratorio aislado.
- Wireshark/TShark: captura local autorizada u offline.
- Suricata: interfaz local definida explícitamente.
- Zeek: host/LAN cuando se complete su instalación oficial.
- Burp: host, navegador de pruebas y listener solo en `127.0.0.1`.

La instalación no equivale a autorización para interceptar o analizar tráfico.

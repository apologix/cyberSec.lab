# Automatización

Este directorio alojará los instaladores y verificadores para reproducir el laboratorio. Los scripts deberán ser idempotentes, mostrar los cambios que realizan y no contener secretos ni valores públicos observados en una sola PC.
# Scripts del laboratorio

Esta carpeta contiene automatización transversal para reproducir el laboratorio
en otra PC. No contiene herramientas, imágenes Docker, evidencia ni secretos.

## Qué debe ir aquí

- instaladores agrupados de dependencias locales;
- verificadores de versiones y prerrequisitos;
- comprobaciones de routing, ProtonWG, kill switches y servicios;
- scripts de reprovisionamiento que puedan ejecutarse de forma repetible.

Cada script debe tener un runbook asociado en `docs/runbooks/`, indicar si
modifica el sistema y evitar credenciales o destinos codificados.

## Actualmente

[`install-local-tools.sh`](install-local-tools.sh) instala Scapy, Bettercap,
Wireshark/TShark y Suricata desde APT. Burp Suite y Zeek tienen procedimientos
separados porque requieren, respectivamente, elección de edición/licencia y
una fuente oficial externa. [`install-special-local-tools.sh`](install-special-local-tools.sh)
instala Zeek desde su repositorio oficial de paquetes para Debian 13 y abre el
instalador local de Burp si está en `~/Downloads`.

Runbook: [`docs/runbooks/install-local-tools.md`](../docs/runbooks/install-local-tools.md).

`verify-local-tools.sh` y `verify-network-policy.sh` son de solo lectura:
comprueban dependencias, ProtonWG, routing y kill switches ya activos.
`verify-network-policy.sh --include-pending` incorpora OSINT, DNS y TLS una
vez que se hayan instalado. `verify-lab.sh`
ejecuta la revisión general de scripts y Compose. `verify-container-egress.sh`
prueba las redes Docker con ProtonWG
activo y apagado, y restaura el estado original de ProtonWG al terminar.

`verify-tor.sh` comprueba el servicio Tor, el listener SOCKS local y un
circuito Tor confirmado. No cambia ProtonWG ni realiza auditorías.

`new-case.sh` crea un caso externo con permisos restrictivos y `case-run.sh`
asocia una ejecución con ese caso sin incluir argumentos potencialmente
sensibles en el log. El flujo se valida con
[`validate-case-workflow.md`](../docs/runbooks/validate-case-workflow.md).

`render-new-network-policy.sh` transforma una plantilla nftables nueva usando
la LAN e interfaz de `.env`, pero no instala ni habilita nada en el host.

`configure-new-network-profiles.sh` es la única automatización que modifica el
host para OSINT, DNS y TLS: añade policy routing, instala los kill switches y
habilita sus servicios. Requiere `sudo`, `nftables` y revisar el runbook antes
de ejecutarlo.

`install-forensics-tools.sh` instala herramientas offline para hashes,
metadata, filesystem, timelines y memoria; `verify-forensics-tools.sh` solo
comprueba que están disponibles.

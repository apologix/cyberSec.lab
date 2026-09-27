# OSINT runner

Entorno Docker para Holehe, Maigret y Sherlock. Su función es separar las
dependencias de OSINT del host; no confirma identidades ni sustituye la revisión
de fuentes. Las claves opcionales se pasan desde `.env` local o variables de
entorno y nunca se incluyen en la imagen.

- Modo normal: `vpn`; `tor` solo mediante un flujo SOCKS/TCP evaluado para la
  herramienta concreta.
- Privilegios: no requiere capacidades adicionales de Docker.
- Red: `osint-runner_osint_net` es externa y solo se crea con
  `scripts/configure-new-network-profiles.sh` después de instalar su kill switch.
- Salida: `CASE/raw/osint/<herramienta>/`.

Validación: [`docs/runbooks/validate-osint.md`](../../../docs/runbooks/validate-osint.md).

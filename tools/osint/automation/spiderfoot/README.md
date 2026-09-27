# SpiderFoot

Capa de automatización y correlación OSINT. Vive en Docker con UI limitada a
`127.0.0.1:5001`, datos persistentes y bridge compartido `osintbr0`. Sus
módulos y APIs son opcionales; no sustituyen la validación de fuentes
individuales. Exporte resultados útiles al CASE y use alcance/módulos mínimos.

- Modo: `vpn` para fuentes externas; no usa Tor como ruta global.
- Privilegios: no requiere capacidades adicionales de Docker.
- Red: `osint-runner_osint_net` es externa y debe existir tras ejecutar
  `scripts/configure-new-network-profiles.sh`.
- Salida: exporte resultados seleccionados a `CASE/raw/osint/spiderfoot/`.

La imagen usa la versión estable `v4.0`, no la rama `master`. Antes de cambiar
esa referencia, revise la versión y el commit publicado por el proyecto y
registre el digest de la imagen construida en el caso.

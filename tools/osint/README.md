# OSINT

Esta categoría agrupa recolección pública y autorizada. No confirma identidades
por sí sola: toda relación empieza como `unverified` o `possible` y requiere
fuentes independientes para elevarse a `probable` o `confirmed`.

## Límite con reconocimiento activo

OSINT reúne fuentes públicas, metadatos, perfiles, certificados y proveedores
usados para investigación autorizada. DNS activo, validación TLS, escaneo de
puertos y detección de vulnerabilidades pertenecen a `recon/`, `tls/` y
`vulnerabilities/`, respectivamente. Un proveedor o módulo que emita consultas
contra un sistema se debe registrar como una acción activa, respetar el alcance
y usar el modo de red aplicable.

## Entorno y red

Las herramientas automatizadas se ejecutan en `osint-runner/`, con resultados
montados desde el caso. Para objetivos externos usa `vpn`; el contenedor no se
debe levantar operativamente hasta instalar su policy routing y kill switch.
Tor es una excepción por comando, únicamente para flujos SOCKS/TCP que hayan
sido probados. Nunca guarde claves en la imagen ni en resultados sin sanear.

| Capacidad | Integración | Salida prevista |
|---|---|---|
| Correo | Holehe | `raw/osint/holehe/` |
| Username | Maigret, Sherlock | `raw/osint/{maigret,sherlock}/` |
| Brechas | HIBP, Intelligence X | `raw/osint/{hibp,intelx}/` |
| Proveedores | Epieos, Gravatar, GitHub | directorio del proveedor |
| Automatización | SpiderFoot | `raw/osint/spiderfoot/` |

Epieos se documenta como proveedor externo/manual. No se automatizan controles
de acceso, límites ni mecanismos anti-bot.

## Solapamiento deliberado

Maigret aporta mayor cobertura, extracción de metadatos y formatos de informe;
Sherlock ofrece una comprobación independiente de presencia de username. Se
usan ambos para validación cruzada, no para fusionar identidades. SpiderFoot
orquesta fuentes y módulos, pero no sustituye la evidencia original de cada
herramienta o proveedor.

Véanse los runbooks en [`docs/runbooks/`](../../docs/runbooks/).

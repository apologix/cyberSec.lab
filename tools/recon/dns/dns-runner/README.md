# DNS runner

Contenedor mínimo para consultas DNS y análisis de infraestructura autorizada.
Incluye `dig`, `delv`, `host`, `whois` y `dnsrecon`: cada uno cubre una
capacidad distinta, por lo que no se añade otro enumerador redundante.

- Modo: `local` para una zona LAN autorizada; `vpn` para infraestructura remota autorizada.
- Privilegios: no requiere capacidades adicionales de Docker.
- Red: `dns-runner_dns_net` es externa. Créela únicamente mediante
  `scripts/configure-new-network-profiles.sh`, que instala primero policy
  routing y el kill switch.
- Salida: guarde resultados sin modificar en `CASE/raw/dns/`.

Validación: [`docs/runbooks/validate-dns.md`](../../../../docs/runbooks/validate-dns.md).

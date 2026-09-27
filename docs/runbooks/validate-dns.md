# Validar DNS

Para Internet, active ProtonWG e instale el perfil `dnsbr0`; para una zona LAN,
use únicamente el alcance permitido. Tor no es un modo válido para DNS activo.
Si la red externa `dns-runner_dns_net` no existe, siga primero
[`configure-new-network-profiles.md`](configure-new-network-profiles.md).

```bash
cd tools/recon/dns/dns-runner
sudo docker compose --env-file ../../../../.env build
sudo docker compose --env-file ../../../../.env run --rm dns-runner dig +dnssec example.org A
sudo docker compose --env-file ../../../../.env run --rm dns-runner delv example.org A
```

No intente transferencias de zona ni enumeración agresiva sin autorización
expresa. Guarde la salida exacta, el servidor consultado y la fecha en
`CASE/raw/dns/`.

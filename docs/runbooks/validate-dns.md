# Validate DNS

For Internet use, enable ProtonWG and install the `dnsbr0` profile. For a LAN
zone, use only the permitted scope. Tor is not a valid mode for active DNS. If
`dns-runner_dns_net` does not exist, first follow
[configure-new-network-profiles.md](configure-new-network-profiles.md).

```bash
cd tools/recon/dns/dns-runner
sudo docker compose --env-file ../../../../.env build
sudo docker compose --env-file ../../../../.env run --rm dns-runner dig +dnssec example.org A
sudo docker compose --env-file ../../../../.env run --rm dns-runner delv example.org A
```

Do not attempt zone transfers or aggressive enumeration without explicit
authorization. Keep exact output, queried server, and date in `CASE/raw/dns/`.

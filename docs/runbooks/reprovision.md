# Reprovision a workstation

## Host dependencies

Debian, Docker Engine, Compose v2, NetworkManager, WireGuard, `iproute2`,
`nftables`, systemd, `curl`, CA certificates, Tor, and ProxyChains4 when needed.

## Recommended order

1. Clone the repository.
2. Copy `.env.example` to `.env` and set the interface, LAN, ProtonWG, and SOCKS values.
3. Import the private ProtonWG profile from outside the repository.
4. Configure routing table `51820` without changing the host default route.
5. Install nftables templates and systemd services from `infra/host/`.
6. Start OpenVAS and Metasploit, then check their bridges and IPs.
7. Test ProtonWG both up and down before adding a new tool.
8. Build only the images needed for the task.

Run `scripts/install-local-tools.sh` and `scripts/install-special-local-tools.sh`,
then `scripts/verify-lab.sh`. With Docker networks running, also use
`scripts/verify-container-egress.sh` to check for direct Wi-Fi leaks.

# Cybersecurity Lab

A reproducible Debian-based lab for authorized vulnerability assessment,
network analysis, controlled evidence collection, and defensive telemetry.

Use only systems you own or systems for which you have explicit authorization.
The included tooling can change devices, capture traffic, access files, or
attempt authentication.

## Purpose

This repository is a public, sanitized reference implementation for rebuilding
the lab on another machine: the same structure, tool isolation, network modes,
and verification workflows. It is intentionally separate from real cases.

Configuration and documentation are versioned here. Case targets, original
results, PCAPs, captures, credentials, tokens, reports, and other evidence
must stay outside Git and outside container images.

## Repository structure

```text
.
├── README.md
├── .env.example
├── docs/                 # architecture, guides, and runbooks
├── infra/host/           # NetworkManager, nftables, systemd, host networking
├── tools/                # tools organized by function
├── scripts/              # installation and verification automation
├── templates/case/       # reproducible case template; no real cases
├── lab/                  # controlled targets and test cases
└── server/               # defensive telemetry web application
```

See [docs/README.md](docs/README.md) and
[docs/architecture/repository-layout.md](docs/architecture/repository-layout.md)
for the detailed layout and data-handling rules.

## Operating model

```text
                     Cybersecurity Lab
                            |
          +-----------------+-----------------+
          |                                   |
    Infrastructure                         Tools
    Docker · nftables                Recon · DNS · OSINT
    routing · VPN · Tor              TLS · Windows · Web
          |                          Visibility · Forensics
          +-----------------+-----------------+
                            |
                  Authorized environments
```

Infrastructure and tools are reproducible and versioned. Case material is
created outside the repository and is never automatically imported here.

## Network policy

Every tool declares one of the following modes:

| Mode | Intended use | Egress |
|---|---|---|
| `local` | An authorized local-lab target | Normal host route; no Tor or VPN required |
| `vpn` | An authorized external target requiring full IP connectivity | Identified Docker network → routing table `51820` → WireGuard VPN |
| `tor` | SOCKS-compatible workflows, primarily TCP | Application-level proxy only; never a global route |
| `offline` | PCAPs, files, reports, and analysis | No network access |

For authorized external targets, `vpn` is the standard mode. Tor is limited to
workflows that are genuinely SOCKS-compatible; it must not be used for UDP,
SYN/raw scans, ARP, full Kerberos flows, packet capture, or network visibility.

Containerizing a tool does not automatically route it through the VPN. The
`vpn` mode relies on source-based policy routing and a kill switch that blocks
direct Wi-Fi egress when the WireGuard connection is down.

The full policy is documented in
[docs/architecture/network-policy.md](docs/architecture/network-policy.md).

## Tool catalog

“Implemented” means that the repository contains its structure, configuration,
and reproducible documentation. Any test against a target still requires an
available, explicitly authorized system.

| Area | Tool or component | Implementation | Documentation | Validation |
|---|---|---|---|---|
| Web server | CyberLab Server | Docker Compose; local development and hardened VPS deployment | [README](server/README.md) | [Project brief](server/cyberlab_project_brief.md) |
| Vulnerabilities | OpenVAS / Greenbone | Docker, VPN routing, and kill switch | [README](tools/vulnerabilities/openvas/README.md) | [Runbook](docs/runbooks/validate-openvas.md) |
| Controlled validation | Metasploit | Docker, VPN routing, and local-lab mode | [README](tools/validation/metasploit/README.md) | [Runbook](docs/runbooks/validate-metasploit.md) |
| Reconnaissance | Nmap | Host execution with ProxyChains or VPN | [README](tools/recon/nmap/README.md) | [Runbook](docs/runbooks/validate-nmap.md) |
| Reconnaissance | Nuclei | Docker, VPN routing, and kill switch | [README](tools/recon/nuclei/README.md) | [Runbook](docs/runbooks/validate-nuclei.md) |
| DNS reconnaissance | DNS runner | Docker with VPN or authorized LAN support | [README](tools/recon/dns/README.md) | [Runbook](docs/runbooks/validate-dns.md) |
| OSINT | Holehe, Maigret, Sherlock, and providers | Docker and VPN; Epieos is manual | [README](tools/osint/README.md) | [Runbook](docs/runbooks/validate-osint.md) |
| OSINT automation | SpiderFoot | Docker, VPN, and local UI | [README](tools/osint/automation/spiderfoot/README.md) | [Runbook](docs/runbooks/validate-spiderfoot.md) |
| TLS | testssl.sh | Docker with VPN or authorized LAN support | [README](tools/tls/README.md) | [Runbook](docs/runbooks/validate-tls.md) |
| Forensics | Integrity, artifacts, PCAP, timeline, and memory | Host-only, offline workflows | [README](tools/forensics/README.md) | [Runbook](docs/runbooks/validate-forensics.md) |
| Windows / SMB / AD | enum4linux-ng | Docker, VPN routing, and kill switch | [README](tools/windows/enum4linux-ng/README.md) | [Runbook](docs/runbooks/validate-enum4linux.md) |
| Windows / SMB / AD | Impacket | Docker, VPN routing, and kill switch | [README](tools/windows/impacket/README.md) | [Runbook](docs/runbooks/validate-impacket.md) |
| Web | Burp Suite | Local host and test browser | [README](tools/web/burp/README.md) | [Runbook](docs/runbooks/validate-burp.md) |
| Packets | Scapy | Host or LAN; no remote profile | [README](tools/network/scapy/README.md) | [Runbook](docs/runbooks/validate-scapy.md) |
| Privacy | Tor / SOCKS | Local TCP proxy; never a VPN or global route | [README](tools/network/tor/README.md) | [Runbook](docs/runbooks/validate-tor.md) |
| Visibility | Wireshark / TShark | Host, LAN, or offline analysis | [README](tools/visibility/README.md) | [Runbook](docs/runbooks/validate-wireshark.md) |
| Visibility | Suricata | Host-based IDS | [README](tools/visibility/README.md) | [Runbook](docs/runbooks/validate-suricata.md) |
| Visibility | Zeek | Network security monitoring | [README](tools/visibility/README.md) | [Runbook](docs/runbooks/validate-zeek.md) |

## Global setup and verification

```bash
bash scripts/install-local-tools.sh
bash scripts/install-special-local-tools.sh
bash scripts/verify-lab.sh
```

The installation scripts and verifiers are indexed in
[scripts/README.md](scripts/README.md). Burp requires completing its graphical
installer; Zeek uses the documented package repository.

## WireGuard VPN routing

The private WireGuard profile is never stored in Git. Import it from a secure
local location and keep activation manual:

```bash
nmcli connection import type wireguard file /secure/path/protonwg.conf
sudo nmcli connection modify protonwg ipv4.never-default yes
sudo nmcli connection modify protonwg ipv6.never-default yes
sudo nmcli connection modify protonwg wireguard.peer-routes no
sudo nmcli connection modify protonwg ipv4.route-table 51820
sudo nmcli connection modify protonwg connection.autoconnect no
nmcli connection up protonwg
```

The host keeps its normal route. Only protected Docker networks use table
`51820`. Host rules and services live in [infra/host](infra/host/).

Useful checks:

```bash
ip rule
ip route show table 51820
wg show protonwg
curl -s https://api.ipify.org; echo
```

## OpenVAS / Greenbone

OpenVAS runs on the dedicated `openvasbr0` network. Its Compose definitions and
VPN configuration are in [tools/vulnerabilities/openvas](tools/vulnerabilities/openvas/).

```bash
cd tools/vulnerabilities/openvas
sudo docker compose -f docker-compose.yml -f docker-compose.override.yml config
sudo docker compose -f docker-compose.yml -f docker-compose.override.yml up -d
sudo docker compose -f docker-compose.yml -f docker-compose.override.yml ps
```

Keep the kill switch enabled and validate behavior with the VPN active, down,
and against an authorized local-lab target.

## Metasploit

Metasploit runs only in Docker and uses the dedicated `metasploitbr0` network
and routing table `51820` for VPN egress.

```bash
cd tools/validation/metasploit
sudo docker compose config
sudo docker compose up -d
sudo docker exec -it metasploit /usr/src/metasploit-framework/msfconsole
```

For a local-lab audit, follow
[tools/validation/metasploit/LAN_MODE.md](tools/validation/metasploit/LAN_MODE.md).
Do not remove the general direct-egress block.

## Tor and ProxyChains4

Tor is an application proxy, not a VPN. Verify it before using it:

```bash
systemctl is-active tor
ss -lntp | grep -E '127\\.0\\.0\\.1:(9050|9150)'
```

Nmap can be reproduced with ProxyChains4, but the standard external workflow
for this lab is the WireGuard VPN. Tor is reserved for TCP-compatible flows.

## Rebuilding on another machine

1. Install Debian, Docker Compose v2, NetworkManager, WireGuard, `iproute2`,
   `nftables`, systemd, Tor, and ProxyChains4.
2. Clone this repository.
3. Copy `.env.example` to `.env`, then adapt the interface, lab LAN, VPN, and
   SOCKS settings.
4. Import the WireGuard profile from a secure local location.
5. Install the host rules in `infra/host/`.
6. Verify routing with [docs/runbooks/verify-routing.md](docs/runbooks/verify-routing.md).
7. Start only the Docker projects needed for the authorized task.

The broader procedure is in [docs/runbooks/reprovision.md](docs/runbooks/reprovision.md).

## Cases and traceability

New cases are not stored in Git. Configure `CYBERSEC_CASES_DIR` in `.env`, or
use the sibling `../cases` directory, then create a case with:

```bash
./scripts/new-case.sh CASE-2026-001
```

The template separates scope, original results, selected evidence, findings,
reporting, operational logs, and `metadata/entities.json`. The data model and
confidence rules are described in
[docs/architecture/cases-and-evidence.md](docs/architecture/cases-and-evidence.md).

Use `scripts/case-run.sh` to associate a tool run with a case without logging
arguments that could contain secrets. If recording a target is approved, set
`CYBERSEC_CASE_TARGET`; the JSONL log records timestamp, case, tool, target,
mode, action, status, and output path.

## Publication policy

Do not add `.env` files, VPN profiles, credentials, captures, databases,
tokens, scan results, real target names, or personal data. See
[CONTRIBUTING.md](CONTRIBUTING.md) and [SECURITY.md](SECURITY.md) before
submitting a change.

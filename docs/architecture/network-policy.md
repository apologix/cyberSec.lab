# Lab network policy

## Modes

### `local`

Use this mode for an authorized LAN target. The host keeps its normal route and
containers may reach only the permitted LAN range. Tor and ProtonWG are not
used.

### `vpn`

This is the standard mode for external targets. The container joins a Docker
network identifiable by source IP; the host routes that source through table
`51820`, whose egress is `protonwg`. A kill switch blocks direct Wi-Fi egress
when ProtonWG is down. Docker alone does not enable this mode.

### `tor`

An application proxy for SOCKS-compatible tools, primarily TCP. It is invoked
per command and never becomes the host's global route. Do not use it for UDP,
SYN/raw scans, full Kerberos, ARP, capture, or network visibility.

### `offline`

Use this mode for PCAPs, files, reports, and local analysis. It requires no
network egress.

### Local Scapy

Scapy is reserved for the host and an authorized lab/LAN. It has no remote
profile and does not use ProtonWG, Tor, or ProxyChains. MITM exercises require
an isolated segment and a restoration procedure.

## Decision rule

```text
Is the target on the authorized LAN?
  yes -> local
  no  -> Does the tool require full IP, UDP, raw sockets, or protocol support?
           yes -> vpn (ProtonWG)
           no  -> vpn by default; tor only when the workflow requires it
```

## Protected networks

| Project | Bridge | Source | Route |
|---|---|---|---|
| OpenVAS | `openvasbr0` | `172.18.0.2`, `172.18.0.7` | table `51820` |
| Metasploit | `metasploitbr0` | `172.20.0.2` | table `51820` |
| Nuclei | `nucleibr0` | `172.30.0.2` | table `51820` |
| enum4linux-ng | `enum4linuxbr0` | `172.31.0.2` | table `51820` |
| Impacket | `impacketbr0` | `172.32.0.2` | table `51820` |

Keep existing networks and rules separate until a tested common automation is
available.

## Profiles awaiting activation

The repository includes uninstalled definitions for OSINT (`osintbr0`,
`172.33.0.2-.3`), DNS (`dnsbr0`, `172.34.0.2`), and TLS (`tlsbr0`,
`172.35.0.2`). Before use, create the source rules for table `51820` and render
and install kill switches from `infra/host/*.example`. They are not active
protections until that procedure is complete.

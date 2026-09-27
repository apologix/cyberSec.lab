# Install local tools

## Scope

This installs tools that operate on the PC or authorized LAN. It does not
configure remote profiles, ProtonWG, Tor, or ProxyChains for Scapy, Bettercap,
Wireshark, TShark, Suricata, or Zeek.

```bash
cd .
bash scripts/install-local-tools.sh
```

The script installs `python3-scapy`, `bettercap`, `wireshark`, `tshark`, and
`suricata`. It starts no service or capture; the `wireshark` group may require
logging out and back in.

```bash
scapy
bettercap --version
tshark --version | head -n 1
suricata --build-info | head -n 3
wireshark --version | head -n 1
```

Exit Scapy with `exit`. The PyX warning affects only `psdump()` and `pdfdump()`;
this verification sends no traffic.

## Burp Suite and Zeek

```bash
cd .
bash scripts/install-special-local-tools.sh
```

The installer expects `~/Downloads/burpsuite_linux_v2026_7_3.sh`; override it
with `BURP_INSTALLER='/path/to/burpsuite.sh'`. Choose Burp Community or
Professional and accept its license in the graphical interface. Zeek installs
from its official Debian 13 repository using HTTPS and a dedicated `signed-by`
keyring. It is installed under `/opt/zeek/bin`; open a new terminal or run
`source /etc/profile.d/zeek.sh`. No capture or service is enabled automatically.

## Use policy

- Scapy: host/LAN and authorized local MITM lab.
- Bettercap: host/LAN with minimum privileges and an isolated lab.
- Wireshark/TShark: authorized local capture or offline work.
- Suricata: explicitly selected local interface.
- Zeek: host/LAN after official installation.
- Burp: host, test browser, listener limited to `127.0.0.1`.

Installation is not authorization to intercept or analyze traffic.

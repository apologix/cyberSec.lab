# Local Scapy Validation
## Objetivo

Validate the installation and construction of packages without sending traffic or
use remote targets. Scapy is reserved for authorized LAN and labs
mITM premises.
## Non-network installation and testing
```bash
python3 -m venv ~/.venvs/cybersec-scapy
~/.venvs/cybersec-scapy/bin/python -m pip install --upgrade pip scapy
~/.venvs/cybersec-scapy/bin/python -c 'from scapy.all import IP, ICMP; print(IP(dst="127.0.0.1")/ICMP())'
```

The last line must print an IP/ICMP packet and does not send.
## Interfaz

```bash
ip -br address
ip route
```

Confirm that the interface belongs to the authorized laboratory and that it is not being
using `protonwg` for a LAN practice.
## MITM

An MITM exercise is not considered validated just because Scapy matters. It is
needs an isolated laboratory, written authorization, own devices and
a restoration procedure. MITM validation will be documented as
separate experiment when that lab exists.
## Resultado esperado

| Test | Result |
|---|---|
| Import | Scapy creates a package in memory |
| Interface | Authorized LAN identified |
| Remote | Not supported by this profile |
| ProtonWG/Tor | Unused |
| MITM | Isolated Lab Slope |
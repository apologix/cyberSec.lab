# Validate Wireshark

Wireshark runs locally for authorized capture and offline analysis. It does not
use ProtonWG or Tor.

```bash
wireshark --version | head -n 1
tshark --version | head -n 1
ip -br address
```

Open a test capture or capture only the authorized interface and segment. Do
not start a broad capture by default.

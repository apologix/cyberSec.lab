# Validate Suricata

Suricata runs locally as IDS/NSM on an explicit interface. It does not use
ProtonWG or Tor.

```bash
suricata --build-info | head -n 3
sudo suricata --list-runmodes
systemctl is-enabled suricata 2>/dev/null || true
```

Do not enable permanent capture until selecting the interface, rules, log
destination, and retention policy for the authorized LAN.

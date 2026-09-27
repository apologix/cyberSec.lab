# Validate Zeek

Zeek runs locally for authorized LAN visibility and PCAP analysis. It does not
use ProtonWG or Tor. If missing, run
`bash scripts/install-special-local-tools.sh` from repository root. The script
uses Zeek's official Debian 13 repository over HTTPS and a `signed-by` keyring;
do not copy a key into APT's global keyring. Open a new terminal or run
`source /etc/profile.d/zeek.sh` because the package installs under `/opt/zeek/bin`.

```bash
zeek --version
zeek -N | head
```

Do not start permanent monitoring until defining interface, log location, and
retention. The first test must use an authorized PCAP or lab interface.

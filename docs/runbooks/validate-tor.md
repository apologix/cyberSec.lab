# Validate Tor

## Goal

Confirm that Tor is active, a local SOCKS listener exists, and a TCP request
through the proxy is recognized as Tor. This does not test audit targets or
modify ProtonWG.

```bash
cd .
bash scripts/verify-tor.sh
```

The script checks `127.0.0.1:9050` and `127.0.0.1:9150`, then queries Tor's
verification endpoint using `--socks5-hostname` to prevent DNS resolution
outside the proxy.

```text
OK   tor service     active
OK   SOCKS listener  127.0.0.1:9050
OK   Tor circuit     check.torproject.org confirms Tor
Tor validation: OK
```

When both ports are active, `9050` is preferred. Do not use Tor profiles until
service and listener failures are corrected. Tor does not cover UDP, raw
sockets, ARP, capture, or full IP protocols; use local networking or ProtonWG.

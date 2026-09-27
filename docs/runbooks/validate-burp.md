# Validate Burp Suite

## Goal

Validate local installation, listener, browser integration, and an owned test
application without generating traffic against external targets.

With Burp listening on `127.0.0.1:8080`:

```bash
ss -lntp | grep ':8080'
curl -I -x http://127.0.0.1:8080 http://burpsuite
```

Expect a local listener only: never `0.0.0.0:8080` or a LAN address.

```bash
rm -rf /tmp/burp-web-test
mkdir -p /tmp/burp-web-test
printf '%s\n' 'Burp local test' > /tmp/burp-web-test/index.html
python3 -m http.server 8080 --bind 127.0.0.1 --directory /tmp/burp-web-test
```

Open the test through Burp's browser or a profile configured with
`127.0.0.1:8080`, confirm the request in `Proxy > HTTP history`, then stop the
server. Future LAN validation must use an authorized URL in `Target > Scope`.
Do not perform external validation until the browser/Burp ProtonWG route is
explicitly designed and verified; enabling ProtonWG alone is insufficient.

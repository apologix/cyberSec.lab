# DNS Recon

`dns-runner/` aporta `dig`, `delv`, `host`, `whois` y `dnsrecon` para consultas
autorizadas. Consultas activas, DNSSEC y transferencias de zona no son flujos
Tor: pueden usar UDP y deben ejecutarse en `local` para la LAN o `vpn` para
infraestructura externa autorizada. La investigación pasiva mediante APIs se
trata como OSINT y usa `osint-runner`.

Los resultados originales se guardan en `CASE/raw/dns/`; la interpretación y
evidencia seleccionada, en `CASE/evidence/` y `CASE/findings/`.

# Tor y SOCKS

Tor se usa como proxy de aplicación para flujos TCP compatibles con SOCKS. No
es una VPN ni una ruta global del host. En este laboratorio se reserva para
PRET, cámaras y otros casos documentados; no se usa para Nmap raw, Scapy,
SMB/RPC/LDAP, Kerberos, captura, Suricata o Zeek.

La validación se ejecuta con
[`scripts/verify-tor.sh`](../../../scripts/verify-tor.sh) y está documentada
en [`docs/runbooks/validate-tor.md`](../../../docs/runbooks/validate-tor.md).

El listener debe estar limitado a `127.0.0.1:9050` o `127.0.0.1:9150`; no se
debe exponer el proxy a la LAN.

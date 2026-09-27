# Validación de Tor

## Objetivo

Comprobar que Tor está activo, que existe un listener SOCKS local y que una
consulta TCP realizada a través del proxy es reconocida como Tor. No prueba
objetivos de auditoría ni modifica ProtonWG.

## Verificación

```bash
cd .
bash scripts/verify-tor.sh
```

El script busca `127.0.0.1:9050` y `127.0.0.1:9150`, y consulta el endpoint
de comprobación de Tor mediante `--socks5-hostname` para evitar resolver DNS
fuera del proxy.

## Resultado esperado

```text
OK   tor service     active
OK   SOCKS listener  127.0.0.1:9050
OK   Tor circuit     check.torproject.org confirms Tor
Validación Tor: OK
```

Si ambos puertos están activos, se usa primero `9050`. Si el servicio o el
listener fallan, no usar perfiles Tor de PRET o cámaras hasta corregirlo.

Tor no cubre UDP, raw sockets, ARP, captura ni protocolos IP completos. Para
esos casos se utiliza la red local o ProtonWG según la política de la
herramienta.

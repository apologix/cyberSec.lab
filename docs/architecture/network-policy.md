# Política de red del laboratorio

## Modos

### `local`

Se usa para objetivos de la LAN autorizada. El host conserva su ruta normal y los contenedores deben alcanzar únicamente el rango LAN permitido. No se usa Tor ni se necesita ProtonWG.

### `vpn`

Es el modo estándar para objetivos externos. El contenedor se conecta a una red Docker identificable por su IP de origen. El host dirige ese origen a la tabla de rutas `51820`, cuya salida es `protonwg`. Un kill switch bloquea la salida directa por Wi-Fi si ProtonWG está apagado.

Dockerizar por sí solo no activa este modo.

### `tor`

Es un proxy de aplicación para herramientas compatibles con SOCKS, principalmente TCP. Se invoca por comando y no se convierte en la ruta global del host. No debe usarse para UDP, SYN/raw scans, Kerberos completo, ARP, captura ni visibilidad de red.

### `offline`

Se usa para PCAP, archivos, reportes y análisis local. No requiere ninguna salida de red.

### Scapy local

Scapy se reserva para el host y la LAN/laboratorio autorizado. No se dockeriza
como herramienta operativa, no tiene perfil remoto y no usa ProtonWG, Tor ni
ProxyChains. Sus prácticas de MITM requieren un segmento aislado y un
procedimiento de restauración.

## Regla de decisión

```text
¿El objetivo está en la LAN autorizada?
  sí  -> local
  no  -> ¿la herramienta necesita IP/UDP/raw/protocolo completo?
           sí  -> vpn (ProtonWG)
           no  -> vpn por defecto; tor solo si el flujo lo requiere
```

## Redes actuales protegidas

| Proyecto | Bridge | Origen | Ruta |
|---|---|---|---|
| OpenVAS | `openvasbr0` | `172.18.0.2`, `172.18.0.7` | tabla `51820` |
| Metasploit | `metasploitbr0` | `172.20.0.2` | tabla `51820` |
| Nuclei | `nucleibr0` | `172.30.0.2` | tabla `51820` |
| enum4linux-ng | `enum4linuxbr0` | `172.31.0.2` | tabla `51820` |
| Impacket | `impacketbr0` | `172.32.0.2` | tabla `51820` |

Las redes y reglas existentes deben mantenerse separadas hasta que exista una automatización común probada.

## Perfiles pendientes de activación

El repositorio incluye definiciones sin instalar para OSINT (`osintbr0`,
`172.33.0.2-.3`), DNS (`dnsbr0`, `172.34.0.2`) y TLS (`tlsbr0`, `172.35.0.2`).
Antes de usarlos hay que crear las reglas de origen hacia la tabla `51820` y
renderizar/instalar los kill switches desde `infra/host/*.example`. No son
protecciones activas hasta completar ese procedimiento.

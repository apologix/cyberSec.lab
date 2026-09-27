# Configuración de privacidad/red del laboratorio

## Propósito

Registro de las configuraciones de red y privacidad observadas en este
laboratorio Debian. Sirve como handoff del host original; sus interfaces,
subredes e IPs son ejemplos de ese host, no valores portables. Para una nueva
instalación use `.env`, [`docs/architecture/network-policy.md`](../../docs/architecture/network-policy.md)
y los runbooks vigentes.

## 1. Proton VPN mediante WireGuard

Conexión de NetworkManager:

``` text
protonwg
```

Características configuradas:

-   WireGuard transporta tráfico IP mediante el túnel de Proton.
-   No es la ruta por defecto del host.
-   No se conecta automáticamente al arrancar.
-   Se activa/desactiva manualmente desde KDE/NetworkManager o `nmcli`.
-   La tabla de policy routing usada para OpenVAS es `51820`.

Estado manual:

``` bash
nmcli connection up protonwg
nmcli connection down protonwg
```

Comprobar:

``` bash
wg show protonwg
nmcli -f connection.id,connection.autoconnect connection show protonwg
```

Esperado para autoconnect:

``` text
connection.autoconnect: no
```

La configuración importada de WireGuard provino de:

``` text
protonwg.conf
```

No guardar ni compartir públicamente el contenido de ese archivo:
contiene una clave privada WireGuard.

## 2. Split tunneling de OpenVAS

Solo estas IP Docker están enviadas a la tabla `51820`:

``` text
172.18.0.2  ospd-openvas
172.18.0.7  openvasd
```

Reglas:

``` text
priority 100 from 172.18.0.2 -> table 51820
priority 101 from 172.18.0.7 -> table 51820
```

Comprobar:

``` bash
ip rule
ip route show table 51820
```

La ruta normal del host debe seguir por `wlp6s0`:

``` bash
ip route get 1.1.1.1
```

## 3. Kill switch de OpenVAS

Bridge:

``` text
openvasbr0
```

Archivo persistente:

``` text
/etc/nftables-openvas.conf
```

Servicio:

``` text
/etc/systemd/system/openvas-killswitch.service
```

Reglas activas:

``` nft
table inet openvas_killswitch {
    chain forward {
        type filter hook forward priority -10; policy accept;

        iifname "openvasbr0" ip saddr { 172.18.0.2, 172.18.0.7 } ip daddr 192.168.100.0/24 oifname "wlp6s0" accept
        iifname "openvasbr0" ip saddr { 172.18.0.2, 172.18.0.7 } oifname "wlp6s0" drop
    }
}
```

Comprobación:

``` bash
sudo nft list table inet openvas_killswitch
systemctl status openvas-killswitch.service --no-pager
```

Comportamiento esperado:

``` text
protonwg OFF -> OpenVAS solo puede alcanzar la LAN autorizada
protonwg ON  -> OpenVAS sale por Proton
host         -> continúa por wlp6s0
```

## 4. Tor y torsocks

### Importante: Tor no equivale a WireGuard

`t​​orsocks`/Tor sirve para aplicaciones compatibles con conexiones TCP a
través del proxy SOCKS de Tor. No es un túnel IP general y no sustituye
a WireGuard para herramientas/protocolos que requieren tráfico
arbitrario, UDP, raw sockets o determinadas técnicas de escaneo.

Por eso OpenVAS se dejó en el esquema WireGuard/Proton y no se intentó
forzar todo su tráfico mediante ProxyChains/Tor.

## 5. ProxyChains / SOCKS

Use una configuración local de ProxyChains/SOCKS revisada para su laboratorio.
No versionar perfiles, rutas o parámetros que identifiquen la infraestructura
personal.

Antes de documentarlo como configuración definitiva, obtener los valores
reales del equipo con:

``` bash
grep -Ev '^[[:space:]]*(#|$)' /etc/proxychains4.conf 2>/dev/null
grep -Ev '^[[:space:]]*(#|$)' /etc/proxychains.conf 2>/dev/null
```

Y revisar Tor:

``` bash
ss -lntp | grep -E '9050|9150'
```

No asumir automáticamente `127.0.0.1:9050` o `127.0.0.1:9150`:
documentar el valor que realmente esté activo.

## 6. Qué mecanismo usar

``` text
Tráfico normal del PC
    -> wlp6s0

OpenVAS seleccionado
    -> policy routing
    -> protonwg
    -> Proton VPN

PRET configurado con torsocks
    -> Tor/SOCKS (cuando Tor está disponible)

Aplicaciones ejecutadas explícitamente con ProxyChains
    -> proxychains
    -> proxy SOCKS configurado
```

## 7. Metasploit y auditoría de la LAN

La LAN actual es `192.168.100.0/24` sobre `wlp6s0`; el host usa
`192.168.100.10`. Metasploit conserva su salida VPN por defecto. Para una
auditoría autorizada de la LAN, aplicar el procedimiento de
`tools/validation/metasploit/LAN_MODE.md`, que añade únicamente la ruta local y una
excepción nftables para esa subnet. El bloqueo general de salida por
`wlp6s0` debe permanecer activo.

Nmap local se ejecuta preferentemente desde el host:

```bash
sudo nmap -n -sn 192.168.100.0/24
sudo nmap -n -Pn -sV --top-ports 100 192.168.100.20
```

## 8. enum4linux-ng y SMB/LDAP

`enum4linux-ng` usa la red Docker `enum4linux-ng_enum4linux_net`, con
bridge `enum4linuxbr0` y origen fijo `172.31.0.2`. Su tráfico se dirige a
la tabla `51820` mediante la regla `priority 130 from 172.31.0.2`.

El kill switch persistente está definido en:

``` text
/etc/nftables-enum4linux.conf
/etc/systemd/system/enum4linux-killswitch.service
```

Cuando ProtonWG está activo, los objetivos externos salen por Proton.
Cuando está apagado, la regla permite únicamente `192.168.100.0/24` por
`wlp6s0` y bloquea el resto. SMB, RPC, LDAP, NetBIOS y Kerberos no se
deben forzar mediante Tor/ProxyChains porque requieren tráfico IP y, en
algunos casos, UDP o resolución de dominio.

La infraestructura fue validada sin una IP Windows/Samba disponible: la
salida externa se bloqueó al apagar ProtonWG, el gateway LAN respondió y
`192.168.100.1` confirmó que no expone SMB/LDAP. La enumeración real queda
pendiente de un objetivo autorizado.

## 9. Impacket y Active Directory

Impacket usa la red `impacket_impacket_net`, bridge `impacketbr0` y origen fijo
`172.32.0.2`. Su tráfico se dirige a la tabla `51820` mediante la regla
`priority 140 from 172.32.0.2`. El kill switch correspondiente está definido
en `/etc/nftables-impacket.conf` y en el servicio
`impacket-killswitch.service`.

La política es igual a la de enum4linux-ng: objetivos externos por ProtonWG,
objetivos LAN solo en `192.168.100.0/24` y ningún uso general de Tor. La
validación de la imagen no necesita objetivo; las pruebas de SMB/RPC/LDAP o
Kerberos esperan una IP Windows/Samba autorizada. En este equipo la regla 140,
el bridge, la salida por ProtonWG, la excepción LAN y el bloqueo con ProtonWG
apagado fueron validados correctamente el 27 de agosto de 2026.

## 10. Comandos rápidos de verificación

IP pública del host:

``` bash
curl https://api.ipify.org
echo
```

WireGuard:

``` bash
wg show protonwg
```

Routing:

``` bash
ip rule
ip route show table 51820
ip route get 1.1.1.1
```

Kill switch:

``` bash
sudo nft list table inet openvas_killswitch
```

enum4linux-ng:

```bash
sudo nft list table inet enum4linux_killswitch
systemctl is-enabled --quiet enum4linux-killswitch.service && echo enabled
systemctl is-active --quiet enum4linux-killswitch.service && echo active
sudo docker network inspect enum4linux-ng_enum4linux_net
```

Docker/OpenVAS:

``` bash
sudo docker ps
sudo docker inspect \
  greenbone-community-edition-ospd-openvas-1 \
  greenbone-community-edition-openvasd-1 \
  --format '{{.Name}} -> {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'
```

## 11. Nota sobre privacidad

VPN, Tor y ProxyChains resuelven problemas distintos. Cambiar la IP de
salida no elimina por sí solo otras formas de identificación de una
aplicación o navegador. Para navegación con Tor, la opción diseñada
específicamente para reducir correlación y fingerprinting entre usuarios
es Tor Browser; no conviene tratar un navegador normal + VPN como
equivalente.

## 12. Burp Suite local

Burp Suite se ejecuta en el host y escucha únicamente en `127.0.0.1:8080`.
El navegador de pruebas se configura para usar ese listener. Para la LAN, el
tráfico sigue la ruta normal hacia `192.168.100.0/24`; no se usa Tor ni se
necesita ProtonWG.

Para objetivos externos todavía debe validarse un perfil que dirija de forma
efectiva el navegador/Burp a ProtonWG. La conexión `protonwg` del laboratorio
usa una tabla no predeterminada, por lo que activarla no basta para afirmar que
el tráfico del host cambió de ruta. Burp no se dockeriza en esta fase.

## 13. Scapy local

Scapy se ejecuta en el host para prácticas autorizadas de paquetes, captura y
MITM dentro de la LAN o de un laboratorio aislado. No se configura como red
Docker, no se dirige a la tabla `51820` y no se usa con Tor/ProxyChains. Se
debe verificar la interfaz antes de cada práctica y conservar el mínimo
privilegio necesario.

------------------------------------------------------------------------

## Pendiente de completar

Para que este archivo sea una copia exacta de toda la configuración del
equipo todavía faltaría incorporar:

-   contenido efectivo de ProxyChains;
-   dirección/puerto SOCKS de Tor;
-   cómo se inicia el servicio/proceso Tor;
-   cualquier alias adicional relacionado con ProxyChains/Tor.

Esos valores no se inventaron en este handoff.

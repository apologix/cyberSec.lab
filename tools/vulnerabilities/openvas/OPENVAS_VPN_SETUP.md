# OpenVAS + Proton VPN (WireGuard) --- configuración y réplica

## Objetivo

Esta configuración deja a Greenbone/OpenVAS en Docker con **split
tunneling**:

-   El host Debian usa normalmente `wlp6s0` y conserva su conexión
    normal.
-   Solo los componentes de escaneo seleccionados de OpenVAS salen por
    `protonwg`.
-   Si Proton/WireGuard está apagado, esos contenedores quedan **sin
    salida a Internet** en vez de caer a la IP pública normal.
-   `protonwg` no se conecta automáticamente al iniciar Debian.

## Entorno comprobado

-   Debian GNU/Linux 13 (trixie)
-   NetworkManager / `nmcli` 1.52.1
-   `wireguard-tools` v1.0.20210914
-   Greenbone Community Edition mediante Docker Compose
-   Directorio del proyecto: `<REPO_ROOT>/tools/vulnerabilities/openvas`
-   Wi-Fi del host: `wlp6s0`
-   WireGuard Proton: `protonwg`
-   Red Docker Greenbone: `172.18.0.0/16`
-   Gateway Docker: `172.18.0.1`
-   Bridge estable configurado: `openvasbr0`
-   `ospd-openvas`: `172.18.0.2`
-   `openvasd`: `172.18.0.7`
-   Tabla de policy routing: `51820`
-   LAN autorizada: `192.168.100.0/24` mediante `wlp6s0`

## Resultado final

``` text
Proton OFF
Host    -> wlp6s0 -> Internet normal
OpenVAS -> BLOQUEADO

Proton ON
Host    -> wlp6s0 -> Internet normal
OpenVAS -> protonwg -> Proton VPN -> Internet
```

Para auditorías autorizadas de equipos dentro de la LAN, los dos
contenedores seleccionados también pueden alcanzar `192.168.100.0/24`.
El resto de la salida directa por `wlp6s0` continúa bloqueada. La ruta LAN
debe existir en la tabla `51820`.

En una prueba de laboratorio, compruebe que la salida del contenedor cambia al
activar la VPN y que, al apagarla, una petición externa termina en timeout.
No guarde la IP de salida ni resultados de pruebas en el repositorio.

------------------------------------------------------------------------

## 1. Importar la configuración WireGuard de Proton

El archivo descargado originalmente tenía un nombre que NetworkManager
rechazó como nombre de interfaz:

``` text
Deb-PC-US-FREE-21.conf
```

Se renombró:

``` bash
mv ~/Downloads/Deb-PC-US-FREE-21.conf ~/Downloads/protonwg.conf
```

Se importó:

``` bash
nmcli connection import type wireguard file ~/Downloads/protonwg.conf
```

Comprobación:

``` bash
nmcli connection show
wg show protonwg
ip addr show protonwg
```

No copies una configuración WireGuard ajena: el `.conf` contiene
material privado de autenticación.

## 2. Evitar que Proton capture todo el tráfico del host

``` bash
sudo nmcli connection modify protonwg ipv4.never-default yes
sudo nmcli connection modify protonwg ipv6.never-default yes
sudo nmcli connection modify protonwg wireguard.peer-routes no
```

Se usa la tabla `51820`:

``` bash
sudo nmcli connection modify protonwg ipv4.route-table 51820
sudo nmcli connection modify protonwg +ipv4.routes \
  "0.0.0.0/0 type=unicast table=51820"
```

Reglas persistentes para los dos contenedores:

``` bash
sudo nmcli connection modify protonwg +ipv4.routing-rules \
  "priority 100 from 172.18.0.2/32 table 51820"

sudo nmcli connection modify protonwg +ipv4.routing-rules \
  "priority 101 from 172.18.0.7/32 table 51820"
```

Proton queda manual:

``` bash
sudo nmcli connection modify protonwg connection.autoconnect no
```

Aplicar cambios:

``` bash
nmcli connection down protonwg
nmcli connection up protonwg
```

Comprobar:

``` bash
ip rule
ip route show table 51820
ip route get 1.1.1.1
```

El `ip route get` normal del host debe seguir mostrando `wlp6s0`, no
`protonwg`.

## 3. Fijar las IP de los contenedores y el bridge Docker

Se creó:

``` text
<REPO_ROOT>/tools/vulnerabilities/openvas/docker-compose.override.yml
```

La intención comprobada del override es mantener:

``` yaml
services:
  ospd-openvas:
    networks:
      default:
        ipv4_address: 172.18.0.2

  openvasd:
    networks:
      default:
        ipv4_address: 172.18.0.7

networks:
  default:
    driver_opts:
      com.docker.network.bridge.name: openvasbr0
    ipam:
      config:
        - subnet: 172.18.0.0/16
          gateway: 172.18.0.1
          ip_range: 172.18.128.0/17
```

> Nota: este bloque documenta el estado/intención final del override
> trabajado. Antes de reemplazar un override existente, compáralo con el
> archivo actual.

Validar la combinación:

``` bash
cd "$(git rev-parse --show-toplevel)/tools/vulnerabilities/openvas"

sudo docker compose \
  -f docker-compose.yml \
  -f docker-compose.override.yml \
  config >/tmp/greenbone-merged.yml

echo $?
```

Debe devolver `0`.

Comprobaciones útiles:

``` bash
grep -n -A12 -B3 'ipv4_address' /tmp/greenbone-merged.yml
grep -n -A10 '^networks:' /tmp/greenbone-merged.yml

sudo docker inspect \
  greenbone-community-edition-ospd-openvas-1 \
  greenbone-community-edition-openvasd-1 \
  --format '{{.Name}} -> {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'
```

Esperado:

``` text
ospd-openvas -> 172.18.0.2
openvasd     -> 172.18.0.7
```

## 4. Kill switch con nftables

Archivo:

``` text
/etc/nftables-openvas.conf
```

Contenido (la plantilla versionada está en `../../../infra/host/nftables-openvas.conf`):

``` nft
table inet openvas_killswitch {
    chain forward {
        type filter hook forward priority -10; policy accept;

        iifname "openvasbr0" ip saddr { 172.18.0.2, 172.18.0.7 } ip daddr 192.168.100.0/24 oifname "wlp6s0" accept
        iifname "openvasbr0" ip saddr { 172.18.0.2, 172.18.0.7 } oifname "wlp6s0" drop
    }
}
```

Validarlo sin aplicarlo:

``` bash
sudo nft -c -f /etc/nftables-openvas.conf
```

El objetivo es impedir que esos contenedores usen directamente `wlp6s0`
si desaparece `protonwg`.

## 5. Persistencia del kill switch mediante systemd

Archivo:

``` text
/etc/systemd/system/openvas-killswitch.service
```

Contenido:

``` ini
[Unit]
Description=OpenVAS VPN Kill Switch
After=network.target docker.service
Wants=network.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/sbin/nft -f /etc/nftables-openvas.conf
ExecStop=/usr/sbin/nft delete table inet openvas_killswitch

[Install]
WantedBy=multi-user.target
```

Activación:

``` bash
sudo systemctl daemon-reload
sudo systemctl enable --now openvas-killswitch.service
```

Comprobar:

``` bash
systemctl status openvas-killswitch.service --no-pager
sudo nft list table inet openvas_killswitch
```

Después de reiniciar Debian se comprobó que la tabla seguía cargada.

## 6. Activar/desactivar Proton manualmente

Desde KDE/NetworkManager se puede activar o desactivar `protonwg`.

Equivalente en terminal:

``` bash
nmcli connection up protonwg
```

y:

``` bash
nmcli connection down protonwg
```

Comprobar que no arranque solo:

``` bash
nmcli -f connection.id,connection.autoconnect connection show protonwg
```

Esperado:

``` text
connection.id: protonwg
connection.autoconnect: no
```

## 7. Pruebas

### Host

``` bash
curl https://api.ipify.org
echo
```

Debe continuar usando la conexión normal del host incluso cuando
`protonwg` está activo.

### OpenVAS con Proton activo

``` bash
sudo docker exec greenbone-community-edition-ospd-openvas-1 \
  python3 -c 'import urllib.request; print(urllib.request.urlopen("https://api.ipify.org", timeout=10).read().decode())'
```

Debe mostrar la IP de salida de Proton.

### Kill switch

Apagar Proton:

``` bash
nmcli connection down protonwg
```

El host debe seguir funcionando:

``` bash
curl https://api.ipify.org
echo
```

Pero:

``` bash
sudo docker exec greenbone-community-edition-ospd-openvas-1 \
  python3 -c 'import urllib.request; print(urllib.request.urlopen("https://api.ipify.org", timeout=5).read().decode())'
```

debe terminar en timeout.

Volver a activar:

``` bash
nmcli connection up protonwg
```

### OpenVAS hacia la LAN

Con el contenedor activo, prueba únicamente equipos propios o
autorizados. Sustituye la dirección por una IP detectada en tu LAN:

``` bash
sudo docker exec greenbone-community-edition-ospd-openvas-1 \
  ping -c 2 192.168.100.1
sudo docker exec greenbone-community-edition-ospd-openvas-1 \
  ping -c 2 192.168.100.113
```

La misma excepción aplica a `openvasd` (`172.18.0.7`). Un objetivo puede
bloquear ICMP; en ese caso usa una comprobación TCP de bajo impacto desde
el host con Nmap.

y repetir la prueba del contenedor. Debe recuperar conectividad mediante
Proton.

## 8. Diagnóstico rápido

``` bash
nmcli connection show protonwg
wg show protonwg
ip rule
ip route show table 51820
ip addr show openvasbr0
sudo nft list table inet openvas_killswitch
sudo docker ps
```

Para verificar la decisión de routing de un paquete que llega desde el
bridge:

``` bash
ip route get 1.1.1.1 \
  from 172.18.0.2 \
  iif openvasbr0
```

Con Proton activo debe indicar:

``` text
dev protonwg table 51820
```

## Estado

Configuración probada después de reiniciar:

-   `protonwg` permanece OFF al arrancar.
-   El kill switch reaparece automáticamente.
-   OpenVAS no tiene salida con Proton OFF.
-   OpenVAS recupera salida por Proton al activar `protonwg`.
-   El tráfico normal del host permanece fuera del túnel.

# Metasploit contra la LAN

La LAN observada en este equipo es `192.168.100.0/24`, con el host en
`192.168.100.10` y la interfaz Wi-Fi `wlp6s0`. Este modo permite que el
contenedor alcance únicamente esa red local. El resto del tráfico sigue
siendo bloqueado si Proton VPN no está activo.

## Preparación del contenedor

Desde este directorio:

```bash
sudo docker compose up -d
sudo docker inspect -f '{{.Name}} {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' metasploit
ip addr show metasploitbr0
```

La dirección esperada del contenedor es `172.20.0.2`. Si el bridge muestra
`NO-CARRIER`, el contenedor no está ejecutándose o no está conectado a la
red; no es un problema que se solucione con `ip link set` manualmente.

## Ruta LAN para el tráfico seleccionado

La regla de Metasploit usa la tabla `51820`, por lo que esa tabla también
necesita conocer la ruta local:

```bash
sudo ip route replace 192.168.100.0/24 dev wlp6s0 src 192.168.100.10 table 51820
sudo ip route get 192.168.100.20 from 172.20.0.2
```

Para hacerla persistente en NetworkManager, añadirla al perfil activo de
Wi-Fi (sustituir el nombre si es distinto):

```bash
nmcli connection show --active
sudo nmcli connection modify 'LAB_WIFI_PROFILE' +ipv4.routes \
  '192.168.100.0/24 0.0.0.0 table=51820'
sudo nmcli connection down 'LAB_WIFI_PROFILE'
sudo nmcli connection up 'LAB_WIFI_PROFILE'
```

Después de reconectar, comprobar que la ruta sigue en la tabla `51820`.

## Kill switch

Instalar la plantilla [`../../../infra/host/nftables-metasploit.conf`](../../../infra/host/nftables-metasploit.conf)
como `/etc/nftables-metasploit.conf` y habilitar el servicio indicado en
[`../../../infra/host/metasploit-killswitch.service`](../../../infra/host/metasploit-killswitch.service).
La regla de aceptación de `192.168.100.0/24` debe aparecer antes del bloqueo
general hacia `wlp6s0`.

```bash
sudo nft -c -f /etc/nftables-metasploit.conf
sudo systemctl daemon-reload
sudo systemctl enable --now metasploit-killswitch.service
```

## Pruebas autorizadas

Comprobar primero un equipo propio de la LAN:

```bash
sudo docker exec metasploit bash -lc 'ip route; ping -c 2 192.168.100.20'
sudo docker exec metasploit bash -lc \
  '/usr/src/metasploit-framework/msfconsole -q -x "db_status; exit -y"'
```

Para Nmap local se recomienda ejecutarlo desde el host, no desde la ruta
VPN de Metasploit:

```bash
sudo nmap -n -sn 192.168.100.0/24
sudo nmap -n -Pn -sV --top-ports 100 192.168.100.20
```

Usar únicamente objetivos propios o expresamente autorizados.

# Impacket — protocolos Windows, SMB y Active Directory

Impacket es una colección de clases y herramientas Python para trabajar con
Ethernet, IP, TCP/UDP, SMB, MSRPC, LDAP, Kerberos, DCOM, WMI y otros protocolos
de Windows. En este laboratorio se usa para validación autorizada de servicios
Windows/Samba y Active Directory, después de confirmar el alcance con Nmap.

No es un escáner genérico ni una herramienta para probar credenciales al azar.
Muchas herramientas pueden autenticar, ejecutar comandos, consultar secretos o
modificar servicios. Cada ejecución debe tener objetivo, cuenta, técnica y
alcance aprobados.

## Herramientas incluidas

| Herramienta | Uso controlado |
|---|---|
| `GetNPUsers.py` | Identificar cuentas AS-REP roastable con autorización |
| `GetUserSPNs.py` | Consultar SPN y delegaciones autorizadas |
| `secretsdump.py` | Extraer secretos solo durante una validación aprobada |
| `wmiexec.py`, `psexec.py`, `smbexec.py` | Validar ejecución remota autorizada |
| `smbclient.py`, `rpcdump.py`, `samrdump.py` | Consultar SMB/RPC y permisos |
| `ntlmrelayx.py` | Solo en un laboratorio aislado y con plan explícito |
| `GetADUsers.py`, `lookupsid.py` | Consultas de usuarios y SID autorizadas |

La lista exacta se consulta con `ls /usr/local/bin/impacket-*` dentro de la
imagen. Los argumentos cambian entre versiones; usar siempre `--help` de la
imagen instalada.

## Imagen y red

| Elemento | Valor |
|---|---|
| Fuente | `github.com/fortra/impacket` vía PyPI |
| Versión | `0.13.1` |
| Imagen local | `cybersec/impacket:0.13.1` |
| Bridge | `impacketbr0` |
| Red Compose | `impacket_impacket_net` |
| Subred | `172.32.0.0/24` |
| Contenedor | `172.32.0.2` |
| Tabla VPN | `51820` |
| Regla | prioridad `140` |

## Política de red

### LAN autorizada

La excepción directa permite únicamente `192.168.100.0/24`. Se usa para un
Windows, Samba o controlador de dominio del laboratorio en esa LAN.

### Objetivo externo

ProtonWG debe estar activo. La IP `172.32.0.2` se dirige a la tabla `51820`,
cuya ruta por defecto es `protonwg`. Si ProtonWG se apaga, el kill switch
bloquea la salida externa por `wlp6s0`.

### Tor

No usar Tor como modo general para Impacket. SMB, RPC, LDAP, Kerberos y
NetBIOS requieren conectividad IP completa y algunos flujos usan UDP o
resolución de nombres. ProxyChains/Tor no sustituye el perfil ProtonWG.

## Instalación

```bash
cd ./tools/windows/impacket
mkdir -p work krb5
sudo docker compose build --pull
sudo docker compose run --rm impacket -c 'import importlib.metadata as m; print(m.version("impacket"))'
```

La carpeta `krb5/` queda disponible para una configuración Kerberos local,
pero no debe contener credenciales ni tickets en Git.

## Configuración del host

Añadir la regla sin eliminar las existentes:

```bash
sudo nmcli connection modify protonwg +ipv4.routing-rules "priority 140 from 172.32.0.2/32 table 51820"
```

Instalar y activar el kill switch:

```bash
sudo install -m 0644 ./infra/host/nftables-impacket.conf /etc/nftables-impacket.conf
sudo install -m 0644 ./infra/host/impacket-killswitch.service /etc/systemd/system/impacket-killswitch.service
sudo nft -c -f /etc/nftables-impacket.conf
sudo systemctl daemon-reload
sudo systemctl enable --now impacket-killswitch.service
```

La tabla `51820` debe conservar la ruta LAN `192.168.100.0/24` y la ruta por
defecto por ProtonWG.

## Uso seguro de ejemplo

Primero comprobar que el servicio existe y que Nmap confirmó SMB/RPC/LDAP en
un objetivo autorizado. Sustituir `192.168.100.20` por una IP real aprobada.

```bash
sudo docker compose run --rm impacket /usr/local/bin/rpcdump.py 192.168.100.20
sudo docker compose run --rm impacket /usr/local/bin/smbclient.py 192.168.100.20
```

Si un script no está en esa ruta, localizarlo sin ejecutar consultas:

```bash
sudo docker compose run --rm --entrypoint sh impacket -lc 'command -v rpcdump.py; command -v smbclient.py; command -v GetADUsers.py'
```

Para autenticación, no poner contraseñas en el comando ni en el repositorio.
Usar un mecanismo local controlado y considerar que hashes, tickets y
credenciales pueden quedar en el historial o en la lista de procesos.

## Kerberos

Kerberos depende de DNS, sincronización horaria, nombre de dominio y SPN. La
configuración de `/etc/krb5/krb5.conf` debe montarse solo desde un archivo local
no versionado. Validar primero resolución y hora; no comenzar con técnicas de
extracción o movimiento lateral.

## Validación

El runbook está en
`docs/runbooks/validate-impacket.md`. Incluye validación de imagen, routing,
kill switch, LAN y ProtonWG apagado. Sin una IP Windows/Samba todavía solo se
puede validar la infraestructura; no se debe inventar un objetivo.

La red de este equipo ya fue validada: la regla `140` está activa, el kill
switch está habilitado, la salida externa usa ProtonWG y la salida externa se
bloquea al apagarlo. Todavía no existe una IP Windows/Samba para validar una
consulta real de SMB/RPC/LDAP.

## Límites

- Ejecutar únicamente sobre sistemas propios o expresamente autorizados.
- No usar `secretsdump`, `psexec`, `wmiexec`, `ntlmrelayx` ni técnicas Kerberos
  contra objetivos sin aprobación específica.
- Guardar resultados en `work/`, que está ignorado por Git.
- No guardar contraseñas, hashes, tickets, claves ni archivos `krb5.conf` reales.

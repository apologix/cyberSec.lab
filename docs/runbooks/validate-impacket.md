# Validación de Impacket

## Objetivo

Validar la imagen, las herramientas y el aislamiento de red sin requerir una
IP Windows/Samba. La enumeración real queda pendiente hasta disponer de un
objetivo autorizado.

## Instalación

```bash
cd ./tools/windows/impacket
mkdir -p work krb5
sudo docker compose config
sudo docker compose build --pull
sudo docker compose run --rm impacket -c 'import importlib.metadata as m; print(m.version("impacket"))'
sudo docker compose run --rm --entrypoint sh impacket -lc 'command -v rpcdump.py; command -v smbclient.py; command -v GetADUsers.py'
```

## Red

```bash
sudo docker network inspect impacket_impacket_net
sudo nft list table inet impacket_killswitch
ip rule
ip route show table 51820
```

Debe aparecer `impacketbr0`, `172.32.0.2`, prioridad `140`, la ruta LAN y la
ruta por defecto de ProtonWG en la tabla `51820`.

## Prueba funcional cuando exista objetivo

Usar solo una IP Windows/Samba autorizada:

```bash
read -r -p 'IP Windows/Samba autorizada: ' TARGET
sudo docker compose run --rm impacket /usr/local/bin/rpcdump.py "$TARGET" | tee "work/rpcdump-$TARGET.txt"
```

Para un objetivo externo, ProtonWG debe estar activo. Para un objetivo LAN,
la excepción permite únicamente `192.168.100.0/24`.

## Estados que deben probarse

| Estado | Resultado esperado |
|---|---|
| ProtonWG activo | Objetivo externo accesible por la ruta VPN |
| ProtonWG apagado | Objetivo externo bloqueado, sin fallback por Wi-Fi |
| Objetivo LAN | Solo la subnet autorizada es accesible |
| Sin objetivo | Imagen y red validables; no se ejecuta enumeración |

No usar Tor para esta validación. No probar autenticación, ejecución remota,
secretsdump o relay hasta documentar una autorización específica.

## Resultado en este equipo

Validación realizada el 27 de agosto de 2026:

- La imagen `cybersec/impacket:0.13.1` compiló correctamente.
- El paquete instalado reportó la versión `0.13.1`.
- La regla `140 from 172.32.0.2` aparece en policy routing.
- La tabla `51820` contiene la ruta por defecto de `protonwg` y la ruta LAN.
- `impacket-killswitch.service` está `active` y habilitado.
- La red usa `impacketbr0`, subnet `172.32.0.0/24` y gateway `172.32.0.1`.
- Con ProtonWG activo, el contenedor salió por la interfaz VPN esperada.
- El gateway LAN `192.168.100.1` respondió con 0% de pérdida.
- Con ProtonWG apagado, la salida externa terminó en timeout con código 1.

La política de red queda aprobada. Falta únicamente repetir una consulta
Impacket contra una IP Windows/Samba autorizada cuando exista.

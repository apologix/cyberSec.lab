# Validación de enum4linux-ng

## Instalación y herramienta

```bash
cd ./tools/windows/enum4linux-ng
sudo docker compose config
sudo docker compose build --pull
sudo docker compose run --rm enum4linux --help
```

## Red protegida

```bash
sudo docker network inspect enum4linux-ng_enum4linux_net
sudo nft list table inet enum4linux_killswitch
ip rule
ip route show table 51820
```

Debe aparecer `enum4linuxbr0`, la IP `172.31.0.2` y la regla de prioridad `130`.

## Pruebas de salida

Las pruebas contra equipos Windows/Samba deben realizarse solo contra objetivos autorizados.

- ProtonWG activo: ejecutar `-As` contra un servidor externo autorizado y confirmar conectividad.
- ProtonWG apagado: repetir una conexión externa y confirmar que queda bloqueada.
- LAN: ejecutar `-As` contra un servidor de laboratorio en `192.168.100.0/24`.
- Exportación: confirmar que el JSON/YAML aparece en `work/`.

No se debe usar Tor para estas pruebas.

## Resultado de la validación de este equipo

La prueba realizada el 27 de agosto de 2026 confirmó la infraestructura y la ejecución:

- La imagen `cybersec/enum4linux-ng:v1.3.10` se compiló correctamente.
- La ayuda del programa confirmó `enum4linux-ng v1.3.10` y sus dependencias Samba/Python.
- Con ProtonWG activo, la red `172.31.0.2` obtuvo salida por Proton.
- El gateway `192.168.100.1` respondió desde el contenedor con cero pérdida de paquetes.
- Con ProtonWG apagado, la salida externa terminó en timeout y no hubo fallback por Wi-Fi.
- Contra `192.168.100.1`, LDAP, LDAPS, SMB y NetBIOS devolvieron `connection refused`, por lo que enum4linux-ng abortó el resto de pruebas de forma correcta.

El gateway no es un objetivo Windows/Samba. Para validar enumeración real se necesita una IP autorizada que exponga SMB o LDAP.

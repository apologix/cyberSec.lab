# Verificación de salida

La prueba mínima de cada herramienta protegida tiene tres estados:

1. Con ProtonWG activo, la salida externa debe mostrar la IP de Proton.
2. Con ProtonWG apagado, la salida externa debe fallar o quedar bloqueada.
3. En ambos estados, el acceso a la LAN autorizada debe seguir el modo documentado.

Comprobaciones del host:

```bash
ip rule
ip route show table 51820
wg show protonwg
sudo nft list ruleset
```

No se deben publicar IPs públicas reales, claves, perfiles WireGuard ni credenciales en los resultados.

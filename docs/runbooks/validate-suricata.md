# Validación de Suricata

Suricata se ejecuta localmente como IDS/NSM sobre una interfaz definida. No usa
ProtonWG ni Tor.

```bash
suricata --build-info | head -n 3
sudo suricata --list-runmodes
systemctl is-enabled suricata 2>/dev/null || true
```

No activar captura permanente hasta seleccionar interfaz, reglas, destino de
logs y retención para la LAN autorizada.

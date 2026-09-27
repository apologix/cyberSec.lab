# Validación de Wireshark

Wireshark se ejecuta localmente para capturas autorizadas y análisis offline.
No usa ProtonWG ni Tor.

```bash
wireshark --version | head -n 1
tshark --version | head -n 1
ip -br address
```

Abrir una captura de prueba o capturar solo la interfaz y el segmento
autorizados. No iniciar una captura amplia por defecto.

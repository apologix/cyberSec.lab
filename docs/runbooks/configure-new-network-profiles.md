# Activar perfiles de red nuevos

Este procedimiento **modifica NetworkManager, nftables y systemd**. No se
ejecuta automáticamente y requiere revisar la LAN, interfaz y disponibilidad
de subredes en `.env`.

Perfiles pendientes:

| Perfil | Bridge | IPs | Prioridad sugerida |
|---|---|---|---|
| OSINT / SpiderFoot | `osintbr0` | `172.33.0.2`, `172.33.0.3` | 150, 151 |
| DNS | `dnsbr0` | `172.34.0.2` | 160 |
| TLS | `tlsbr0` | `172.35.0.2` | 170 |

La automatización reproducible está en `scripts/configure-new-network-profiles.sh`.
Compruebe primero que las subredes no colisionan y ejecute el script con sudo.
Este añade reglas `from IP/32 table 51820`, renderiza y valida los archivos
nftables, instala y habilita los servicios, y solo entonces crea las redes
Docker externas. Los Compose no pueden crear esas redes por sí mismos: si no
existen, se detienen en lugar de permitir una salida directa accidental.

La instalación se rechaza si ya existe alguno de los servicios nuevos, para no
mezclar una configuración previa con una nueva. Si una etapa falla, el script
retira las reglas y archivos que acababa de crear. Finalmente ejecute:

```bash
./scripts/verify-network-policy.sh --include-pending
./scripts/verify-container-egress.sh
```

La segunda prueba debe realizarse con ProtonWG activo y apagado. Hasta que
ambas terminen correctamente, no ejecute los contenedores contra Internet.

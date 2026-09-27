# Validar SpiderFoot

Primero ejecute
[`configure-new-network-profiles.md`](configure-new-network-profiles.md): crea
la red externa `osint-runner_osint_net` únicamente después de aplicar policy
routing y el kill switch. Valide ambos estados de ProtonWG antes de construir o
levantar el servicio. Después, mantenga la UI solo en localhost:

```bash
cd tools/osint/automation/spiderfoot
sudo docker compose --env-file ../../../../.env build
sudo docker compose --env-file ../../../../.env up -d
sudo docker compose --env-file ../../../../.env ps
```

Abra `http://127.0.0.1:5001` localmente y configure APIs opcionales mediante la
interfaz o secreto local. Use únicamente objetivos autorizados, limite módulos
y exporte resultados al directorio del caso. No exponga el puerto a la LAN o
Internet sin una decisión explícita.

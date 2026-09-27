# Validación de OpenVAS

```bash
cd ./tools/vulnerabilities/openvas
sudo docker compose -f docker-compose.yml -f docker-compose.override.yml config
sudo docker compose -f docker-compose.yml -f docker-compose.override.yml ps
ip rule
ip route show table 51820
sudo nft list table inet openvas_killswitch
```

Debe existir el bridge `openvasbr0`, las fuentes documentadas de OpenVAS y el
kill switch activo. Las tareas de escaneo se crean solo para objetivos
autorizados y no se ejecutan durante esta comprobación.

# Validate OpenVAS

```bash
cd ./tools/vulnerabilities/openvas
sudo docker compose -f docker-compose.yml -f docker-compose.override.yml config
sudo docker compose -f docker-compose.yml -f docker-compose.override.yml ps
ip rule
ip route show table 51820
sudo nft list table inet openvas_killswitch
```

The `openvasbr0` bridge, documented OpenVAS sources, and active kill switch must
exist. Create scan tasks only for authorized targets; do not run them during this check.

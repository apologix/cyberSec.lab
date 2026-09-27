# Validación de Metasploit

```bash
cd ./tools/validation/metasploit
sudo docker compose config
sudo docker compose ps
ip rule
ip route show table 51820
sudo nft list table inet metasploit_killswitch
```

La consola no debe ejecutar módulos contra objetivos durante esta validación.
Para la LAN, leer primero [`LAN_MODE.md`](../../tools/validation/metasploit/LAN_MODE.md)
y confirmar autorización, rango y restauración.

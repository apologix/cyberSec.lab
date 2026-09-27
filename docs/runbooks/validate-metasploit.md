# Validate Metasploit

```bash
cd ./tools/validation/metasploit
sudo docker compose config
sudo docker compose ps
ip rule
ip route show table 51820
sudo nft list table inet metasploit_killswitch
```

Do not execute modules against targets during validation. For LAN work, read
[LAN_MODE.md](../../tools/validation/metasploit/LAN_MODE.md) first and confirm
authorization, range, and restoration.

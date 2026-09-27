# Validate Impacket

## Goal

Validate image, tools, and network isolation without requiring a Windows/Samba
IP. Real enumeration remains pending until an authorized target is available.

```bash
cd ./tools/windows/impacket
mkdir -p work krb5
sudo docker compose config
sudo docker compose build --pull
sudo docker compose run --rm impacket -c 'import importlib.metadata as m; print(m.version("impacket"))'
sudo docker compose run --rm --entrypoint sh impacket -lc 'command -v rpcdump.py; command -v smbclient.py; command -v GetADUsers.py'
sudo docker network inspect impacket_impacket_net
sudo nft list table inet impacket_killswitch
ip rule
ip route show table 51820
```

Expect `impacketbr0`, `172.32.0.2`, priority `140`, an authorized LAN route,
and the ProtonWG default route in table `51820`.

```bash
read -r -p 'Authorized Windows/Samba IP: ' TARGET
sudo docker compose run --rm impacket /usr/local/bin/rpcdump.py "$TARGET" | tee "work/rpcdump-$TARGET.txt"
```

Use ProtonWG for external targets; the LAN exception allows only the authorized
subnet. Do not use Tor or test authentication, remote execution, secretsdump,
or relay without documented authorization.

# Validate enum4linux-ng

## Installation and tool

```bash
cd ./tools/windows/enum4linux-ng
sudo docker compose config
sudo docker compose build --pull
sudo docker compose run --rm enum4linux --help
```

## Protected network

```bash
sudo docker network inspect enum4linux-ng_enum4linux_net
sudo nft list table inet enum4linux_killswitch
ip rule
ip route show table 51820
```

Expect `enum4linuxbr0`, `172.31.0.2`, and priority rule `130`.

Test Windows/Samba systems only when authorized: with ProtonWG active, confirm
an external `-As` connection; with it down, confirm external egress is blocked;
on the LAN, use an authorized lab server and verify JSON/YAML under `work/`.
Do not use Tor. A real enumeration requires an authorized target exposing SMB
or LDAP.

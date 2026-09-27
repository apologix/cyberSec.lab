# Egress verification

Every protected tool needs three checks:

1. With ProtonWG active, external egress must use the Proton address.
2. With ProtonWG inactive, external egress must fail or be blocked.
3. In both states, authorized LAN access must follow the documented mode.

Host checks:

```bash
ip rule
ip route show table 51820
wg show protonwg
sudo nft list ruleset
```

Never publish real public IPs, WireGuard keys or profiles, or credentials in results.

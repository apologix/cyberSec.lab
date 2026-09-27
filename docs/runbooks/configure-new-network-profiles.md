# Activate new network profiles

This procedure **changes NetworkManager, nftables, and systemd**. It is not
automatic: review LAN, interface, and subnet availability in `.env` first.

| Profile | Bridge | IPs | Suggested priority |
|---|---|---|---|
| OSINT / SpiderFoot | `osintbr0` | `172.33.0.2`, `172.33.0.3` | 150, 151 |
| DNS | `dnsbr0` | `172.34.0.2` | 160 |
| TLS | `tlsbr0` | `172.35.0.2` | 170 |

Run `scripts/configure-new-network-profiles.sh` with sudo only after confirming
subnets do not collide. It adds `from IP/32 table 51820` rules, renders and
validates nftables files, installs and enables services, then creates external
Docker networks. Compose files cannot create these networks: they stop instead
of allowing accidental direct egress.

The installation refuses an existing service to avoid mixing configurations. If
a stage fails, it removes rules and files it just created. Then run:

```bash
./scripts/verify-network-policy.sh --include-pending
./scripts/verify-container-egress.sh
```

Run the second test with ProtonWG both active and inactive. Do not use the
containers against the Internet until both complete successfully.

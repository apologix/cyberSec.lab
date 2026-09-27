# Validate TLS

This profile requires ProtonWG and the `tlsbr0` kill switch for external
destinations. If `tls_tls_net` does not exist, first follow
[configure-new-network-profiles.md](configure-new-network-profiles.md). Test an
owned service first.

```bash
cd tools/tls
sudo docker compose --env-file ../../.env pull
sudo docker compose --env-file ../../.env run --rm tls-runner --version
```

Run only against in-scope host:port pairs, retain the original report in the
external case directory, and validate a configuration before recording a finding.

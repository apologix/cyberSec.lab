# Validar SpiderFoot

Run first
[`configure-new-network-profiles.md`](configure-new-network-profiles.md): Create
the external network `osint-runner_osint_net` only after applying policy
routing and the kill switch. Validate both states of ProtonWG before building or
lift the service, then keep the UI only on localhost:
```bash
cd tools/osint/automation/spiderfoot
sudo docker compose --env-file ../../../../.env build
sudo docker compose --env-file ../../../../.env up -d
sudo docker compose --env-file ../../../../.env ps
```

Open `http://127.0.0.1:5001` locally and configure optional APIs using the
interface or local secret. Use only authorized targets, limit modules
and export results to the case directory. Do not expose the port to the LAN or
Internet without an explicit decision.
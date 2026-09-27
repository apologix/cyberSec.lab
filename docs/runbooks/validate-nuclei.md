# Full Nuclei validation

These checks do not run a vulnerability scan. They verify expected container
networking and restrictions.

## Preparation

```bash
cd ./tools/recon/nuclei
sudo docker compose config
sudo docker network inspect nuclei_nuclei_net >/dev/null
find data/templates -type f -name '*.yaml' | wc -l
sudo nft list table inet nuclei_killswitch
```

The template count must be greater than zero and the bridge must exist as
`nucleibr0`.

## ProtonWG active: external egress

```bash
nmcli connection up protonwg
sudo docker run --rm --network nuclei_nuclei_net --ip 172.30.0.2 busybox:1.36.1 wget -qO- --timeout=10 https://api.ipify.org
ip route get 1.1.1.1 from 172.30.0.2 iif nucleibr0
```

Expect a Proton public IP, not the normal host IP, and table `51820` through
`protonwg`.

## ProtonWG inactive: block egress

```bash
nmcli connection down protonwg
sudo timeout 15 docker run --rm --network nuclei_nuclei_net --ip 172.30.0.2 busybox:1.36.1 wget -qO- --timeout=10 https://api.ipify.org
echo $?
```

The command must fail or time out and show no public IP. Authorized LAN access
may remain available; use the current gateway or an authorized TCP service.

## Temporary HTTP test

Use an empty temporary directory rather than serving the repository:

```bash
rm -rf /tmp/nuclei-http-test
mkdir -p /tmp/nuclei-http-test
echo 'Nuclei test' > /tmp/nuclei-http-test/index.html
python3 -m http.server 8080 --bind 0.0.0.0 --directory /tmp/nuclei-http-test >/tmp/nuclei-http-test.log 2>&1 &
SERVER_PID=$!
```

Run Nuclei only against that authorized test server, confirm Python/SimpleHTTP
technology detection and JSONL generation, then stop it with `kill "$SERVER_PID"`.
This validates connectivity and execution, not a vulnerability. Leave ProtonWG
in its usual operational state afterward.

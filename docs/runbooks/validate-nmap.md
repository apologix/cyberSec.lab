# Validate Nmap

Use Nmap only against owned or authorized targets. Confirm the scope first and
select the appropriate interface and route.

```bash
nmap --version
sudo nmap -n -sn 192.168.100.0/24
```

For an authorized external target, validate the ProtonWG route first and use the
approved ProxyChains4 procedure. Do not scan the Internet indiscriminately.

# Validar OSINT

Primero instale el perfil de red OSINT, active ProtonWG y verifique que su kill
switch está activo. Si la red externa `osint-runner_osint_net` no existe, siga
primero [`configure-new-network-profiles.md`](configure-new-network-profiles.md).
Holehe consulta actualizaciones incluso con `--help`; con
ProtonWG apagado debe fallar por diseño. No ejecute consultas contra
identificadores fuera del alcance.

```bash
cd tools/osint/osint-runner
sudo docker compose --env-file ../../../.env build
sudo docker compose --env-file ../../../.env run --rm osint-runner holehe --help
sudo docker compose --env-file ../../../.env run --rm osint-runner maigret --help
sudo docker compose --env-file ../../../.env run --rm osint-runner sherlock --help
```

Valide primero contra identificadores de prueba propios y escriba resultados en
`/cases/CASE-.../raw/osint/<herramienta>/`. Una respuesta positiva sigue siendo
un indicador. HIBP, Intelligence X y GitHub requieren sus respectivas claves
locales; no imprima las variables ni las incluya en logs.

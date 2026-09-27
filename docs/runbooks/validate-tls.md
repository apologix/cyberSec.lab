# Validar TLS

Este perfil requiere ProtonWG y el kill switch de `tlsbr0` para destinos
externos. Si la red externa `tls_tls_net` no existe, siga primero
[`configure-new-network-profiles.md`](configure-new-network-profiles.md).
Compruebe primero un servicio propio de prueba.

```bash
cd tools/tls
sudo docker compose --env-file ../../.env pull
sudo docker compose --env-file ../../.env run --rm tls-runner --version
```

Ejecute solo contra host:puerto incluido en el alcance y conserve el informe
original en `CASE/raw/tls/`. Una configuración detectada debe validarse antes de
registrarla como hallazgo.

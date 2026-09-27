# Reprovisionar una PC

## Dependencias del host

Debian, Docker Engine, Compose v2, NetworkManager, WireGuard, `iproute2`, `nftables`, systemd, `curl`, certificados CA, Tor y ProxyChains4 cuando sean necesarios.

## Orden recomendado

1. Clonar el repositorio privado.
2. Copiar `.env.example` a `.env` y ajustar interfaz, LAN, ProtonWG y SOCKS.
3. Importar el perfil privado de ProtonWG fuera del repositorio.
4. Configurar la tabla de rutas `51820` sin cambiar la ruta por defecto del host.
5. Instalar las plantillas nftables y servicios systemd desde `infra/host/`.
6. Levantar OpenVAS y Metasploit; comprobar sus bridges e IPs.
7. Verificar ProtonWG encendido y apagado antes de incorporar una herramienta nueva.
8. Construir solo las imágenes que se vayan a utilizar.

La instalación local se ejecuta con `scripts/install-local-tools.sh` y
`scripts/install-special-local-tools.sh`. Después de instalar, ejecutar
`scripts/verify-lab.sh` y corregir cualquier elemento pendiente antes de usar
las herramientas.
Para comprobar que los contenedores no tengan fuga por Wi-Fi, ejecutar también
`scripts/verify-container-egress.sh` con las redes Docker levantadas.

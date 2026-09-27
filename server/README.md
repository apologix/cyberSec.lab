# CyberLab Server

Herramienta web independiente para telemetría, reconocimiento autorizado,
honeypot pasivo, collectors estáticos y visualización administrativa. Se
desarrolla localmente con Docker Desktop y se despliega en un VPS. No comparte
redes ni configuración de ProtonWG/Tor con las herramientas operativas del
laboratorio.

## Desarrollo local

```bash
cd server
cp .env.example .env
docker compose -f compose.yaml -f compose.dev.yaml up --build
```

Docker Desktop muestra los servicios bajo el proyecto `cyberlab-server`.
Nginx queda disponible en `http://localhost:8080` con la configuración de
ejemplo. Cambie todos los valores de `.env` antes de usar collectors o el
dashboard.

Los collectors muestran JSON por defecto. Para enviarlo, defina solo en el
equipo autorizado `CYBERLAB_COLLECTOR_URL` (por ejemplo,
`https://tu-dominio/api/collector`) y `CYBERLAB_COLLECTOR_TOKEN`; los scripts
no aceptan comandos, carga de archivos ni código remoto.

## Convención de scripts

Cada script tiene su propia carpeta y usa un nombre de archivo fijo. Esto evita
mezclar scripts, hashes y futuros archivos auxiliares dentro de una misma
carpeta de plataforma:

```text
scripts/
├── linux/<nombre>/script.sh
└── windows/<nombre>/script.ps1
```

Por ejemplo: `/scripts/linux/sys/script.sh` y
`/scripts/windows/sys/script.ps1`. Cada archivo publica su checksum junto a
él como `script.sh.sha256` o `script.ps1.sha256`.

## Producción en VPS

El despliegue de producción parte de las mismas imágenes, pero no monta el
código fuente, no publica FastAPI ni PostgreSQL y termina TLS en Nginx o en un
proxy TLS controlado. Antes de publicar el servicio se debe añadir el perfil
de HTTPS, configurar DNS/certificados y sustituir los secretos de ejemplo por
valores aleatorios almacenados fuera de Git.

En el VPS, coloque `fullchain.pem` y `privkey.pem` en un directorio seguro y
defina `TLS_CERTS_HOST_PATH` a ese directorio. Luego ejecute:

```bash
docker compose -f compose.yaml -f compose.production.yaml up -d --build
```

El perfil publica únicamente 80/443; HTTP redirige a HTTPS y el servicio
`migrate` inicializa el esquema antes de iniciar la API. No exponga `5432` ni
`8000`. La cuenta única de dashboard es adecuada para administración personal;
para uso multiusuario debe sustituirse por un proveedor de identidad.

## Funciones incluidas

- Autenticación con `fastapi-users`, contraseñas hasheadas con Argon2, cookie
  `HttpOnly`/`SameSite=Strict` y JWT de duración limitada.
- Dashboard de Recon, eventos de honeypot, collectors y scripts publicados.
- Recon del navegador con matriz de capacidades y solicitud de ubicación
  precisa al abrir la ruta; el navegador exige el permiso explícito de la
  persona y solo se almacena cuando lo concede.
- Honeypot pasivo que no guarda cuerpos, credenciales ni ejecuta contenido.
- Scripts estáticos Windows/Linux de hello, sistema y red; cada uno publica su
  SHA-256 y solo puede enviar JSON al endpoint configurado por el administrador.
- GeoIP opcional desde una base local y purga diaria de los eventos vencidos.

Los datos de administración se representan como texto/JSON y nunca como HTML
capturado. Antes de un despliegue multiusuario, sustituya el usuario único de
entorno por un proveedor de identidad o administración de usuarios dedicada.

El primer superusuario se crea al inicializar la base de datos mediante
`FIRST_SUPERUSER_EMAIL` y `FIRST_SUPERUSER_PASSWORD`. Para el entorno local
deben definirse valores únicos y aleatorios en un archivo `.env` no
versionado. No se deben utilizar credenciales predeterminadas al exponer el
servicio.

## Organización del backend

`backend/app/main.py` se limita a configurar FastAPI, el ciclo de vida y los
routers. Cada módulo conserva un `router.py` delgado y un `service.py` con la
lógica de aplicación:

```text
backend/app/
├── core/                 # configuración, DB, HTTP y retención
└── modules/
    ├── auth/
    ├── recon/
    ├── honeypot/
    ├── collectors/
    └── admin/
```

Este diseño evita que un handler HTTP contenga reglas de negocio, acceso a
datos y detalles de infraestructura a la vez.

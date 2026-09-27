# CyberLab Server — Project Brief

> Estado de arquitectura: herramienta web independiente del laboratorio. Se
> desarrolla localmente con Docker Desktop y su destino principal es un VPS
> administrado. No utiliza ProtonWG, Tor, policy routing ni los kill switches
> de las herramientas de evaluación del repositorio.

## 1. Objetivo

Construir un servidor web de laboratorio orientado a ciberseguridad básica, reconocimiento, recolección de telemetría, entrega controlada de scripts, honeypot pasivo y visualización de eventos.

El proyecto es una herramienta del catálogo de Cybersecurity Lab, pero opera
como un servicio de servidor autónomo. Puede ejecutarse localmente para
desarrollo y pruebas, y desplegarse sin cambios de arquitectura en un VPS.

El proyecto debe priorizar:

- Seguridad del propio servidor.
- Recolección controlada de información.
- Trazabilidad y auditoría.
- Aislamiento entre módulos.
- No permitir ejecución arbitraria de comandos.
- No exponer archivos internos, secretos, variables de entorno, configuraciones ni rutas del sistema.
- Mantener el laboratorio útil para aprendizaje y pruebas en infraestructura propia o autorizada.

---

## 2. Stack recomendado

### Backend
- Python
- FastAPI
- fastapi-users para autenticación, gestión de contraseñas y sesiones
- Uvicorn/Gunicorn según despliegue
- Pydantic para validación

### Frontend
- React
- Vite
- TypeScript

### Base de datos
- PostgreSQL

### Reverse proxy
- Nginx

### Infraestructura
- Docker
- Docker Compose

### Sistema operativo
- Debian estable o Ubuntu LTS

## 2.1 Modelo de despliegue

El mismo proyecto debe admitir dos perfiles explícitos:

| Perfil | Propósito | Exposición |
|---|---|---|
| `development` | Desarrollo local con Docker Desktop | Nginx en `localhost`; hot reload para frontend y backend |
| `production` | VPS administrado | Solo Nginx publica 80/443; frontend, backend y PostgreSQL permanecen en redes Docker internas |

El proyecto Compose se llamará `cyberlab-server`, para que Docker Desktop lo
muestre como un grupo independiente. La topología no comparte redes Docker,
volúmenes ni reglas de enrutamiento con OpenVAS, Metasploit, Nuclei u otras
herramientas del laboratorio.

La implementación inicial vive en `server/compose.yaml`; el perfil de
desarrollo se activa con `server/compose.dev.yaml`. El perfil de producción
debe conservar la misma separación de redes y añadir la terminación TLS antes
de abrir el servicio a Internet.

```text
Internet / navegador local
          |
          v
        Nginx
       /     \
frontend   FastAPI
              |
          PostgreSQL
```

En producción, FastAPI y PostgreSQL no publican puertos al host. Los secretos
se suministran exclusivamente mediante el entorno seguro del VPS o Docker
secrets; no se incluyen en imágenes ni en el repositorio. HTTPS es obligatorio
en producción. El uso de Docker Desktop es únicamente una facilidad de
desarrollo y no cambia las medidas de seguridad propias de la aplicación.

---

## 3. Arquitectura general

```text
Internet
   |
   v
Nginx
   |
   +-------------------+
   |                   |
   v                   v
React               FastAPI
                        |
        +---------------+---------------+
        |               |               |
        v               v               v
      Recon          Honeypot       Collectors
        |               |               |
        +---------------+---------------+
                        |
                        v
                  Event Engine
                        |
                        v
                   PostgreSQL
                        |
                        v
                    Dashboard
```

---

# 4. Módulos principales

## 4.1 Recon

Ruta principal:

```text
POST /api/recon
```

Todo el reconocimiento debe intentar consolidarse en una sola sesión y una sola solicitud principal.

La información enviada por el navegador se combina con la información observada por el servidor.

### Datos observados por el servidor

- IP pública observada.
- Puerto remoto cuando esté disponible.
- Método HTTP.
- Protocolo HTTP.
- Host solicitado.
- User-Agent.
- Accept.
- Accept-Language.
- Accept-Encoding.
- Referer.
- Origin.
- Headers permitidos para análisis.
- Timestamp.
- TLS metadata disponible desde Nginx.
- GeoIP de la IP observada.
- ASN.
- Organización de red.

No confiar automáticamente en:

```text
X-Forwarded-For
Forwarded
X-Real-IP
```

Estos headers solo deben considerarse confiables cuando provengan del reverse proxy controlado por el proyecto.

### Datos recolectados por el navegador

Siempre dentro de las capacidades normales del navegador.

Ejemplos:

- Resolución de pantalla.
- Viewport.
- Device pixel ratio.
- Color depth.
- Idioma principal.
- Lista de idiomas.
- Timezone.
- CPU cores aproximados expuestos por el navegador.
- Memoria aproximada cuando la API esté disponible.
- Touch support.
- Max touch points.
- Cookies habilitadas.
- Do Not Track cuando exista.
- Secure Context.
- WebGL.
- WebGL2.
- Información gráfica permitida por el navegador.
- WebGPU disponible o no.
- IndexedDB.
- localStorage.
- sessionStorage.
- Service Workers.
- WebSockets.
- Clipboard API disponible.
- Notifications API disponible.
- Geolocation API disponible.
- Network Information API cuando esté disponible.
- Battery API cuando esté disponible.
- Capabilities generales del navegador.
- Performance API.
- Timings básicos de navegación.

### Capability Matrix

Generar una matriz similar a:

```text
WebSocket         yes
WebGL             yes
WebGL2            yes
WebGPU            no
IndexedDB         yes
Service Worker    yes
Geolocation       yes
Notifications     yes
Clipboard API     yes
Bluetooth API     no
USB API           no
```

No solicitar permisos innecesarios solo para comprobar capacidades.

---

## 4.2 Geolocalización

Dentro de Recon se utilizarán dos mecanismos.

### GeoIP

Automático sobre la IP observada por el servidor.

Puede usar una base como GeoLite2 u otra alternativa equivalente.

Datos aproximados:

- País.
- Región.
- Ciudad estimada.
- ASN.
- ISP u organización.
- Coordenadas aproximadas si la base las proporciona.

Debe quedar claro en la interfaz que esta información es aproximada.

### Geolocalización del navegador

Usar:

```javascript
navigator.geolocation
```

Solo cuando el usuario acepte explícitamente el permiso mostrado por el navegador.

Guardar:

- Latitude.
- Longitude.
- Accuracy.
- Timestamp.
- Permission state.

No solicitar geolocalización en segundo plano de forma oculta.

La UI debe explicar claramente qué dato se solicita antes de disparar el prompt del navegador.

---

# 5. Honeypot

El honeypot debe ser pasivo.

Su función es observar y registrar peticiones recibidas.

No debe:

- Contraatacar.
- Ejecutar payloads.
- Descargar malware automáticamente.
- Ejecutar archivos recibidos.
- Intentar explotar al cliente.
- Convertirse en un proxy abierto.

Ejemplos de rutas señuelo:

```text
/honeypot/admin
/honeypot/login
/honeypot/wp-login.php
/honeypot/phpmyadmin
/honeypot/.env
/honeypot/.git/config
/honeypot/server-status
/honeypot/api
```

Todas pueden llegar al mismo controlador genérico.

### HoneypotEvent

Guardar:

```text
event_id
timestamp
source_ip
source_port
geoip_country
geoip_region
geoip_city
asn
network_organization
method
path
query_string
selected_headers
user_agent
content_type
body_size
response_status
```

Evitar almacenar datos sensibles innecesarios.

No almacenar credenciales reales introducidas por visitantes.

Para formularios señuelo, registrar únicamente eventos como:

```text
credential_submission_attempt = true
```

sin guardar usuario ni contraseña.

---

# 6. Correlación de eventos

Cada interacción relevante debe poder asociarse a:

```text
session_id
```

Ejemplo:

```text
20:14:01 Browser recon
20:14:09 Windows collector
20:14:12 Script requested
20:14:21 WebSocket connected
20:14:33 Recon completed
```

Para honeypot se puede agrupar tráfico por IP + ventana temporal.

Ejemplo:

```text
20:01:03 GET /
20:01:04 GET /.env
20:01:05 GET /.git/config
20:01:07 GET /wp-login.php
20:01:10 GET /phpmyadmin
```

Debe poder visualizarse como una sola secuencia de actividad.

---

# 7. Collectors

Collectors para dispositivos propios o explícitamente autorizados.

```text
/collector/windows
/collector/linux
```

Los collectors deben ser scripts estáticos, versionados y revisables.

Pueden recolectar, según el caso:

- Hostname.
- Usuario actual.
- Sistema operativo.
- Versión del sistema.
- Arquitectura.
- Interfaces.
- IP local.
- Gateway.
- DNS configurado.
- Uptime.
- Fecha/hora.
- Estado básico del dispositivo.

Enviar resultados únicamente al endpoint definido:

```text
POST /api/collector
```

No implementar ejecución remota arbitraria.

No implementar un endpoint donde el servidor pueda enviar comandos libres a los collectors.

---

# 8. Script Delivery

Rutas:

```text
/scripts/windows/
/scripts/linux/
```

Ejemplos:

```text
/scripts/windows/hello/script.ps1
/scripts/windows/sys/script.ps1
/scripts/windows/network/script.ps1

/scripts/linux/hello/script.sh
/scripts/linux/sys/script.sh
/scripts/linux/network/script.sh
```

Los scripts deben:

- Ser estáticos.
- Estar versionados.
- Ser parte del repositorio.
- Pasar revisión.
- No aceptar código arbitrario desde parámetros HTTP.
- No construir comandos usando entrada del usuario.
- Tener hash SHA-256 publicado.

Opcional:

```text
/scripts/windows/sys/script.ps1.sha256
/scripts/linux/sys/script.sh.sha256
```

No debe existir algo equivalente a:

```text
/scripts/run?command=...
```

ni ningún mecanismo equivalente.

---

# 9. Dashboard

Rutas aproximadas:

```text
/dashboard
/dashboard/recon
/dashboard/honeypot
/dashboard/collectors
/dashboard/scripts
/dashboard/events
/dashboard/ips
/dashboard/network-map
```

## Dashboard Overview

Mostrar:

- Eventos recientes.
- Recon sessions.
- Honeypot hits.
- IPs únicas.
- Países.
- ASN.
- Paths más solicitados.
- User-Agents frecuentes.
- Actividad por hora.

## Network Map

El mapa del honeypot utiliza únicamente GeoIP.

No utiliza ubicación GPS ni precisa del navegador.

Ejemplo:

```text
Costa Rica     12
United States 184
Germany        43
Netherlands    71
Singapore      29
```

---

# 10. Páginas del sitio

Crear páginas explícitas para:

```text
/
/recon
/privacy
/terms
/security
/404
/403
/500
```

## Privacy Policy

Debe explicar:

- Qué datos recopila Recon.
- Qué datos obtiene el servidor automáticamente.
- Qué datos dependen de permisos del navegador.
- Que la geolocalización precisa requiere consentimiento.
- Que GeoIP es aproximado.
- Cuánto tiempo se conservan datos.
- Para qué se utilizan.
- Cómo solicitar eliminación cuando corresponda.

## Security Page

Explicar de forma general:

- El servidor es un laboratorio.
- No se permite uso abusivo.
- No se deben enviar secretos.
- No se deben subir datos sensibles.
- Cómo reportar problemas de seguridad.

No publicar arquitectura interna sensible ni versiones exactas innecesarias.

---

# 11. Manejo de errores

Implementar páginas personalizadas.

## 404

No revelar:

- Framework.
- Stack traces.
- Rutas internas.
- Directorios.
- Configuración.

Respuesta ejemplo:

```text
404
Resource not found.
```

## 403

Respuesta genérica:

```text
403
Access forbidden.
```

No explicar qué archivo existe ni por qué fue bloqueado.

## 500

Nunca devolver stack trace al cliente en producción.

Respuesta:

```text
500
Internal server error.
```

El detalle debe ir únicamente al logging interno.

---

# 12. Seguridad del servidor

La seguridad del servidor es requisito prioritario.

## 12.1 Path Traversal

Prevenir entradas como:

```text
../
../../
..%2f
%2e%2e/
%252e%252e%252f
```

Nunca concatenar directamente paths suministrados por usuarios con paths del filesystem.

Usar allowlists.

Ejemplo conceptual:

```python
ALLOWED_SCRIPTS = {
    "hello": "/app/scripts/windows/hello/script.ps1",
    "sys": "/app/scripts/windows/sys/script.ps1"
}
```

No permitir que un nombre recibido por URL controle directamente una ruta real.

---

## 12.2 File Exposure

Bloquear acceso web a:

```text
.env
.git
.gitignore
docker-compose.yml
Dockerfile
requirements.txt
package.json
package-lock.json
node_modules
venv
__pycache__
logs
backups
database dumps
private keys
SSH keys
certificates private keys
source maps en producción cuando puedan revelar código sensible
```

Nginx debe negar explícitamente dotfiles y archivos sensibles.

---

## 12.3 Secrets

Nunca almacenar secretos en el repositorio.

Usar variables de entorno o Docker secrets.

Ejemplos:

```text
DATABASE_PASSWORD
JWT_SECRET
SESSION_SECRET
GEOIP_LICENSE_KEY
```

Nunca devolver variables de entorno a endpoints de debugging.

No crear endpoints como:

```text
/debug
/env
/config
```

en producción.

---

## 12.4 Debug Mode

Deshabilitado en producción.

FastAPI no debe devolver traceback al usuario.

No montar herramientas administrativas públicas.

---

## 12.5 SQL Injection

Usar ORM o consultas parametrizadas.

Nunca interpolar directamente datos HTTP dentro de SQL.

---

## 12.6 Command Injection

No utilizar:

```python
os.system(user_input)
subprocess(... shell=True ...)
```

con datos controlados por usuarios.

Toda ejecución interna permitida debe utilizar allowlists estrictas.

Idealmente el backend web no debe ejecutar comandos del sistema operativo.

---

## 12.7 SSRF

Cualquier funcionalidad futura que permita consultar URLs o hosts externos debe:

- Usar allowlists.
- Bloquear localhost.
- Bloquear loopback.
- Bloquear link-local.
- Bloquear rangos privados salvo laboratorios explícitamente configurados.
- Bloquear metadata services cloud.

Ejemplos que nunca deben ser accesibles mediante parámetros públicos:

```text
127.0.0.1
::1
169.254.169.254
10.0.0.0/8
172.16.0.0/12
192.168.0.0/16
```

salvo una función administrativa de laboratorio explícitamente aislada.

---

## 12.8 Header Injection

Validar cualquier valor utilizado para construir respuestas HTTP.

No reflejar headers arbitrarios suministrados por el cliente.

---

## 12.9 XSS

Todo contenido capturado por honeypot o recon debe considerarse no confiable.

Ejemplo:

```text
User-Agent
Referer
Path
Query
Origin
```

puede contener payloads HTML/JavaScript.

El dashboard nunca debe renderizarlos como HTML.

Siempre escapar output.

React debe mostrarlo como texto.

Evitar `dangerouslySetInnerHTML`.

---

## 12.10 CSRF

Los endpoints que cambien configuración deben usar protección CSRF cuando corresponda.

APIs autenticadas deben utilizar estrategias adecuadas de tokens/cookies.

---

## 12.11 CORS

No usar:

```text
Access-Control-Allow-Origin: *
```

junto con credenciales.

Configurar únicamente origins necesarios.

---

## 12.12 Rate Limiting

Aplicar límites a:

```text
/api/recon
/api/collector
/honeypot/*
/scripts/*
```

Usar límites diferentes según función.

Prevenir abuso y DoS simple.

---

## 12.13 Request Size Limits

Nginx y FastAPI deben limitar:

- Tamaño del body.
- Tamaño de headers.
- Longitud de URL.
- Número de parámetros.

No existe funcionalidad de upload de archivos en este proyecto.

---

## 12.14 Timeouts

Configurar:

- Client timeout.
- Read timeout.
- Write timeout.
- Upstream timeout.
- Keepalive razonable.

Evitar conexiones indefinidas.

---

## 12.15 Logging Seguro

No registrar:

- Passwords.
- Tokens.
- Cookies de sesión completas.
- Authorization headers.
- API keys.
- Secretos.

Sanitizar logs.

Ejemplo:

```text
Authorization: [REDACTED]
Cookie: [REDACTED]
```

---

## 12.16 Authentication

El dashboard administrativo no debe ser público.

Proteger:

```text
/dashboard/*
/api/admin/*
```

La superficie pública debe limitarse a las funciones deliberadamente públicas.

---

## 12.17 Authorization

Implementar separación clara:

```text
PUBLIC
ADMIN
INTERNAL
```

No confiar únicamente en ocultar URLs.

---

## 12.18 Security Headers

Configurar como mínimo cuando aplique:

```text
Content-Security-Policy
X-Content-Type-Options: nosniff
Referrer-Policy
Permissions-Policy
Strict-Transport-Security
frame-ancestors
```

Evitar headers obsoletos cuando exista una política moderna equivalente.

---

## 12.19 HTTPS

HTTPS obligatorio en producción.

HTTP debe redirigir a HTTPS.

Cookies administrativas:

```text
Secure
HttpOnly
SameSite
```

---

## 12.20 Reverse Proxy

FastAPI no debe estar directamente expuesto a Internet.

Arquitectura:

```text
Internet
   |
 Nginx
   |
FastAPI internal network
```

PostgreSQL tampoco debe exponerse públicamente.

---

## 12.21 Docker

Separar servicios:

```text
frontend
backend
postgres
nginx
```

Principios:

- Ejecutar como usuario no-root cuando sea posible.
- Filesystem read-only donde sea práctico.
- Capabilities mínimas.
- No montar `/` del host.
- No montar Docker socket.
- No utilizar `privileged: true`.
- Redes internas para DB.
- Volúmenes mínimos.
- Imágenes actualizadas.
- Versiones fijadas.

---

# 13. Honeypot Isolation

El honeypot debe compartir la menor cantidad posible de infraestructura con componentes administrativos.

Preferible:

```text
Nginx
 |
 +--> public/recon
 |
 +--> honeypot handler
 |
 +--> admin dashboard [authenticated]
```

El honeypot nunca debe tener:

- Credenciales administrativas.
- Acceso al Docker socket.
- Acceso al filesystem del host.
- Capacidad de ejecutar comandos.
- Acceso de escritura a scripts.
- Acceso directo a secretos.

Los datos capturados deben almacenarse como texto no confiable.

---

# 14. Data Retention

Definir retención desde el inicio.

Ejemplo inicial:

```text
Recon normal:          30 días
Precise geolocation:    7 días
Honeypot events:       90 días
Application logs:      30 días
```

Estos valores deben ser configurables.

La ubicación precisa debería poder deshabilitarse completamente.

---

# 15. Base de datos conceptual

## ReconSession

```text
id
session_id
timestamp
source_ip
geoip_data
browser_location
browser_location_accuracy
browser_data
network_data
capabilities
http_metadata
tls_metadata
```

## HoneypotEvent

```text
id
timestamp
source_ip
geoip_data
asn
method
path
query
selected_headers
user_agent
content_type
body_size
response_status
correlation_id
```

## CollectorEvent

```text
id
session_id
timestamp
source_ip
host_identifier
os
architecture
hostname
network_data
uptime
collector_version
```

---

# 16. No implementar

El proyecto NO debe implementar:

```text
arbitrary remote command execution
shell web
web terminal
arbitrary PowerShell execution
arbitrary Bash execution
file manager
file upload
arbitrary file download
server filesystem browser
remote desktop
credential harvesting
password storage
reverse shell generation
automatic exploitation
malware execution
proxy abierto
port scanner público contra terceros
```

Si en el futuro se añade alguna función sensible, debe tratarse como un módulo separado, local o restringido a hosts de laboratorio explícitamente autorizados.

---

# 17. Estructura propuesta

```text
cyberlab/
|
+-- frontend/
|   +-- src/
|       +-- pages/
|       |   +-- Home
|       |   +-- Recon
|       |   +-- Privacy
|       |   +-- Terms
|       |   +-- Security
|       |   +-- NotFound
|       |   +-- Forbidden
|       |   +-- ServerError
|       |
|       +-- dashboard/
|           +-- Overview
|           +-- Recon
|           +-- Honeypot
|           +-- Collectors
|           +-- Scripts
|           +-- Events
|           +-- NetworkMap
|
+-- backend/
|   +-- app/
|       +-- modules/
|       |   +-- recon/
|       |   +-- honeypot/
|       |   +-- collectors/
|       |   +-- scripts/
|       |   +-- events/
|       |
|       +-- core/
|       |   +-- config.py
|       |   +-- database.py
|       |   +-- security.py
|       |   +-- logging.py
|       |   +-- middleware.py
|       |
|       +-- models/
|       +-- schemas/
|       +-- main.py
|
+-- scripts/
|   +-- windows/
|   +-- linux/
|
+-- nginx/
|   +-- nginx.conf
|
+-- docker/
|
+-- docker-compose.yml
+-- .env.example
+-- README.md
```

---

# 18. Prioridades de implementación

## Fase 1

- Docker Compose.
- Nginx.
- FastAPI.
- PostgreSQL.
- React.
- Configuración segura base.
- Error pages.
- Logging.
- Security headers.
- Rate limits.
- Path traversal protections.

## Fase 2

- `/api/recon`.
- GeoIP.
- Browser capability collection.
- Geolocation con consentimiento.
- ReconSession.
- Página Recon.

## Fase 3

- Honeypot.
- HoneypotEvent.
- Correlación de actividad.
- GeoIP para honeypot.
- Dashboard honeypot.

## Fase 4

- Windows collectors.
- Linux collectors.
- CollectorEvent.
- Script delivery.
- SHA-256 de scripts.

## Fase 5

- Dashboard completo.
- Network map.
- Timeline.
- Statistics.
- Retention jobs.
- Hardening adicional.

---

# 19. Reglas para Codex

Al implementar:

1. No simplificar controles de seguridad.
2. No agregar ejecución arbitraria de comandos.
3. No agregar uploads.
4. No usar paths suministrados por usuarios directamente.
5. No almacenar secretos en el repositorio.
6. No habilitar debug en producción.
7. No exponer PostgreSQL.
8. No exponer FastAPI directamente.
9. Validar toda entrada.
10. Tratar todos los datos de recon y honeypot como contenido hostil.
11. Escapar siempre datos mostrados en el dashboard.
12. Mantener scripts en allowlist.
13. Mantener módulos desacoplados.
14. Toda función pública nueva debe analizarse primero desde perspectiva de abuso.
15. Preferir diseño seguro por defecto.
16. Documentar decisiones importantes.
17. Crear tests para controles de seguridad.
18. Agregar tests específicos para path traversal, XSS almacenado, command injection, SQL injection, headers maliciosos y acceso no autorizado.

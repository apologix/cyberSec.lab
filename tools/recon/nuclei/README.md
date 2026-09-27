# Nuclei — escáner de vulnerabilidades basado en plantillas

Nuclei es el motor de reconocimiento y evaluación web del laboratorio. Recibe uno o varios objetivos y ejecuta plantillas YAML que describen solicitudes, condiciones de coincidencia y criterios de reporte.

No es un escáner de puertos como Nmap ni un reemplazo de OpenVAS. Trabaja principalmente sobre servicios ya identificados, especialmente HTTP/HTTPS, y permite comprobar tecnologías, exposiciones, configuraciones inseguras y vulnerabilidades conocidas.

En este proyecto se ejecuta dentro de Docker con una versión fijada, plantillas persistentes y una red dedicada protegida por ProtonWG y nftables.

## Qué hace

Su flujo es:

`text
Objetivo o lista de objetivos
        ↓
Normalización y descubrimiento de URLs/servicios
        ↓
Selección de plantillas
        ↓
Solicitudes HTTP, DNS, TCP, SSL, headless u otros protocolos
        ↓
Matchers y extractors
        ↓
Resultado en texto o JSONL
`

Una plantilla puede:

- enviar solicitudes GET, POST, PUT u otros métodos;
- comprobar códigos HTTP, cabeceras, cookies, títulos y cuerpos;
- buscar expresiones regulares, palabras, firmas o condiciones DSL;
- identificar versiones y tecnologías;
- comprobar archivos, paneles, endpoints y configuraciones expuestas;
- realizar varias solicitudes relacionadas en un mismo flujo;
- extraer datos de una respuesta y usarlos en otra solicitud;
- ejecutar comprobaciones HTTP, DNS, SSL, red, headless, JavaScript, código o DAST cuando la plantilla lo requiere;
- reportar nombre, severidad, plantilla, objetivo, evidencia y timestamp.

La plantilla define qué se prueba. Nuclei no declara una vulnerabilidad solo porque exista un puerto abierto: necesita que la respuesta coincida con los criterios definidos.

## Tipos de comprobación

| Categoría | Propósito |
|---|---|
| `http/technologies` | Identificar servidores, frameworks, CMS, librerías y tecnologías |
| `http/misconfiguration` | Encontrar configuraciones inseguras o servicios expuestos |
| `http/exposures` | Buscar archivos, paneles, respaldos o información publicada |
| `http/cves` | Comprobar indicadores asociados con CVE conocidas |
| `http/vulnerabilities` | Validar vulnerabilidades específicas de productos |
| `http/default-logins` | Comprobar autenticaciones predeterminadas cuando esté autorizado |
| `http/fuzzing` | Probar rutas o parámetros; requiere alcance y tasa controlados |
| `dns`, `ssl`, `network` | Comprobaciones no limitadas a HTTP |
| `headless`, `javascript`, `code`, `dast` | Flujos que requieren navegador, JavaScript o análisis dinámico |

## Resultados y severidades

- `info`: tecnología o metadato observado; no significa vulnerabilidad.
- `low`, `medium`, `high`, `critical`: severidad asignada por la plantilla cuando la condición coincide.

La severidad es una señal de priorización, no una confirmación automática de impacto. Cada hallazgo debe validarse con producto, versión, endpoint, evidencia de respuesta y alcance autorizado.

La detección de Python y SimpleHTTP realizada en la prueba local fue un resultado `info`, no una vulnerabilidad.

## Estructura

`text
tools/recon/nuclei/
├── docker-compose.yml
├── README.md
├── data/
│   ├── config/             # configuración y estado
│   ├── cache/              # caché generada
│   └── templates/          # plantillas persistentes
└── work/                   # resultados JSONL
`

`data/` y `work/` son datos locales generados. Los resultados finales se
guardan fuera del repositorio siguiendo la convención del caso.

## Imagen y red

| Elemento | Valor |
|---|---|
| Imagen | `projectdiscovery/nuclei:v3.11.1` |
| Motor probado | `v3.11.1` |
| Templates probados | `v10.4.8` |
| Red Docker | `nuclei_nuclei_net` |
| Bridge del host | `nucleibr0` |
| Subred | `172.30.0.0/24` |
| Gateway | `172.30.0.1` |
| IP del contenedor | `172.30.0.2` |
| Tabla de rutas | `51820` |
| Regla de origen | prioridad `120` |

## Modos de red

### Externo: ProtonWG

Es el modo estándar para objetivos fuera de la LAN:

`text
Nuclei 172.30.0.2
    → nucleibr0
    → regla 120
    → tabla 51820
    → protonwg
    → Internet por Proton VPN
`

ProtonWG debe estar activo antes de actualizar plantillas o ejecutar comprobaciones contra objetivos externos.

### Local: LAN autorizada

La tabla `51820` incluye una ruta a `192.168.100.0/24` por `wlp6s0`. El kill switch permite ese rango y bloquea cualquier otra salida directa por Wi-Fi.

### Tor

Tor no se usa como modo estándar de Nuclei. Las plantillas pueden generar múltiples solicitudes, callbacks, DNS, TCP u otros protocolos incompatibles con SOCKS. Si se necesita un proxy para un caso específico, debe documentarse y probarse como excepción.

### ProtonWG apagado

Con ProtonWG apagado, el kill switch bloquea el tráfico externo del contenedor. Así se evita que Nuclei use silenciosamente la conexión normal del host.

## Instalación

Requisitos: Docker Engine activo, Compose v2, NetworkManager, ProtonWG, `iproute2`, `nftables` y systemd.

`bash
cd ./tools/recon/nuclei
mkdir -p data/config data/cache data/templates work
sudo docker compose config
sudo docker compose pull
sudo docker compose run --rm nuclei -version
`

`docker compose pull` descarga la imagen; no ejecuta un escaneo.

## Configuración del host

Añadir la regla de origen, conservando las reglas existentes:

`bash
sudo nmcli connection modify protonwg +ipv4.routing-rules "priority 120 from 172.30.0.2/32 table 51820"
`

Ejemplo de parámetros de laboratorio:

`text
Perfil Wi-Fi: LAB_WIFI_PROFILE
Interfaz:    LAN_INTERFACE
LAN:         LAN_CIDR
Host:        LAB_HOST_IP
`

Si la ruta LAN aún no existe:

`bash
sudo nmcli connection modify 'LAB_WIFI_PROFILE' +ipv4.routes 'LAN_CIDR 0.0.0.0 table=51820'
`

Instalar el kill switch:

`bash
sudo install -m 0644 ./infra/host/nftables-nuclei.conf /etc/nftables-nuclei.conf
sudo install -m 0644 ./infra/host/nuclei-killswitch.service /etc/systemd/system/nuclei-killswitch.service
sudo nft -c -f /etc/nftables-nuclei.conf
sudo systemctl daemon-reload
sudo systemctl enable --now nuclei-killswitch.service
`

## Actualizar plantillas

Las plantillas son el conocimiento que Nuclei ejecuta y se actualizan separadamente del motor:

`bash
cd ./tools/recon/nuclei
nmcli connection up protonwg
sudo docker compose run --rm nuclei -update-templates -update-template-dir /root/nuclei-templates
sudo chown -R "$(id -u):$(id -g)" data/config data/cache data/templates work
sudo docker compose run --rm nuclei -templates-version
`

La actualización requiere Internet y debe realizarse con ProtonWG activo. Si el directorio persistente quedó vacío:

`bash
mv data/config/.templates-config.json data/config/.templates-config.json.bak 2>/dev/null || true
rm -f data/cache/index.gob
sudo docker compose run --rm nuclei -update-templates -update-template-dir /root/nuclei-templates
`

## Comandos de uso

### Un objetivo web

`bash
sudo docker compose run --rm nuclei -t /root/nuclei-templates -u https://AUTHORIZED-TARGET.example -severity medium,high,critical -rate-limit 10 -jsonl-export /work/results.jsonl
`

### Objetivo HTTP local

`bash
sudo docker compose run --rm nuclei -t /root/nuclei-templates -no-interactsh -u http://192.168.100.20 -severity medium,high,critical -rate-limit 10 -jsonl-export /work/local-results.jsonl
`

### Lista de objetivos

Crear `work/targets.txt` con una URL por línea:

`bash
sudo docker compose run --rm nuclei -t /root/nuclei-templates -l /work/targets.txt -severity medium,high,critical -rate-limit 10 -jsonl-export /work/list-results.jsonl
`

### Solo tecnologías

Útil para reconocimiento inicial:

`bash
sudo docker compose run --rm nuclei -t /root/nuclei-templates -tags tech -no-interactsh -duc -u http://192.168.100.20:8080 -severity info -rate-limit 10 -jsonl-export /work/technology-results.jsonl
`

### Categoría específica

`bash
sudo docker compose run --rm nuclei -t /root/nuclei-templates/http/misconfiguration -no-interactsh -u https://AUTHORIZED-TARGET.example -severity low,medium,high,critical -rate-limit 10 -jsonl-export /work/misconfiguration-results.jsonl
`

### Ver plantillas y resultados

`bash
sudo docker compose run --rm nuclei -tl
sudo docker compose run --rm nuclei -tags tech -tl
cat work/results.jsonl
`

## Flujo recomendado con Nmap

`text
1. Confirmar autorización y alcance.
2. Nmap identifica IPs, puertos y servicios.
3. Seleccionar URLs HTTP/HTTPS realmente abiertas.
4. Ejecutar Nuclei con severidades y tasa controladas.
5. Revisar manualmente cada coincidencia.
6. Validar versión, endpoint y evidencia.
7. Guardar JSONL y notas en el caso autorizado.
`

No tiene sentido ejecutar todas las plantillas contra una IP sin servicios web. Comenzar con tecnologías y configuraciones, y ampliar según los servicios observados.

## Interactsh, tasas y seguridad

Algunas plantillas comprueban vulnerabilidades fuera de banda mediante Interactsh. Esto puede generar callbacks hacia infraestructura externa.

Para pruebas locales o de conectividad:

`bash
-no-interactsh
`

Si una vulnerabilidad requiere interacción fuera de banda, el resultado puede no aparecer con Interactsh desactivado.

`-rate-limit` limita solicitudes por segundo, pero algunas plantillas generan varias solicitudes o acceden a endpoints sensibles. Antes de ejecutar:

- usar objetivos autorizados;
- comenzar con reconocimiento y severidades bajas;
- fijar una tasa conservadora;
- evitar fuzzing, headless, callbacks y plantillas intrusivas sin autorización específica;
- revisar alcance, exclusiones y horarios;
- no usar credenciales reales sin autorización;
- no publicar respuestas completas que contengan secretos.

## Limitaciones

- no reemplaza Nmap para descubrimiento de puertos;
- no reemplaza OpenVAS para evaluación amplia;
- un puerto abierto no implica un hallazgo;
- un resultado `info` no implica vulnerabilidad;
- la falta de resultados no prueba que el objetivo sea seguro;
- una IP sin HTTP/HTTPS no produce resultados de plantillas web;
- algunas plantillas necesitan DNS, callbacks, JavaScript o navegador;
- la detección de versión puede ser incompleta o incorrecta;
- `-no-interactsh` no convierte toda plantilla en una prueba puramente local.

## Validación realizada

La validación completa está en [`docs/runbooks/validate-nuclei.md`](../../../docs/runbooks/validate-nuclei.md). En este equipo se confirmó:

| Prueba | Resultado |
|---|---|
| Compose y red | Correctos |
| Plantillas | `v10.4.8`, disponibles en volumen |
| ProtonWG activo | IP pública del contenedor distinta a la del host |
| ProtonWG apagado | Internet externo bloqueado por timeout |
| LAN | Gateway `192.168.100.1` alcanzable |
| HTTP local | Detección de Python/SimpleHTTP |
| Limpieza | Servidor temporal detenido |

La prueba HTTP no representa una vulnerabilidad; confirmó que el contenedor puede alcanzar un servicio local autorizado y reportar tecnología.

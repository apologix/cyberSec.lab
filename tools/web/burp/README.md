# Burp Suite — pruebas web locales y autorizadas

Burp Suite es un proxy de interceptación para aplicaciones web. Se coloca
entre el navegador y el servidor para observar, repetir y modificar solicitudes
HTTP/HTTPS. No es un escáner de red ni debe apuntarse a objetivos sin alcance
autorizado.

## Qué hace

Burp permite:

- ver solicitudes y respuestas HTTP/HTTPS;
- interceptar una solicitud antes de enviarla;
- repetir solicitudes en Repeater;
- organizar objetivos en Target y Proxy history;
- revisar cookies, encabezados, parámetros y respuestas;
- comparar cambios de una petición durante una validación;
- usar extensiones o escaneo activo solo cuando el alcance lo permita.

El tráfico HTTPS se descifra localmente entre el navegador y Burp. Por eso el
certificado CA de Burp solo debe instalarse en un perfil de pruebas, nunca como
una CA de confianza general del sistema.

## Diseño del laboratorio

```text
Firefox/Chromium de pruebas
          ↓ 127.0.0.1:8080
Burp Suite en el host
          ↓
LAN autorizada o internet por el perfil aprobado
```

Burp se mantiene en el host por su GUI y por la integración con el navegador.
El repositorio guarda documentación, no el instalador, licencia, proyecto de
Burp ni certificado privado.

## Modos de red

### LAN

Para una aplicación propia en `192.168.100.0/24`, Burp y el navegador usan la
ruta normal del host. No se usa Tor ni se necesita ProtonWG.

### Externo

Solo contra un objetivo autorizado. La política del laboratorio exige que el
flujo externo use ProtonWG. Como `protonwg` está configurado como ruta no
predeterminada, activar la conexión no garantiza por sí solo que el navegador
del host cambie de ruta. Antes de usar un objetivo externo hay que confirmar la
ruta efectiva del navegador/Burp mediante una prueba controlada.

No se documentará Burp como “protegido por ProtonWG” hasta completar esa
prueba. La validación inicial de este directorio es LAN y offline.

### Tor

No es el modo predeterminado. Burp puede trabajar con un proxy upstream en
casos TCP concretos, pero Tor no sustituye una ruta IP completa y no debe usarse
para afirmar que Kerberos, UDP, escaneo o tráfico no HTTP están cubiertos.

## Instalación

Descargar Burp Suite Community o Professional desde PortSwigger y conservar el
instalador fuera del repositorio. En Debian, verificar Java y ejecutar el
instalador descargado desde `~/Downloads`:

```bash
java -version
find "$HOME/Downloads" -maxdepth 1 -type f -iname 'burpsuite*.sh' -print
```

La versión y la licencia dependen de la edición elegida. No guardar claves,
tokens ni instaladores propietarios en Git.

## Configuración inicial de Burp

1. Abrir Burp y crear un proyecto temporal o un proyecto local fuera del repo.
2. Mantener el listener en `127.0.0.1:8080`.
3. En `Proxy > Intercept`, dejar `Intercept off` para navegación normal.
4. Encender `Intercept` únicamente cuando se quiera detener una solicitud.
5. En `Target > Scope`, añadir solo los hosts y puertos autorizados.
6. Activar el filtro de historial para mostrar únicamente el alcance.
7. Desactivar escaneo activo y extensiones no necesarias durante la primera
   validación.

El listener debe quedar limitado a `127.0.0.1`; no exponer Burp en `0.0.0.0`.

## Configuración del navegador

Configurar un perfil de navegador dedicado, no el perfil personal:

| Campo | Valor |
|---|---|
| Proxy HTTP | `127.0.0.1` |
| Puerto HTTP | `8080` |
| Proxy HTTPS | `127.0.0.1` |
| Puerto HTTPS | `8080` |
| SOCKS | vacío, salvo excepción documentada |
| No proxy para LAN | solo si el caso lo exige y está documentado |

Para Firefox: `Settings > Network Settings > Manual proxy configuration`.
Marcar el uso del proxy para HTTPS y no reutilizar este perfil para banca,
correo o navegación personal.

También se puede usar el navegador integrado de Burp, que ya viene preparado
para su listener. Es la opción preferida para la primera prueba.

## Certificado CA de Burp

Solo es necesario para un navegador externo. Con Burp ejecutándose y el proxy
configurado, abrir `http://burpsuite` y descargar `CA Certificate`. Importarlo
como autoridad de confianza únicamente en el perfil de pruebas.

Al terminar un proyecto, retirar esa CA del perfil o eliminar el perfil. No
subir el certificado ni su clave privada a Git. Burp genera una CA única por
instalación; proteger los archivos locales porque quien obtenga la clave podría
interceptar ese perfil.

## Primera prueba segura

Levantar una aplicación web propia o un servidor de prueba en la LAN. En Burp,
dejar `Intercept off`, abrir el navegador integrado y visitar, por ejemplo,
`http://192.168.100.20:8080` cuando esa IP exista y esté autorizada.

Confirmar:

- la solicitud aparece en `Proxy > HTTP history`;
- el host está dentro de `Target > Scope`;
- el navegador recibe la respuesta;
- no aparecen dominios externos inesperados;
- el listener sigue escuchando solo en `127.0.0.1:8080`.

Para una prueba local reproducible se puede usar temporalmente:

```bash
mkdir -p /tmp/burp-web-test
printf '%s\n' 'Burp local test' > /tmp/burp-web-test/index.html
python3 -m http.server 8080 --bind 127.0.0.1 --directory /tmp/burp-web-test
```

Visitar `http://127.0.0.1:8080` desde el navegador de pruebas y detener el
servidor con `Ctrl+C`.

## Flujo de trabajo

```text
1. Confirmar autorización y alcance.
2. Abrir el perfil de navegador de pruebas.
3. Confirmar listener 127.0.0.1:8080.
4. Configurar Target Scope.
5. Navegar primero con Intercept off.
6. Revisar Proxy history.
7. Repetir solicitudes puntuales en Repeater.
8. Guardar notas y evidencia fuera del repositorio, nunca en `tools/web`.
9. Cerrar Burp y retirar la CA si el perfil ya no se usará.
```

## Seguridad y límites

- Usar únicamente aplicaciones propias o expresamente autorizadas.
- No enviar contraseñas reales a Repeater o Intruder sin autorización.
- No usar Intruder, Scanner, Collaborator ni extensiones activas fuera del
  alcance aprobado.
- No guardar proyectos Burp con cookies, tokens o credenciales en Git.
- No usar el navegador de pruebas para cuentas personales.
- No asumir que la VPN protege Burp sin comprobar la ruta efectiva.
- No exponer el listener en la LAN.

## Referencias oficiales

- [Instalación de Burp Suite](https://portswigger.net/burp/documentation/desktop/getting-started/download-and-install)
- [Burp Proxy](https://portswigger.net/burp/documentation/desktop/tools/proxy)
- [Certificado CA](https://portswigger.net/burp/documentation/desktop/external-browser-config/certificate)

# Validación de Burp Suite

## Objetivo

Validar la instalación local, el listener, la integración del navegador y una
aplicación de prueba propia sin generar tráfico contra objetivos externos.

## Comprobaciones del host

Con Burp abierto en `127.0.0.1:8080`:

```bash
ss -lntp | grep ':8080'
curl -I -x http://127.0.0.1:8080 http://burpsuite
```

Debe aparecer un listener local. No debe aparecer `0.0.0.0:8080` ni una IP de
la LAN como dirección de escucha.

## Prueba local

En una terminal:

```bash
rm -rf /tmp/burp-web-test
mkdir -p /tmp/burp-web-test
printf '%s\n' 'Burp local test' > /tmp/burp-web-test/index.html
python3 -m http.server 8080 --bind 127.0.0.1 --directory /tmp/burp-web-test
```

La prueba debe abrirse desde el navegador integrado de Burp o desde un perfil
externo configurado con `127.0.0.1:8080`. Confirmar la petición en `Proxy > HTTP
history` y detener el servidor con `Ctrl+C`.

## Validación LAN futura

Cuando exista una aplicación web autorizada en la LAN:

```bash
read -r -p 'URL LAN autorizada: ' TARGET
curl -I --max-time 10 -x http://127.0.0.1:8080 "$TARGET"
```

Confirmar que el objetivo está dentro de `192.168.100.0/24` y dentro de
`Target > Scope` en Burp.

## Validación externa futura

No ejecutar esta prueba hasta documentar un objetivo autorizado. Como
ProtonWG usa una tabla no predeterminada, primero se debe diseñar y validar el
mecanismo que hará que el navegador/Burp use ProtonWG. Activar ProtonWG no es
una prueba suficiente.

## Resultado esperado

| Prueba | Resultado |
|---|---|
| Listener | Solo `127.0.0.1:8080` |
| Navegador | Solicitud visible en HTTP history |
| HTTPS | CA instalada solo en perfil de pruebas |
| LAN | Objetivo autorizado accesible |
| Externo | Pendiente de validar ruta efectiva por ProtonWG |
| Tor | No usado por defecto |

# Validación completa de Nuclei

Estas pruebas no ejecutan un escaneo de vulnerabilidades. Verifican que el contenedor tenga la red y las restricciones esperadas.

## Preparación

```bash
cd ./tools/recon/nuclei
sudo docker compose config
sudo docker network inspect nuclei_nuclei_net >/dev/null
find data/templates -type f -name '*.yaml' | wc -l
sudo nft list table inet nuclei_killswitch
```

La cantidad de plantillas debe ser mayor que cero y el bridge debe existir como `nucleibr0`.

## ProtonWG activo: salida externa

```bash
nmcli connection up protonwg
sudo docker run --rm --network nuclei_nuclei_net --ip 172.30.0.2 busybox:1.36.1 wget -qO- --timeout=10 https://api.ipify.org
echo
```

La salida debe ser una IP pública de Proton, no la IP normal del host.

Comprobar la ruta seleccionada:

```bash
ip route get 1.1.1.1 from 172.30.0.2 iif nucleibr0
```

Debe utilizar la tabla `51820` y `protonwg`.

## ProtonWG apagado: bloqueo de salida

```bash
nmcli connection down protonwg
sudo timeout 15 docker run --rm --network nuclei_nuclei_net --ip 172.30.0.2 busybox:1.36.1 wget -qO- --timeout=10 https://api.ipify.org
echo $?
```

El comando debe fallar o terminar por timeout. No debe mostrar una IP pública.

## LAN autorizada

El gateway observado en este equipo es `192.168.100.1`. Si el gateway cambia, sustituirlo por el valor que muestre `ip route`.

```bash
sudo docker run --rm --network nuclei_nuclei_net --ip 172.30.0.2 busybox:1.36.1 ping -c 2 -W 3 192.168.100.1
```

Esta prueba debe funcionar con ProtonWG activo y apagado, siempre que el gateway responda ICMP. Si ICMP está bloqueado, comprobar un servicio TCP autorizado de la LAN.

## Escaneo de prueba HTTP

Para probar detección sin servir el repositorio, usar una carpeta temporal vacía:

```bash
rm -rf /tmp/nuclei-http-test
mkdir -p /tmp/nuclei-http-test
echo 'Nuclei test' > /tmp/nuclei-http-test/index.html
cd /tmp/nuclei-http-test
python3 -m http.server 8080 --bind 0.0.0.0 >/tmp/nuclei-http-test.log 2>&1 &
SERVER_PID=$!
sleep 2

cd ./tools/recon/nuclei
sudo docker compose run --rm nuclei -t /root/nuclei-templates -tags tech -no-interactsh -duc -u http://192.168.100.10:8080 -severity info -rate-limit 10 -jsonl-export /work/nuclei-test.jsonl

kill "$SERVER_PID" 2>/dev/null || true
```

El resultado esperado es la detección de Python/SimpleHTTP. Eso valida conectividad y ejecución; no representa una vulnerabilidad.

## Criterio de aprobación

| Prueba | Resultado esperado |
|---|---|
| Compose | Configuración válida |
| Plantillas | Más de cero archivos YAML |
| ProtonWG activo | IP pública de Proton |
| ProtonWG apagado | Internet externo bloqueado |
| LAN | Acceso solo al rango autorizado |
| HTTP temporal | Detección tecnológica y JSONL generado |

## Resultado de la validación de este equipo

La prueba realizada el 27 de agosto de 2026 confirmó todos los criterios:

- Con ProtonWG activo, el host mostró su salida normal y el contenedor mostró una IP diferente correspondiente a Proton.
- Con ProtonWG apagado, la prueba HTTPS desde `172.30.0.2` terminó en timeout y no hubo salida directa por Wi-Fi.
- El gateway `192.168.100.1` respondió desde el contenedor con cero pérdida de paquetes.
- La prueba HTTP temporal fue detectada como `Python` y `SimpleHTTP`, ambas con severidad `info`.
- El archivo JSONL se generó correctamente.
- El servidor temporal se detuvo al finalizar.

La prueba de Internet con BusyBox muestra una advertencia de que esa imagen no valida certificados TLS. Esa advertencia no afecta la prueba de enrutamiento y conectividad; para validar certificados se debe usar una imagen con cliente TLS completo.

Al terminar, dejar ProtonWG en el estado operativo habitual y eliminar el servidor temporal si siguiera activo.

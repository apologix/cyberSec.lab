# Scapy — paquetes y laboratorio local de MITM

Scapy es una biblioteca y consola Python para construir, enviar, recibir y
analizar paquetes. En este proyecto se usa localmente para aprender protocolos,
validar controles de red y realizar prácticas de MITM únicamente en una LAN o
laboratorio aislado y autorizado.

## Decisión de arquitectura

Scapy no tendrá un perfil remoto ni una ruta ProtonWG. Su función principal es
interactuar con interfaces y segmentos locales. No se dockeriza como herramienta
operativa porque el acceso a interfaces reales, captura, ARP y paquetes de bajo
nivel se vuelve menos claro y exige privilegios adicionales.

La reproducibilidad se obtiene mediante scripts versionados sin credenciales.

## Usos previstos

- construir y analizar paquetes en un entorno controlado;
- validar respuestas de protocolos de la LAN;
- estudiar ARP, ICMP, TCP y UDP con objetivos propios;
- crear ejercicios de MITM en un laboratorio aislado;
- leer y analizar PCAP localmente;
- preparar paquetes de prueba para comparar con Wireshark.

Scapy no reemplaza Nmap, Nuclei, Wireshark, Bettercap, Suricata o Zeek.

## Red y privacidad

| Caso | Política |
|---|---|
| LAN/laboratorio | Ruta local por `wlp6s0`; objetivo autorizado |
| Externo/remoto | No soportado por este proyecto |
| ProtonWG | No se usa para Scapy |
| Tor/ProxyChains | No compatible con raw sockets, ARP ni captura |
| PCAP/archivos | Offline |

Antes de enviar paquetes, definir las IP, interfaces, duración y técnica
aprobadas. No practicar en redes públicas, equipos de terceros o producción.

## MITM autorizado

MITM significa aquí un ejercicio controlado donde todos los dispositivos,
cuentas y flujos pertenecen al laboratorio o tienen autorización explícita.
El laboratorio debe permitir restaurar la conectividad y registrar topología,
interfaz, hora, tráfico esperado y procedimiento de recuperación.

No se documentan comandos de envenenamiento ARP ni interceptación contra
terceros. La práctica requiere un segmento aislado y un plan de restauración.

## Privilegios y flujo seguro

La captura y el envío pueden requerir permisos elevados. Usar el mínimo
privilegio posible y verificar la interfaz antes de cada práctica:

```bash
ip -br address
ip route
```

```text
1. Aislar el laboratorio.
2. Confirmar autorización y alcance.
3. Identificar interfaz y objetivo.
4. Capturar una línea base sin modificar tráfico.
5. Ejecutar una prueba mínima y observable.
6. Comparar PCAP y logs.
7. Restaurar la red.
8. Guardar evidencia fuera del repositorio, en el directorio de caso configurado.
```

## Validación inicial sin enviar tráfico

```bash
python3 -m venv ~/.venvs/cybersec-scapy
~/.venvs/cybersec-scapy/bin/python -m pip install --upgrade pip scapy
~/.venvs/cybersec-scapy/bin/python -c 'from scapy.all import IP, ICMP; print(IP(dst="127.0.0.1")/ICMP())'
```

La última línea solo construye un paquete en memoria. Para análisis de PCAP,
usar una copia autorizada y conservar el original sin modificar.

## Relación con otras herramientas

- `Wireshark`: inspección gráfica y validación visual de capturas.
- `Bettercap`: automatización interactiva; se documentará aparte con controles
  más estrictos.
- `Suricata`: detección basada en reglas y alertas.
- `Zeek`: metadatos y visibilidad de protocolos.
- `Scapy`: experimentación programable y paquetes personalizados.

## Límites

- Sin escaneo remoto ni objetivos de internet.
- Sin Tor, ProxyChains o ProtonWG.
- Sin MITM fuera del laboratorio autorizado.
- No guardar secretos, capturas sensibles o MAC/IP reales en Git.
- Detener la práctica si cambia la topología o aparece tráfico inesperado.

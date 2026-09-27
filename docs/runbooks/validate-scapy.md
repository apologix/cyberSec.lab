# Validación de Scapy local

## Objetivo

Validar la instalación y la construcción de paquetes sin enviar tráfico ni
usar objetivos remotos. Scapy se reserva para la LAN autorizada y laboratorios
locales de MITM.

## Instalación y prueba sin red

```bash
python3 -m venv ~/.venvs/cybersec-scapy
~/.venvs/cybersec-scapy/bin/python -m pip install --upgrade pip scapy
~/.venvs/cybersec-scapy/bin/python -c 'from scapy.all import IP, ICMP; print(IP(dst="127.0.0.1")/ICMP())'
```

La última línea debe imprimir un paquete IP/ICMP y no realiza un envío.

## Interfaz

```bash
ip -br address
ip route
```

Confirmar que la interfaz pertenece al laboratorio autorizado y que no se está
usando `protonwg` para una práctica LAN.

## MITM

No se considera validado un ejercicio MITM solo porque Scapy importe. Se
necesita un laboratorio aislado, autorización escrita, dispositivos propios y
un procedimiento de restauración. La validación MITM se documentará como
experimento separado cuando exista ese laboratorio.

## Resultado esperado

| Prueba | Resultado |
|---|---|
| Importación | Scapy crea un paquete en memoria |
| Interfaz | LAN autorizada identificada |
| Remoto | No soportado por este perfil |
| ProtonWG/Tor | No usados |
| MITM | Pendiente de laboratorio aislado |

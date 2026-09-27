# enum4linux-ng — enumeración autorizada de Windows, Samba y SMB

`enum4linux-ng` es una herramienta de enumeración para sistemas Windows y Samba. Reúne y normaliza información obtenida mediante clientes Samba, RPC, LDAP y consultas relacionadas. Es especialmente útil después de que Nmap confirme que un objetivo expone SMB, NetBIOS, RPC o LDAP.

La herramienta es principalmente un wrapper de `nmblookup`, `net`, `rpcclient` y `smbclient`. También implementa comprobaciones LDAP y polenum, y puede exportar los resultados completos a JSON o YAML.

## Qué información puede obtener

Según lo que permita el objetivo y las credenciales disponibles, puede revisar:

- nombre NetBIOS, nombre de máquina y dominio/workgroup;
- información del sistema Windows o Samba;
- dominio, SID y políticas de contraseña;
- usuarios, grupos y miembros de grupos;
- recursos compartidos y permisos visibles;
- sesiones, transporte y servicios RPC;
- información de LDAP cuando el servicio está disponible;
- soporte de SMBv1, dialectos SMB y firma SMB;
- información de impresoras y otros recursos publicados;
- rangos RID y posibles identificadores de cuentas;
- datos en texto, JSON o YAML para análisis posterior.

El resultado depende de la configuración del servidor, el firewall, la versión SMB, el acceso anónimo y las credenciales. Un resultado vacío no demuestra que el host no tenga usuarios, recursos o vulnerabilidades.

## Cómo funciona

```text
Objetivo Windows/Samba
        ↓
Detección de SMB/NetBIOS/RPC/LDAP
        ↓
Ejecución de comprobaciones seleccionadas
        ↓
Parseo de respuestas de Samba/RPC/LDAP
        ↓
Consola + exportación JSON/YAML opcional
```

La opción `-A` realiza la enumeración general. La opción `-As` usa enumeración inteligente y desactiva comprobaciones que probablemente fallarían según lo detectado. La herramienta también permite activar áreas concretas como servicios, usuarios, grupos, shares, políticas, sistema, LDAP o RID cycling.

## Opciones principales

| Opción | Función |
|---|---|
| `-A` | Enumeración general |
| `-As` | Enumeración general inteligente |
| `-U` | Enumeración de usuarios |
| `-G` | Enumeración de grupos |
| `-Gm` | Miembros de grupos |
| `-S` | Recursos compartidos |
| `-C` | Servicios |
| `-P` | Políticas de contraseña |
| `-O` | Información del sistema operativo |
| `-L` | LDAP |
| `-I` | Información adicional |
| `-R` | RID cycling; puede generar muchas consultas |
| `-u USER` | Usuario autorizado |
| `-p PASSWORD` | Contraseña; evitar dejarla en el historial |
| `-H NTHASH` | Autenticación mediante NT hash autorizado |
| `-K FILE` | Ticket Kerberos autorizado |
| `--local-auth` | Autenticación local en lugar de dominio |
| `-w DOMAIN` | Dominio de autenticación |
| `-t SECONDS` | Timeout |
| `-v` | Salida detallada |
| `--keep` | Conserva comandos/salidas para diagnóstico |
| `-oJ FILE` | Exporta JSON |
| `-oY FILE` | Exporta YAML |
| `-oA PREFIX` | Exporta formatos asociados con un prefijo |

Consultar todas las opciones de la versión instalada:

```bash
sudo docker compose run --rm enum4linux --help
```

## Imagen y red

| Elemento | Valor |
|---|---|
| Fuente | `github.com/cddmp/enum4linux-ng` |
| Versión | `v1.3.10` |
| Imagen local | `cybersec/enum4linux-ng:v1.3.10` |
| Bridge | `enum4linuxbr0` |
| Red Compose | `enum4linux-ng_enum4linux_net` |
| Subred | `172.31.0.0/24` |
| Contenedor | `172.31.0.2` |
| Tabla VPN | `51820` |
| Regla | prioridad `130` |

La imagen incluye Python, `smbclient`, `rpcclient`, `nmblookup`, `net`, `ldapsearch` y las dependencias Python declaradas por el proyecto.

## Modos de red

### LAN local

Usar para un dominio, servidor Windows o Samba de la red autorizada. La tabla `51820` tiene una excepción a `192.168.100.0/24` y el kill switch permite únicamente ese destino directo por `wlp6s0`.

### Objetivo externo

Usar ProtonWG. La IP `172.31.0.2` se dirige a la tabla `51820`, que utiliza `protonwg` como salida. Esto conserva SMB/RPC/LDAP como tráfico IP normal; no se intenta forzarlo mediante Tor.

### Tor

No usar Tor como modo general. SMB, RPC, LDAP, NetBIOS, Kerberos y consultas UDP no son un flujo apropiado para SOCKS. Si un caso requiere un proxy, debe documentarse como excepción independiente.

## Instalación

Desde el directorio de la herramienta:

```bash
cd ./tools/windows/enum4linux-ng
mkdir -p work
sudo docker compose build --pull
sudo docker compose run --rm enum4linux --help
```

La compilación descarga la versión fijada del repositorio oficial y las dependencias de la imagen. No ejecuta consultas contra ningún objetivo.

## Configuración del host

Añadir la regla de policy routing, conservando OpenVAS, Metasploit y Nuclei:

```bash
sudo nmcli connection modify protonwg +ipv4.routing-rules "priority 130 from 172.31.0.2/32 table 51820"
```

Instalar y activar el kill switch:

```bash
sudo install -m 0644 ./infra/host/nftables-enum4linux.conf /etc/nftables-enum4linux.conf
sudo install -m 0644 ./infra/host/enum4linux-killswitch.service /etc/systemd/system/enum4linux-killswitch.service
sudo nft -c -f /etc/nftables-enum4linux.conf
sudo systemctl daemon-reload
sudo systemctl enable --now enum4linux-killswitch.service
```

Para la LAN, la tabla `51820` también debe tener la ruta local:

```bash
sudo nmcli connection modify 'LAB_WIFI_PROFILE' +ipv4.routes 'LAN_CIDR 0.0.0.0 table=51820'
```

## Uso sin credenciales

Usar únicamente contra un equipo propio o expresamente autorizado:

```bash
sudo docker compose run --rm enum4linux -As 192.168.100.20 -oA /work/enum4linux-lan
```

La salida se guardará en `work/enum4linux-lan.*`.

Enumeración general explícita:

```bash
sudo docker compose run --rm enum4linux -A 192.168.100.20 -oY /work/enum4linux-general
```

Comprobar solo recursos compartidos y servicios:

```bash
sudo docker compose run --rm enum4linux -S -C 192.168.100.20 -oJ /work/enum4linux-services.json
```

## Uso con credenciales

No escribir contraseñas en comandos que quedarán en el historial. Para una prueba puntual, desactivar el historial de esa línea o usar un procedimiento local controlado:

```bash
read -r -s -p 'Contraseña autorizada: ' PASS
echo
sudo docker compose run --rm enum4linux -A -u 'USUARIO_AUTORIZADO' -p "$PASS" 192.168.100.20 -oJ /work/enum4linux-auth.json
unset PASS
```

El argumento puede ser visible temporalmente en la lista de procesos. No usar credenciales reales fuera del alcance autorizado.

## Flujo recomendado con Nmap

```text
1. Confirmar alcance y autorización.
2. Nmap verifica 139/tcp, 445/tcp, 389/tcp, 88/tcp u otros servicios relevantes.
3. Identificar si es Windows, Samba, dominio o workgroup.
4. Comenzar con -As y timeout conservador.
5. Ejecutar áreas específicas solo cuando sean necesarias.
6. Guardar JSON/YAML y salida de consola en el caso.
7. Validar manualmente usuarios, shares, políticas y versiones.
```

No comenzar con RID cycling, pruebas de credenciales, enumeración masiva o SMBv1 si no está expresamente autorizado.

## Validación de la instalación

La prueba inicial de la imagen no necesita un objetivo:

```bash
sudo docker compose config
sudo docker compose run --rm enum4linux --help
```

Las pruebas de red deben hacerse contra un Windows/Samba de laboratorio autorizado. Deben verificar:

| Estado | Resultado |
|---|---|
| ProtonWG activo | Objetivo externo alcanzable por Proton |
| ProtonWG apagado | Objetivo externo bloqueado, sin salida por Wi-Fi |
| LAN | Servidor autorizado alcanzable por `192.168.100.0/24` |
| Exportación | JSON/YAML creado en `work/` |

La prueba realizada en este equipo validó ProtonWG, LAN y bloqueo de salida. El gateway `192.168.100.1` no expone SMB ni LDAP, por lo que el programa terminó después de la comprobación de listeners; ese resultado es esperado y no constituye un hallazgo.

## Limitaciones y seguridad

- El acceso anónimo puede estar deshabilitado.
- Firewall, SMB signing, SMBv1, DNS y resolución NetBIOS afectan los resultados.
- Kerberos y LDAP requieren DNS y parámetros de dominio correctos.
- Tor no es un transporte adecuado para esta herramienta.
- Enumerar usuarios, grupos o shares puede generar eventos en los logs del objetivo.
- RID cycling puede producir muchas consultas y debe limitarse.
- No interpretar un dato enumerado como vulnerabilidad sin validación.
- No usar password spraying, fuerza bruta, credenciales por defecto ni explotación desde esta guía.
- Los resultados pueden contener nombres de usuarios, shares, dominios y otra información sensible; guardarlos fuera del repositorio en el directorio de casos configurado.

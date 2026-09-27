# Forensics

Forensics usa predominantemente `offline`: no modifica la ruta del host ni
necesita acceso a Internet. Evite escribir sobre evidencia; monte imágenes y
dumps en solo lectura cuando una herramienta lo permita, calcule hashes antes
y después del análisis y registre cada operación con `scripts/case-run.sh`.

| Área | Herramientas iniciales | Entorno |
|---|---|---|
| Integridad | `sha256sum`, `hashdeep` | Host/offline |
| Filesystem | The Sleuth Kit; Autopsy opcional con interfaz gráfica | Host/offline |
| Metadata | ExifTool | Host/offline |
| PCAP | Wireshark, TShark, Zeek | Host/offline |
| Timeline | Plaso/log2timeline | Host/offline |
| Memoria | Volatility 3 | Host/offline |

Autopsy se mantiene como opción manual en el host por su interfaz gráfica: no
forma parte del instalador mínimo. El resto puede añadirse progresivamente
mediante paquetes locales; no se incluyen imágenes Docker que oculten o copien
evidencia.

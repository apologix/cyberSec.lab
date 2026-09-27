# Validar forensics offline

No conecte la estación de análisis a redes innecesarias. Trabaje sobre una copia
de evidencia y monte las imágenes como solo lectura.

Instalación local opcional:

```bash
bash scripts/install-forensics-tools.sh
bash scripts/verify-forensics-tools.sh
```

```bash
sha256sum EVIDENCE_FILE
exiftool EVIDENCE_FILE
```

Guarde hashes, herramienta, versión y rutas de entrada/salida en el caso. Nunca
copie dumps, imágenes de disco o PCAP al repositorio ni a una imagen Docker.

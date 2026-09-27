# Casos, evidencia y correlación

Los casos nuevos se almacenan fuera del repositorio, en `CYBERSEC_CASES_DIR`.
Si la variable no está definida, el valor seguro y portátil es el directorio
hermano `../cases`. Los casos, resultados y evidencia no se versionan.

Crear un caso:

```bash
./scripts/new-case.sh CASE-2026-001
```

La plantilla separa los resultados originales (`raw/`) de la evidencia
seleccionada (`evidence/`). El wrapper `scripts/case-run.sh` registra timestamp,
caso, herramienta, objetivo, modo de red, acción, resultado y ruta de salida
en `metadata/logs/operations.jsonl`. Defina `CYBERSEC_CASE_TARGET` al
invocarlo cuando el objetivo se pueda registrar. No registra argumentos para no
filtrar secretos.

```bash
CYBERSEC_CASE_TARGET=192.0.2.15 \
  ./scripts/case-run.sh CASE-2026-001 local nmap raw/nmap/host.xml -- \
  nmap -oX raw/nmap/host.xml 192.0.2.15
```

`metadata/entities.json` representa entidades y relaciones. Las confianzas son
`unverified`, `possible`, `probable` y `confirmed`. Una coincidencia de correo,
username o perfil no prueba una identidad; cada relación debe conservar fuente,
fecha, referencia de evidencia y notas.

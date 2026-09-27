# Estructura del repositorio

El repositorio separa la infraestructura reproducible de la evidencia de cada caso.

```text
.
├── README.md
├── .env.example
├── docs/
│   ├── architecture/
│   ├── guides/
│   ├── runbooks/
├── infra/host/                 # nftables, systemd y notas de red del host
├── tools/
│   ├── recon/
│   ├── osint/
│   ├── tls/
│   ├── forensics/
│   ├── vulnerabilities/
│   ├── windows/
│   ├── web/
│   ├── network/
│   ├── visibility/
│   └── validation/
├── scripts/                    # instaladores y verificadores reproducibles
├── templates/case/              # estructura sin datos reales
├── lab/                         # objetivos y pruebas controladas
└── (casos fuera de Git)          # evidencia y resultados no versionados
```

## Convenciones

- Cada herramienta nueva debe tener su propio directorio y un README corto.
- Un `Dockerfile` o `compose.yaml` describe instalación y ejecución; la configuración local va en `.env` o fuera del repositorio.
- Las guías deben indicar explícitamente si el flujo es `local`, `vpn`, `tor` u `offline`.
- `scripts/` contiene automatización transversal del laboratorio: instalación,
  comprobaciones de dependencias, validación de red y reprovisionamiento.
- Los scripts deben ser idempotentes cuando sea posible, explicar los cambios
  que realizan y no guardar contraseñas, tokens, certificados ni objetivos.
- Los casos nuevos se guardan fuera del repositorio en `CYBERSEC_CASES_DIR`; los
  resultados se montan desde allí y nunca dentro de una imagen Docker.

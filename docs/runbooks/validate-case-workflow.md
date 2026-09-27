# Validar el flujo de casos

Esta validación no necesita red, Docker ni privilegios.

```bash
./scripts/new-case.sh CASE-2026-001
CYBERSEC_CASE_TARGET=archivo-de-prueba \
  ./scripts/case-run.sh CASE-2026-001 offline validation raw/validation/echo.txt -- \
  sh -c 'echo ok > raw/validation/echo.txt'
```

Compruebe que se creó el árbol con permisos restrictivos y que
`metadata/logs/operations.jsonl` contiene una línea JSON con objetivo, modo,
acción, estado y salida. Repita el primer
comando: debe fallar sin sobrescribir el caso existente. Elimine el caso de
prueba manualmente solo después de verificar que no contiene evidencia real.

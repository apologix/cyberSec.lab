# Herramientas web

## Burp Suite

Burp Suite se ejecuta localmente en el host porque necesita interfaz gráfica,
integración con el navegador y su propia autoridad certificadora para
inspeccionar HTTPS.

La documentación está en [`burp/README.md`](burp/README.md). La validación
repetible está en [`docs/runbooks/validate-burp.md`](../../docs/runbooks/validate-burp.md).

Burp no se dockeriza en esta fase. El host puede probar aplicaciones de la LAN
y, para objetivos externos autorizados, se debe usar el perfil de navegador
aprobado junto con la política de ProtonWG documentada.

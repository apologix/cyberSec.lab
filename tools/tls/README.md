# TLS

El perfil `tls-runner` usa testssl.sh y OpenSSL para revisar versiones, suites,
certificados, cadena, expiración y configuración HTTPS de servicios en alcance.
El modo es `local` para LAN autorizada y `vpn` para destinos externos. No se
usa Tor por defecto: la validación puede requerir resolución, SNI y flujos que
no son apropiados para SOCKS.

Exporte las salidas originales a `CASE/raw/tls/`; valide cualquier resultado
antes de elevarlo a un hallazgo.

La imagen oficial usa la etiqueta estable `ghcr.io/testssl/testssl.sh:3.2`.
La etiqueta no representa una versión de parche inmutable; se debe revisar y
registrar el digest antes de una actualización reproducible.

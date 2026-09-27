# Cybersecurity Lab

Repositorio de portafolio para un laboratorio reproducible de ciberseguridad.
Muestra diseño de red, automatización, verificación de controles y una
plataforma de telemetría defensiva para entornos de práctica autorizados.

> Uso ético: ejecutar estas configuraciones únicamente contra sistemas propios,
> simulados o con autorización explícita. Este repositorio no contiene casos,
> objetivos, resultados, credenciales ni evidencia de terceros.

## Capacidades demostradas

- Aislamiento de herramientas con Docker, policy routing y *kill switches* de
  `nftables` para evitar salida directa cuando la VPN no está disponible.
- Flujos diferenciados para trabajo local, VPN, Tor y análisis sin red.
- Automatización de instalación y verificaciones reproducibles para análisis de
  red, vulnerabilidades, TLS, forense, visibilidad y Windows/SMB.
- CyberLab Server: API FastAPI, PostgreSQL, interfaz React, proxy Nginx,
  autenticación, retención de datos y telemetría defensiva.
- Plantillas de caso que separan alcance, evidencia, resultados y trazabilidad.

## Arquitectura

```text
                 Cybersecurity Lab
                         |
        +----------------+----------------+
        |                                 |
  Infraestructura                    Herramientas
  Docker · nftables                  Recon · TLS · Forense
  policy routing · VPN               Visibilidad · Windows · Web
        |                                 |
        +----------- controles -----------+
                         |
              Entornos autorizados
```

La política de red y los límites de cada modo de ejecución están en
[docs/architecture/network-policy.md](docs/architecture/network-policy.md).
La estructura y el tratamiento de datos de casos están en
[docs/architecture/repository-layout.md](docs/architecture/repository-layout.md)
y [docs/architecture/cases-and-evidence.md](docs/architecture/cases-and-evidence.md).

## Componentes

| Componente | Qué demuestra |
|---|---|
| [CyberLab Server](server/README.md) | Telemetría defensiva, API, autenticación, retención y despliegue con Docker |
| [Infraestructura](infra/README.md) | Rutas por política y controles de egreso |
| [Herramientas](tools/README.md) | Organización por propósito y modos de red explícitos |
| [Scripts](scripts/README.md) | Instalación y validaciones repetibles |
| [Plantilla de caso](templates/case/README.md) | Trazabilidad sin publicar datos de objetivos |

## Revisión antes de publicar cambios

No agregues al repositorio archivos `.env`, perfiles VPN, claves, capturas,
PCAP, bases de datos, resultados de escaneo, nombres de objetivos ni datos
personales. Los casos y su evidencia deben vivir fuera del repositorio. Consulta
[CONTRIBUTING.md](CONTRIBUTING.md) y [SECURITY.md](SECURITY.md) antes de enviar
cambios.

## Alcance de esta publicación

Este repositorio se comparte para evaluación técnica y aprendizaje. La
configuración debe adaptarse a una red de laboratorio propia; las direcciones,
interfaces y valores de ejemplo no representan una infraestructura desplegada.

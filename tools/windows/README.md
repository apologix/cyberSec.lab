# Windows, SMB y Active Directory

Directorio para enum4linux-ng, Impacket y utilidades de protocolos Windows.

`enum4linux-ng/` contiene una imagen fijada para enumeración autorizada de Windows/Samba. Usa ProtonWG para objetivos externos y una excepción LAN explícita para objetivos locales. No se usa Tor en esta categoría.

`impacket/` contiene una imagen fijada para validaciones autorizadas de SMB,
RPC, LDAP, Kerberos y Active Directory. Usa ProtonWG para objetivos externos,
una excepción LAN explícita y kill switch. No se usa Tor como transporte
general.

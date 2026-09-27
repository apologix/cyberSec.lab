# Validación de Nmap

Nmap debe usarse únicamente contra objetivos propios o autorizados. Confirmar
primero el alcance y seleccionar la interfaz/ruta correspondiente.

```bash
nmap --version
sudo nmap -n -sn 192.168.100.0/24
```

Para un objetivo externo autorizado, validar primero la ruta ProtonWG y usar
el procedimiento aprobado de ProxyChains4. No escanear internet de forma
indiscriminada.

# Sincronización remota con Rsync

Este script permite sincronizar una carpeta local contra una remota en un servidor remoto, lo que permite mantener ambos iguales.

Es util puesto que la carpeta remota es accesible por varios medios como Samba por VPN hacia mi móvil o mediante clientes Windows. Y además localmente también se pueden incluir ficheros. Por tanto es importante que ambas copias tengan siempre el mismo contenido.

## Utilización
Tenemos que crear un *daemon* que se lance, una vez la configuración de red este lista. Ya que si no el funcionamiento es nulo. Y usar `@reboot` como tarea cron es inviable.

Creación del daemon:

```bash
[Unit]
Description=Sync remote folders with rsync
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/home/nonay/fetch.sh
User=nonay

[Install]
WantedBy=multi-user.target
```
Posteriormente, también se puede añadir una tarea cron que con cierta regularidad, vuelva a ejecutar el script para mantener la sincronización.

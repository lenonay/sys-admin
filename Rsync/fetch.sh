#!/bin/bash

# Variables
local_dir="/home/nonay/Imágenes/fotos/";
remote_dir='/mnt/nonay/vault/fotos/';
log="/home/nonay/last_backup"
host="mugre"

# Quitamos el ultimo backup
rm $log

# Elegimos el host
# Hacemos una consulta al servidor estando en local
nslookup mugre.lan &>/dev/null

if [ $? -ne 0 ]; then
	# Si la consulta dns falla, vamos por el server remoto
	host="mugreV"
fi

echo "--------- Sincronización $(date +'%F %T') ---------" >> $log
echo "Host elegido: $host" >> $log

echo "Revisando conexión" >> $log

ping -c 1 92.222.25.178 &>/dev/null

if [ $? -ne 0 ]; then
	echo "No hay conexión al servidor. Abortando" >> $log
	exit 1
fi

echo "Conexión exitosa. Continuando" >> $log

echo "----- Comenzando copia desde el servidor -----" >> $log

rsync -atzv --ignore-existing $host:$remote_dir $local_dir >> $log

echo "----- Copia desde el servidor terminada ------" >> $log
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" >> $log
echo "----- Copia local hacia el servidor -----" >> $log

rsync -atzv --ignore-existing $local_dir $host:$remote_dir >> $log

echo "----- Copia local terminada -----" >> $log

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" >> $log

echo "Peso del directorio:" >> $log

du -h -d 1 $local_dir >> $log

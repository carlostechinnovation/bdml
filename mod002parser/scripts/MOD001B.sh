#!/bin/bash

echo "Modulo 001B - Planificador de descarga de datos en BRUTO"

echo "sudo crontab -e"
echo "Meter estas lineas:"
echo "PATH=/home/carloslinux/bin:/home/carloslinux/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/usr/lib/jvm/java-8-oracle/bin:/usr/lib/jvm/java-8-oracle/db/bin:/usr/lib/jvm/java-8-oracle/jre/bin"
echo "0 19 * * * /home/carloslinux/Desktop/CODIGOS/MOD001A.sh 2>&1 /home/carloslinux/Desktop/descarga_bruto.log"














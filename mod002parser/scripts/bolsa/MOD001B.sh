#!/bin/bash

echo "Modulo 001B - Planificador de descarga de datos en BRUTO"

echo "sudo crontab -e"
echo "Meter estas lineas:"
echo "PATH=/home/carloslinux/bin:/home/carloslinux/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/usr/lib/jvm/java-8-oracle/bin:/usr/lib/jvm/java-8-oracle/db/bin:/usr/lib/jvm/java-8-oracle/jre/bin"
echo "0 19 * * * /home/carloslinux/Desktop/GIT_REPO_BDML/bdml/mod002parser/scripts/bolsa/MOD001A.sh 2>&1 /home/carloslinux/Desktop/LOGS/descarga_bruto.log"














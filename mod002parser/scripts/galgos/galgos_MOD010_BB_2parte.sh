#!/bin/bash

source "/root/git/bdml/mod002parser/scripts/galgos/funciones.sh"

PATH_SCRIPTS="/root/git/bdml/mod002parser/scripts/galgos/"

PATH_BRUTO="/home/carloslinux/Desktop/DATOS_BRUTO/galgos/"
PATH_LIMPIO="/home/carloslinux/Desktop/DATOS_LIMPIO/galgos/"
PATH_JAR="/root/git/bdml/mod002parser/target/mod002parser-jar-with-dependencies.jar"
FILE_SENTENCIAS_CREATE_TABLE="/home/carloslinux/Desktop/DATOS_LIMPIO/galgos/galgos_sentencias_create_table"


PATH_LIMPIO_CARRERAS="/home/carloslinux/Desktop/DATOS_LIMPIO/galgos/tb_galgos_carreras_file"
PATH_LIMPIO_POSICIONES="/home/carloslinux/Desktop/DATOS_LIMPIO/galgos/tb_galgos_posiciones_en_carreras_file"
PATH_LIMPIO_HISTORICO="/home/carloslinux/Desktop/DATOS_LIMPIO/galgos/tb_galgos_historico_file"
PATH_LIMPIO_AGREGADOS="/home/carloslinux/Desktop/DATOS_LIMPIO/galgos/tb_galgos_agregados_file"

PATH_LIMPIO_GALGOS_INICIALES_WARNINGS="/home/carloslinux/Desktop/DATOS_LIMPIO/galgos/warnings_galgos_iniciales"
PATH_LIMPIO_CARRERAS_WARNINGS="/home/carloslinux/Desktop/DATOS_LIMPIO/galgos/warnings_carreras"
PATH_LIMPIO_POSICIONES_WARNINGS="/home/carloslinux/Desktop/DATOS_LIMPIO/galgos/warnings_posiciones"
PATH_LIMPIO_HISTORICO_WARNINGS="/home/carloslinux/Desktop/DATOS_LIMPIO/galgos/warnings_historico"
PATH_LIMPIO_AGREGADOS_WARNINGS="/home/carloslinux/Desktop/DATOS_LIMPIO/galgos/warnings_agregados"

PATH_LIMPIO_ESTADISTICAS="/home/carloslinux/Desktop/DATOS_LIMPIO/galgos/galgos_limpio_estadisticas"

echo -e $(date +"%T")" Path del log: ${LOG_DESCARGA_BRUTO}" 2>&1 1>>${LOG_DESCARGA_BRUTO}
#rm -f ${LOG_DESCARGA_BRUTO}


##########################################
echo -e $(date +"%T")" Borrando ficheros antiguos..." 2>&1 1>>${LOG_DESCARGA_BRUTO}
#rm -f "$PATH_BRUTO*"
#rm -f "$PATH_LIMPIO*"

#################### FUTURAS - BETBRIGHT ######################

##########################################

echo -e $(date +"%T")" Galgos-Modulo 010 - FIN" 2>&1 1>>${LOG_DESCARGA_BRUTO}




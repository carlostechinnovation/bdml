#!/bin/bash

source "/root/git/bdml/mod002parser/scripts/galgos/funciones.sh"

#Script principal COORDINADOR de todas las tareas. Lo que no quiera ejecutar, lo comento.

PATH_LOG="/home/carloslinux/Desktop/LOGS/galgos_coordinador.log"
PATH_SCRIPTS="/root/git/bdml/mod002parser/scripts/galgos/"

#limpiar logs
rm -f "/home/carloslinux/Desktop/LOGS/log4j-application.log"
rm -f $PATH_LOG


##########################################
#sudo service mysql start

##########################################
echo -e "-------- "$(date +"%T")" ---------- GALGOS - Cadena de procesos ------------" >>$PATH_LOG
echo -e "Ruta script="${PATH_SCRIPTS}
echo -e "Ruta log (coordinador)="${PATH_LOG}

echo -e $(date +"%T")" Descarga de datos (planificado con CRON)" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD010.sh'

echo -e $(date +"%T")" Analisis de datos: ESTADISTICA BASICA" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD020.sh'

echo -e $(date +"%T")" Generador de COLUMNAS ELABORADAS" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD030.sh'


#### Analisis de SUBGRUPOS ###
analizarScoreSobreSubgrupos "$PATH_LOG"


echo -e $(date +"%T")" DATASETS + FILTRADAS + INTELIGENCIA ARTIFICIAL" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD035.sh' "" "" "" "TOTAL"
${PATH_SCRIPTS}'galgos_MOD040.sh' "TOTAL" >>$PATH_LOG

#echo -e $(date +"%T")" INFORMES (resultados)" >>$PATH_LOG
#${PATH_SCRIPTS}'galgos_MOD050.sh'

#echo -e $(date +"%T")" Análisis posterior" >>$PATH_LOG
#${PATH_SCRIPTS}'galgos_MOD060.sh'

#echo -e $(date +"%T")" Análisis TIC de la ejecucion" >>$PATH_LOG
#${PATH_SCRIPTS}'galgos_MOD007.sh'

##########################################

#sudo service mysql stop

##########################################




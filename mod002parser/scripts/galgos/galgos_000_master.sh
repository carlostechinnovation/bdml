#!/bin/bash

source "/root/git/bdml/mod002parser/scripts/galgos/funciones.sh"

#Script principal COORDINADOR de todas las tareas. Lo que no quiera ejecutar, lo comento.

PATH_LOG="/home/carloslinux/Desktop/LOGS/galgos_coordinador.log"


#limpiar logs
rm -f "/home/carloslinux/Desktop/LOGS/log4j-application.log"
rm -f $PATH_LOG


##########################################

echo -e "Tiempo de 5 segundos para que abras los logs (tailf)..."
#sleep 5s

echo -e "-------- "$(date +"%T")" ---------- GALGOS - Cadena de procesos ------------" >>$PATH_LOG
echo -e "Ruta script="${PATH_SCRIPTS}
echo -e "Ruta log (coordinador)="${PATH_LOG}

echo -e $(date +"%T")" Descarga de datos (planificado con CRON)" >>$PATH_LOG
rm -f "$FLAG_BB_DESCARGADO_OK" #fichero FLAG que indica que el proceso hijo ha terminado (el padre lo mirará cuando le haga falta en el módulo predictivo de carreras FUTURAS).
#${PATH_SCRIPTS}'galgos_MOD010_paralelo_BB.sh' & ## FUTURAS - BETBRIGHT (ASYNC) ##
#${PATH_SCRIPTS}'galgos_MOD010.sh' #Sportium


echo -e $(date +"%T")" Analisis de datos BRUTOS: ESTADISTICA BASICA" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD020.sh'

echo -e $(date +"%T")" Generador de COLUMNAS ELABORADAS" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD030.sh'

echo -e $(date +"%T")" FILTRADAS + DATASETS + INTELIGENCIA ARTIFICIAL" >>$PATH_LOG
analizarScoreSobreSubgrupos "$PATH_LOG"

#Subgrupo GANADOR (con mas rentabilidad)
${PATH_SCRIPTS}'galgos_MOD035.sh' "" "" "" "TOTAL" #llama a 036 y 037
${PATH_SCRIPTS}'galgos_MOD040.sh' "TOTAL" >>$PATH_LOG


echo -e $(date +"%T")" PREDICCION SOBRE EL FUTURO (resultados)" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD050.sh' "TOTAL"

echo -e $(date +"%T")" Análisis posterior" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD060_caso_endtoend.sh'
${PATH_SCRIPTS}'galgos_MOD060_tablas.sh'

echo -e $(date +"%T")" Análisis TIC de la ejecucion" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD070.sh'

echo -e $(date +"%T")" Limpieza final (tablas pasadas, pero no las futuras)" >>$PATH_LOG
limpieza

##########################################




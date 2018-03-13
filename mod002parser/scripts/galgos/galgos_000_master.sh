#!/bin/bash

source "/root/git/bdml/mod002parser/scripts/galgos/funciones.sh"

#Script principal COORDINADOR de todas las tareas. Lo que no quiera ejecutar, lo comento.

PATH_LOG="/home/carloslinux/Desktop/LOGS/galgos_coordinador.log"


#limpiar logs
rm -f "/home/carloslinux/Desktop/LOGS/log4j-application.log"
rm -f $PATH_LOG


##########################################
echo -e $(date +"%T")" ************** MASTER: INICIO ***************" >>$PATH_LOG
echo -e "Tiempo de 5 segundos para que abras los logs (tailf)..."
#sleep 5s

echo -e "-------- "$(date +"%T")" ---------- GALGOS - Cadena de procesos ------------" >>$PATH_LOG
echo -e "Ruta script="${PATH_SCRIPTS}
echo -e "Ruta log (coordinador)="${PATH_LOG}

#echo -e $(date +"%T")" Descarga de datos BRUTOS (planificado con CRON)" >>$PATH_LOG
#rm -f "$FLAG_BB_DESCARGADO_OK" #fichero FLAG que indica que el proceso hijo ha terminado (el padre lo mirará cuando le haga falta en el módulo predictivo de carreras FUTURAS).
#${PATH_SCRIPTS}'galgos_MOD010_paralelo_BB.sh'  >>$PATH_LOG ## FUTURAS - BETBRIGHT (ASYNC?? Poner & en tal caso) ##
#${PATH_SCRIPTS}'galgos_MOD010.sh'  >>$PATH_LOG #Sportium


echo -e $(date +"%T")" Limpieza y normalizacion de tablas brutas (Sportium y Betbright)" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD011.sh' >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD012.sh' >>$PATH_LOG

echo -e $(date +"%T")" Analisis de datos BRUTOS: ESTADISTICA BASICA" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD020.sh' >>$PATH_LOG

echo -e $(date +"%T")" Generador de COLUMNAS ELABORADAS" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD030.sh' >>$PATH_LOG

echo -e $(date +"%T")" FILTRADAS + DATASETS + INTELIGENCIA ARTIFICIAL" >>$PATH_LOG
analizarScoreSobreSubgrupos "$PATH_LOG"

#Subgrupo GANADOR (con mas rentabilidad)
${PATH_SCRIPTS}'galgos_MOD035.sh' "" "" "" "TOTAL" >>$PATH_LOG #llama a 036 y 037
${PATH_SCRIPTS}'galgos_MOD040.sh' "TOTAL" >>$PATH_LOG


echo -e $(date +"%T")" PREDICCION SOBRE EL FUTURO (resultados)" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD050.sh' "TOTAL" >>$PATH_LOG

echo -e $(date +"%T")" Análisis posterior" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD060_caso_endtoend.sh' >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD060_tablas.sh' >>$PATH_LOG

echo -e $(date +"%T")" Análisis TIC de la ejecucion" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD070.sh' >>$PATH_LOG

#echo -e $(date +"%T")" Limpieza final (tablas pasadas, pero no las futuras)" >>$PATH_LOG
#limpieza

##########################################
echo -e $(date +"%T")" ************** MASTER: FIN ***************" >>$PATH_LOG



#!/bin/bash

source "/root/git/bdml/mod002parser/scripts/galgos/funciones.sh"

#Script principal COORDINADOR de todas las tareas. Lo que no quiera ejecutar, lo comento.


#limpiar logs
rm -f "/home/carloslinux/Desktop/LOGS/log4j-application.log"
rm -f $LOG_MASTER


##########################################
echo -e $(date +"%T")" ************** MASTER: INICIO ***************" >>$LOG_MASTER
echo -e "Tiempo de 5 segundos para que abras los logs (tailf)..."
#sleep 5s

echo -e "-------- "$(date +"%T")" ---------- GALGOS - Cadena de procesos ------------" >>$LOG_MASTER
echo -e "Ruta script="${PATH_SCRIPTS}
echo -e "Ruta log (coordinador)="${LOG_MASTER}

#echo -e $(date +"%T")" Descarga de datos BRUTOS (planificado con CRON)" >>$LOG_MASTER
#rm -f "$FLAG_BB_DESCARGADO_OK" #fichero FLAG que indica que el proceso hijo ha terminado (el padre lo mirará cuando le haga falta en el módulo predictivo de carreras FUTURAS).
#${PATH_SCRIPTS}'galgos_MOD010_paralelo_BB.sh'  >>$LOG_MASTER ## FUTURAS - BETBRIGHT (ASYNC?? Poner & en tal caso) ##
#${PATH_SCRIPTS}'galgos_MOD010.sh'  >>$LOG_MASTER #Sportium


#echo -e $(date +"%T")" Limpieza y normalizacion de tablas brutas (Sportium y Betbright)" >>$LOG_MASTER
#${PATH_SCRIPTS}'galgos_MOD011.sh' >>$LOG_MASTER
#${PATH_SCRIPTS}'galgos_MOD012.sh' >>$LOG_MASTER

#echo -e $(date +"%T")" Analisis de datos BRUTOS: ESTADISTICA BASICA" >>$LOG_MASTER
#${PATH_SCRIPTS}'galgos_MOD020.sh' >>$LOG_MASTER

echo -e $(date +"%T")" Generador de COLUMNAS ELABORADAS" >>$LOG_MASTER
${PATH_SCRIPTS}'galgos_MOD030.sh' >>$LOG_MASTER

echo -e $(date +"%T")" FILTRADAS + DATASETS + INTELIGENCIA ARTIFICIAL" >>$LOG_MASTER
analizarScoreSobreSubgrupos "$LOG_MASTER"

Subgrupo GANADOR (con mas rentabilidad)
${PATH_SCRIPTS}'galgos_MOD035.sh' "" "" "" "TOTAL" >>$LOG_MASTER #llama a 036 y 037
${PATH_SCRIPTS}'galgos_MOD040.sh' "TOTAL" >>$LOG_MASTER


echo -e $(date +"%T")" PREDICCION SOBRE EL FUTURO (resultados)" >>$LOG_MASTER
${PATH_SCRIPTS}'galgos_MOD050.sh' "TOTAL" >>$LOG_MASTER

echo -e $(date +"%T")" Análisis posterior" >>$LOG_MASTER
${PATH_SCRIPTS}'galgos_MOD060_caso_endtoend.sh' >>$LOG_MASTER
${PATH_SCRIPTS}'galgos_MOD060_tablas.sh' >>$LOG_MASTER

echo -e $(date +"%T")" Análisis TIC de la ejecucion" >>$LOG_MASTER
${PATH_SCRIPTS}'galgos_MOD070.sh' >>$LOG_MASTER

#echo -e $(date +"%T")" Limpieza final (tablas pasadas, pero no las futuras)" >>$LOG_MASTER
#limpieza

##########################################
echo -e $(date +"%T")" ************** MASTER: FIN ***************" >>$LOG_MASTER



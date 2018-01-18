#!/bin/bash

#Script principal COORDINADOR de todas las tareas. Lo que no quiera ejecutar, lo comento.

PATH_LOG="/home/carloslinux/Desktop/LOGS/galgos_coordinador.log"
PATH_SCRIPTS="/home/carloslinux/Desktop/CODIGOS/workspace_java/bdml/mod002parser/scripts/galgos/"

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
${PATH_SCRIPTS}'galgos_MOD001A.sh'

echo -e $(date +"%T")" Planificador de DESCARGA DIARIA (comandos CRON solo para descargas de datos)" >>$PATH_LOG
#.${PATH_SCRIPTS}'galgos_MOD001B.sh'

echo -e $(date +"%T")" Limpieza basica (parseado, padding, diferenciales...) y tablas auxiliares utiles" >>$PATH_LOG
#${PATH_SCRIPTS}'galgos_MOD002A.sh'

echo -e $(date +"%T")" Limpieza inteligente (scaling, normalizacion...) que necesitan los algoritmos" >>$PATH_LOG
#${PATH_SCRIPTS}'galgos_MOD002B.sh'

echo -e $(date +"%T")" Analisis de datos: ESTADISTICA BASICA" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD003A.sh'

echo -e $(date +"%T")" OBSOLETO Sistema predictivo simple PGA (funcion con pesos, para cada galgo)" >>$PATH_LOG
#${PATH_SCRIPTS}'galgos_MOD003PGA.sh'

echo -e $(date +"%T")" Generador de COLUMNAS ELABORADAS y DATASETS" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD003B.sh'

echo -e $(date +"%T")" INTELIGENCIA ARTIFICIAL" >>$PATH_LOG
#${PATH_SCRIPTS}'galgos_MOD004_nucleo.sh'
#${PATH_SCRIPTS}'galgos_MOD004.sh'

echo -e $(date +"%T")" INFORMES (resultados)" >>$PATH_LOG
#${PATH_SCRIPTS}'galgos_MOD005.sh'
#${PATH_SCRIPTS}'galgos_MOD005_PGA.sh'

echo -e $(date +"%T")" Análisis posterior" >>$PATH_LOG
#${PATH_SCRIPTS}'galgos_MOD006.sh'

echo -e $(date +"%T")" Análisis TIC de la ejecucion" >>$PATH_LOG
#${PATH_SCRIPTS}'galgos_MOD007.sh'

##########################################

#sudo service mysql stop

##########################################

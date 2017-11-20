#!/bin/bash

#Script principal COORDINADOR de todas las tareas. Lo que no quiera ejecutar, lo comento.

PATH_LOG="/home/carloslinux/Desktop/LOGS/galgos_coordinador.log"
PATH_SCRIPTS="/home/carloslinux/Desktop/CODIGOS/workspace_java/bdml/mod002parser/scripts/galgos/"

echo -e "GALGOS - Cadena de procesos"

echo -e "Ruta script="${PATH_SCRIPTS}

#limpiar log
rm -f "/home/carloslinux/Desktop/LOGS/log4j-application.log"

#Descarga de datos (planificado con CRON)
${PATH_SCRIPTS}'galgos_MOD001A.sh'

#Planificador de DESCARGA DIARIA (comandos CRON solo para descargas de datos)
#.${PATH_SCRIPTS}'galgos_MOD001B.sh'

#Limpieza basica (parseado, padding, diferenciales...) y tablas auxiliares utiles
#${PATH_SCRIPTS}'galgos_MOD002A.sh'

#Limpieza inteligente (scaling, normalizacion...) que necesitan los algoritmos
#${PATH_SCRIPTS}'galgos_MOD002B.sh'

#Análisis de datos: ESTADISTICA BASICA
#${PATH_SCRIPTS}'galgos_MOD003A.sh'

#Generador de DATASETS
${PATH_SCRIPTS}'galgos_MOD003B.sh'

#INTELIGENCIA ARTIFICIAL
#${PATH_SCRIPTS}'galgos_MOD004_nucleo.sh'
${PATH_SCRIPTS}'galgos_MOD004.sh'

#INFORMES (resultados)
${PATH_SCRIPTS}'galgos_MOD005.sh'

#Análisis posterior
#${PATH_SCRIPTS}'galgos_MOD006.sh'






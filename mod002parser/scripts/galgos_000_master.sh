#!/bin/bash

#Script principal COORDINADOR de todas las tareas. Lo que no quiera ejecutar, lo comento.

PATH_LOG="/home/carloslinux/Desktop/galgos_coordinador.log"
PATH_SCRIPTS="/home/carloslinux/Desktop/GIT_REPO_BDML/bdml/mod002parser/scripts/"

############# ID de ejecucion = fecha_hora BOE #####################3
PATH_JAR="/home/carloslinux/Desktop/GIT_REPO_BDML/bdml/mod002parser/target/mod002parser-jar-with-dependencies.jar"

TAG_BOE="BOE"
#BOE_01: dia y hora oficial en este instante.
curl 'https://www.boe.es/sede_electronica/informacion/hora_oficial.php' > "/home/carloslinux/Desktop/DATOS_BRUTO/BOE_in"
sleep 3s
FILE_BOE_OUT="/home/carloslinux/Desktop/DATOS_BRUTO/BOE_out"
rm ${FILE_BOE_OUT}
java -jar ${PATH_JAR} "01" -Djava.util.logging.SimpleFormatter.format='%1$tY-%1$tm-%1$td %1$tH:%1$tM:%1$tS %4$s %2$s %5$s%6$s%n' 2>>${PATH_LOG} 1>>${PATH_LOG}

export TAG_DIA_DESCARGA=$(cat $FILE_BOE_OUT)
echo -e "GALGOS - Dia BOE extraido: "$TAG_DIA_DESCARGA 2>&1 1>>${PATH_LOG}

############################################################

echo -e "GALGOS - Cadena de procesos"

echo -e ${PATH_SCRIPTS}

#Descarga de datos (planificado con CRON)
${PATH_SCRIPTS}'galgos_MOD001A.sh' $TAG_DIA_DESCARGA

#Planificador de DESCARGA DIARIA (comandos CRON solo para descargas de datos)
#.${PATH_SCRIPTS}'/galgos_MOD001B.sh'

#Limpieza basica (parseado, padding, diferenciales...) y tablas auxiliares utiles
#${PATH_SCRIPTS}'galgos_MOD002A.sh' $TAG_DIA_DESCARGA

#Limpieza inteligente (scaling, normalizacion...) que necesitan los algoritmos
#${PATH_SCRIPTS}'galgos_MOD002B.sh'

#Análisis de datos: ESTADISTICA BASICA
#${PATH_SCRIPTS}'galgos_MOD003A.sh'

#Generador de DATASETS
#${PATH_SCRIPTS}'galgos_MOD003B.sh'

#INTELIGENCIA ARTIFICIAL
#${PATH_SCRIPTS}'galgos_MOD004A.sh'

#INFORMES (resultados)
#${PATH_SCRIPTS}'galgos_MOD005.sh'

#Análisis posterior
#${PATH_SCRIPTS}'galgos_MOD006.sh'






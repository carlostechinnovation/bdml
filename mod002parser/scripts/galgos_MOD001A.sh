#!/bin/bash

PATH_LOG="/home/carloslinux/Desktop/galgos_descarga_bruto.log"
PATH_SCRIPTS="/home/carloslinux/Desktop/GIT_REPO_BDML/bdml/mod002parser/scripts/"

echo "Galgos-Modulo 001A - Obtener datos en BRUTO" 2>&1 1>>${PATH_LOG}

PATH_CARPETA="/home/carloslinux/Desktop/DATOS_BRUTO/galgos/"
PATH_JAR="/home/carloslinux/Desktop/GIT_REPO_BDML/bdml/mod002parser/target/mod002parser-jar-with-dependencies.jar"


######## BOE - DIA ##################################
if [ $# -eq 0 ]
  then
    echo "ERROR Parametro de entrada vacio. Debes indicar el dia (BOE) que quieres procesar!"
    exit -1
fi

TAG_DIA_DESCARGA=${1}
anio=${TAG_DIA_DESCARGA:1:4}
mes=${TAG_DIA_DESCARGA:5:2}
dia=${TAG_DIA_DESCARGA:7:2}

echo 'ID de ejecucion parseado = '$anio'/'$mes'/'$dia

##########################################
TAG_GBGB="GBGB"
echo ${TAG_GBGB}'...' 2>&1 1>>${PATH_LOG}


#GBGB Descargar+parsear las carreras de ese dia concreto y descargar+parsear los detalles (galgos y sus historicos)
java -jar ${PATH_JAR} "04" "${anio}${mes}${dia}" "${PATH_CARPETA}galgos_${anio}${mes}${dia}_${TAG_GBGB}_bruto" 





echo "Galgos-Modulo 001A - FIN" 2>&1 1>>${PATH_LOG}







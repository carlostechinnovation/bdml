#!/bin/bash

PATH_LOG="/home/carloslinux/Desktop/descarga_bruto.log"
PATH_SCRIPTS="/home/carloslinux/Desktop/GIT_REPO_BDML/bdml/mod002parser/scripts/"

echo "Modulo 001A - Obtener datos en BRUTO" 2>&1 1>>${PATH_LOG}

PATH_CARPETA="/home/carloslinux/Desktop/DATOS_BRUTO/"
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

########### SHELL que invoca a NODE.js ###############################
TAG_YAHOO_FINANCE="YF"

#Instalacion en local del programa descargador de yahoo finance
#npm install --save yahoo-finance

#Ejecutar cuando se necesite descargar el historico, indicando rangos de fecha. En caso de reejecucion, se sobreescriben los ficheros brutos de ese anio.
${PATH_SCRIPTS}'MOD001A_yahoo_finance.sh' ${anio}



echo "Modulo 001A - FIN" 2>&1 1>>${PATH_LOG}



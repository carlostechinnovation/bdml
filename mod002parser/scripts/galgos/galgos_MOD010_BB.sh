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
rm -f ${LOG_DESCARGA_BRUTO}


##########################################
echo -e $(date +"%T")" Borrando ficheros antiguos..." 2>&1 1>>${LOG_DESCARGA_BRUTO}
rm -f "$PATH_BRUTO*"
rm -f "$PATH_LIMPIO*"

#################### FUTURAS - BETBRIGHT ######################
PATH_FILE_GALGOS_INICIALES_BB="/home/carloslinux/Desktop/DATOS_LIMPIO/galgos/galgos_iniciales_bb.txt"
PATH_FILE_GALGOS_INICIALES_BB_FULL="/home/carloslinux/Desktop/DATOS_LIMPIO/galgos/galgos_iniciales_bb.txt_full"

echo -e $(date +"%T")" Descargando todas las carreras FUTURAS de BETBRIGHT usando un navegador..." 2>&1 1>>${LOG_DESCARGA_BRUTO}
BB_URL_TODAY="www.betbright.com/greyhound-racing/today"
BB_URL_TOMORROW="www.betbright.com/greyhound-racing/tomorrow"
BB_FICHEROS="/home/carloslinux/Desktop/DATOS_BRUTO/galgos/betbright*"
BB_FICHERO_PREFIJO="/home/carloslinux/Desktop/DATOS_BRUTO/galgos/betbright_"
BB_FICHERO_TODAY="/home/carloslinux/Desktop/DATOS_BRUTO/galgos/betbright_today.html"
BB_FICHERO_TOMORROW="/home/carloslinux/Desktop/DATOS_BRUTO/galgos/betbright_tomorrow.html"

echo -e $(date +"%T")" Borrando todos estos ficheros: ${BB_FICHEROS}" 2>&1 1>>${LOG_DESCARGA_BRUTO}
sudo rm -rf ${BB_FICHEROS}
sleep 2s

num_betbright_restantes=$(ls -l ${BB_FICHEROS} | wc -l)
echo -e $(date +"%T")" Comprobacion de ficheros NO borrados = "${num_betbright_restantes} 2>&1 1>>${LOG_DESCARGA_BRUTO}
if [ ${num_betbright_restantes} -gt 0 ]
  then
    echo -e "No se han borrado bien los ficheros antiguos de Betbright." 2>&1 1>>${LOG_DESCARGA_BRUTO}
    exit -1
fi


echo -e $(date +"%T")" Descarga de carreras BB-FUTURAS-TODAY a fichero = "${BB_FICHERO_TODAY} 2>&1 1>>${LOG_DESCARGA_BRUTO}
"${PATH_SCRIPTS}save_page_as.sh" "${BB_URL_TODAY}" --destination "${BB_FICHERO_TODAY}" --browser "google-chrome" --load-wait-time 6 --save-wait-time 4
sleep 1s
echo -e $(date +"%T")" Descarga de carreras BB-FUTURAS-TOMORROW a fichero = "${BB_FICHERO_TOMORROW} 2>&1 1>>${LOG_DESCARGA_BRUTO}
"${PATH_SCRIPTS}save_page_as.sh" "${BB_URL_TOMORROW}" --destination "${BB_FICHERO_TOMORROW}" --browser "google-chrome" --load-wait-time 6 --save-wait-time 4
sleep 1s


echo -e $(date +"%T")" Borrando ${PATH_FILE_GALGOS_INICIALES_BB} ..."
rm -f "${PATH_FILE_GALGOS_INICIALES_BB}"
sleep 2s
echo -e $(date +"%T")" Borrando ${PATH_FILE_GALGOS_INICIALES_BB_FULL} ..."
rm -f "${PATH_FILE_GALGOS_INICIALES_BB_FULL}"
sleep 2s
echo -e "Comprobando ficheros borrados:"
echo -e $(ls -l "${PATH_FILE_GALGOS_INICIALES_BB}")
echo -e $(ls -l "${PATH_FILE_GALGOS_INICIALES_BB_FULL}")
sleep 2s

echo -e $(date +"%T")" Parseando las carreras FUTURAS (today y tomorrow) de BETBRIGHT mediante JAVA para guardarlas aqui: ${PATH_BRUTO}semillas_betbright" 2>&1 1>>${LOG_DESCARGA_BRUTO}
java -jar ${PATH_JAR} "GALGOS_02_BETBRIGHT" "${BB_FICHERO_PREFIJO}" "${PATH_FILE_GALGOS_INICIALES_BB}" 2>&1 1>>${LOG_DESCARGA_BRUTO}


echo -e "Leemos todas las URLs de detalles (del fichero) y descargamos cada detalle uno a uno mediante script externo. La ruta de cada FICHERO BRUTO DE DETALLE debe ser: ${PATH_BRUTO}semillas_betbright_DET_XXX (donde XXX es 1, 2... 10,11...111,112)" 2>&1 1>>${LOG_DESCARGA_BRUTO}

java -jar ${PATH_JAR} "GALGOS_02_BETBRIGHT_DETALLES" "${PATH_BRUTO}semillas_betbright" "${PATH_FILE_GALGOS_INICIALES_BB}" 2>&1 1>>${LOG_DESCARGA_BRUTO}
echo -e "BB_Ejemplo de fichero limpio:\n"$(head -n 3 "${PATH_FILE_GALGOS_INICIALES_BB}")

#consultar "LOAD DATA LOCAL INFILE '${PATH_FILE_GALGOS_INICIALES_BB_FULL}' INTO TABLE datos_desa.tb_cg_semillas_betbright FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n' IGNORE 0 LINES\W;" #"$PATH_LIMPIO_GALGOS_INICIALES_WARNINGS"
#consultar "SELECT COUNT(*) as num_galgos_iniciales FROM datos_desa.tb_cg_semillas_betbright LIMIT 1\W;" "${LOG_DESCARGA_BRUTO}" "-t"

##########################################

echo -e $(date +"%T")"Galgos-Modulo 010 - FIN" 2>&1 1>>${LOG_DESCARGA_BRUTO}




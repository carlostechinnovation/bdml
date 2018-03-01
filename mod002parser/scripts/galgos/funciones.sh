#!/bin/bash

LOG_DESCARGA_BRUTO="/home/carloslinux/Desktop/LOGS/galgos_010_descarga_bruto.log"
FLAG_BB_DESCARGADO_OK="/home/carloslinux/Desktop/LOGS/galgos_010_BB.descargado.OK"
DOC_ANALISIS_PREVIO="/home/carloslinux/Desktop/INFORMES/analisis_previo.txt"
LOG_ESTADISTICA_BRUTO="/home/carloslinux/Desktop/LOGS/galgos_020_stats.log"
LOG_CE="/home/carloslinux/Desktop/LOGS/galgos_031_columnas_elaboradas.log"
LOG_DS="/home/carloslinux/Desktop/LOGS/galgos_037_datasets.log"
LOG_ML="/home/carloslinux/Desktop/LOGS/galgos_040_ML.log"


function consultar(){
  sentencia_sql=${1}
  path_log_sql=${2}
  opciones=${3}
  mysql -u root --password=datos1986 ${opciones} --execute="${sentencia_sql}" 2>&1 1>>${path_log_sql}
}

function consultar_sobreescribirsalida(){
  sentencia_sql=${1}
  path_output_file=${2}
  opciones=${3}
  mysql -u root --password=datos1986 ${opciones} --execute="${sentencia_sql}" >"$path_output_file"
  sleep 4s
}

function mostrar_tabla(){
  descripcion=${1}
  schema_tabla=${2}
  path_output_file=${3}
  echo -e "\n${descripcion} (${schema_tabla}): " 2>&1 1>>${path_output_file}
  consultar "SHOW CREATE TABLE ${schema_tabla}\W;" "${path_output_file}" "-tNs"
  consultar "SELECT COUNT(*) as num_filas FROM ${schema_tabla} LIMIT 1\W;" "${path_output_file}"  "-t"
  consultar "SELECT * FROM ${schema_tabla} LIMIT 1\W;" "${path_output_file}" "-t"
}



#################### FUTURAS - BETBRIGHT ######################
function obtenerFuturasBetbright(){



echo -e $(date +"%T")" Descargando todas las carreras FUTURAS de BETBRIGHT usando un navegador..." 2>&1 1>>${LOG_DESCARGA_BRUTO}
BB_URL_TODAY="www.betbright.com/greyhound-racing/today"
BB_URL_TOMORROW="www.betbright.com/greyhound-racing/tomorrow"
BB_FICHEROS="/home/carloslinux/Desktop/DATOS_BRUTO/galgos/betbright*"
BB_FICHERO_PREFIJO="/home/carloslinux/Desktop/DATOS_BRUTO/galgos/betbright_"
BB_FICHERO_TODAY="/home/carloslinux/Desktop/DATOS_BRUTO/galgos/betbright_today.html"
BB_FICHERO_TOMORROW="/home/carloslinux/Desktop/DATOS_BRUTO/galgos/betbright_tomorrow.html"

PATH_FILE_GALGOS_INICIALES_BB="/home/carloslinux/Desktop/DATOS_LIMPIO/galgos/galgos_iniciales_bb.txt"


echo -e $(date +"%T")" Borrando todos estos ficheros: ${BB_FICHEROS}" 2>&1 1>>${LOG_DESCARGA_BRUTO}
sudo rm -rf ${BB_FICHEROS} 2>&1 1>>${LOG_DESCARGA_BRUTO}

num_betbright_restantes=$(ls -l ${BB_FICHEROS} | wc -l)
echo -e $(date +"%T")" Comprobacion de ficheros NO borrados = "${num_betbright_restantes} 2>&1 1>>${LOG_DESCARGA_BRUTO}
if [ ${num_betbright_restantes} -gt 0 ]
  then
    echo -e "No se han borrado bien los ficheros antiguos de Betbright." 2>&1 1>>${LOG_DESCARGA_BRUTO}
    exit -1
fi


echo -e $(date +"%T")" Descarga de carreras BB-FUTURAS-TODAY a fichero = "${BB_FICHERO_TODAY} 2>&1 1>>${LOG_DESCARGA_BRUTO}
"${PATH_SCRIPTS}save_page_as.sh" "${BB_URL_TODAY}" --destination "${BB_FICHERO_TODAY}" --browser "google-chrome" --load-wait-time 4 --save-wait-time 3

echo -e $(date +"%T")" Descarga de carreras BB-FUTURAS-TOMORROW a fichero = "${BB_FICHERO_TOMORROW} 2>&1 1>>${LOG_DESCARGA_BRUTO}
"${PATH_SCRIPTS}save_page_as.sh" "${BB_URL_TOMORROW}" --destination "${BB_FICHERO_TOMORROW}" --browser "google-chrome" --load-wait-time 4 --save-wait-time 3


echo -e $(date +"%T")" Borrando ${PATH_FILE_GALGOS_INICIALES_BB} ..." 2>&1 1>>${LOG_DESCARGA_BRUTO}
rm -f "${PATH_FILE_GALGOS_INICIALES_BB}" 2>&1 1>>${LOG_DESCARGA_BRUTO}
echo -e $(date +"%T")"Comprobando ficheros borrados:" 2>&1 1>>${LOG_DESCARGA_BRUTO}
echo -e $(date +"%T")" "$(ls -l "${PATH_FILE_GALGOS_INICIALES_BB}") 2>&1 1>>${LOG_DESCARGA_BRUTO}


echo -e $(date +"%T")" Parseando las carreras FUTURAS (today y tomorrow) de BETBRIGHT mediante JAVA para guardarlas aqui: ${PATH_BRUTO}semillas_betbright" 2>&1 1>>${LOG_DESCARGA_BRUTO}
java -jar ${PATH_JAR} "GALGOS_02_BETBRIGHT" "${BB_FICHERO_PREFIJO}" "${PATH_FILE_GALGOS_INICIALES_BB}" 2>&1 1>>${LOG_DESCARGA_BRUTO}


echo -e $(date +"%T")"\n\nLeemos fichero con URLs y descargamos los ficheros de detalle, uno a uno...\n" 2>&1 1>>${LOG_DESCARGA_BRUTO}


### BB-DETALLES

PATH_FILE_GALGOS_INICIALES_BB_FULL="${PATH_FILE_GALGOS_INICIALES_BB}_full"
BB_FICHEROS_DET="/home/carloslinux/Desktop/DATOS_BRUTO/galgos/semillas_betbright_DET_*"
PATH_LIMPIO_GALGOS_BB_WARNINGS="/home/carloslinux/Desktop/DATOS_LIMPIO/galgos/warnings_galgos_bb"


echo -e $(date +"%T")" Borrando ${PATH_FILE_GALGOS_INICIALES_BB_FULL} ..." 2>&1 1>>${LOG_DESCARGA_BRUTO}
rm -f "${PATH_FILE_GALGOS_INICIALES_BB_FULL}" 2>&1 1>>${LOG_DESCARGA_BRUTO}

echo -e $(date +"%T")"Comprobando ficheros borrados:" 2>&1 1>>${LOG_DESCARGA_BRUTO}
echo -e $(date +"%T")" "$(ls -l "${PATH_FILE_GALGOS_INICIALES_BB_FULL}") 2>&1 1>>${LOG_DESCARGA_BRUTO}


echo -e $(date +"%T")"Leemos todas las URLs de detalles (del fichero) y descargamos cada detalle uno a uno mediante script externo. La ruta de cada FICHERO BRUTO DE DETALLE debe ser: ${PATH_BRUTO}semillas_betbright_DET_XXX (donde XXX es 1, 2... 10,11...111,112)" 2>&1 1>>${LOG_DESCARGA_BRUTO}



echo -e $(date +"%T")" Borrando todos estos ficheros: ${BB_FICHEROS_DET}" 2>&1 1>>${LOG_DESCARGA_BRUTO}
sudo rm -rf ${BB_FICHEROS_DET} 2>&1 1>>${LOG_DESCARGA_BRUTO}


counter=0
nombreFicheroDetalle=""

while IFS= read -r urlDetalle
do
  ((counter++))
  nombreFicheroDetalle="${PATH_BRUTO}semillas_betbright_DET_${counter}.html"
  
  #DEBUG: podemos limitar este contador de carreras futuras a descargar (ver linea siguiente)
  
  if [ $counter -le 10 ]
  then
    echo -e $(date +"%T")" #=$counter | URL=$urlDetalle | File=${nombreFicheroDetalle}" 2>&1 1>>${LOG_DESCARGA_BRUTO}
    
    "${PATH_SCRIPTS}save_page_as.sh" "${urlDetalle}" --destination "${nombreFicheroDetalle}" --browser "google-chrome" --load-wait-time 4 --save-wait-time 3  2>&1 1>>${LOG_DESCARGA_BRUTO}

    #echo -e $(date +"%T") Ficheros acumulados en iteracion=$counter son: \n" $(ls -l '/home/carloslinux/Desktop/DATOS_BRUTO/galgos/' | grep '_DET_' | grep '.html')  2>&1 1>>${LOG_DESCARGA_BRUTO}

  fi
done <"${PATH_FILE_GALGOS_INICIALES_BB}"



java -jar ${PATH_JAR} "GALGOS_02_BETBRIGHT_DETALLES" "${PATH_BRUTO}semillas_betbright" "${PATH_FILE_GALGOS_INICIALES_BB}" 2>&1 1>>${LOG_DESCARGA_BRUTO}


echo -e $(date +"%T")" BB_Numero de filas en fichero-FULL limpio (${PATH_LIMPIO}semillas_betbright_full) = "$(wc -l "${PATH_LIMPIO}semillas_betbright_full")  2>&1 1>>${LOG_DESCARGA_BRUTO}
echo -e $(date +"%T")" BB_Ejemplo de filas en fichero-FULL limpio (${PATH_LIMPIO}semillas_betbright_full):\n"$(head -n 1 "${PATH_LIMPIO}semillas_betbright_full")  2>&1 1>>${LOG_DESCARGA_BRUTO}

consultar "DROP TABLE IF EXISTS datos_desa.tb_cg_semillas_betbright\W;" "${LOG_DESCARGA_BRUTO}" "-tN"
consultar "LOAD DATA LOCAL INFILE '${PATH_LIMPIO}semillas_betbright_full' INTO TABLE datos_desa.tb_cg_semillas_betbright FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n' IGNORE 0 LINES\W;" "$PATH_LIMPIO_GALGOS_BB_WARNINGS"
consultar "SELECT COUNT(*) as num_galgos_iniciales FROM datos_desa.tb_cg_semillas_betbright LIMIT 1\W;" "${LOG_DESCARGA_BRUTO}" "-t"
consultar "SELECT * FROM datos_desa.tb_cg_semillas_betbright LIMIT 3\W;" "${LOG_DESCARGA_BRUTO}" "-t"


#ASYNC: Fichero que indica que el proceso ha terminado, para que el padre lo sepa.
echo -e "Descarga de Betbright: OK" >> "$FLAG_BB_DESCARGADO_OK"

}


######## SUBGRUPOS #######################################################################
function analizarScoreSobreSubgrupos ()
{

PATH_LOG=${1}
echo -e $(date +"%T")" Analisis de subgrupos..." >>$PATH_LOG

#filtro_carreras filtro_galgos filtro_cg sufijo

#----Criterios simples ---
echo -e $(date +"%T")" --------" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD035.sh' "" "" "" "TOTAL"
${PATH_SCRIPTS}'galgos_MOD040.sh' "TOTAL" >>$PATH_LOG

echo -e $(date +"%T")" --------" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD035.sh' "" "" "WHERE id_carrera IN (SELECT DISTINCT id_carrera FROM datos_desa.tb_elaborada_carreras_pre WHERE distancia_norm <=0.33)" "DISTANCIA_CORTA"
${PATH_SCRIPTS}'galgos_MOD040.sh' "DISTANCIA_CORTA" >>$PATH_LOG

echo -e $(date +"%T")" --------" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD035.sh' "" "" "WHERE id_carrera IN (SELECT DISTINCT id_carrera FROM datos_desa.tb_elaborada_carreras_pre WHERE (distancia_norm >0.33 AND  distancia_norm <=0.66))" "DISTANCIA_MEDIA"
${PATH_SCRIPTS}'galgos_MOD040.sh' "DISTANCIA_MEDIA" >>$PATH_LOG

echo -e $(date +"%T")" --------" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD035.sh' "" "" "WHERE id_carrera IN (SELECT DISTINCT id_carrera FROM datos_desa.tb_elaborada_carreras_pre WHERE distancia_norm >0.66)" "DISTANCIA_LARGA"
${PATH_SCRIPTS}'galgos_MOD040.sh' "DISTANCIA_LARGA" >>$PATH_LOG


echo -e $(date +"%T")" --------" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD035.sh' "" "" "WHERE id_carrera IN (SELECT DISTINCT id_carrera FROM datos_desa.tb_elaborada_carreras_pre WHERE hora_norm <=0.33)" "HORA_PRONTO"
${PATH_SCRIPTS}'galgos_MOD040.sh' "HORA_PRONTO" >>$PATH_LOG

echo -e $(date +"%T")" --------" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD035.sh' "" "" "WHERE id_carrera IN (SELECT DISTINCT id_carrera FROM datos_desa.tb_elaborada_carreras_pre WHERE hora_norm >=0.66)" "HORA_TARDE"
${PATH_SCRIPTS}'galgos_MOD040.sh' "HORA_TARDE" >>$PATH_LOG


echo -e $(date +"%T")" --------" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD035.sh' "" "" "WHERE id_carrera IN ( SELECT id_carrera FROM datos_desa.tb_elaborada_carrerasgalgos_pre WHERE edad_en_dias_norm<=0.33 GROUP BY id_carrera HAVING count(*)>=5 )" "CON_5_GALGOS_JOVENES"
${PATH_SCRIPTS}'galgos_MOD040.sh' "CON_5_GALGOS_JOVENES" >>$PATH_LOG

echo -e $(date +"%T")" --------" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD035.sh' "" "" "WHERE id_carrera IN ( SELECT id_carrera FROM datos_desa.tb_elaborada_carrerasgalgos_pre WHERE edad_en_dias_norm<=0.66 GROUP BY id_carrera HAVING count(*)>=5 )" "CON_5_GALGOS_VIEJOS"
${PATH_SCRIPTS}'galgos_MOD040.sh' "CON_5_GALGOS_VIEJOS" >>$PATH_LOG


echo -e $(date +"%T")" --------" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD035.sh' "" "" "WHERE id_carrera IN ( SELECT id_carrera FROM datos_desa.tb_elaborada_carrerasgalgos_pre WHERE experiencia_en_clase is NULL OR experiencia_en_clase<=0.33 GROUP BY id_carrera HAVING count(*)>=5 )" "POCA_EXPER_EN_CLASE"
${PATH_SCRIPTS}'galgos_MOD040.sh' "POCA_EXPER_EN_CLASE" >>$PATH_LOG

echo -e $(date +"%T")" --------" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD035.sh' "" "" "WHERE id_carrera IN ( SELECT id_carrera FROM datos_desa.tb_elaborada_carrerasgalgos_pre WHERE experiencia_en_clase>=0.66 GROUP BY id_carrera HAVING count(*)>=5 )" "MUCHA_EXPER_EN_CLASE"
${PATH_SCRIPTS}'galgos_MOD040.sh' "MUCHA_EXPER_EN_CLASE" >>$PATH_LOG


echo -e $(date +"%T")" --------" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD035.sh' "" "" "WHERE id_carrera IN ( SELECT id_carrera FROM datos_desa.tb_elaborada_carrerasgalgos_pre WHERE peso_galgo_norm<=0.33 GROUP BY id_carrera HAVING count(*)>=5 )" "CON_5_GALGOS_DELGADOS"
${PATH_SCRIPTS}'galgos_MOD040.sh' "CON_5_GALGOS_DELGADOS" >>$PATH_LOG

echo -e $(date +"%T")" --------" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD035.sh' "" "" "WHERE id_carrera IN ( SELECT id_carrera FROM datos_desa.tb_elaborada_carrerasgalgos_pre WHERE peso_galgo_norm>=0.66 GROUP BY id_carrera HAVING count(*)=3 )" "CON_3_GALGOS_PESADOS"
${PATH_SCRIPTS}'galgos_MOD040.sh' "CON_3_GALGOS_PESADOS" >>$PATH_LOG


echo -e $(date +"%T")" --------" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD035.sh' "" "" "WHERE id_carrera IN ( SELECT DISTINCT id_carrera FROM datos_desa.tb_elaborada_carrerasgalgos_pre WHERE entrenador_posicion_norm>=0.5 )" "TRAINER_BUENOS_GALGOS"
${PATH_SCRIPTS}'galgos_MOD040.sh' "TRAINER_BUENOS_GALGOS" >>$PATH_LOG

echo -e $(date +"%T")" --------" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD035.sh' "" "" "WHERE id_carrera IN ( SELECT DISTINCT id_carrera FROM datos_desa.tb_elaborada_carrerasgalgos_pre WHERE entrenador_posicion_norm<0.5 )" "TRAINER_MALOS_GALGOS"
${PATH_SCRIPTS}'galgos_MOD040.sh' "TRAINER_MALOS_GALGOS" >>$PATH_LOG


#----Criterios COMPLEJOS ---

echo -e $(date +"%T")" --------" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD035.sh' "" "" "WHERE id_carrera IN (SELECT DISTINCT id_carrera FROM datos_desa.tb_elaborada_carreras_pre WHERE distancia_norm >0.66) AND id_carrera IN ( SELECT DISTINCT id_carrera FROM datos_desa.tb_elaborada_carrerasgalgos_pre WHERE galgo_nombre IN (SELECT DISTINCT galgo_nombre FROM datos_desa.tb_elaborada_galgos_pre WHERE vel_going_largas_max_norm<=0.33 ) )" "LARGA_Y_ALGUNO_LENTO"
${PATH_SCRIPTS}'galgos_MOD040.sh' "LARGA_Y_ALGUNO_LENTO" >>$PATH_LOG

}
##########################################################################################


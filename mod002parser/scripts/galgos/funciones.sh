#!/bin/bash

DATASET_TEST_PORCENTAJE="0.10"
DATASET_VALIDATION_PORCENTAJE="0.40"
RENTABILIDAD_MINIMA="25"
PORCENTAJE_SUFICIENTES_CASOS="0.1"

PATH_SCRIPTS="/home/carloslinux/git/bdml/mod002parser/scripts/galgos/"
PATH_JAR="/home/carloslinux/git/bdml/mod002parser/target/mod002parser-jar-with-dependencies.jar"
PATH_BRUTO="/home/carloslinux/Desktop/DATOS_BRUTO/galgos/"
PATH_LIMPIO="/home/carloslinux/Desktop/DATOS_LIMPIO/galgos/"
PATH_INFORMES="/home/carloslinux/Desktop/INFORMES/"
PATH_LOGS="/home/carloslinux/Desktop/LOGS/"
PATH_EXTERNAL_DATA="/home/carloslinux/Desktop/EXTERNAL/"
PATH_MYSQL_PRIV_SECURE="/var/lib/mysql-files/"

TAG_GBGB="GBGB"
FILE_SENTENCIAS_CREATE_TABLE="${PATH_LIMPIO}galgos_sentencias_create_table"
PATH_FILE_GALGOS_INICIALES="${PATH_LIMPIO}galgos_iniciales.txt"
PATH_FILE_GALGOS_INICIALES_FULL="${PATH_FILE_GALGOS_INICIALES}_full"
PATH_LIMPIO_CARRERAS="${PATH_LIMPIO}tb_galgos_carreras_file"
PATH_LIMPIO_POSICIONES="${PATH_LIMPIO}tb_galgos_posiciones_en_carreras_file"
PATH_LIMPIO_HISTORICO="${PATH_LIMPIO}tb_galgos_historico_file"
PATH_LIMPIO_AGREGADOS="${PATH_LIMPIO}tb_galgos_agregados_file"
PATH_LIMPIO_GALGOS_INICIALES_WARNINGS="${PATH_LIMPIO}warnings_galgos_iniciales"
PATH_LIMPIO_CARRERAS_WARNINGS="${PATH_LIMPIO}warnings_carreras"
PATH_LIMPIO_POSICIONES_WARNINGS="${PATH_LIMPIO}warnings_posiciones"
PATH_LIMPIO_HISTORICO_WARNINGS="${PATH_LIMPIO}warnings_historico"
PATH_LIMPIO_AGREGADOS_WARNINGS="${PATH_LIMPIO}warnings_agregados"
PATH_LIMPIO_ESTADISTICAS="${PATH_LIMPIO}galgos_limpio_estadisticas"

LOG_MASTER="${PATH_LOGS}galgos_coordinador.log"
PATH_BRUTO_SEMILLAS_SPORTIUM="${PATH_BRUTO}semillas_sportium"
LOG_DESCARGA_BRUTO="${PATH_LOGS}galgos_010_descarga_bruto.log"

LOG_DESCARGA_BRUTO_BB="${PATH_LOGS}galgos_010_descarga_bruto_BB.log"
FLAG_BB_DESCARGADO_OK="${PATH_LOGS}galgos_010_BB.descargado.OK"
LOG_010_FUT="${PATH_LOGS}galgos_010_FUT.log"
LOG_011="${PATH_LOGS}galgos_011_limpieza.log"
LOG_012="${PATH_LOGS}galgos_012_normalizacion.log"
LOG_019_EXPORT="${PATH_LOGS}galgos_019_export.log"
LOG_020_ESTADISTICA="${PATH_LOGS}galgos_020_stats.log"
LOG_CE="${PATH_LOGS}galgos_031_columnas_elaboradas.log"
LOG_DS="${PATH_LOGS}galgos_037_datasets.log"
LOG_DS_COLPEN="${PATH_LOGS}galgos_037_datasets_COLUMNAS_PENDIENTES.log"
LOG_038_DS_TTV="${PATH_LOGS}galgos_038_datasets_TTV.log"
FILELOAD_RENTABILIDADES="${PATH_LOGS}galgos_040_FILELOAD_RENTABILIDADES.txt"
SUBGRUPO_GANADOR_FILE="${PATH_LOGS}temp_subgrupo_ganador.txt"
LOG_ML="${PATH_LOGS}galgos_040_ML.log"
LOG_041="${PATH_LOGS}galgos_041_1o2.log"
LOG_042="${PATH_LOGS}galgos_042_1st.log"
LOG_045="${PATH_LOGS}galgos_045_PRED_FUT.log"
LOG_050="${PATH_LOGS}galgos_050_prediccion.log"
LOG_060_TABLAS="${PATH_LOGS}galgos_060_tablas.log"
LOG_060_ENDTOEND="${PATH_LOGS}galgos_060_endtoend.log"
LOG_061="${PATH_LOGS}galgos_061_export.log"
LOG_070="${PATH_LOGS}INFORME_TIC.txt"
LOG_080="${PATH_LOGS}galgos_080_guardar_info_productiva.txt"
LOG_099="${PATH_LOGS}galgos_099_posteriori_bruto.txt"
LOG_999_LIMPIEZA_FINAL="${PATH_LOGS}galgos_999_limpieza.log"

PATH_RENTABILIDADES_WARNINGS="${PATH_LIMPIO}warnings_rentabilidades"
INFORME_CONFIG_010="${PATH_LOGS}INFORME_CONFIG_010.txt"
INFORME_RENTABILIDADES="${PATH_LOGS}INFORME_RENTABILIDADES.txt"
INFORME_PREDICCIONES="${PATH_LOGS}INFORME_PREDICCIONES.txt"
INFORME_PREDICCIONES_COMANDOS="${PATH_LOGS}INFORME_PREDICCIONES_COMANDOS.sh"
INFORME_BRUTO_POSTERIORI="${PATH_LOGS}INFORME_BRUTO_POSTERIORI.txt"
INFORME_LIMPIO_POSTERIORI="${PATH_LOGS}INFORME_LIMPIO_POSTERIORI.txt"

EXTERNAL_010_BRUTO="${PATH_EXTERNAL_DATA}010_BRUTOS/"
EXTERNAL_012_LIMNOR="${PATH_EXTERNAL_DATA}012_LIMNOR/"
EXTERNAL_037_DS_PASADOS_SPLIT="${PATH_EXTERNAL_DATA}037_DS_PASADOS_SPLIT/"
EXTERNAL_038_DS_PASADOS="${PATH_EXTERNAL_DATA}038_DS_PASADOS/"
EXTERNAL_050_DS_FUTUROS="${PATH_EXTERNAL_DATA}050_DS_FUTUROS/"

#########################################################################

function consultar(){
  sentencia_sql=${1}
  path_log_sql=${2}
  opciones=${3}
  mysql ${opciones} --execute="${sentencia_sql}" 2>&1 1>>${path_log_sql}
}

function consultar_sobreescribirsalida(){
  sentencia_sql=${1}
  path_output_file=${2}
  opciones=${3}
  mysql ${opciones} --execute="${sentencia_sql}" >"$path_output_file"
  sleep 2s
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

rm -f "${LOG_DESCARGA_BRUTO_BB}"

echo -e "MOD010_BB --> LOG = "${LOG_DESCARGA_BRUTO_BB}

echo -e $(date +"%T")" Descargando todas las carreras FUTURAS de BETBRIGHT usando un navegador..." 2>&1 1>>${LOG_DESCARGA_BRUTO_BB}
BB_URL_TODAY="www.betbright.com/greyhound-racing/today"
BB_URL_TOMORROW="www.betbright.com/greyhound-racing/tomorrow"
BB_BRUTO_GALGOS="/home/carloslinux/Desktop/DATOS_BRUTO/galgos/betbright/"
BB_FICHERO_PREFIJO="${BB_BRUTO_GALGOS}betbright_"
BB_FICHERO_TODAY="${BB_BRUTO_GALGOS}betbright_today.html"
BB_FICHERO_TOMORROW="${BB_BRUTO_GALGOS}betbright_tomorrow.html"

BB_LIMPIO_GALGOS="/home/carloslinux/Desktop/DATOS_LIMPIO/galgos/betbright/"
PATH_FILE_GALGOS_INICIALES_BB="${BB_LIMPIO_GALGOS}galgos_iniciales_bb.txt"


echo -e $(date +"%T")" Borrando todos estos ficheros ( rm -fR ${BB_BRUTO_GALGOS}* ):" 2>&1 1>>${LOG_DESCARGA_BRUTO_BB}
rm -fR "${BB_BRUTO_GALGOS}" 2>&1 1>>${LOG_DESCARGA_BRUTO_BB}
rm -fR "${BB_LIMPIO_GALGOS}" 2>&1 1>>${LOG_DESCARGA_BRUTO_BB}

echo -e "Comprobando si se han borrado los ficheros antiguos:" 2>&1 1>>${LOG_DESCARGA_BRUTO_BB}
echo -e $(ls -l "${BB_BRUTO_GALGOS}" | grep ' betbright'  ) 2>&1 1>>${LOG_DESCARGA_BRUTO_BB}
echo -e $(ls -l "${BB_LIMPIO_GALGOS}" | grep ' betbright'  ) 2>&1 1>>${LOG_DESCARGA_BRUTO_BB}

echo -e $(date +"%T")" Creando directorio (VACIO): ${BB_BRUTO_GALGOS}" 2>&1 1>>${LOG_DESCARGA_BRUTO_BB}
mkdir "${BB_BRUTO_GALGOS}" 2>&1 1>>${LOG_DESCARGA_BRUTO_BB}
mkdir "${BB_LIMPIO_GALGOS}" 2>&1 1>>${LOG_DESCARGA_BRUTO_BB}


num_betbright_restantes=$(ls -l "${BB_BRUTO_GALGOS}" | grep ' betbright'  | wc -l)
echo -e $(date +"%T")" Comprobacion de ficheros NO borrados = "${num_betbright_restantes} 2>&1 1>>${LOG_DESCARGA_BRUTO_BB}
if [ ${num_betbright_restantes} -gt 0 ]
  then
    echo -e $(date +"%T")" ERROR No se han borrado bien los ficheros antiguos de Betbright. RESTANTES="${num_betbright_restantes} 2>&1 1>>${LOG_DESCARGA_BRUTO_BB}
    exit -1
fi


echo -e $(date +"%T")" Descarga de carreras BB-FUTURAS-TODAY a fichero = "${BB_FICHERO_TODAY} 2>&1 1>>${LOG_DESCARGA_BRUTO_BB}
"${PATH_SCRIPTS}save_page_as.sh" "${BB_URL_TODAY}" --destination "${BB_FICHERO_TODAY}" --browser "google-chrome" --load-wait-time 4 --save-wait-time 3
sleep 3s #necesario
echo -e $(date +"%T")" Descarga de carreras BB-FUTURAS-TOMORROW a fichero = "${BB_FICHERO_TOMORROW} 2>&1 1>>${LOG_DESCARGA_BRUTO_BB}
"${PATH_SCRIPTS}save_page_as.sh" "${BB_URL_TOMORROW}" --destination "${BB_FICHERO_TOMORROW}" --browser "google-chrome" --load-wait-time 4 --save-wait-time 3
sleep 3s #necesario

echo -e $(date +"%T")" Borrando ${PATH_FILE_GALGOS_INICIALES_BB} ..." 2>&1 1>>${LOG_DESCARGA_BRUTO_BB}
rm -fR "${PATH_FILE_GALGOS_INICIALES_BB}" 2>&1 1>>${LOG_DESCARGA_BRUTO_BB}
echo -e $(date +"%T")" Comprobando ficheros borrados:" 2>&1 1>>${LOG_DESCARGA_BRUTO_BB}
echo -e $(date +"%T")" "$(ls -l "${PATH_FILE_GALGOS_INICIALES_BB}") 2>&1 1>>${LOG_DESCARGA_BRUTO_BB}
echo -e "" > ${PATH_FILE_GALGOS_INICIALES_BB} 2>&1 1>>${LOG_DESCARGA_BRUTO_BB}

echo -e $(date +"%T")" Parseando las carreras FUTURAS (today y tomorrow) de BETBRIGHT mediante JAVA para guardarlas aqui: ${PATH_FILE_GALGOS_INICIALES_BB}\n\n" 2>&1 1>>${LOG_DESCARGA_BRUTO_BB}
java -jar ${PATH_JAR} "GALGOS_02_BETBRIGHT" "${BB_FICHERO_PREFIJO}" "${PATH_FILE_GALGOS_INICIALES_BB}" 2>&1 1>>${LOG_DESCARGA_BRUTO_BB}


echo -e $(date +"%T")" PASO01_Comprobando ficheros de URLs ( ${PATH_FILE_GALGOS_INICIALES_BB} ):" 2>&1 1>>${LOG_DESCARGA_BRUTO_BB}
echo -e $(date +"%T")" "$(head -n 10 "${PATH_FILE_GALGOS_INICIALES_BB}") 2>&1 1>>${LOG_DESCARGA_BRUTO_BB}


### BB-DETALLES
echo -e $(date +"%T")" Leemos fichero con URLs y descargamos los ficheros de detalle, uno a uno..." 2>&1 1>>${LOG_DESCARGA_BRUTO_BB}


PATH_FILE_GALGOS_INICIALES_BB_FULL="${PATH_FILE_GALGOS_INICIALES_BB}_full"
BB_FICHEROS_DET="/home/carloslinux/Desktop/DATOS_BRUTO/galgos/betbright/semillas_betbright_DET_*"
PATH_LIMPIO_GALGOS_BB_WARNINGS="/home/carloslinux/Desktop/DATOS_LIMPIO/galgos/warnings_galgos_bb"


echo -e $(date +"%T")" Borrando ${PATH_FILE_GALGOS_INICIALES_BB_FULL} ..." 2>&1 1>>${LOG_DESCARGA_BRUTO_BB}
rm -fR "${PATH_FILE_GALGOS_INICIALES_BB_FULL}" 2>&1 1>>${LOG_DESCARGA_BRUTO_BB}
echo -e $(date +"%T")" Comprobando ficheros borrados:" 2>&1 1>>${LOG_DESCARGA_BRUTO_BB}
echo -e $(date +"%T")" "$(ls -l "${PATH_FILE_GALGOS_INICIALES_BB_FULL}") 2>&1 1>>${LOG_DESCARGA_BRUTO_BB}
echo -e "" > ${PATH_FILE_GALGOS_INICIALES_BB_FULL} 2>&1 1>>${LOG_DESCARGA_BRUTO_BB}

echo -e $(date +"%T")" Leemos todas las URLs de detalles (del fichero) y descargamos cada detalle uno a uno mediante script externo. La ruta de cada FICHERO BRUTO DE DETALLE debe ser: ${PATH_BRUTO}semillas_betbright_DET_XXX (donde XXX es 1, 2... 10,11...111,112)" 2>&1 1>>${LOG_DESCARGA_BRUTO_BB}


echo -e $(date +"%T")" Borrando todos estos ficheros: ${BB_FICHEROS_DET}" 2>&1 1>>${LOG_DESCARGA_BRUTO_BB}
rm -fR ${BB_FICHEROS_DET} 2>&1 1>>${LOG_DESCARGA_BRUTO_BB}


counter=0
nombreFicheroDetalle=""

while IFS= read -r urlDetalle
do
  ((counter++))
  nombreFicheroDetalle="${BB_BRUTO_GALGOS}semillas_betbright_DET_${counter}.html"
  
  #DEBUG: podemos limitar este contador de carreras futuras a descargar (ver linea siguiente)
  
  if [ $counter -le 100 ]
  then
    echo -e $(date +"%T")" #=$counter | URL=$urlDetalle | File=${nombreFicheroDetalle}" 2>&1 1>>${LOG_DESCARGA_BRUTO_BB}
    
    "${PATH_SCRIPTS}save_page_as.sh" "${urlDetalle}" --destination "${nombreFicheroDetalle}" --browser "google-chrome" --load-wait-time 4 --save-wait-time 3  2>&1 1>>${LOG_DESCARGA_BRUTO_BB}

    #echo -e $(date +"%T") Ficheros acumulados en iteracion=$counter son: \n" $(ls -l '${BB_BRUTO_GALGOS}' | grep '_DET_' | grep '.html')  2>&1 1>>${LOG_DESCARGA_BRUTO_BB}

  fi
done <"${PATH_FILE_GALGOS_INICIALES_BB}"


echo -e $(date +"%T")" PASO02_Comprobando ficheros de URLs ( ${PATH_FILE_GALGOS_INICIALES_BB} ):" 2>&1 1>>${LOG_DESCARGA_BRUTO_BB}
echo -e $(date +"%T")" "$(head -n 10 "${PATH_FILE_GALGOS_INICIALES_BB}") 2>&1 1>>${LOG_DESCARGA_BRUTO_BB}


java -jar ${PATH_JAR} "GALGOS_02_BETBRIGHT_DETALLES" "${PATH_BRUTO}semillas_betbright" "${PATH_FILE_GALGOS_INICIALES_BB}" 2>&1 1>>${LOG_DESCARGA_BRUTO_BB}


echo -e $(date +"%T")" BB_Numero de filas en fichero-FULL limpio (${PATH_LIMPIO}semillas_betbright_full) = "$(wc -l "${PATH_LIMPIO}semillas_betbright_full")  2>&1 1>>${LOG_DESCARGA_BRUTO_BB}
echo -e $(date +"%T")" BB_Ejemplo de filas en fichero-FULL limpio (${PATH_LIMPIO}semillas_betbright_full):\n"$(head -n 1 "${PATH_LIMPIO}semillas_betbright_full")  2>&1 1>>${LOG_DESCARGA_BRUTO_BB}

consultar "TRUNCATE TABLE datos_desa.tb_cg_semillas_betbright\W;" "${LOG_DESCARGA_BRUTO_BB}" "-tN"
consultar "LOAD DATA LOCAL INFILE '${PATH_LIMPIO}semillas_betbright_full' INTO TABLE datos_desa.tb_cg_semillas_betbright FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n' IGNORE 0 LINES\W;" "$PATH_LIMPIO_GALGOS_BB_WARNINGS"
consultar "SELECT COUNT(*) as num_galgos_iniciales FROM datos_desa.tb_cg_semillas_betbright LIMIT 1\W;" "${LOG_DESCARGA_BRUTO_BB}" "-t"
consultar "SELECT * FROM datos_desa.tb_cg_semillas_betbright LIMIT 3\W;" "${LOG_DESCARGA_BRUTO_BB}" "-t"


echo -e $(date +"%T")" BETBRIGHT-ASYNC: Fichero que indica que el proceso ha terminado, para que el padre lo sepa." 2>&1 1>>${LOG_DESCARGA_BRUTO_BB}
echo -e " Descarga de Betbright: OK" >> "${FLAG_BB_DESCARGADO_OK}"

}


########################### REMARKS-PUNTOS #################################
function insertSelectRemark ()
{
  remark_in="${1}"

  echo -e "Calculando peso del remark='${remark_in}'..." 2>&1 1>>${LOG_CE}

read -d '' CONSULTA_REMARKS_PUNTOS <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_remark_puntos_1;

CREATE TABLE datos_desa.tb_remark_puntos_1 AS SELECT posicion, count(*) as contador FROM datos_desa.tb_galgos_historico_norm WHERE remarks LIKE '%${remark_in}%' GROUP BY posicion;

set @sum_contador=(SELECT  SUM(contador) FROM datos_desa.tb_remark_puntos_1);

DROP TABLE IF EXISTS datos_desa.tb_remark_puntos_2;
CREATE TABLE datos_desa.tb_remark_puntos_2 AS SELECT posicion, contador/@sum_contador AS puntos_norm FROM datos_desa.tb_remark_puntos_1;

INSERT INTO datos_desa.tb_remarks_puntos(remark,posicion,remark_puntos_norm) SELECT '${remark_in}' AS remark, posicion, CAST(puntos_norm AS decimal(20,6)) AS remark_puntos_norm FROM datos_desa.tb_remark_puntos_2;
EOF

  echo -e "$CONSULTA_REMARKS_PUNTOS" 2>&1 1>>${LOG_CE}
  mysql -e "$CONSULTA_REMARKS_PUNTOS" 2>&1 1>>${LOG_CE}
}


function crearTablaRemarksPuntos ()
{
echo -e "La tabla de remarks_puntos indica el PESO/INFLUENCIA que tiene cada REMARK en el campo POSICION. Es una especie de 'posición normalizada mirando solo remarks'" 2>&1 1>>${LOG_CE}

CONSULTA_DROP="DROP TABLE IF EXISTS datos_desa.tb_remarks_puntos;"
mysql -e "$CONSULTA_DROP" 2>&1 1>>${LOG_CE}

CONSULTA_CREAR="CREATE TABLE datos_desa.tb_remarks_puntos (remark varchar(20) CHARACTER SET utf8 NOT NULL DEFAULT '', posicion SMALLINT DEFAULT NULL, remark_puntos_norm decimal(20,2) ) ENGINE=InnoDB DEFAULT CHARSET=latin1;"
mysql -e "$CONSULTA_CREAR" 2>&1 1>>${LOG_CE}

echo -e "$CONSULTA_DROP" 2>&1 1>>${LOG_CE}
echo -e "$CONSULTA_CREAR" 2>&1 1>>${LOG_CE}

#Calcular e INSERTAR los puntos NORMALIZADOS (peso) de influencia en la posición, por tener cada remark
insertSelectRemark 'Crd'
insertSelectRemark 'Crowd'
insertSelectRemark 'Wide'
insertSelectRemark 'RanOn'
insertSelectRemark 'Led'
insertSelectRemark 'AlwaysLed'
insertSelectRemark 'ClearRun'
insertSelectRemark 'Handy'
insertSelectRemark 'RunUp'
insertSelectRemark 'Rls'
insertSelectRemark 'Baulked'
insertSelectRemark 'Blk'
insertSelectRemark 'Mid'
insertSelectRemark 'SAw'
insertSelectRemark 'Bmp'

#PENDIENTE Los acronimos Crd=Crowd=Crowded, AlwaysHandy=AHandy, ... Por tanto, debo modificar la funcion insertSelectRemark para que acepte un parametro (ej: 'Crd#Crowd#Crowded') para que filtre considerando que significa lo mismo.
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
${PATH_SCRIPTS}'galgos_MOD035.sh' "" "" "WHERE id_carrera IN (SELECT DISTINCT id_carrera FROM datos_desa.tb_elaborada_carreras_pre WHERE dow_l=1)" "DOW_L"
${PATH_SCRIPTS}'galgos_MOD040.sh' "DOW_L" >>$PATH_LOG

echo -e $(date +"%T")" --------" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD035.sh' "" "" "WHERE id_carrera IN (SELECT DISTINCT id_carrera FROM datos_desa.tb_elaborada_carreras_pre WHERE dow_m=1)" "DOW_M"
${PATH_SCRIPTS}'galgos_MOD040.sh' "DOW_M" >>$PATH_LOG

echo -e $(date +"%T")" --------" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD035.sh' "" "" "WHERE id_carrera IN (SELECT DISTINCT id_carrera FROM datos_desa.tb_elaborada_carreras_pre WHERE dow_x=1)" "DOW_X"
${PATH_SCRIPTS}'galgos_MOD040.sh' "DOW_X" >>$PATH_LOG

echo -e $(date +"%T")" --------" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD035.sh' "" "" "WHERE id_carrera IN (SELECT DISTINCT id_carrera FROM datos_desa.tb_elaborada_carreras_pre WHERE dow_j=1)" "DOW_J"
${PATH_SCRIPTS}'galgos_MOD040.sh' "DOW_J" >>$PATH_LOG

echo -e $(date +"%T")" --------" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD035.sh' "" "" "WHERE id_carrera IN (SELECT DISTINCT id_carrera FROM datos_desa.tb_elaborada_carreras_pre WHERE dow_v=1)" "DOW_V"
${PATH_SCRIPTS}'galgos_MOD040.sh' "DOW_V" >>$PATH_LOG

echo -e $(date +"%T")" --------" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD035.sh' "" "" "WHERE id_carrera IN (SELECT DISTINCT id_carrera FROM datos_desa.tb_elaborada_carreras_pre WHERE dow_s=1)" "DOW_S"
${PATH_SCRIPTS}'galgos_MOD040.sh' "DOW_S" >>$PATH_LOG

echo -e $(date +"%T")" --------" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD035.sh' "" "" "WHERE id_carrera IN (SELECT DISTINCT id_carrera FROM datos_desa.tb_elaborada_carreras_pre WHERE dow_d=1)" "DOW_D"
${PATH_SCRIPTS}'galgos_MOD040.sh' "DOW_D" >>$PATH_LOG

echo -e $(date +"%T")" --------" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD035.sh' "" "" "WHERE id_carrera IN (SELECT DISTINCT id_carrera FROM datos_desa.tb_elaborada_carreras_pre WHERE dow_laborable=1)" "DOW_LAB"
${PATH_SCRIPTS}'galgos_MOD040.sh' "DOW_LAB" >>$PATH_LOG

echo -e $(date +"%T")" --------" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD035.sh' "" "" "WHERE id_carrera IN (SELECT DISTINCT id_carrera FROM datos_desa.tb_elaborada_carreras_pre WHERE dow_finde=1)" "DOW_FIN"
${PATH_SCRIPTS}'galgos_MOD040.sh' "DOW_FIN" >>$PATH_LOG


#echo -e $(date +"%T")" --------" >>$PATH_LOG
#${PATH_SCRIPTS}'galgos_MOD035.sh' "" "" "WHERE id_carrera IN (SELECT DISTINCT id_carrera FROM datos_desa.tb_elaborada_carreras_pre WHERE distancia_norm <=0.33)" "DISTANCIA_CORTA"
#${PATH_SCRIPTS}'galgos_MOD040.sh' "DISTANCIA_CORTA" >>$PATH_LOG

#echo -e $(date +"%T")" --------" >>$PATH_LOG
#${PATH_SCRIPTS}'galgos_MOD035.sh' "" "" "WHERE id_carrera IN (SELECT DISTINCT id_carrera FROM datos_desa.tb_elaborada_carreras_pre WHERE (distancia_norm >0.33 AND  distancia_norm <=0.66))" "DISTANCIA_MEDIA"
#${PATH_SCRIPTS}'galgos_MOD040.sh' "DISTANCIA_MEDIA" >>$PATH_LOG

#echo -e $(date +"%T")" --------" >>$PATH_LOG
#${PATH_SCRIPTS}'galgos_MOD035.sh' "" "" "WHERE id_carrera IN (SELECT DISTINCT id_carrera FROM datos_desa.tb_elaborada_carreras_pre WHERE distancia_norm >0.66)" "DISTANCIA_LARGA"
#${PATH_SCRIPTS}'galgos_MOD040.sh' "DISTANCIA_LARGA" >>$PATH_LOG


echo -e $(date +"%T")" --------" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD035.sh' "" "" "WHERE id_carrera IN (SELECT DISTINCT id_carrera FROM datos_desa.tb_elaborada_carreras_pre WHERE hora_norm <= 0.33)" "HORA_PRONTO"
${PATH_SCRIPTS}'galgos_MOD040.sh' "HORA_PRONTO" >>$PATH_LOG

echo -e $(date +"%T")" --------" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD035.sh' "" "" "WHERE id_carrera IN (SELECT DISTINCT id_carrera FROM datos_desa.tb_elaborada_carreras_pre WHERE hora_norm >= 0.3 AND hora_norm <= 0.7)" "HORA_MEDIA"
${PATH_SCRIPTS}'galgos_MOD040.sh' "HORA_MEDIA" >>$PATH_LOG

echo -e $(date +"%T")" --------" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD035.sh' "" "" "WHERE id_carrera IN (SELECT DISTINCT id_carrera FROM datos_desa.tb_elaborada_carreras_pre WHERE hora_norm >= 0.66 )" "HORA_TARDE"
${PATH_SCRIPTS}'galgos_MOD040.sh' "HORA_TARDE" >>$PATH_LOG


echo -e $(date +"%T")" --------" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD035.sh' "" "" "WHERE id_carrera IN ( SELECT id_carrera FROM datos_desa.tb_elaborada_carrerasgalgos_pre WHERE edad_en_dias_norm <= 0.33 GROUP BY id_carrera HAVING count(*)>=5 )" "CON_5_GALGOS_JOVENES"
${PATH_SCRIPTS}'galgos_MOD040.sh' "CON_5_GALGOS_JOVENES" >>$PATH_LOG

echo -e $(date +"%T")" --------" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD035.sh' "" "" "WHERE id_carrera IN ( SELECT id_carrera FROM datos_desa.tb_elaborada_carrerasgalgos_pre WHERE edad_en_dias_norm <= 0.66 GROUP BY id_carrera HAVING count(*)>=5 )" "CON_5_GALGOS_VIEJOS"
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

#echo -e $(date +"%T")" --------" >>$PATH_LOG
#${PATH_SCRIPTS}'galgos_MOD035.sh' "" "" "WHERE id_carrera IN (SELECT DISTINCT id_carrera FROM datos_desa.tb_elaborada_carreras_pre WHERE distancia_norm >0.66) AND id_carrera IN ( SELECT DISTINCT id_carrera FROM datos_desa.tb_elaborada_carrerasgalgos_pre WHERE galgo_nombre IN (SELECT DISTINCT galgo_nombre FROM datos_desa.tb_elaborada_galgos_pre WHERE vel_going_largas_max_norm<=0.33 ) )" "LARGA_Y_ALGUNO_LENTO"
#${PATH_SCRIPTS}'galgos_MOD040.sh' "LARGA_Y_ALGUNO_LENTO" >>$PATH_LOG
}



##########################################################################################

######## MOD040 - ECONOMIA #######################################################################
function resetTablaRentabilidades ()
{
echo -e $(date +"%T")" Creando tabla de rentabilidades..." 2>&1 1>>${LOG_ML}
consultar "DROP TABLE IF EXISTS datos_desa.tb_rentabilidades\W;" "${LOG_ML}" "-tN"
consultar "CREATE TABLE IF NOT EXISTS datos_desa.tb_rentabilidades (tipo_prediccion varchar(10) NOT NULL, dataset_probado varchar(50) NOT NULL, subgrupo varchar(200) NOT NULL, grupo_sp varchar(15) NOT NULL, aciertos INT, casos INT, cobertura_sg_sp DECIMAL(10,4), rentabilidad_porciento DECIMAL(10,4))\W;" "${LOG_DESCARGA_BRUTO}" "-tN"

rm -f $FILELOAD_RENTABILIDADES #vacío
}


function calculoEconomicoPasado ()
{
tag_prediccion="${1}"     #Toma los valores: '1st' ó '1o2'
filtro_posicion_predicha="${2}" #Toma los valores: '1' ó '1,2'
sp_min="${3}"     #Limite inferior (inclusive) del grupo según SP
sp_max="${4}"     #Limite superior (excluido) del grupo según SP
tag_grupo_sp="${5}"    #TAG que identifica al grupo según SP
tag_subgrupo="${6}"    #TAG del subgrupo de analisis (calculado en modulo 035)
dinero_gastado="${7}"	#Dinero gastado por apuesta
log_ml_tipo="${8}"	#log concreto

echo -e "ECONOMICO sobre DS-PASADO-VALIDATION -->[Prediccion|filtro_pos|sp_min|sp_max|grupo_sp|subgrupo] = [$tag_prediccion|$filtro_posicion_predicha|$sp_min|$sp_max|$tag_grupo_sp|$tag_subgrupo]" 2>&1 1>>${log_ml_tipo}

read -d '' CONSULTA_ECONOMICA <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_val_${tag_prediccion}_economico_${TAG}_${tag_grupo_sp};

CREATE TABLE datos_desa.tb_val_${tag_prediccion}_economico_${TAG}_${tag_grupo_sp} AS
SELECT A.*, GH.sp, ${dinero_gastado} AS gastado_${tag_prediccion}, acierto * 1 * sp AS beneficio_bruto 
FROM datos_desa.tb_val_${tag_prediccion}_riesgo_${TAG} A 
INNER JOIN datos_desa.tb_galgos_historico_norm GH 
ON (
  A.id_carrera=GH.id_carrera 
  AND A.galgo_nombre=GH.galgo_nombre 
  AND A.posicion_predicha IN ( $filtro_posicion_predicha ) 
  AND GH.sp >= ${sp_min} AND GH.sp < ${sp_max}  
);


SELECT 'NULOS' AS tipo, count(*) AS contador_${tag_grupo_sp} 
FROM datos_desa.tb_val_${tag_prediccion}_economico_${TAG}_${tag_grupo_sp} 
WHERE beneficio_bruto IS NULL
UNION ALL   
SELECT 'LLENOS' AS tipo, count(*) AS contador 
FROM datos_desa.tb_val_${tag_prediccion}_economico_${TAG}_${tag_grupo_sp} 
WHERE beneficio_bruto IS NOT NULL
LIMIT 10;
EOF

echo -e "$CONSULTA_ECONOMICA" 2>&1 1>>${log_ml_tipo}
mysql -t --execute="$CONSULTA_ECONOMICA" 2>&1 1>>${log_ml_tipo}

FILE_TEMP_PRED="./temp_MOD040_num_predicciones"
rm -f ${FILE_TEMP_PRED}
mysql -N --execute="SELECT count(*) AS contador FROM datos_desa.tb_val_${tag_prediccion}_economico_${TAG}_${tag_grupo_sp} WHERE beneficio_bruto IS NOT NULL LIMIT 10;" > ${FILE_TEMP_PRED}
numero_predicciones_grupo_sp=$(cat ${FILE_TEMP_PRED})

FILE_TEMP="./temp_MOD040_rentabilidad"
rm -f ${FILE_TEMP}
mysql -N --execute="SELECT ROUND( 100.0 * SUM( beneficio_bruto - gastado_${tag_prediccion} )/SUM(gastado_${tag_prediccion}) , 2) AS rentabilidad FROM datos_desa.tb_val_${tag_prediccion}_economico_${TAG}_${tag_grupo_sp};" > ${FILE_TEMP}
rentabilidad=$( cat ${FILE_TEMP})

FILE_TEMP="./temp_MOD040_num_ciertos_gruposp"
#Numeros: SOLO pongo el dinero en las que el sistema me predice 1st o 1o2, pero no en las otras predichas.
mysql -N --execute="SELECT SUM(acierto) as num_aciertos_gruposp FROM datos_desa.tb_val_${tag_prediccion}_economico_${TAG}_${tag_grupo_sp} LIMIT 1;" > ${FILE_TEMP}
numero_aciertos_gruposp=$( cat ${FILE_TEMP})


COBERTURA_SUBGRUPO_GRUPOSP=$(echo "scale=2; $numero_aciertos_gruposp / $numero_predicciones_grupo_sp" | bc -l)

####SALIDA
MENSAJE="${tag_prediccion}|DS_PASADO_VALIDATION|${TAG}|${tag_grupo_sp}|${numero_aciertos_gruposp}|${numero_predicciones_grupo_sp}|${COBERTURA_SUBGRUPO_GRUPOSP}|${rentabilidad}"

echo -e "${MENSAJE}" 2>&1 1>>${log_ml_tipo}
echo -e "${MENSAJE}" 2>&1 1>>${FILELOAD_RENTABILIDADES}

}


function cargarTablaRentabilidades ()
{
  echo -e $(date +"%T")" Cargando tabla de rentabilidades..." 2>&1 1>>${LOG_ML}
  consultar_sobreescribirsalida "LOAD DATA LOCAL INFILE '${FILELOAD_RENTABILIDADES}' INTO TABLE datos_desa.tb_rentabilidades FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n' IGNORE 0 LINES\W;" "$PATH_RENTABILIDADES_WARNINGS"
}


function analisisRentabilidadesPorSubgrupos(){

  resetTablaRentabilidades #Reseteando tabla de rentabilidades
  analizarScoreSobreSubgrupos "$LOG_MASTER"

  #Cargando fichero de rentabilidades a la tabla
  echo -e "ATENCION: Solo pongo DINERO en las carreras predichas y que sean rentables (en los grupo_sp que tengan muchos casos) !!!!\n" 2>&1 1>>${LOG_ML}
  cargarTablaRentabilidades

  rm -f "$INFORME_RENTABILIDADES"
  echo -e "******** Informe de RENTABILIDADES ********" >>${INFORME_RENTABILIDADES}

  echo -e "\nDATASETS --> [TRAIN + TEST + *VALIDATION] = [100-test-validation + $DATASET_TEST_PORCENTAJE + $DATASET_VALIDATION_PORCENTAJE ]" 2>&1 1>>${INFORME_RENTABILIDADES}
  echo -e "\n* Los usados para Validation seran menos, porque solo cogere los id_carrera de los que conozca el resultado de los 6 galgos que corrieron. Descarto las carreras en las que solo conozca algunos de los galgos que corrieron. Esto es util para calcular bien el SCORE.\n" 2>&1 1>>${INFORME_RENTABILIDADES}
  echo -e "\nSe muestran las tuplas (subgrupo, grupo_sp) más rentables." >>${INFORME_RENTABILIDADES}
  echo -e "\nLas columnas 'aciertos' y 'casos' indican filas predichas. Si es 1st, indican carreras (porque solo hay una prediccion por carrera). Si es 1o2, 2 casos abarcan 1 carrera. " >>${INFORME_RENTABILIDADES}
  echo -e "\nPoner DINERO solo en las tuplas indicadas, por este orden de prioridad: \n\n" >>${INFORME_RENTABILIDADES}
  mysql -t  --execute="SELECT * FROM datos_desa.tb_rentabilidades WHERE rentabilidad_porciento >= $RENTABILIDAD_MINIMA AND casos > (select $PORCENTAJE_SUFICIENTES_CASOS*(count(*)/6) AS casos_suficientes FROM datos_desa.tb_galgos_posiciones_en_carreras_norm WHERE id_carrera >10000 LIMIT 1) ORDER BY cobertura_sg_sp DESC LIMIT 100;" 2>&1 1>>${INFORME_RENTABILIDADES}

  rm -f $SUBGRUPO_GANADOR_FILE
  mysql -N --execute="SELECT subgrupo FROM ( SELECT A.* FROM datos_desa.tb_rentabilidades A WHERE rentabilidad_porciento > $RENTABILIDAD_MINIMA AND casos > (select $PORCENTAJE_SUFICIENTES_CASOS*(count(*)/6) AS casos_suficientes FROM datos_desa.tb_galgos_posiciones_en_carreras_norm WHERE id_carrera >10000 LIMIT 1) ORDER BY cobertura_sg_sp DESC ) B LIMIT 1;"  1>>${SUBGRUPO_GANADOR_FILE} 2>>$LOG_MASTER

}


##################### LIMPIEZA ############################################
function limpieza ()
{
sufijo="${1}"

echo -e $(date +"%T")"------- LIMPIEZA ------" 2>&1 1>>${LOG_999_LIMPIEZA_FINAL}

borrarTablasInnecesarias_036_037_040 "TOTAL"

borrarTablasInnecesarias_036_037_040 "DOW_L"
borrarTablasInnecesarias_036_037_040 "DOW_M"
borrarTablasInnecesarias_036_037_040 "DOW_X"
borrarTablasInnecesarias_036_037_040 "DOW_J"
borrarTablasInnecesarias_036_037_040 "DOW_V"
borrarTablasInnecesarias_036_037_040 "DOW_S"
borrarTablasInnecesarias_036_037_040 "DOW_D"
borrarTablasInnecesarias_036_037_040 "DOW_LAB"
borrarTablasInnecesarias_036_037_040 "DOW_FIN" 

borrarTablasInnecesarias_036_037_040 "DISTANCIA_CORTA"
borrarTablasInnecesarias_036_037_040 "DISTANCIA_MEDIA"
borrarTablasInnecesarias_036_037_040 "DISTANCIA_LARGA"

borrarTablasInnecesarias_036_037_040 "HORA_PRONTO"
borrarTablasInnecesarias_036_037_040 "HORA_MEDIA"
borrarTablasInnecesarias_036_037_040 "HORA_TARDE"

borrarTablasInnecesarias_036_037_040 "CON_5_GALGOS_JOVENES"
borrarTablasInnecesarias_036_037_040 "CON_5_GALGOS_VIEJOS"
borrarTablasInnecesarias_036_037_040 "POCA_EXPER_EN_CLASE"
borrarTablasInnecesarias_036_037_040 "MUCHA_EXPER_EN_CLASE"
borrarTablasInnecesarias_036_037_040 "CON_5_GALGOS_DELGADOS"
borrarTablasInnecesarias_036_037_040 "CON_3_GALGOS_PESADOS"
borrarTablasInnecesarias_036_037_040 "TRAINER_BUENOS_GALGOS"
borrarTablasInnecesarias_036_037_040 "TRAINER_MALOS_GALGOS"

borrarTablasInnecesarias_036_037_040 "LARGA_Y_ALGUNO_LENTO" 

}


function borrarTablasInnecesarias_036_037_040 ()
{
sufijo="${1}"
TAG="${1}"

echo -e "Borrando tablas innecesarias de 036..." 2>&1 1>>${LOG_999_LIMPIEZA_FINAL}
read -d '' CONSULTA_DROP_TABLAS_036 <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_filtrada_carreras_${sufijo};
DROP TABLE IF EXISTS datos_desa.tb_filtrada_galgos_${sufijo};
DROP TABLE IF EXISTS datos_desa.tb_filtrada_carrerasgalgos_${sufijo};
EOF
#echo -e "\n$CONSULTA_DROP_TABLAS_036" 2>&1 1>>${LOG_999_LIMPIEZA_FINAL}
mysql -t --execute="$CONSULTA_DROP_TABLAS_036" >>$LOG_999_LIMPIEZA_FINAL

echo -e "Borrando tablas innecesarias de 037..." 2>&1 1>>${LOG_999_LIMPIEZA_FINAL}
read -d '' CONSULTA_DROP_TABLAS_037 <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_dataset_con_ids_${TAG};
DROP TABLE IF EXISTS datos_desa.tb_dataset_ids_pasados_${TAG};

DROP TABLE IF EXISTS datos_desa.tb_dataset_ids_pasado_train_${TAG};
DROP TABLE IF EXISTS datos_desa.tb_dataset_ids_pasado_test_${TAG};
DROP TABLE IF EXISTS datos_desa.tb_dataset_ids_pasado_validation_${TAG};
DROP TABLE IF EXISTS datos_desa.tb_ds_pasado_train_features_${TAG};
DROP TABLE IF EXISTS datos_desa.tb_ds_pasado_train_targets_${TAG};
DROP TABLE IF EXISTS datos_desa.tb_ds_pasado_test_features_${TAG};
DROP TABLE IF EXISTS datos_desa.tb_ds_pasado_test_targets_${TAG};
DROP TABLE IF EXISTS datos_desa.tb_ds_pasado_validation_featuresytarget_${TAG};
DROP TABLE IF EXISTS datos_desa.tb_ds_pasado_validation_features_${TAG};
DROP TABLE IF EXISTS datos_desa.tb_ds_pasado_validation_targets_${TAG};

EOF
#echo -e "\n$CONSULTA_DROP_TABLAS_037" 2>&1 1>>${LOG_999_LIMPIEZA_FINAL}
mysql -t --execute="$CONSULTA_DROP_TABLAS_037" >>$LOG_999_LIMPIEZA_FINAL

echo -e "Borrando tablas innecesarias de 040..." 2>&1 1>>${LOG_999_LIMPIEZA_FINAL}
read -d '' CONSULTA_DROP_TABLAS_040 <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_val_${TAG}_aux1;
DROP TABLE IF EXISTS datos_desa.tb_val_${TAG}_aux2;
DROP TABLE IF EXISTS datos_desa.tb_val_${TAG}_aux3;
DROP TABLE IF EXISTS datos_desa.tb_val_${TAG}_aux4;
DROP TABLE IF EXISTS datos_desa.tb_val_${TAG}_aux5;
DROP TABLE IF EXISTS datos_desa.tb_val_${TAG};

DROP TABLE IF EXISTS datos_desa.tb_val_score_real_${TAG};
DROP TABLE IF EXISTS datos_desa.tb_val_score_predicho_${TAG};
DROP TABLE IF EXISTS datos_desa.tb_score_aciertos_${TAG};
DROP TABLE IF EXISTS datos_desa.tb_val_connombre_${TAG};
DROP TABLE IF EXISTS datos_desa.tb_val_aciertos_connombre_${TAG};
DROP TABLE IF EXISTS datos_desa.tb_val_economico_${TAG};

DROP TABLE IF EXISTS datos_desa.tb_val_1st_score_real_${TAG};
DROP TABLE IF EXISTS datos_desa.tb_val_1st_score_predicho_${TAG};
DROP TABLE IF EXISTS datos_desa.tb_1st_score_aciertos_${TAG};
DROP TABLE IF EXISTS datos_desa.tb_val_1st_connombre_${TAG};
DROP TABLE IF EXISTS datos_desa.tb_val_1st_aciertos_connombre_${TAG};
DROP TABLE IF EXISTS datos_desa.tb_val_1st_economico_${TAG};
EOF
#echo -e "\n$CONSULTA_DROP_TABLAS_040" 2>&1 1>>${LOG_999_LIMPIEZA_FINAL}
mysql -t --execute="$CONSULTA_DROP_TABLAS_040" >>$LOG_999_LIMPIEZA_FINAL

}


##########################################################################################

function analizarTabla ()
{
schemaEntrada="${1}"
tablaEntrada="${2}"
logsalida="${3}"

path_temp="./temp_analisis_tabla"
rm -f $path_temp

echo -e "\n--------- TABLA: ${schemaEntrada}"."${tablaEntrada} ----------\n"  2>&1 1>>${logsalida}

echo -e "Leyenda --> campo : MAX|MIN|AVG|STD|NO_NULOS|NULOS\n"  2>&1 1>>${logsalida}

mysql -N --execute="SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = '${schemaEntrada}' AND TABLE_NAME = '${tablaEntrada}';" >>$path_temp

query_out="SELECT "
contador=0

while IFS= read -r linea
do
  contador=$((contador+1))
  if [[ "$contador" -ge 1 ]];then  #Quito la cabecera
    if [[ "$linea" != *"----"* ]];then #Quito las lineas horizontales
      query_out="$query_out concat( ROUND(MAX($linea),6),'|', ROUND(MIN($linea),6),'|', ROUND(AVG($linea),6),'|', ROUND(STD($linea),6),'|', COUNT($linea),'|', COUNT(*)-COUNT($linea) ) AS _$linea, "
    fi
  fi
done < "$path_temp"

#Eliminamos los dos ultimos caracteres (coma y espacio)
query_out="${query_out::-2}"

query_out="${query_out} FROM ${schemaEntrada}.${tablaEntrada};"

#Pintar query
#echo -e "\n\n\n${query_out}\n\n\n" 2>&1 1>>${logsalida}

mysql --vertical --execute="${query_out}\G" 2>&1 1>>${logsalida}

echo -e "-----------------------------------------------------\n"  2>&1 1>>${logsalida}
}

##########################################################################################

########## EXPORTAR TABLA A FICHERO EXTERNO (para estudiar con KNIME) #########
function exportarTablaAFichero(){
  TEMP_DATA="${PATH_MYSQL_PRIV_SECURE}data.txt"
  SCHEMA="${1}"
  TABLA="${2}"
  PATH_OUTPUT="${3}"
  PATH_LOG="${4}"
  PATH_OUTPUT_EXTERNO="${5}"

  echo -e "Exportando $SCHEMA.$TABLA ---" >> "${PATH_LOG}"

  #Limpieza
  rm -f "$TEMP_DATA"
  rm -f "$PATH_OUTPUT"
  rm -f "${PATH_OUTPUT_EXTERNO}"

  #headers
  mysql -e "SELECT GROUP_CONCAT(COLUMN_NAME SEPARATOR '|') FROM INFORMATION_SCHEMA.COLUMNS WHERE table_schema='$SCHEMA' and table_name='$TABLA' INTO OUTFILE '$PATH_OUTPUT' FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '' ESCAPED BY '' LINES TERMINATED BY '\n';" 2>&1 1>> "${PATH_LOG}"

  #data
  mysql -e "SELECT * FROM $SCHEMA.$TABLA INTO OUTFILE '$TEMP_DATA' FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '' LINES TERMINATED BY '\n';" 2>&1 1>> "${PATH_LOG}"

  #headers+data
  cat "$TEMP_DATA" >> "$PATH_OUTPUT"

  #Copiar a tabla externa
  cp "$PATH_OUTPUT" "${PATH_OUTPUT_EXTERNO}"
}

##########################################################################################







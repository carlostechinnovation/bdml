#!/bin/bash

PATH_SCRIPTS="/root/git/bdml/mod002parser/scripts/galgos/"
PATH_JAR="/root/git/bdml/mod002parser/target/mod002parser-jar-with-dependencies.jar"

PATH_BRUTO="/home/carloslinux/Desktop/DATOS_BRUTO/galgos/"
PATH_LIMPIO="/home/carloslinux/Desktop/DATOS_LIMPIO/galgos/"

LOG_MASTER="/home/carloslinux/Desktop/LOGS/galgos_coordinador.log"
LOG_DESCARGA_BRUTO="/home/carloslinux/Desktop/LOGS/galgos_010_descarga_bruto.log"
LOG_DESCARGA_BRUTO_BB="/home/carloslinux/Desktop/LOGS/galgos_010_descarga_bruto_BB.log"
FLAG_BB_DESCARGADO_OK="/home/carloslinux/Desktop/LOGS/galgos_010_BB.descargado.OK"
LOG_011="/home/carloslinux/Desktop/LOGS/galgos_011_limpieza.log"
LOG_012="/home/carloslinux/Desktop/LOGS/galgos_012_normalizacion.log"
DOC_ANALISIS_PREVIO="/home/carloslinux/Desktop/INFORMES/analisis_previo.txt"
LOG_ESTADISTICA_BRUTO="/home/carloslinux/Desktop/LOGS/galgos_020_stats.log"
LOG_CE="/home/carloslinux/Desktop/LOGS/galgos_031_columnas_elaboradas.log"
LOG_DS="/home/carloslinux/Desktop/LOGS/galgos_037_datasets.log"
LOG_DS_COLPEN="/home/carloslinux/Desktop/LOGS/galgos_037_datasets_COLUMNAS_PENDIENTES.log"
LOG_ML="/home/carloslinux/Desktop/LOGS/galgos_040_ML.log"
LOG_050="/home/carloslinux/Desktop/LOGS/galgos_050_prediccion.log"
LOG_060_TABLAS="/home/carloslinux/Desktop/LOGS/galgos_060_tablas.log"
LOG_060_ENDTOEND="/home/carloslinux/Desktop/LOGS/galgos_060_endtoend.log"
LOG_070="/home/carloslinux/Desktop/LOGS/galgos_070.log"
LOG_999_LIMPIEZA_FINAL="/home/carloslinux/Desktop/LOGS/galgos_999_limpieza.log"


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
  mysql -u root --password=datos1986 --execute="$CONSULTA_REMARKS_PUNTOS" 2>&1 1>>${LOG_CE}
}


function crearTablaRemarksPuntos ()
{
echo -e "La tabla de remarks_puntos indica el PESO/INFLUENCIA que tiene cada REMARK en el campo POSICION. Es una especie de 'posición normalizada mirando solo remarks'" 2>&1 1>>${LOG_CE}

CONSULTA_DROP="DROP TABLE IF EXISTS datos_desa.tb_remarks_puntos;"
mysql -u root --password=datos1986 --execute="$CONSULTA_DROP" 2>&1 1>>${LOG_CE}

CONSULTA_CREAR="CREATE TABLE datos_desa.tb_remarks_puntos (remark varchar(20) CHARACTER SET utf8 NOT NULL DEFAULT '', posicion SMALLINT DEFAULT NULL, remark_puntos_norm decimal(20,2) ) ENGINE=InnoDB DEFAULT CHARSET=latin1;"
mysql -u root --password=datos1986 --execute="$CONSULTA_CREAR" 2>&1 1>>${LOG_CE}

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
${PATH_SCRIPTS}'galgos_MOD035.sh' "" "" "WHERE id_carrera IN (SELECT DISTINCT id_carrera FROM datos_desa.tb_elaborada_carreras_pre WHERE hora_norm <= 0.20)" "HORA_PRONTO_A"
${PATH_SCRIPTS}'galgos_MOD040.sh' "HORA_PRONTO_A" >>$PATH_LOG

echo -e $(date +"%T")" --------" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD035.sh' "" "" "WHERE id_carrera IN (SELECT DISTINCT id_carrera FROM datos_desa.tb_elaborada_carreras_pre WHERE hora_norm >= 0.2 AND hora_norm <= 0.4)" "HORA_PRONTO_B"
${PATH_SCRIPTS}'galgos_MOD040.sh' "HORA_PRONTO_B" >>$PATH_LOG

echo -e $(date +"%T")" --------" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD035.sh' "" "" "WHERE id_carrera IN (SELECT DISTINCT id_carrera FROM datos_desa.tb_elaborada_carreras_pre WHERE hora_norm >= 0.3 AND hora_norm <= 0.7)" "HORA_MEDIA"
${PATH_SCRIPTS}'galgos_MOD040.sh' "HORA_MEDIA" >>$PATH_LOG

echo -e $(date +"%T")" --------" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD035.sh' "" "" "WHERE id_carrera IN (SELECT DISTINCT id_carrera FROM datos_desa.tb_elaborada_carreras_pre WHERE hora_norm >= 0.6 AND hora_norm <= 0.8)" "HORA_TARDE_A"
${PATH_SCRIPTS}'galgos_MOD040.sh' "HORA_TARDE_A" >>$PATH_LOG

echo -e $(date +"%T")" --------" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD035.sh' "" "" "WHERE id_carrera IN (SELECT DISTINCT id_carrera FROM datos_desa.tb_elaborada_carreras_pre WHERE hora_norm >= 0.8)" "HORA_TARDE_B"
${PATH_SCRIPTS}'galgos_MOD040.sh' "HORA_TARDE_B" >>$PATH_LOG

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

echo -e $(date +"%T")" --------" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD035.sh' "" "" "WHERE id_carrera IN (SELECT DISTINCT id_carrera FROM datos_desa.tb_elaborada_carreras_pre WHERE distancia_norm >0.66) AND id_carrera IN ( SELECT DISTINCT id_carrera FROM datos_desa.tb_elaborada_carrerasgalgos_pre WHERE galgo_nombre IN (SELECT DISTINCT galgo_nombre FROM datos_desa.tb_elaborada_galgos_pre WHERE vel_going_largas_max_norm<=0.33 ) )" "LARGA_Y_ALGUNO_LENTO"
${PATH_SCRIPTS}'galgos_MOD040.sh' "LARGA_Y_ALGUNO_LENTO" >>$PATH_LOG
}
##########################################################################################

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

borrarTablasInnecesarias_036_037_040 "HORA_PRONTO_A"
borrarTablasInnecesarias_036_037_040 "HORA_PRONTO_B"
borrarTablasInnecesarias_036_037_040 "HORA_MEDIA"
borrarTablasInnecesarias_036_037_040 "HORA_TARDE_A"
borrarTablasInnecesarias_036_037_040 "HORA_TARDE_B"

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
mysql -u root --password=datos1986 -t --execute="$CONSULTA_DROP_TABLAS_036" >>$LOG_999_LIMPIEZA_FINAL

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
mysql -u root --password=datos1986 -t --execute="$CONSULTA_DROP_TABLAS_037" >>$LOG_999_LIMPIEZA_FINAL

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
mysql -u root --password=datos1986 -t --execute="$CONSULTA_DROP_TABLAS_040" >>$LOG_999_LIMPIEZA_FINAL

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

echo -e "Leyenda --> campo : MAX|MIN|AVG|COUNT\n"  2>&1 1>>${logsalida}

mysql -u root --password=datos1986 -N --execute="SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = '${schemaEntrada}' AND TABLE_NAME = '${tablaEntrada}';" >>$path_temp

query_out="SELECT "
contador=0

while IFS= read -r linea
do
  contador=$((contador+1))
  if [[ "$contador" -ge 1 ]];then  #Quito la cabecera
    if [[ "$linea" != *"----"* ]];then #Quito las lineas horizontales
      query_out="$query_out concat(MAX($linea),'|', MIN($linea),'|', AVG($linea),'|', COUNT($linea) ) AS _$linea, "
    fi
  fi
done < "$path_temp"

#Eliminamos lso dos ultimos caracteres (coma y espacio)
query_out="${query_out::-2}"

query_out="${query_out} FROM ${schemaEntrada}.${tablaEntrada};"

#Pintar query
#echo -e "\n\n\n${query_out}\n\n\n" 2>&1 1>>${logsalida}

mysql -u root --password=datos1986 --vertical --execute="${query_out}\G" 2>&1 1>>${logsalida}

echo -e "-----------------------------------------------------\n"  2>&1 1>>${logsalida}
}

##########################################################################################







#!/bin/bash

source "/home/carloslinux/git/bdml/mod002parser/scripts/galgos/funciones.sh"

#Borrar log
rm -f ${LOG_DESCARGA_BRUTO}

#Parametro
PARAM_CONFIG="${1}"

echo -e $(date +"%T")" | 010 | Descarga datos brutos | INICIO" >>$LOG_070
echo -e "MOD010 --> LOG = "${LOG_DESCARGA_BRUTO}

##########################################
echo -e $(date +"%T")" Borrando ficheros antiguos..." 2>&1 1>>${LOG_DESCARGA_BRUTO}
rm -f "$PATH_BRUTO*"
rm -f "$PATH_LIMPIO*"
rm -f "${PATH_FILE_GALGOS_INICIALES}"
rm -f "${PATH_FILE_GALGOS_INICIALES_FULL}"
rm -f "${PATH_LIMPIO_CARRERAS}"
rm -f "${PATH_LIMPIO_POSICIONES}"
rm -f "${PATH_LIMPIO_HISTORICO}"
rm -f "${PATH_LIMPIO_AGREGADOS}"

echo -e $(date +"%T")" Creando carpetas vacias (si no existen ya)..." 2>&1 1>>${LOG_DESCARGA_BRUTO}
mkdir -p "$PATH_BRUTO"
mkdir -p "$PATH_LIMPIO"


##########################################
echo -e $(date +"%T")" Borrando tablas..." 2>&1 1>>${LOG_DESCARGA_BRUTO}

consultar "DROP TABLE IF EXISTS datos_desa.tb_cg_semillas_sportium\W;" "${LOG_DESCARGA_BRUTO}" "-tN"

consultar "DROP TABLE IF EXISTS datos_desa.tb_galgos_carreras\W;" "${LOG_DESCARGA_BRUTO}" "-tN"
consultar "DROP TABLE IF EXISTS datos_desa.tb_galgos_posiciones_en_carreras\W;" "${LOG_DESCARGA_BRUTO}" "-tN"
consultar "DROP TABLE IF EXISTS datos_desa.tb_galgos_historico\W;" "${LOG_DESCARGA_BRUTO}" "-tN"
consultar "DROP TABLE IF EXISTS datos_desa.tb_galgos_agregados\W;" "${LOG_DESCARGA_BRUTO}" "-tN"
sleep 4s


################# SENTENCIAS SQL #########################
echo -e $(date +"%T")" Generando fichero de SENTENCIAS SQL (varios CREATE TABLE) con prefijo="prefijoPathDatosBruto 2>&1 1>>${LOG_DESCARGA_BRUTO}

rm $FILE_SENTENCIAS_CREATE_TABLE
java -jar ${PATH_JAR} "GALGOS_01" "$FILE_SENTENCIAS_CREATE_TABLE" 2>&1 1>>${LOG_DESCARGA_BRUTO}
SENTENCIAS_CREATE_TABLE=$(cat ${FILE_SENTENCIAS_CREATE_TABLE})
consultar "$SENTENCIAS_CREATE_TABLE" "${LOG_DESCARGA_BRUTO}" "-tN"


consultar "ALTER TABLE datos_desa.tb_galgos_carreras ADD INDEX tb_GC_idx(id_carrera);" "${LOG_DESCARGA_BRUTO}" "-tN"
consultar "ALTER TABLE datos_desa.tb_galgos_posiciones_en_carreras ADD INDEX tb_GPEC_idx(id_carrera);" "${LOG_DESCARGA_BRUTO}" "-tN"
consultar "ALTER TABLE datos_desa.tb_galgos_historico ADD INDEX tb_GH_idx(galgo_nombre);" "${LOG_DESCARGA_BRUTO}" "-tN"
consultar "ALTER TABLE datos_desa.tb_galgos_agregados ADD INDEX tb_GA_idx(galgo_nombre);" "${LOG_DESCARGA_BRUTO}" "-tN"

#################### FUTURAS - SPORTIUM ######################
echo -e $(date +"%T")" Borrando las paginas BRUTAS de detalle (carreras FUTURAS)..." 2>&1 1>>${LOG_DESCARGA_BRUTO}
rm -fR "${PATH_BRUTO_SEMILLAS_SPORTIUM}_BRUTOCARRERADET*"

echo -e $(date +"%T")" Descargando todas las carreras FUTURAS en las que PUEDO apostar y sus galgos (semillas)..." 2>&1 1>>${LOG_DESCARGA_BRUTO}
java -jar ${PATH_JAR} "GALGOS_02_SPORTIUM" "${PATH_BRUTO_SEMILLAS_SPORTIUM}" "${PATH_FILE_GALGOS_INICIALES}" "${PARAM_CONFIG}" 2>&1 1>>${LOG_DESCARGA_BRUTO}
consultar_sobreescribirsalida "TRUNCATE TABLE datos_desa.tb_cg_semillas_sportium\W;" "$PATH_LIMPIO_GALGOS_INICIALES_WARNINGS"
consultar_sobreescribirsalida "LOAD DATA LOCAL INFILE '${PATH_FILE_GALGOS_INICIALES_FULL}' INTO TABLE datos_desa.tb_cg_semillas_sportium FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n' IGNORE 0 LINES\W;" "$PATH_LIMPIO_GALGOS_INICIALES_WARNINGS"
consultar "SELECT COUNT(*) as num_galgos_iniciales FROM datos_desa.tb_cg_semillas_sportium LIMIT 1\W;" "${LOG_DESCARGA_BRUTO}" "-t"


###################### FUTURAS - SPORTIUM - DETALLE ####################

echo -e $(date +"%T")" GBGB - Descarga de DATOS BRUTOS históricos (embuclándose) de todas las carreras en las que han corrido los galgos semilla y los de carreras derivadas..." 2>&1 1>>${LOG_DESCARGA_BRUTO}
java -jar ${PATH_JAR} "GALGOS_03" "${PATH_BRUTO}galgos_${TAG_GBGB}_bruto" "${PATH_FILE_GALGOS_INICIALES}" "${PARAM_CONFIG}" 2>&1 1>>${LOG_DESCARGA_BRUTO}

consultar_sobreescribirsalida "TRUNCATE TABLE datos_desa.tb_galgos_carreras\W;" "$PATH_LIMPIO_GALGOS_INICIALES_WARNINGS"
consultar_sobreescribirsalida "LOAD DATA LOCAL INFILE '${PATH_LIMPIO_CARRERAS}' INTO TABLE datos_desa.tb_galgos_carreras FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n' IGNORE 0 LINES\W;" "$PATH_LIMPIO_CARRERAS_WARNINGS"

consultar_sobreescribirsalida "TRUNCATE TABLE datos_desa.tb_galgos_posiciones_en_carreras\W;" "$PATH_LIMPIO_GALGOS_INICIALES_WARNINGS"
consultar_sobreescribirsalida "LOAD DATA LOCAL INFILE '${PATH_LIMPIO_POSICIONES}' INTO TABLE datos_desa.tb_galgos_posiciones_en_carreras FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n' IGNORE 0 LINES\W;" "$PATH_LIMPIO_POSICIONES_WARNINGS"

consultar_sobreescribirsalida "TRUNCATE TABLE datos_desa.tb_galgos_historico\W;" "$PATH_LIMPIO_GALGOS_INICIALES_WARNINGS"
consultar_sobreescribirsalida "LOAD DATA LOCAL INFILE '${PATH_LIMPIO_HISTORICO}' INTO TABLE datos_desa.tb_galgos_historico FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n' IGNORE 0 LINES\W;" "$PATH_LIMPIO_HISTORICO_WARNINGS"

consultar_sobreescribirsalida "TRUNCATE TABLE datos_desa.tb_galgos_agregados\W;" "$PATH_LIMPIO_GALGOS_INICIALES_WARNINGS"
consultar_sobreescribirsalida "LOAD DATA LOCAL INFILE '${PATH_LIMPIO_AGREGADOS}' INTO TABLE datos_desa.tb_galgos_agregados FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n' IGNORE 0 LINES\W;" "$PATH_LIMPIO_AGREGADOS_WARNINGS"


##########################################
echo -e $(date +"%T")" GBGB - Comprobando tablas de datos HISTORICOS recien creadas..." 2>&1 1>>${LOG_DESCARGA_BRUTO}

mostrar_tabla "CARRERAS" "datos_desa.tb_galgos_carreras" "${LOG_DESCARGA_BRUTO}"
mostrar_tabla "POSICIONES EN CARRERAS" "datos_desa.tb_galgos_posiciones_en_carreras" "${LOG_DESCARGA_BRUTO}"
mostrar_tabla "GALGOS HISTORICO" "datos_desa.tb_galgos_historico" "${LOG_DESCARGA_BRUTO}"
mostrar_tabla "GALGOS AGREGADO" "datos_desa.tb_galgos_agregados" "${LOG_DESCARGA_BRUTO}"

echo -e $(date +"%T")"\nNumero de galgos diferentes de los que conocemos su historico: " >>$PATH_LIMPIO_ESTADISTICAS
mysql --execute="SELECT COUNT(DISTINCT galgo_nombre) as num_galgos_diferentes FROM datos_desa.tb_galgos_historico LIMIT 1\W;">>$PATH_LIMPIO_ESTADISTICAS


#################### BORRADO PARA AHORRAR ESPACIO EN DISCO (andamos justos...) ######################
echo -e $(date +"%T")" BORRADO PARA AHORRAR ESPACIO EN DISCO (andamos justos...)..." 2>&1 1>>${LOG_DESCARGA_BRUTO}

brutos_gbgb="${PATH_BRUTO}galgos_${TAG_GBGB}_bruto*"
echo -e $(date +"%T")" Borrando datos brutos GBGB: "${brutos_gbgb} 2>&1 1>>${LOG_MASTER}
rm -f ${brutos_gbgb} 2>&1 1>>${LOG_MASTER}

brutos_semillas_sportium="${PATH_BRUTO_SEMILLAS_SPORTIUM}_BRUTOCARRERADET*"
echo -e $(date +"%T")" Borrando datos brutos: "${brutos_semillas_sportium} 2>&1 1>>${LOG_MASTER}
rm -f ${brutos_semillas_sportium} 2>&1 1>>${LOG_MASTER}


#################### Enriquecimiento de tabla CARRERAS con WEATHER (WEAMD) #################################

read -d '' CONSULTA_RELLENAR_WEAMD <<- EOF

REPLACE INTO datos_desa.tb_galgos_carreras

SELECT id_carrera,id_campeonato,track,clase, A.anio,A.mes,A.dia,
hora,minuto, distancia,num_galgos,premio_primero, premio_segundo, premio_otros, 
premio_total_carrera,going_allowance_segundos, fc_1, fc_2, fc_pounds, 
tc_1, tc_2, tc_3, tc_pounds,

B.pasada, B.tempMin, B.tempMax, (B.tempMax - B.tempMin) AS tempSpan, B.histAvgMin, B.histAvgMax, 
B.texto, B.rain, B.wind, B.cloud, B.sun, B.snow

FROM datos_desa.tb_galgos_carreras A 
LEFT JOIN datos_desa.tb_galgos_weamd B
ON (A.track=B.estadio AND A.anio=B.anio AND A.mes=B.mes AND A.dia=B.dia)
EOF

echo -e $(date +"%T")" Rellenando info WEAMD en tabla de carreras: INICIO..." 2>&1 1>>${LOG_MASTER}
echo -e "$CONSULTA_RELLENAR_WEAMD\n********************************\n" 2>&1 1>>${LOG_DESCARGA_BRUTO}
mysql --execute="$CONSULTA_RELLENAR_WEAMD" 2>&1 1>>${LOG_DESCARGA_BRUTO}
echo -e "\n-------------------------------------" 2>&1 1>>${LOG_DESCARGA_BRUTO}
echo -e $(date +"%T")" Rellenando info WEAMD en tabla de carreras: FIN" 2>&1 1>>${LOG_MASTER}



##########################################

echo -e $(date +"%T")" | 010 | Descarga datos brutos | FIN" >>$LOG_070




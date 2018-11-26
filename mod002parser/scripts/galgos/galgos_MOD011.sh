#!/bin/bash

source "/home/carloslinux/git/bdml/mod002parser/scripts/galgos/funciones.sh"

#Borrar log
rm -f ${LOG_011}

echo -e $(date +"%T")" | 011 | INICIO" >>$LOG_070
echo -e "MOD011 --> LOG = "${LOG_011}

##########################################

#PENDIENTE Limpiar datos brutos de SPORTIUM y de Betbright, usando las mismas funciones.

##########################################
echo -e "Extraigo dia, hora y minuto de la primera carrera futura. Como la descarga de datos tarda horas, hay veces que descarga resultados de las primeras carreras futuras. Quiero evitar coger ese resultado REAL, para no entrenar con ello. Deberia quitar esas filas en las tablas limpias afectadas. Pero por vagancia, basta con CONTROLAR que debo ejecutar cuando en las 2 horas siguientes no haya carreras (por ejemplo, de noche o muy de mañana)." >> "${LOG_011}"

#select TIMESTAMP(concat_ws(' ', concat_ws('-',anio,mes,dia), concat_ws(':',hora,minuto,'0'))) AS amdhms from datos_desa.tb_galgos_carreras WHERE  id_carrera=1;

##########################################
echo -e "Generando tablas limpias:" >> "${LOG_011}"

echo -e "LIMPIANDO tb_galgos_carreras..." >> "${LOG_011}"
mysql -tN --execute="DROP TABLE IF EXISTS datos_desa.tb_galgos_carreras_LIM; CREATE TABLE datos_desa.tb_galgos_carreras_LIM AS SELECT * FROM datos_desa.tb_galgos_carreras WHERE (distancia IS NULL OR (distancia>100 AND distancia<=750)) AND num_galgos>=4 AND (going_allowance_segundos IS NULL OR (going_allowance_segundos>=-0.8 AND going_allowance_segundos<=0.8)) AND clase IS NOT NULL;" 2>&1 1>>"${LOG_011}"

echo -e "LIMPIANDO tb_galgos_posiciones_en_carreras..." >> "${LOG_011}"
mysql -tN --execute="DROP TABLE IF EXISTS datos_desa.tb_galgos_posiciones_en_carreras_LIM; CREATE TABLE datos_desa.tb_galgos_posiciones_en_carreras_LIM AS SELECT * FROM datos_desa.tb_galgos_posiciones_en_carreras WHERE galgo_nombre <>'VACANT' AND (sp IS NULL OR sp<12);" 2>&1 1>>"${LOG_011}"

echo -e "LIMPIANDO tb_galgos_historico..." >> "${LOG_011}"
mysql -tN --execute="DROP TABLE IF EXISTS datos_desa.tb_galgos_historico_LIM; CREATE TABLE datos_desa.tb_galgos_historico_LIM AS SELECT * FROM datos_desa.tb_galgos_historico WHERE (distancia IS NULL OR (distancia>100 AND distancia<=750)) AND trap<=6 AND (velocidad_con_going IS NULL OR (velocidad_con_going>=15 AND velocidad_con_going<=18.1)) AND clase IS NOT NULL AND galgo_nombre <>'VACANT' AND edad_en_dias>90 AND edad_en_dias<2400 AND (sp IS NULL OR sp<12);" 2>&1 1>>"${LOG_011}"

echo -e "LIMPIANDO tb_galgos_agregados..." >> "${LOG_011}"
mysql -tN --execute="DROP TABLE IF EXISTS datos_desa.tb_galgos_agregados_LIM; CREATE TABLE datos_desa.tb_galgos_agregados_LIM AS SELECT * FROM datos_desa.tb_galgos_agregados WHERE vel_real_longmedias_max<17.5;" 2>&1 1>>"${LOG_011}"


##########################################
echo -e "Indices en tablas limpias..." >> "${LOG_011}"
mysql -tN --execute="ALTER TABLE datos_desa.tb_galgos_posiciones_en_carreras_LIM ADD INDEX tb_PECLIM_idx(id_carrera,galgo_nombre);" 2>&1 1>>"${LOG_011}"
mysql -tN --execute="ALTER TABLE datos_desa.tb_galgos_historico_LIM ADD INDEX tb_GHLIM_idx1(id_carrera,galgo_nombre);" 2>&1 1>>"${LOG_011}"
mysql -tN --execute="ALTER TABLE datos_desa.tb_galgos_historico_LIM ADD INDEX tb_GHLIM_idx2(galgo_nombre,clase);" 2>&1 1>>"${LOG_011}"
mysql -tN --execute="ALTER TABLE datos_desa.tb_galgos_agregados_LIM ADD INDEX tb_GALIM_idx2(galgo_nombre);" 2>&1 1>>"${LOG_011}"


######### Analisis estadistico de tablas LIM #######################

echo -e "Analisis de id_carrera viendo pasados y futuros:" 2>&1 1>>"${LOG_011}"

read -d '' CONSULTA_ANALISIS_PASADOS_FUTUROS <<- EOF
select 'tb_galgos_posiciones_en_carreras_LIM' AS tabla, 'futuro' as tipo, count(*) as num FROM datos_desa.tb_galgos_posiciones_en_carreras_LIM WHERE id_carrera <100000
UNION ALL
select 'tb_galgos_posiciones_en_carreras_LIM' AS tabla, 'pasado' as tipo, count(*) as num FROM datos_desa.tb_galgos_posiciones_en_carreras_LIM WHERE id_carrera >100000
UNION ALL
select 'tb_galgos_historico_LIM' AS tabla, 'futuro' as tipo, count(*) as num FROM datos_desa.tb_galgos_historico_LIM WHERE id_carrera <100000
UNION ALL
select 'tb_galgos_historico_LIM' AS tabla, 'pasado' as tipo, count(*) as num FROM datos_desa.tb_galgos_historico_LIM WHERE id_carrera >100000;
EOF

echo -e "$CONSULTA_ANALISIS_PASADOS_FUTUROS" 2>&1 1>>${LOG_011}
mysql -t --execute="$CONSULTA_ANALISIS_PASADOS_FUTUROS" 2>&1 1>>${LOG_011}


analizarTabla "datos_desa" "tb_galgos_carreras_LIM" "${LOG_011}"
analizarTabla "datos_desa" "tb_galgos_posiciones_en_carreras_LIM" "${LOG_011}"
analizarTabla "datos_desa" "tb_galgos_historico_LIM" "${LOG_011}"
analizarTabla "datos_desa" "tb_galgos_agregados_LIM" "${LOG_011}"


#######################################
echo -e "\n----------- Tablas LIMPIAS --------------" 2>&1 1>>${LOG_011}
echo -e "datos_desa.tb_galgos_carreras_LIM" 2>&1 1>>${LOG_011}
echo -e "datos_desa.tb_galgos_posiciones_en_carreras_LIM" 2>&1 1>>${LOG_011}
echo -e "datos_desa.tb_galgos_historico_LIM" 2>&1 1>>${LOG_011}
echo -e "datos_desa.tb_galgos_agregados_LIM" 2>&1 1>>${LOG_011}
echo -e "----------------------------------------------------\n\n\n" 2>&1 1>>${LOG_011}
#######################################


echo -e $(date +"%T")" | 011 | FIN" >>$LOG_070




#!/bin/bash

source "/root/git/bdml/mod002parser/scripts/galgos/funciones.sh"


#Borrar log
rm -f ${LOG_011}


echo -e $(date +"%T")" | 011 | INICIO" >>$LOG_070
echo -e "MOD011 --> LOG = "${LOG_011}


##########################################

#PENDIENTE Limpiar datos brutos de SPORTIUM y de Betbright, usando las mismas funciones.

##########################################
echo -e "Generando tablas limpias:" >> "${LOG_011}"

echo -e "LIMPIANDO tb_galgos_carreras..." >> "${LOG_011}"
mysql --login-path=local -tN --execute="DROP TABLE IF EXISTS datos_desa.tb_galgos_carreras_LIM; CREATE TABLE datos_desa.tb_galgos_carreras_LIM AS SELECT * FROM datos_desa.tb_galgos_carreras WHERE num_galgos>=4 AND (going_allowance_segundos IS NULL OR (going_allowance_segundos>=-0.8 AND going_allowance_segundos<=0.8));" 2>&1 1>>"${LOG_011}"

echo -e "LIMPIANDO tb_galgos_posiciones_en_carreras..." >> "${LOG_011}"
mysql --login-path=local -tN --execute="DROP TABLE IF EXISTS datos_desa.tb_galgos_posiciones_en_carreras_LIM; CREATE TABLE datos_desa.tb_galgos_posiciones_en_carreras_LIM AS SELECT * FROM datos_desa.tb_galgos_posiciones_en_carreras;" 2>&1 1>>"${LOG_011}"

echo -e "LIMPIANDO tb_galgos_historico..." >> "${LOG_011}"
mysql --login-path=local -tN --execute="DROP TABLE IF EXISTS datos_desa.tb_galgos_historico_LIM; CREATE TABLE datos_desa.tb_galgos_historico_LIM AS SELECT * FROM datos_desa.tb_galgos_historico WHERE (distancia IS NULL OR distancia<950) AND trap<=6 AND (velocidad_con_going IS NULL OR (velocidad_con_going>=15 AND velocidad_con_going<=18.1));" 2>&1 1>>"${LOG_011}"

echo -e "LIMPIANDO tb_galgos_agregados..." >> "${LOG_011}"
mysql --login-path=local -tN --execute="DROP TABLE IF EXISTS datos_desa.tb_galgos_agregados_LIM; CREATE TABLE datos_desa.tb_galgos_agregados_LIM AS SELECT * FROM datos_desa.tb_galgos_agregados;" 2>&1 1>>"${LOG_011}"


#######################################
echo -e "\n----------- Tablas LIMPIAS --------------" 2>&1 1>>${LOG_012}
echo -e "datos_desa.tb_galgos_carreras_LIM" 2>&1 1>>${LOG_012}
echo -e "datos_desa.tb_galgos_posiciones_en_carreras_LIM" 2>&1 1>>${LOG_012}
echo -e "datos_desa.tb_galgos_historico_LIM" 2>&1 1>>${LOG_012}
echo -e "datos_desa.tb_galgos_agregados_LIM" 2>&1 1>>${LOG_012}
echo -e "----------------------------------------------------\n\n\n" 2>&1 1>>${LOG_012}
#######################################


echo -e $(date +"%T")" | 011 | FIN" >>$LOG_070




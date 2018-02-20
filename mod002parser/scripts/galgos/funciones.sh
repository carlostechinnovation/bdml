#!/bin/bash

LOG_DESCARGA_BRUTO="/home/carloslinux/Desktop/LOGS/galgos_001A_descarga_bruto.log"
DOC_ANALISIS_PREVIO="/home/carloslinux/Desktop/INFORMES/analisis_previo.txt"
LOG_ESTADISTICA_BRUTO="/home/carloslinux/Desktop/LOGS/galgos_003A_stats_bruto.log"
LOG_CE="/home/carloslinux/Desktop/LOGS/galgos_003B_columnas_elaboradas.log"
LOG_DS="/home/carloslinux/Desktop/LOGS/galgos_003C_datasets.log"
LOG_ML="/home/carloslinux/Desktop/LOGS/galgos_004.log"


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


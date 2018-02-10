#!/bin/bash

#Script principal COORDINADOR de todas las tareas. Lo que no quiera ejecutar, lo comento.

PATH_LOG="/home/carloslinux/Desktop/LOGS/galgos_coordinador.log"
PATH_SCRIPTS="/root/git/bdml/mod002parser/scripts/galgos/"

#limpiar logs
rm -f "/home/carloslinux/Desktop/LOGS/log4j-application.log"
rm -f $PATH_LOG



######## SUBGRUPOS #######################################################################
function analizarScoreSobreSubgrupos ()
{
#filtro_carreras filtro_galgos filtro_cg sufijo
echo -e $(date +"%T")" --------" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD003C.sh' "" "" "" "TOTAL"
${PATH_SCRIPTS}'galgos_MOD004.sh' "TOTAL" >>$PATH_LOG

echo -e $(date +"%T")" --------" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD003C.sh' "WHERE distancia_norm IS NULL OR distancia_norm <=0.33" "" "" "DISTANCIA_CORTA"
${PATH_SCRIPTS}'galgos_MOD004.sh' "DISTANCIA_CORTA" >>$PATH_LOG

echo -e $(date +"%T")" --------" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD003C.sh' "WHERE distancia_norm IS NULL OR (distancia_norm >0.33 AND  distancia_norm <=0.66" "" "" "DISTANCIA_MEDIA"
${PATH_SCRIPTS}'galgos_MOD004.sh' "DISTANCIA_MEDIA" >>$PATH_LOG

echo -e $(date +"%T")" --------" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD003C.sh' "WHERE distancia_norm IS NULL OR distancia_norm >0.66" "" "" "DISTANCIA_LARGA"
${PATH_SCRIPTS}'galgos_MOD004.sh' "DISTANCIA_LARGA" >>$PATH_LOG

echo -e $(date +"%T")" --------" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD003C.sh' "WHERE hora_norm IS NULL OR hora_norm <=0.33" "" "" "HORA_PRONTO"
${PATH_SCRIPTS}'galgos_MOD004.sh' "HORA_PRONTO" >>$PATH_LOG

echo -e $(date +"%T")" --------" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD003C.sh' "WHERE hora_norm IS NULL OR hora_norm >=0.66" "" "" "HORA_TARDE"
${PATH_SCRIPTS}'galgos_MOD004.sh' "HORA_TARDE" >>$PATH_LOG


echo -e $(date +"%T")" --------" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD003C.sh' "WHERE distancia_norm IS NULL OR distancia_norm >=0.66" "" "WHERE id_carrera IN ( SELECT DISTINCT id_carrera FROM datos_desa.tb_elaborada_carrerasgalgos_pre WHERE galgo_nombre IN (SELECT DISTINCT galgo_nombre FROM datos_desa.tb_elaborada_galgos_pre WHERE vel_going_largas_max_norm IS NULL OR vel_going_largas_max_norm<=0.33 ) )" "DISTANCIA_LARGA_Y_ALGUN_GALGO_MUY_LENTO"
${PATH_SCRIPTS}'galgos_MOD004.sh' "DISTANCIA_LARGA_Y_ALGUN_GALGO_MUY_LENTO" >>$PATH_LOG


echo -e $(date +"%T")" --------" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD003C.sh' "" "" "WHERE edad_en_dias_norm is NULL OR edad_en_dias_norm<=0.33" "GALGOS_JOVENES"
${PATH_SCRIPTS}'galgos_MOD004.sh' "GALGOS_JOVENES" >>$PATH_LOG

echo -e $(date +"%T")" --------" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD003C.sh' "" "" "WHERE edad_en_dias_norm is NULL OR edad_en_dias_norm>=0.66" "GALGOS_VIEJOS"
${PATH_SCRIPTS}'galgos_MOD004.sh' "GALGOS_VIEJOS" >>$PATH_LOG

echo -e $(date +"%T")" --------" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD003C.sh' "" "" "WHERE experiencia_en_clase is NULL OR experiencia_en_clase<=0.33" "GALGOS_CON_POCA_EXPER_EN_CLASE"
${PATH_SCRIPTS}'galgos_MOD004.sh' "GALGOS_CON_POCA_EXPER_EN_CLASE" >>$PATH_LOG

echo -e $(date +"%T")" --------" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD003C.sh' "" "" "WHERE experiencia_en_clase is NULL OR experiencia_en_clase>=0.66" "GALGOS_CON_MUCHA_EXPER_EN_CLASE"
${PATH_SCRIPTS}'galgos_MOD004.sh' "GALGOS_CON_MUCHA_EXPER_EN_CLASE" >>$PATH_LOG

echo -e $(date +"%T")" --------" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD003C.sh' "" "" "WHERE peso_galgo_norm is NULL OR peso_galgo_norm<=0.33" "GALGOS_DELGADOS"
${PATH_SCRIPTS}'galgos_MOD004.sh' "GALGOS_DELGADOS" >>$PATH_LOG

echo -e $(date +"%T")" --------" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD003C.sh' "" "" "WHERE peso_galgo_norm is NULL OR peso_galgo_norm>=0.66" "GALGOS_GORDOS"
${PATH_SCRIPTS}'galgos_MOD004.sh' "GALGOS_GORDOS" >>$PATH_LOG

echo -e $(date +"%T")" --------" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD003C.sh' "" "" "WHERE entrenador_posicion_norm is NULL OR id_carrera IN ( SELECT DISTINCT id_carrera FROM datos_desa.tb_elaborada_carrerasgalgos_pre WHERE entrenador_posicion_norm>=0.5 )" "ALGUN_ENTRENADOR_CON_BUENOS_GALGOS"
${PATH_SCRIPTS}'galgos_MOD004.sh' "ALGUN_ENTRENADOR_CON_BUENOS_GALGOS" >>$PATH_LOG

echo -e $(date +"%T")" --------" >>$PATH_LOG
${PATH_SCRIPTS}'galgos_MOD003C.sh' "" "" "WHERE entrenador_posicion_norm is NULL OR id_carrera IN ( SELECT DISTINCT id_carrera FROM datos_desa.tb_elaborada_carrerasgalgos_pre WHERE entrenador_posicion_norm<0.5 )" "ALGUN_ENTRENADOR_CON_MALOS_GALGOS"
${PATH_SCRIPTS}'galgos_MOD004.sh' "ALGUN_ENTRENADOR_CON_MALOS_GALGOS" >>$PATH_LOG


}
##########################################################################################



##########################################
#sudo service mysql start

##########################################
echo -e "-------- "$(date +"%T")" ---------- GALGOS - Cadena de procesos ------------" >>$PATH_LOG
echo -e "Ruta script="${PATH_SCRIPTS}
echo -e "Ruta log (coordinador)="${PATH_LOG}

#echo -e $(date +"%T")" Descarga de datos (planificado con CRON)" >>$PATH_LOG
#${PATH_SCRIPTS}'galgos_MOD001A.sh'

#echo -e $(date +"%T")" Analisis de datos: ESTADISTICA BASICA" >>$PATH_LOG
#${PATH_SCRIPTS}'galgos_MOD003A.sh'

#echo -e $(date +"%T")" Generador de COLUMNAS ELABORADAS y DATASETS" >>$PATH_LOG
#${PATH_SCRIPTS}'galgos_MOD003B.sh'


#### Bucle ###
analizarScoreSobreSubgrupos()
#### Fin de bucle ###

#echo -e $(date +"%T")" Tablas FILTRADAS" >>$PATH_LOG
filtro_carreras="WHERE 1=1"
filtro_galgos="WHERE 1=1"
filtro_cg="WHERE 1=1"
sufijo="SUBGRUPO_X"
#${PATH_SCRIPTS}'galgos_MOD003C.sh' "$filtro_carreras" "$filtro_galgos" "$filtro_cg" "${sufijo}"

#echo -e $(date +"%T")" INTELIGENCIA ARTIFICIAL" >>$PATH_LOG
#${PATH_SCRIPTS}'galgos_MOD004.sh' "${sufijo}"



#echo -e $(date +"%T")" INFORMES (resultados)" >>$PATH_LOG
#${PATH_SCRIPTS}'galgos_MOD005.sh'
#${PATH_SCRIPTS}'galgos_MOD005_PGA.sh'

#echo -e $(date +"%T")" Análisis posterior" >>$PATH_LOG
#${PATH_SCRIPTS}'galgos_MOD006.sh'

#echo -e $(date +"%T")" Análisis TIC de la ejecucion" >>$PATH_LOG
#${PATH_SCRIPTS}'galgos_MOD007.sh'

##########################################

#sudo service mysql stop

##########################################




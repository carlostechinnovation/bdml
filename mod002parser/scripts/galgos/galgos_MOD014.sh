#!/bin/bash

source "/home/carloslinux/git/bdml/mod002parser/scripts/galgos/funciones.sh"

#Borrar log
rm -f "${LOG_014_STATS}"

echo -e $(date +"%T")" | 014 | Estadistica sobre columnas no transformadas | INICIO" >>$LOG_070
echo -e "MOD014 --> LOG = "${LOG_014_STATS}

######################################################################################################
echo -e "-------------- CG Semillas FUTURAS SPORTIUM --------------" >> "${LOG_014_STATS}"
analizarTabla "datos_desa" "tb_cg_semillas_sportium" "${LOG_014_STATS}"

######################################################################################################
echo -e "-------------- TABLAS BRUTAS (pasadas + futuras) --------------" >> "${LOG_014_STATS}"
analizarTabla "datos_desa" "tb_galgos_carreras" "${LOG_014_STATS}"
analizarTabla "datos_desa" "tb_galgos_posiciones_en_carreras" "${LOG_014_STATS}"
analizarTabla "datos_desa" "tb_galgos_historico" "${LOG_014_STATS}"
analizarTabla "datos_desa" "tb_galgos_agregados" "${LOG_014_STATS}"

#####################################################################################################
echo -e "-------------- TABLAS con columnas no transformadas --------------" >> "${LOG_014_STATS}"
analizarTabla "datos_desa" "tb_elaborada_carreras" "${LOG_014_STATS}"  #BUENA
analizarTabla "datos_desa" "tb_elaborada_galgos" "${LOG_014_STATS}"	#BUENA
analizarTabla "datos_desa" "tb_elaborada_carrerasgalgos" "${LOG_014_STATS}"	#BUENA


stats_completitud=$(cat "${LOG_014_STATS}" | grep '_velocidad_con_going_norm')
echo -e "\nMETRICA de COMPLETITUD de los datos historicos --> (tabla datos_desa.tb_elaborada_carrerasgalgos, campo _velocidad_con_going_norm ): ${stats_completitud}\n" >>$LOG_070
echo -e "MAX|MIN|AVG|STD|NO_NULOS|NULOS --> El ratio NULOS/No_nulos debe ser bajo.\n" >>$LOG_070


echo -e "Analizando con KNIME..." >> "${LOG_014_STATS}"
exportarTablaAFichero "datos_desa" "tb_elaborada_carreras" "${PATH_MYSQL_PRIV_SECURE}014_carreras.txt" "${LOG_014_STATS}" "${EXTERNAL_014}014_carreras.txt"
exportarTablaAFichero "datos_desa" "tb_elaborada_galgos" "${PATH_MYSQL_PRIV_SECURE}014_carreras.txt" "${LOG_014_STATS}" "${EXTERNAL_014}014_galgos.txt"
exportarTablaAFichero "datos_desa" "tb_elaborada_carrerasgalgos" "${PATH_MYSQL_PRIV_SECURE}014_carreras.txt" "${LOG_014_STATS}" "${EXTERNAL_014}014_carrerasgalgos.txt"
#sudo "/home/carloslinux/Desktop/PROGRAMAS/knime/knime" -batch -reset -workflowFile="/home/carloslinux/Desktop/WORKSPACES/wksp_knime/workflow_galgos/galgos_014_analisis" &



#####################################################################################################


echo -e $(date +"%T")" | 014 | Estadistica sobre columnas no transformadas | FIn" >>$LOG_070




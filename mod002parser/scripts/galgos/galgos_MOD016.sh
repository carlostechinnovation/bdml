#!/bin/bash
 
source "/home/carloslinux/git/bdml/mod002parser/scripts/galgos/funciones.sh"

#Borrar log
rm -f "${LOG_016_STATS}"

echo -e $(date +"%T")" | 016 | Estadistica sobre columnas transformadas | INICIO" >>$LOG_070
echo -e "MOD016 --> LOG = "${LOG_016_STATS}

#####################################################################################################
echo -e "-------------- TABLAS con columnas SI transformadas --------------" >> "${LOG_016_STATS}"
analizarTabla "datos_desa" "tb_trans_carreras" "${LOG_016_STATS}"
analizarTabla "datos_desa" "tb_trans_galgos" "${LOG_016_STATS}"
analizarTabla "datos_desa" "tb_trans_carrerasgalgos" "${LOG_016_STATS}"


############################## OPTIMIZACION #######################################################################
echo -e "-------------- OPTIMIZACION --------------" >> "${LOG_016_STATS}"
mysql -t --execute="ALTER TABLE datos_desa.tb_trans_galgos ADD INDEX trans_galgos_idx1(galgo_nombre(255));" 2>&1 1>>${LOG_016_STATS}
mysql -t --execute="ALTER TABLE datos_desa.tb_trans_galgos ADD INDEX trans_galgos_idx2(vel_going_largas_max(255));" 2>&1 1>>${LOG_016_STATS}


mysql -t --execute="ALTER TABLE datos_desa.tb_trans_carreras ADD INDEX trans_carreras_idx1(id_carrera);" 2>&1 1>>${LOG_016_STATS}
mysql -t --execute="ALTER TABLE datos_desa.tb_trans_carreras ADD INDEX trans_carreras_idx2(distancia(255));" 2>&1 1>>${LOG_016_STATS}

mysql -t --execute="ALTER TABLE datos_desa.tb_trans_carrerasgalgos ADD INDEX trans_cg_idx1(id_carrera);" 2>&1 1>>${LOG_016_STATS}
mysql -t --execute="ALTER TABLE datos_desa.tb_trans_carrerasgalgos ADD INDEX trans_cg_idx2(galgo_nombre(255));" 2>&1 1>>${LOG_016_STATS}
mysql -t --execute="ALTER TABLE datos_desa.tb_trans_carrerasgalgos ADD INDEX trans_cg_idx3(id_carrera(255), galgo_nombre(255));" 2>&1 1>>${LOG_016_STATS}



#####################################################################################################
echo -e "Analizando con KNIME..." >> "${LOG_016_STATS}"
PATH_KNIME_WFLOW="/root/knime-workspace/workflow_galgos/"
#sudo "/home/carloslinux/Desktop/PROGRAMAS/knime/knime" -batch -reset -workflowFile="${PATH_KNIME_WFLOW}galgos_016_analisis_trans" &
#sudo "/home/carloslinux/Desktop/PROGRAMAS/knime/knime" -consoleLog -nosplash -noexit -application org.knime.product.KNIME_BATCH_APPLICATION -workflowFile="${PATH_KNIME_WFLOW}galgos_016_analisis_trans"  > "/home/carloslinux/Desktop/LOGS/016_knime_log.txt"



#####################################################################################################


echo -e $(date +"%T")" | 016 | Estadistica sobre columnas transformadas | FIn" >>$LOG_070




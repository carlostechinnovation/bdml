#!/bin/bash

source "/home/carloslinux/git/bdml/mod002parser/scripts/galgos/funciones.sh"

#Borrar log
rm -f "${LOG_061}"


####### PARAMETROS ###
TAG="${1}"
ID_EJECUCION="${2}"

echo -e $(date +"%T")" | 061 | Export de datasets pasados y futuros | INICIO" >>$LOG_070
echo -e "MOD061 --> LOG = "${LOG_061}

#Limpiar informe
rm -f "${LOG_061}"

########## SUBCARPETAS #################
PATH_DIR_OUT="${PATH_EXTERNAL_DATA}${ID_EJECUCION}/"
rm -rf "${PATH_DIR_OUT}" #Por si reejecutamos a mano 
mkdir "${PATH_DIR_OUT}"

############### EXPORTACION A CARPETA EXTERNA #####################

##PASADO (SPLIT): 037
#echo -e "Datasets pasados (train, test, validation)" >> "${LOG_061}"
#exportarTablaAFichero "datos_desa" "tb_ds_pasado_train_features_${TAG}" "${PATH_MYSQL_PRIV_SECURE}037_ds_pasado_train_f.txt" "${LOG_061}" "${PATH_DIR_OUT}037_ds_pasado_train_f.txt"
#exportarTablaAFichero "datos_desa" "tb_ds_pasado_train_targets_${TAG}" "${PATH_MYSQL_PRIV_SECURE}037_ds_pasado_train_t.txt" "${LOG_061}" "${PATH_DIR_OUT}037_ds_pasado_train_t.txt"
#exportarTablaAFichero "datos_desa" "tb_ds_pasado_test_features_${TAG}" "${PATH_MYSQL_PRIV_SECURE}037_ds_pasado_test_f.txt" "${LOG_061}" "${PATH_DIR_OUT}037_ds_pasado_test_f.txt"
#exportarTablaAFichero "datos_desa" "tb_ds_pasado_test_targets_${TAG}" "${PATH_MYSQL_PRIV_SECURE}037_ds_pasado_test_t.txt" "${LOG_061}" "${PATH_DIR_OUT}037_ds_pasado_test_t.txt"
#exportarTablaAFichero "datos_desa" "tb_ds_pasado_validation_features_${TAG}" "${PATH_MYSQL_PRIV_SECURE}037_ds_pasado_val_f.txt" "${LOG_061}" "${PATH_DIR_OUT}037_ds_pasado_val_f.txt"
#exportarTablaAFichero "datos_desa" "tb_ds_pasado_validation_targets_${TAG}" "${PATH_MYSQL_PRIV_SECURE}037_ds_pasado_val_t.txt" "${LOG_061}" "${PATH_DIR_OUT}037_ds_pasado_val_t.txt"
#exportarTablaAFichero "datos_desa" "tb_val_${TAG}" "${PATH_MYSQL_PRIV_SECURE}037_ds_pasado_val_tptr.txt" "${LOG_061}" "${PATH_DIR_OUT}037_ds_pasado_val_tptr.txt" #target predicho y real

##PASADO: 038
echo -e "Datasets pasados" >> "${LOG_061}"
exportarTablaAFichero "datos_desa" "tb_ds_pasado_ttv_features_${TAG}" "${PATH_MYSQL_PRIV_SECURE}038_ds_pasado_f.txt" "${LOG_061}" "${PATH_DIR_OUT}038_ds_pasado_f.txt"
exportarTablaAFichero "datos_desa" "tb_ds_pasado_ttv_targets_${TAG}" "${PATH_MYSQL_PRIV_SECURE}038_ds_pasado_t.txt" "${LOG_061}" "${PATH_DIR_OUT}038_ds_pasado_t.txt"

##FUTURO: 037+050
echo -e "Datasets futuros" >> "${LOG_061}"
exportarTablaAFichero "datos_desa" "tb_ds_futuro_features_${TAG}" "${PATH_MYSQL_PRIV_SECURE}037_ds_futuro_f.txt" "${LOG_061}" "${PATH_DIR_OUT}037_ds_futuro_f.txt"
exportarTablaAFichero "datos_desa" "tb_fut_${TAG}_aux3" "${PATH_MYSQL_PRIV_SECURE}050_ds_futuro_t.txt" "${LOG_061}" "${PATH_DIR_OUT}050_ds_futuro_t.txt"

#INFORMES (PRIORI)
echo -e "Informes (priori)" >> "${LOG_061}"
cp "$LOG_070" "${PATH_DIR_OUT}priori_tic.txt" #Informe TIC. En su ultima linea aparece el COMANDO que debo lanzar a POSTERIORI
cp "$INFORME_RENTABILIDADES" "${PATH_DIR_OUT}priori_rentabilidades.txt"
cp "$INFORME_PREDICCIONES" "${PATH_DIR_OUT}priori_predicciones.txt"
cp "$INFORME_PREDICCIONES_COMANDOS" "${PATH_DIR_OUT}priori_predicciones_comandos.txt"

#Posteriori --> Ver script 099



##################### Permisos ########################################################################
chmod -R 777 "${PATH_DIR_OUT}"
#####################################################################################################

echo -e $(date +"%T")" | 061 | Export de datasets pasados y futuros | FIN" >>$LOG_070




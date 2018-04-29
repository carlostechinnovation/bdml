#!/bin/bash

source "/home/carloslinux/git/bdml/mod002parser/scripts/galgos/funciones.sh"

#Borrar log
rm -f "${LOG_061}"


####### PARAMETROS ###
TAG="${1}"

echo -e $(date +"%T")" | 061 | Export de datasets pasados y futuros | INICIO" >>$LOG_070
echo -e "MOD061 --> LOG = "${LOG_061}

#Limpiar informe
rm -f "${LOG_061}"

########## SUBCARPETAS #################
rm -Rf $EXTERNAL_037_DS_PASADOS_SPLIT 
mkdir $EXTERNAL_037_DS_PASADOS_SPLIT

rm -Rf $EXTERNAL_038_DS_PASADOS
mkdir $EXTERNAL_038_DS_PASADOS

rm -Rf $EXTERNAL_050_DS_FUTUROS
mkdir $EXTERNAL_050_DS_FUTUROS


############### EXPORTACION A CARPETA EXTERNA #####################

##PASADO (SPLIT): 037
echo -e "Datasets pasados (train, test, validation)" >> "${LOG_061}"
exportarTablaAFichero "datos_desa" "tb_ds_pasado_train_features_${TAG}" "${PATH_MYSQL_PRIV_SECURE}037_ds_pasado_train_f.txt" "${LOG_061}" "${EXTERNAL_037_DS_PASADOS_SPLIT}037_ds_pasado_train_f.txt"
exportarTablaAFichero "datos_desa" "tb_ds_pasado_train_targets_${TAG}" "${PATH_MYSQL_PRIV_SECURE}037_ds_pasado_train_t.txt" "${LOG_061}" "${EXTERNAL_037_DS_PASADOS_SPLIT}037_ds_pasado_train_t.txt"
exportarTablaAFichero "datos_desa" "tb_ds_pasado_test_features_${TAG}" "${PATH_MYSQL_PRIV_SECURE}037_ds_pasado_test_f.txt" "${LOG_061}" "${EXTERNAL_037_DS_PASADOS_SPLIT}037_ds_pasado_test_f.txt"
exportarTablaAFichero "datos_desa" "tb_ds_pasado_test_targets_${TAG}" "${PATH_MYSQL_PRIV_SECURE}037_ds_pasado_test_t.txt" "${LOG_061}" "${EXTERNAL_037_DS_PASADOS_SPLIT}037_ds_pasado_test_t.txt"
exportarTablaAFichero "datos_desa" "tb_ds_pasado_validation_features_${TAG}" "${PATH_MYSQL_PRIV_SECURE}037_ds_pasado_val_f.txt" "${LOG_061}" "${EXTERNAL_037_DS_PASADOS_SPLIT}037_ds_pasado_val_f.txt"
exportarTablaAFichero "datos_desa" "tb_ds_pasado_validation_targets_${TAG}" "${PATH_MYSQL_PRIV_SECURE}037_ds_pasado_val_t.txt" "${LOG_061}" "${EXTERNAL_037_DS_PASADOS_SPLIT}037_ds_pasado_val_t.txt"
exportarTablaAFichero "datos_desa" "tb_val_${TAG}" "${PATH_MYSQL_PRIV_SECURE}037_ds_pasado_val_tptr.txt" "${LOG_061}" "${EXTERNAL_037_DS_PASADOS_SPLIT}037_ds_pasado_val_tptr.txt" #target predicho y real

##PASADO: 038
echo -e "Datasets pasados" >> "${LOG_061}"
exportarTablaAFichero "datos_desa" "tb_ds_pasado_ttv_features_${TAG}" "${PATH_MYSQL_PRIV_SECURE}038_ds_pasado_f.txt" "${LOG_061}" "${EXTERNAL_038_DS_PASADOS}038_ds_pasado_f.txt"
exportarTablaAFichero "datos_desa" "tb_ds_pasado_ttv_targets_${TAG}" "${PATH_MYSQL_PRIV_SECURE}038_ds_pasado_t.txt" "${LOG_061}" "${EXTERNAL_038_DS_PASADOS}038_ds_pasado_t.txt"

##FUTURO: 037+050
echo -e "Datasets futuros" >> "${LOG_061}"
exportarTablaAFichero "datos_desa" "tb_ds_futuro_features_${TAG}" "${PATH_MYSQL_PRIV_SECURE}037_ds_futuro_f.txt" "${LOG_061}" "${EXTERNAL_050_DS_FUTUROS}037_ds_futuro_f.txt"
exportarTablaAFichero "datos_desa" "tb_fut_${TAG}_aux3" "${PATH_MYSQL_PRIV_SECURE}050_ds_futuro_t.txt" "${LOG_061}" "${EXTERNAL_050_DS_FUTUROS}050_ds_futuro_t.txt"

#####################################################################################################

echo -e $(date +"%T")" | 061 | Export de datasets pasados y futuros | FIN" >>$LOG_070




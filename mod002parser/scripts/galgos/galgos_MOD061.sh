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
mkdir $EXTERNAL_038_DS_PASADOS
mkdir $EXTERNAL_050_DS_FUTUROS


############### EXPORTACION A CARPETA EXTERNA #####################

##PASADO: 038
echo -e "Datasets pasados" >> "${LOG_061}"
exportarTablaAFichero "datos_desa" "tb_ds_pasado_ttv_features_${TAG}" "${PATH_MYSQL_PRIV_SECURE}038_ds_pasado_f.txt" "${LOG_061}" "${EXTERNAL_010_BRUTO}038_ds_pasado_f.txt"
exportarTablaAFichero "datos_desa" "tb_ds_pasado_ttv_targets_${TAG}" "${PATH_MYSQL_PRIV_SECURE}038_ds_pasado_t.txt" "${LOG_061}" "${EXTERNAL_010_BRUTO}038_ds_pasado_t.txt"


##FUTURO: 037+050
echo -e "Datasets futuros" >> "${LOG_061}"
exportarTablaAFichero "datos_desa" "tb_ds_futuro_features_${TAG}" "${PATH_MYSQL_PRIV_SECURE}037_ds_futuro_f.txt" "${LOG_061}" "${EXTERNAL_010_BRUTO}037_ds_futuro_f.txt"
exportarTablaAFichero "datos_desa" "tb_fut_${TAG}_aux3" "${PATH_MYSQL_PRIV_SECURE}050_ds_futuro_t.txt" "${LOG_061}" "${EXTERNAL_010_BRUTO}050_ds_futuro_t.txt"




#####################################################################################################

echo -e $(date +"%T")" | 061 | Export de datasets pasados y futuros | FIN" >>$LOG_070




#!/bin/bash

source "/root/git/bdml/mod002parser/scripts/galgos/funciones.sh"

#### Limpiar LOG ###
rm -f "${LOG_038_DS_TTV}"

#Parametro
TAG="${1}"

echo -e $(date +"%T")" | 038 | Datasets pasados: TRAIN+TEST+VAL (subgrupo: $TAG) | INICIO" >>$LOG_070
echo -e $(date +"%T")" Creo un gran DS-PASADO-TTV" 2>&1 1>>${LOG_038_DS_TTV}

#####################################################################################
echo -e $(date +"%T")" PASADO-TTV..." 2>&1 1>>${LOG_038_DS_TTV}

read -d '' CONSULTA_DS_TTV <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_ds_pasado_ttv_features_${TAG};

CREATE TABLE datos_desa.tb_ds_pasado_ttv_features_${TAG} AS 
SELECT * FROM datos_desa.tb_ds_pasado_train_features_${TAG}
UNION ALL
SELECT * FROM datos_desa.tb_ds_pasado_test_features_${TAG}
UNION ALL
SELECT * FROM datos_desa.tb_ds_pasado_validation_features_${TAG}
;

SELECT * FROM datos_desa.tb_ds_pasado_ttv_features_${TAG} LIMIT 3;
SELECT count(*) as num_pasado_ttv_features FROM datos_desa.tb_ds_pasado_ttv_features_${TAG} LIMIT 1;


DROP TABLE IF EXISTS datos_desa.tb_ds_pasado_ttv_targets_${TAG};

CREATE TABLE datos_desa.tb_ds_pasado_ttv_targets_${TAG} AS 
SELECT * FROM datos_desa.tb_ds_pasado_train_targets_${TAG}
UNION ALL
SELECT * FROM datos_desa.tb_ds_pasado_test_targets_${TAG}
UNION ALL
SELECT * FROM datos_desa.tb_ds_pasado_validation_targets_${TAG}
;

SELECT * FROM datos_desa.tb_ds_pasado_ttv_targets_${TAG} LIMIT 3;
SELECT count(*) as num_pasado_ttv_targets FROM datos_desa.tb_ds_pasado_ttv_targets_${TAG} LIMIT 1;

EOF

echo -e "\n ----------------- $CONSULTA_DS_TTV\n ----------------- " 2>&1 1>>${LOG_038_DS_TTV}
mysql -u root --password=datos1986 -t --execute="$CONSULTA_DS_TTV" 2>&1 1>>${LOG_038_DS_TTV}

echo -e "PASADO-TRAIN --> datos_desa.tb_ds_pasado_ttv_features_${TAG}   datos_desa.tb_ds_pasado_ttv_targets_${TAG}" 2>&1 1>>${LOG_038_DS_TTV}


######### Análisis del DATASET de PASADO-TTV-FEATURES (entrada) y FUTURO-TTV-TARGETS (entrada) #######################

analizarTabla "datos_desa" "tb_ds_pasado_ttv_features_${TAG}" "${LOG_038_DS_TTV}"
analizarTabla "datos_desa" "tb_ds_pasado_ttv_targets_${TAG}" "${LOG_038_DS_TTV}"


echo -e "\n---------------- DATASET-TTV --------------" 2>&1 1>>${LOG_038_DS_TTV}
echo -e "datos_desa.tb_ds_pasado_ttv_features_${TAG}  <--> datos_desa.tb_ds_pasado_ttv_targets_${TAG}" 2>&1 1>>${LOG_038_DS_TTV}
echo -e "----------------------------------------------------\n\n\n" 2>&1 1>>${LOG_038_DS_TTV}


###########################################################################

echo -e $(date +"%T")" | 038 | Datasets pasados: TRAIN+TEST+VAL (subgrupo: $TAG) | FIN" >>$LOG_070




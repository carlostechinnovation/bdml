#!/bin/bash

source "/root/git/bdml/mod002parser/scripts/galgos/funciones.sh"

#### Limpiar LOG ###
rm -f $LOG_ML

######################## PARAMETROS ############
if [ "$#" -ne 1 ]; then
    echo " Numero de parametros incorrecto!!!" 2>&1 1>>${LOG_ML}
fi

TAG="${1}"


echo -e $(date +"%T")" Modulo 040 - Modelos predictivos (nucleo)" 2>&1 1>>${LOG_ML}

echo -e "MOD040 --> LOG = "${LOG_ML}

PATH_MODELO_GANADOR='/home/carloslinux/Desktop/GIT_REPO_PYTHON_POC_ML/python_poc_ml/galgos/galgos_regresion_MEJOR_MODELO.pkl'
rm -f $PATH_MODELO_GANADOR


########### Modelo predictivo REGRESION ###########
echo -e $(date +"%T")" Entrenando el modelo (train) y sacando score (test)..." 2>&1 1>>${LOG_ML}
python3 '/home/carloslinux/Desktop/GIT_REPO_PYTHON_POC_ML/python_poc_ml/galgos/galgos_regresion_train_test.py' "_${TAG}" >> "${LOG_ML}"

cat "${LOG_ML}" | grep 'Gana modelo'  >&1

echo -e $(date +"%T")" Generando tabla de validacion..." 2>&1 1>>${LOG_ML}

PATH_FILE_VALIDATION_TARGETS_PREDICHOS="/home/carloslinux/Desktop/DATOS_LIMPIO/galgos/pasado_validation_targets_predichos_"${TAG}".txt"

read -d '' CONSULTA_VALIDACION <<- EOF

DROP TABLE IF EXISTS datos_desa.tb_val_${TAG}_aux1;
CREATE TABLE datos_desa.tb_val_${TAG}_aux1 AS
SELECT A.*, @rowid:=@rowid+1 as rowid FROM datos_desa.tb_ds_pasado_validation_features_${TAG} A, (SELECT @rowid:=0) R;

DROP TABLE IF EXISTS datos_desa.tb_val_${TAG}_aux2;
CREATE TABLE datos_desa.tb_val_${TAG}_aux2 AS
SELECT A.*, @rowid:=@rowid+1 as rowid FROM datos_desa.tb_ds_pasado_validation_targets_${TAG} A, (SELECT @rowid:=0) R;


DROP TABLE IF EXISTS datos_desa.tb_val_${TAG}_aux3;
CREATE TABLE datos_desa.tb_val_${TAG}_aux3 (TARGET decimal(8,6) DEFAULT NULL) ENGINE=InnoDB DEFAULT CHARSET=latin1;
LOAD DATA LOCAL INFILE '$PATH_FILE_VALIDATION_TARGETS_PREDICHOS' INTO TABLE datos_desa.tb_val_${TAG}_aux3;

DROP TABLE IF EXISTS datos_desa.tb_val_${TAG}_aux4;
CREATE TABLE datos_desa.tb_val_${TAG}_aux4 AS
SELECT A.*, @rowid:=@rowid+1 as rowid FROM datos_desa.tb_val_${TAG}_aux3 A, (SELECT @rowid:=0) R;


DROP TABLE IF EXISTS datos_desa.tb_val_${TAG}_aux5;

CREATE TABLE datos_desa.tb_val_${TAG}_aux5 AS
SELECT dentro.id_carrera, @rowid:=@rowid+1 as rowid 
FROM datos_desa.tb_ds_pasado_validation_featuresytarget_${TAG} dentro, (SELECT @rowid:=0) R;


SELECT count(*) as num_tb_val1 FROM datos_desa.tb_val_${TAG}_aux1 LIMIT 1;
SELECT count(*) as num_tb_val2 FROM datos_desa.tb_val_${TAG}_aux2 LIMIT 1;
SELECT count(*) as num_tb_val3 FROM datos_desa.tb_val_${TAG}_aux3 LIMIT 1;
SELECT count(*) as num_tb_val4 FROM datos_desa.tb_val_${TAG}_aux4 LIMIT 1;
SELECT count(*) as num_tb_val5 FROM datos_desa.tb_val_${TAG}_aux5 LIMIT 1;


SELECT * FROM datos_desa.tb_val_${TAG}_aux1 LIMIT 5;
SELECT * FROM datos_desa.tb_val_${TAG}_aux2 LIMIT 5;
SELECT * FROM datos_desa.tb_val_${TAG}_aux4 LIMIT 5;
SELECT * FROM datos_desa.tb_val_${TAG}_aux5 LIMIT 5;


ALTER TABLE datos_desa.tb_val_${TAG}_aux1 ADD INDEX tb_val_${TAG}_aux1_idx(rowid);
ALTER TABLE datos_desa.tb_val_${TAG}_aux2 ADD INDEX tb_val_${TAG}_aux2_idx(rowid);
ALTER TABLE datos_desa.tb_val_${TAG}_aux4 ADD INDEX tb_val_${TAG}_aux4_idx(rowid);
ALTER TABLE datos_desa.tb_val_${TAG}_aux5 ADD INDEX tb_val_${TAG}_aux5_idx(rowid);


DROP TABLE IF EXISTS datos_desa.tb_val_${TAG};

CREATE TABLE datos_desa.tb_val_${TAG} AS
SELECT 
T1.*,
T2.TARGET AS target_real,
T4.TARGET AS target_predicho,
T5.id_carrera
FROM datos_desa.tb_val_${TAG}_aux1 T1
LEFT JOIN datos_desa.tb_val_${TAG}_aux2 T2 ON (T1.rowid=T2.rowid)
LEFT JOIN datos_desa.tb_val_${TAG}_aux4 T4 ON (T1.rowid=T4.rowid)
LEFT JOIN datos_desa.tb_val_${TAG}_aux5 T5 ON (T1.rowid=T5.rowid)
;

SELECT * FROM datos_desa.tb_val_${TAG} LIMIT 3;
SELECT count(*) as num_ids_validation_predichos FROM datos_desa.tb_val_${TAG} LIMIT 1;

SELECT id_carrera, count(*) AS contador  FROM datos_desa.tb_val_${TAG}  GROUP BY id_carrera ORDER BY contador DESC LIMIT 10;
EOF


#echo -e $(date +"%T")"$CONSULTA_VALIDACION" 2>&1 1>>${LOG_ML}
mysql -u root --password=datos1986 -t --execute="$CONSULTA_VALIDACION" 2>&1 1>>${LOG_ML}


######################### CALCULO DEL SCORE + Rentabilidad en Predicción de target=1o2 y target=1st ################
${PATH_SCRIPTS}galgos_MOD041_1o2.sh "${TAG}" 2>&1 1>>${LOG_ML}
${PATH_SCRIPTS}galgos_MOD042_1st.sh "${TAG}" 2>&1 1>>${LOG_ML}

################################################
##############################################################

echo -e $(date +"%T")" Modulo 040 - FIN\n\n" 2>&1 1>>${LOG_ML}






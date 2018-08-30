#!/bin/bash

source "/home/carloslinux/git/bdml/mod002parser/scripts/galgos/funciones.sh"

#### Limpiar LOG ###
#rm -f $LOG_ML

######################## PARAMETROS ############
if [ "$#" -ne 1 ]; then
    echo " Numero de parametros incorrecto!!!" 2>&1 1>>${LOG_ML}
fi

TAG="${1}"


echo -e $(date +"%T")" | 040 | Modelo predictivo (subgrupo: $TAG) | INICIO" >>$LOG_070
echo -e "MOD040 (subgrupo: $TAG) --> LOG = "${LOG_ML}


PATH_FILE_VALIDATION_TARGETS_PREDICHOS="/home/carloslinux/Desktop/DATOS_LIMPIO/galgos/pasado_validation_targets_predichos_"${TAG}".txt"
echo -e "MOD040 - Se calcularan los pasado_validation_targets_predichos para $TAG . Borramos posible fichero antiguo... " 2>&1 1>>${LOG_ML}
rm -f $PATH_FILE_VALIDATION_TARGETS_PREDICHOS

#------------------------------------------------ PYTHON ----------------------------------------------------
#PATH_PYTHON_MODELO_GANADOR='/home/carloslinux/Desktop/WORKSPACES/wksp_pycharm/python_poc_ml/galgos/galgos_regresion_MEJOR_MODELO.pkl'
#rm -f $PATH_PYTHON_MODELO_GANADOR 2>&1 1>>"${LOG_ML}"

# Modelo predictivo REGRESION
#echo -e $(date +"%T")" Entrenando el modelo (train) y sacando score (test)..." 2>&1 1>>${LOG_ML}
#python3 '/home/carloslinux/Desktop/WORKSPACES/wksp_pycharm/python_poc_ml/galgos/galgos_regresion_train_test.py' "_${TAG}" 2>&1 1>>"${LOG_ML}"

#cat "${LOG_ML}" | grep 'Gana modelo'  >&1

#------------------------------------------------ R ----------------------------------------------------
# Modelo predictivo REGRESION
echo -e "MOD040 - Prediciendo con R..." 2>&1 1>>${LOG_ML}
Rscript '/home/carloslinux/Desktop/WORKSPACES/wksp_for_r/r_galgos/galgos_040_ttv_por_tag_pasado.R' "1" "${TAG}" "30000" "PCA" "/home/carloslinux/Desktop/DATOS_LIMPIO/galgos/pca_modelo_" $PCA_UMBRAL_VARIANZA_ACUM $TSNE_NUM_F_OUT 2>&1 1>>"${LOG_ML}"

#---------------------------------------------------------------------------------------------------------------




if [ -f "$PATH_FILE_VALIDATION_TARGETS_PREDICHOS" ]
then
	

############## dentro del IF
echo -e $(date +"%T")" Generando tabla de validacion..." 2>&1 1>>${LOG_ML}

read -d '' CONSULTA_VALIDACION <<- EOF

DROP TABLE IF EXISTS datos_desa.tb_val_${TAG}_aux1;
CREATE TABLE datos_desa.tb_val_${TAG}_aux1 AS
SELECT A.*, @rowid:=@rowid+1 as rowid FROM datos_desa.tb_ds_pasado_validation_features_${TAG} A, (SELECT @rowid:=0) R;

DROP TABLE IF EXISTS datos_desa.tb_val_${TAG}_aux2;
CREATE TABLE datos_desa.tb_val_${TAG}_aux2 AS
SELECT A.*, @rowid:=@rowid+1 as rowid FROM datos_desa.tb_ds_pasado_validation_targets_${TAG} A, (SELECT @rowid:=0) R;


DROP TABLE IF EXISTS datos_desa.tb_val_${TAG}_aux3;
CREATE TABLE datos_desa.tb_val_${TAG}_aux3 (TARGET decimal(15,13) DEFAULT NULL) ENGINE=InnoDB DEFAULT CHARSET=latin1;
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


DROP TABLE datos_desa.tb_val_${TAG}_aux1;
DROP TABLE datos_desa.tb_val_${TAG}_aux2;
DROP TABLE datos_desa.tb_val_${TAG}_aux3;
DROP TABLE datos_desa.tb_val_${TAG}_aux4;
DROP TABLE datos_desa.tb_val_${TAG}_aux5;


SELECT * FROM datos_desa.tb_val_${TAG} LIMIT 3;
SELECT count(*) as num_ids_validation_predichos FROM datos_desa.tb_val_${TAG} LIMIT 1;

SELECT id_carrera, count(*) AS contador  FROM datos_desa.tb_val_${TAG}  GROUP BY id_carrera ORDER BY contador DESC LIMIT 10;




EOF


echo -e "$CONSULTA_VALIDACION" 2>&1 1>>${LOG_ML}
mysql -t --execute="$CONSULTA_VALIDACION" 2>&1 1>>${LOG_ML}


######################### CALCULO DEL SCORE + Rentabilidad en Predicción de target=1o2 y target=1st ################
echo -e "MOD040 - Analisis economico por grupos de SP: sirve para ELEGIR en qué carreras pongo el euro, de las 200 que haya apostables. Es decir, debo mirar estos resultados poner el euro sólo en las que cumplan ese grupo_sp." 2>&1 1>>${LOG_ML}
#${PATH_SCRIPTS}galgos_MOD041_1o2.sh "${TAG}" 2>&1 1>>${LOG_ML}
${PATH_SCRIPTS}galgos_MOD042_1st.sh "${TAG}" 2>&1 1>>${LOG_ML}

#Combinacion ganadora



############## fin del primer IF

else
	echo "$PATH_FILE_VALIDATION_TARGETS_PREDICHOS no encontrado!! ERROR!!"
fi




################################################
##############################################################

echo -e $(date +"%T")" | 040 | Modelos predictivos | FIN" >>$LOG_070






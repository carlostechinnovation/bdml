#!/bin/bash

source "/root/git/bdml/mod002parser/scripts/galgos/funciones.sh"


######################## PARAMETROS ############
if [ "$#" -ne 1 ]; then
    echo " Numero de parametros incorrecto!!!" 2>&1 1>>${LOG_DS}
fi

TAG="${1}"


#### Limpiar LOG ###
rm -f $LOG_ML

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


echo -e $(date +"%T")"$CONSULTA_VALIDACION" 2>&1 1>>${LOG_ML}
mysql -u root --password=datos1986 -t --execute="$CONSULTA_VALIDACION" >>$LOG_ML


######################### CALCULO DEL SCORE ################
echo -e $(date +"%T")" Calculando SCORE a partir del dataset de VALIDATION..." 2>&1 1>>${LOG_ML}

#SCORE: de las predichas que hayan quedado primero o segundo, veremos si en REAL quedaron primero o segundo. Y sacamos el porcentaje de acierto.

read -d '' CONSULTA_SCORE <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_val_score_real_${TAG};

CREATE TABLE datos_desa.tb_val_score_real_${TAG} AS
SELECT id_carrera, galgo_rowid, target_real,
CASE id_carrera
  WHEN @curIdCarrera THEN @curRow := @curRow + 1 
  ELSE (@curRow := 1 AND @curIdCarrera := id_carrera )
END AS posicion_real
FROM (
  SELECT id_carrera, rowid AS galgo_rowid, target_real FROM datos_desa.tb_val_${TAG}  ORDER BY id_carrera ASC, target_real DESC 
) dentro,
(SELECT @curRow := 0, @curIdCarrera := '') R;


DROP TABLE IF EXISTS datos_desa.tb_val_score_predicho_${TAG};

CREATE TABLE datos_desa.tb_val_score_predicho_${TAG} AS
SELECT id_carrera, galgo_rowid, target_predicho,
CASE id_carrera
  WHEN @curIdCarrera THEN @curRow := @curRow + 1 
  ELSE (@curRow := 1 AND @curIdCarrera := id_carrera )
END AS posicion_predicha
FROM (
  SELECT id_carrera, rowid AS galgo_rowid, target_predicho FROM datos_desa.tb_val_${TAG} ORDER BY id_carrera ASC, target_predicho DESC 
) dentro,
(SELECT @curRow := 0, @curIdCarrera := '') R;


DROP TABLE IF EXISTS datos_desa.tb_score_aciertos_${TAG};

CREATE TABLE datos_desa.tb_score_aciertos_${TAG} AS
SELECT A.*, B.posicion_real,

CASE
  WHEN A.posicion_predicha IN (1,2) THEN true
  ELSE false
END AS predicha_1o2,

CASE 
  WHEN (A.posicion_predicha IN (1,2) AND B.posicion_real IN (1,2)) THEN 1
  ELSE 0 
END as acierto

FROM datos_desa.tb_val_score_predicho_${TAG} A
LEFT JOIN datos_desa.tb_val_score_real_${TAG} B
ON (A.id_carrera=B.id_carrera AND A.galgo_rowid=B.galgo_rowid)
;


DROP TABLE IF EXISTS datos_desa.tb_val_connombre_${TAG};

CREATE TABLE datos_desa.tb_val_connombre_${TAG} AS
SELECT AB.*, @rowid:=@rowid+1 as rowid 
FROM (
  SELECT A.id_carrera, A.galgo_nombre
  FROM datos_desa.tb_dataset_con_ids_${TAG} A 
  RIGHT JOIN datos_desa.tb_dataset_ids_pasado_validation_${TAG} B
  ON (A.id_carrera=B.id_carrera)
) AB
, (SELECT @rowid:=0) R;



DROP TABLE IF EXISTS datos_desa.tb_val_aciertos_connombre_${TAG};

CREATE TABLE datos_desa.tb_val_aciertos_connombre_${TAG} AS
SELECT A.*, B.galgo_nombre
FROM datos_desa.tb_score_aciertos_${TAG} A
LEFT JOIN datos_desa.tb_val_connombre_${TAG} B
ON (A.galgo_rowid=B.rowid);

ALTER TABLE datos_desa.tb_val_aciertos_connombre_${TAG} ADD INDEX tb_val_aciertos_connombre_${TAG}_idx(id_carrera, galgo_nombre);
EOF

echo -e "$CONSULTA_SCORE" 2>&1 1>>${LOG_ML}
mysql -u root --password=datos1986 -t --execute="$CONSULTA_SCORE" >>$LOG_ML

FILE_TEMP="./temp_numero_MOD004"

#Numeros: SOLO pongo el dinero en las que el sistema me predice 1o2, pero no en las otras predichas.
mysql -u root --password=datos1986 -N --execute="SELECT SUM(acierto) as num_aciertos FROM datos_desa.tb_val_aciertos_connombre_${TAG} LIMIT 1;" > ${FILE_TEMP}
numero_aciertos=$( cat ${FILE_TEMP})

mysql -u root --password=datos1986 -N --execute="SELECT count(*) as num_predicciones_1o2 FROM datos_desa.tb_val_aciertos_connombre_${TAG} WHERE predicha_1o2 = true LIMIT 1;" > ${FILE_TEMP}
numero_predicciones_1o2=$( cat ${FILE_TEMP})

echo -e "numero_aciertos = ${numero_aciertos}" 2>&1 1>>${LOG_ML}
echo -e "numero_predicciones_1o2 = ${numero_predicciones_1o2}" 2>&1 1>>${LOG_ML}

SCORE_FINAL=$(echo "scale=2; $numero_aciertos / $numero_predicciones_1o2" | bc -l)
echo -e "\nTAG=$TAG --> SCORE (sobre dataset de validation) = ${numero_aciertos}/${numero_predicciones_1o2} = ${SCORE_FINAL}" 2>&1 1>>${LOG_ML}



echo -e "\nEjemplos de filas PREDICHAS (dataset PASADO_VALIDATION):" 2>&1 1>>${LOG_ML}
mysql -u root --password=datos1986 --execute="SELECT id_carrera, galgo_nombre, posicion_real, posicion_predicha, predicha_1o2, acierto FROM datos_desa.tb_val_aciertos_connombre_${TAG} LIMIT 3;" 2>&1 1>>${LOG_ML}


##################### CALCULO ECONÓMICO ################

echo -e "\nCalculo ECONOMICO sobre DS-PASADO-VALIDATION..." 2>&1 1>>${LOG_ML}
mysql -u root --password=datos1986 --execute="DROP TABLE IF EXISTS datos_desa.tb_val_economico_${TAG};" 2>&1 1>>${LOG_ML}

mysql -u root --password=datos1986 --execute="CREATE TABLE datos_desa.tb_val_economico_${TAG} AS SELECT A.*, GH.sp, 2 AS gastado_1o2, acierto*1*sp AS beneficio_bruto FROM datos_desa.tb_val_aciertos_connombre_${TAG} A INNER JOIN datos_desa.tb_galgos_historico_norm GH ON (A.id_carrera=GH.id_carrera AND A.galgo_nombre=GH.galgo_nombre AND A.posicion_predicha IN (1,2) AND GH.sp>=2.01);" 2>&1 1>>${LOG_ML}

mysql -u root --password=datos1986 --execute="SELECT 'NULOS' AS tipo, count(*) AS contador FROM datos_desa.tb_val_economico_${TAG} WHERE beneficio_bruto IS NULL   UNION ALL   SELECT 'LLENOS' AS tipo, count(*) AS contador FROM datos_desa.tb_val_economico_${TAG} WHERE beneficio_bruto IS NOT NULL LIMIT 10;" 2>&1 1>>${LOG_ML}

echo -e "\nEjemplos de filas con valoración ECONÓMICA (dataset PASADO_VALIDATION):" 2>&1 1>>${LOG_ML}
mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_val_economico_${TAG} LIMIT 10;" 2>&1 1>>${LOG_ML}



FILE_TEMP="./temp_numero"
rm -f ${FILE_TEMP}
mysql -u root --password=datos1986 -N --execute="SELECT SUM(beneficio_bruto)/SUM(gastado_1o2) AS rentabilidad_${TAG} FROM datos_desa.tb_val_economico_${TAG};" > ${FILE_TEMP}
rentabilidad=$( cat ${FILE_TEMP})

echo -e "Rentabilidad (sobre dataset PASADO_VALIDATION; señal de compra si >1.0) - ${TAG} --> ${rentabilidad}" 2>&1 1>>${LOG_ML}


echo -e "ATENCION: Solo pongo DINERO en las carreras predichas 1º o 2º y que paguen más de 2.01 euros por ganador y colocado!!!! \n\n" 2>&1 1>>${LOG_ML}


##############################################################
############### SALIDA HACIA SCRIPT PADRE ####
echo -e "DS_PASADO_VALIDATION|${TAG}|SCORE = ${numero_aciertos}/${numero_predicciones_1o2} = ${SCORE_FINAL}|Rentabilidad = ${rentabilidad}"

################################################
##############################################################

echo -e $(date +"%T")" Modulo 040 - FIN\n\n" 2>&1 1>>${LOG_ML}






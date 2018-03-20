#!/bin/bash

source "/root/git/bdml/mod002parser/scripts/galgos/funciones.sh"

######################## PARAMETROS ############
if [ "$#" -ne 1 ]; then
    echo " Numero de parametros incorrecto!!!" 2>&1 1>>${LOG_045}
fi

TAG="${1}"

#### Limpiar LOG ###
rm -f $LOG_050

echo -e $(date +"%T")" | 050 | Prediccion FUTURA | INICIO" >>$LOG_070
echo -e "MOD050 --> LOG = "${LOG_050}


########### Modelo predictivo REGRESION ###########
PATH_MODELO_GANADOR='/home/carloslinux/Desktop/GIT_REPO_PYTHON_POC_ML/python_poc_ml/galgos/galgos_regresion_MEJOR_MODELO.pkl'

echo -e $(date +"%T")" Ejecutando modelo (ya entrenado) sobre DS-FUTURO..." 2>&1 1>>${LOG_050}
python3 '/home/carloslinux/Desktop/GIT_REPO_PYTHON_POC_ML/python_poc_ml/galgos/galgos_regresion_predictor.py' "_${TAG}" 2>&1 1>>${LOG_050}


PATH_FILE_FUTURO_TARGETS="/home/carloslinux/Desktop/DATOS_LIMPIO/galgos/FILELOAD_ds_futuro_targets_${TAG}.txt"
PATH_FILE_FUTURO_TARGETS_LIMPIO="/home/carloslinux/Desktop/DATOS_LIMPIO/galgos/FILELOAD_ds_futuro_targets_2_${TAG}.txt"

#Limpiar los brackets metidos por python
cat "${PATH_FILE_FUTURO_TARGETS}" | tr -d '[' | tr ']' ' ' > "${PATH_FILE_FUTURO_TARGETS_LIMPIO}"

echo -e $(date +"%T")" Path de targets FUTUROS predichos = "$PATH_FILE_FUTURO_TARGETS_LIMPIO 2>&1 1>>${LOG_050}
echo -e $(date +"%T")" Ejemplo de targets FUTUROS predichos:" 2>&1 1>>${LOG_050}
echo -e $(head -n 10 $PATH_FILE_FUTURO_TARGETS_LIMPIO) 2>&1 1>>${LOG_050}

echo -e "\n\n---------------------- Comprobacion de PREDICCIONES ----------------------------------\n" 2>&1 1>>${LOG_050}
num_targets_file=$(cat "$PATH_FILE_FUTURO_TARGETS_LIMPIO" | wc -l)
if [ ${num_targets_file} -eq 0 ]
  then
    echo -e "ERROR En el fichero generado por Python (050) NO hay NINGUN target PREDICHO. Salida forzada. num_targets_file=$num_targets_file"
    exit -1
fi
echo -e "\n-------------------------------------------------------------------\n" 2>&1 1>>${LOG_050}

echo -e $(date +"%T")" Generando tabla de predicciones FUTURAS (subgrupo ${TAG})..." 2>&1 1>>${LOG_ML}

read -d '' CONSULTA_PREDICCIONES_FUTURAS_1 <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_fut_${TAG}_aux1;
CREATE TABLE datos_desa.tb_fut_${TAG}_aux1 AS
SELECT A.*, @rowid:=@rowid+1 as rowid FROM datos_desa.tb_ds_futuro_features_${TAG} A, (SELECT @rowid:=0) R;

DROP TABLE IF EXISTS datos_desa.tb_fut_${TAG}_aux3;
CREATE TABLE datos_desa.tb_fut_${TAG}_aux3 (TARGET decimal(10,8) DEFAULT NULL) ENGINE=InnoDB DEFAULT CHARSET=latin1;
LOAD DATA LOCAL INFILE '$PATH_FILE_FUTURO_TARGETS_LIMPIO' INTO TABLE datos_desa.tb_fut_${TAG}_aux3;

DROP TABLE IF EXISTS datos_desa.tb_fut_${TAG}_aux4;
CREATE TABLE datos_desa.tb_fut_${TAG}_aux4 AS
SELECT A.*, @rowid:=@rowid+1 as rowid FROM datos_desa.tb_fut_${TAG}_aux3 A, (SELECT @rowid:=0) R;


-- Metemos id_carrera y galgo_nombre ---------------

DROP TABLE IF EXISTS datos_desa.tb_fut_${TAG}_aux5;
CREATE TABLE datos_desa.tb_fut_${TAG}_aux5 AS
SELECT dentro.id_carrera, @rowid:=@rowid+1 as rowid 
FROM datos_desa.tb_ds_futuro_features_id_${TAG} dentro, (SELECT @rowid:=0) R;


SELECT count(*) as num_tb_fut1 FROM datos_desa.tb_fut_${TAG}_aux1 LIMIT 1;
SELECT count(*) as num_tb_fut3 FROM datos_desa.tb_fut_${TAG}_aux3 LIMIT 1;
SELECT count(*) as num_tb_fut4 FROM datos_desa.tb_fut_${TAG}_aux4 LIMIT 1;
SELECT count(*) as num_tb_fut5 FROM datos_desa.tb_fut_${TAG}_aux5 LIMIT 1;

SELECT * FROM datos_desa.tb_fut_${TAG}_aux1 LIMIT 3;
SELECT * FROM datos_desa.tb_fut_${TAG}_aux3 LIMIT 3;
SELECT * FROM datos_desa.tb_fut_${TAG}_aux4 LIMIT 3;
SELECT * FROM datos_desa.tb_fut_${TAG}_aux5 LIMIT 3;


DROP TABLE IF EXISTS datos_desa.tb_fut_${TAG};

CREATE TABLE datos_desa.tb_fut_${TAG} AS
SELECT 
T1.*,
T4.TARGET AS target_predicho,
T5.id_carrera
FROM datos_desa.tb_fut_${TAG}_aux1 T1
LEFT JOIN datos_desa.tb_fut_${TAG}_aux4 T4 ON (T1.rowid=T4.rowid)
LEFT JOIN datos_desa.tb_fut_${TAG}_aux5 T5 ON (T1.rowid=T5.rowid)
;

SELECT * FROM datos_desa.tb_fut_${TAG} LIMIT 3;
SELECT count(*) as num_ids_futuro_predichos FROM datos_desa.tb_fut_${TAG} LIMIT 1;
EOF

echo -e "$CONSULTA_PREDICCIONES_FUTURAS_1" 2>&1 1>>${LOG_050}
mysql -u root --password=datos1986 -t --execute="$CONSULTA_PREDICCIONES_FUTURAS_1"  2>&1 1>>$LOG_050


echo -e "--------- Uso los resultados tras predecir ----------------" 2>&1 1>>${LOG_050}

read -d '' CONSULTA_PREDICCIONES_FUTURAS_2 <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_fut_1st_predicho_${TAG};

CREATE TABLE datos_desa.tb_fut_1st_predicho_${TAG} AS
SELECT id_carrera, galgo_rowid, target_predicho,
CASE id_carrera
  WHEN @curIdCarrera THEN @curRow := @curRow + 1 
  ELSE (@curRow := 1 AND @curIdCarrera := id_carrera )
END AS posicion_predicha
FROM (
  SELECT id_carrera, rowid AS galgo_rowid, target_predicho FROM datos_desa.tb_fut_${TAG} ORDER BY id_carrera ASC, target_predicho DESC 
) dentro,
(SELECT @curRow := 0, @curIdCarrera := '') R;



DROP TABLE IF EXISTS datos_desa.tb_fut_1st_connombre_${TAG};

CREATE TABLE datos_desa.tb_fut_1st_connombre_${TAG} AS
SELECT AB.*, @rowid:=@rowid+1 as rowid 
FROM (
  SELECT A.id_carrera, A.galgo_nombre
  FROM datos_desa.tb_dataset_con_ids_${TAG} A 
  RIGHT JOIN datos_desa.tb_dataset_ids_futuros_${TAG} B
  ON (A.id_carrera=B.id_carrera)
) AB
, (SELECT @rowid:=0) R;


SELECT * FROM datos_desa.tb_fut_1st_connombre_${TAG} LIMIT 3;
SELECT count(*) as num_ids_futuro_connombre FROM datos_desa.tb_fut_1st_connombre_${TAG} LIMIT 1;


DROP TABLE IF EXISTS datos_desa.tb_fut_1st_final_${TAG};

CREATE TABLE datos_desa.tb_fut_1st_final_${TAG} AS
SELECT A.*, B.galgo_nombre
FROM datos_desa.tb_fut_1st_predicho_${TAG} A
LEFT JOIN datos_desa.tb_fut_1st_connombre_${TAG} B
ON (A.galgo_rowid=B.rowid);

ALTER TABLE datos_desa.tb_fut_1st_final_${TAG} ADD INDEX tb_fut_1st_final_${TAG}_idx(id_carrera, galgo_nombre);


DROP TABLE IF EXISTS datos_desa.tb_fut_1st_final_riesgo_${TAG};

CREATE TABLE datos_desa.tb_fut_1st_final_riesgo_${TAG} AS
select 
A.*, 
-- RIESGO: cuanta mas diferencia, mas efectiva sera la prediccion
(A.target_predicho - B.target_predicho) AS dif_velocidades_ganador_y_perdedores
FROM datos_desa.tb_fut_1st_final_TRAINER_BUENOS_GALGOS  A
LEFT JOIN datos_desa.tb_fut_1st_final_TRAINER_BUENOS_GALGOS B
ON (A.id_carrera=B.id_carrera)
WHERE A.posicion_predicha=1 and B.posicion_predicha=2
ORDER BY dif_velocidades_ganador_y_perdedores DESC
;

ALTER TABLE datos_desa.tb_fut_1st_final_riesgo_${TAG} ADD INDEX tb_fut_1st_final_riesgo_${TAG}_idx(id_carrera, galgo_nombre);

SELECT * FROM datos_desa.tb_fut_1st_final_riesgo_${TAG} LIMIT 3;
SELECT count(*) as num_fut_1st_final FROM datos_desa.tb_fut_1st_final_riesgo_${TAG} LIMIT 1;
EOF

echo -e "$CONSULTA_PREDICCIONES_FUTURAS_2" 2>&1 1>>${LOG_050}
mysql -u root --password=datos1986 -t --execute="$CONSULTA_PREDICCIONES_FUTURAS_2"  2>&1 1>>$LOG_050


###################### INFORME FINAL ##########################
echo -e "MOD050 - Informe FINAL..." 2>&1 1>>${LOG_050}

#limpiar
rm -f "$INFORME_PREDICCIONES"

read -d '' CONSULTA_PREDICCIONES_INFORME <<- EOF
SELECT 
B.anio,B.mes,B.dia, B.track AS estadio, B.hora,B.minuto,
A.galgo_nombre, A.target_predicho, A.dif_velocidades_ganador_y_perdedores
FROM datos_desa.tb_fut_1st_final_riesgo_${TAG} A
LEFT JOIN  datos_desa.tb_galgos_carreras B
ON (A.id_carrera=B.id_carrera)
WHERE A.posicion_predicha=1 

ORDER BY B.anio ASC, B.mes ASC, B.dia ASC, B.hora ASC, B.minuto ASC;
EOF

echo -e "$CONSULTA_PREDICCIONES_INFORME" 2>&1 1>>${LOG_050}
mysql -u root --password=datos1986 -t --execute="$CONSULTA_PREDICCIONES_INFORME"  2>&1 1>>$INFORME_PREDICCIONES


###################### MAIL ##########################
#cat "$PATH_INFORME_FINAL" | mail -s "GALGOS - Prediccion carreras futuras Sportium" carlosandresgarcia1986@gmail.com,fcacereslau@hotmail.com,luisandresgarcia@gmail.com

##################################################

echo -e $(date +"%T")" | 050 | Prediccion FUTURA | FIN" >>$LOG_070





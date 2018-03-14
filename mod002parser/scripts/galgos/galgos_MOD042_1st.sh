#!/bin/bash

source "/root/git/bdml/mod002parser/scripts/galgos/funciones.sh"


######################## PARAMETROS ############
if [ "$#" -ne 1 ]; then
    echo " MOD042_1st - Numero de parametros incorrecto!!!" 2>&1 1>>${LOG_ML}
fi

TAG="${1}"


echo -e $(date +"%T")" Modulo 042_1st - Modelos predictivos (nucleo)" 2>&1 1>>${LOG_ML}

echo -e "MOD042_1st --> LOG = "${LOG_ML}


######################### CALCULO DEL SCORE ################
echo -e $(date +"%T")" Calculando SCORE a partir del dataset de VALIDATION..." 2>&1 1>>${LOG_ML}

#SCORE: de las predichas que hayan quedado PRIMERO, veremos si en REAL quedaron PRIMERO. Y sacamos el porcentaje de acierto.

read -d '' CONSULTA_SCORE <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_val_1st_score_real_${TAG};

CREATE TABLE datos_desa.tb_val_1st_score_real_${TAG} AS
SELECT id_carrera, galgo_rowid, target_real,
CASE id_carrera
  WHEN @curIdCarrera THEN @curRow := @curRow + 1 
  ELSE (@curRow := 1 AND @curIdCarrera := id_carrera )
END AS posicion_real
FROM (
  SELECT id_carrera, rowid AS galgo_rowid, target_real FROM datos_desa.tb_val_${TAG} ORDER BY id_carrera ASC, target_real DESC 
) dentro,
(SELECT @curRow := 0, @curIdCarrera := '') R;


DROP TABLE IF EXISTS datos_desa.tb_val_1st_score_predicho_${TAG};

CREATE TABLE datos_desa.tb_val_1st_score_predicho_${TAG} AS
SELECT id_carrera, galgo_rowid, target_predicho,
CASE id_carrera
  WHEN @curIdCarrera THEN @curRow := @curRow + 1 
  ELSE (@curRow := 1 AND @curIdCarrera := id_carrera )
END AS posicion_predicha
FROM (
  SELECT id_carrera, rowid AS galgo_rowid, target_predicho FROM datos_desa.tb_val_${TAG} ORDER BY id_carrera ASC, target_predicho DESC 
) dentro,
(SELECT @curRow := 0, @curIdCarrera := '') R;


DROP TABLE IF EXISTS datos_desa.tb_1st_score_aciertos_${TAG};

CREATE TABLE datos_desa.tb_1st_score_aciertos_${TAG} AS
SELECT A.*, B.posicion_real,

CASE
  WHEN A.posicion_predicha IN (1) THEN true
  ELSE false
END AS predicha_1st,

CASE 
  WHEN (A.posicion_predicha IN (1) AND B.posicion_real IN (1)) THEN 1
  ELSE 0 
END as acierto

FROM datos_desa.tb_val_1st_score_predicho_${TAG} A
LEFT JOIN datos_desa.tb_val_1st_score_real_${TAG} B
ON (A.id_carrera=B.id_carrera AND A.galgo_rowid=B.galgo_rowid)
;


DROP TABLE IF EXISTS datos_desa.tb_val_1st_connombre_${TAG};

CREATE TABLE datos_desa.tb_val_1st_connombre_${TAG} AS
SELECT AB.*, @rowid:=@rowid+1 as rowid 
FROM (
  SELECT A.id_carrera, A.galgo_nombre
  FROM datos_desa.tb_dataset_con_ids_${TAG} A 
  RIGHT JOIN datos_desa.tb_dataset_ids_pasado_validation_${TAG} B
  ON (A.id_carrera=B.id_carrera)
) AB
, (SELECT @rowid:=0) R;



DROP TABLE IF EXISTS datos_desa.tb_val_1st_aciertos_connombre_${TAG};

CREATE TABLE datos_desa.tb_val_1st_aciertos_connombre_${TAG} AS
SELECT A.*, B.galgo_nombre
FROM datos_desa.tb_1st_score_aciertos_${TAG} A
LEFT JOIN datos_desa.tb_val_1st_connombre_${TAG} B
ON (A.galgo_rowid=B.rowid);

ALTER TABLE datos_desa.tb_val_1st_aciertos_connombre_${TAG} ADD INDEX tb_val_1st_aciertos_connombre_${TAG}_idx(id_carrera, galgo_nombre);
EOF

#echo -e "$CONSULTA_SCORE" 2>&1 1>>${LOG_ML}
mysql -u root --password=datos1986 -t --execute="$CONSULTA_SCORE" >>$LOG_ML

FILE_TEMP="./temp_numero_MOD042"

#Numeros: SOLO pongo el dinero en las que el sistema me predice 1st, pero no en las otras predichas.
mysql -u root --password=datos1986 -N --execute="SELECT SUM(acierto) as num_aciertos FROM datos_desa.tb_val_1st_aciertos_connombre_${TAG} LIMIT 1;" > ${FILE_TEMP}
numero_aciertos=$( cat ${FILE_TEMP})

mysql -u root --password=datos1986 -N --execute="SELECT count(*) as num_predicciones_1st FROM datos_desa.tb_val_1st_aciertos_connombre_${TAG} WHERE predicha_1st = true LIMIT 1;" > ${FILE_TEMP}
numero_predicciones_1st=$( cat ${FILE_TEMP})

echo -e "MOD042_1st numero_aciertos = ${numero_aciertos}" 2>&1 1>>${LOG_ML}
echo -e "MOD042_1st numero_predicciones_1st = ${numero_predicciones_1st}" 2>&1 1>>${LOG_ML}

SCORE_FINAL=$(echo "scale=2; $numero_aciertos / $numero_predicciones_1st" | bc -l)
echo -e "MOD042_1st|DS_PASADO_VALIDATION|${TAG}|Cualquier_SP|ACIERTOS=${numero_aciertos}|CASOS_1st=${numero_predicciones_1st}|SCORE = ${SCORE_FINAL}" 2>&1 1>>${LOG_ML}


echo -e "MOD042_1st Ejemplos de filas PREDICHAS (dataset PASADO_VALIDATION):" 2>&1 1>>${LOG_ML}
mysql -u root --password=datos1986 --execute="SELECT id_carrera, galgo_nombre, posicion_real, posicion_predicha, predicha_1st, acierto FROM datos_desa.tb_val_1st_aciertos_connombre_${TAG} LIMIT 3;" 2>&1 1>>${LOG_ML}


##################### CALCULO ECONÓMICO y salida hacia SCRIPT PADRE ################

#llamadas
calculoEconomico "1st" "1" "1.00" "1.50" "SP100150" "${TAG}" "1"
calculoEconomico "1st" "1" "1.50" "2.00" "SP150200" "${TAG}" "1"
calculoEconomico "1st" "1" "2.00" "2.50" "SP200250" "${TAG}" "1"
calculoEconomico "1st" "1" "2.50" "3.00" "SP250300" "${TAG}" "1"
calculoEconomico "1st" "1" "3.00" "999.00" "SP30099900" "${TAG}" "1"
calculoEconomico "1st" "1" "1.00" "999.00" "SP10099900" "${TAG}" "1"
calculoEconomico "1st" "1" "2.00" "999.00" "SP20099900" "${TAG}" "1"

##############################################################

echo -e $(date +"%T")" MOD042_1st - FIN\n\n" 2>&1 1>>${LOG_ML}




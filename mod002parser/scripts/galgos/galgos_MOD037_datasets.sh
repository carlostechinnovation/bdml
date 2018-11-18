#!/bin/bash

source "/home/carloslinux/git/bdml/mod002parser/scripts/galgos/funciones.sh"


#Parametro
TAG="${1}"

echo -e $(date +"%T")" | 037 | Datasets (subgrupo: $TAG) | INICIO" >>$LOG_070
echo -e $(date +"%T")" Solo debo usar las columnas que conocere en el futuro. Por ejemplo, no puedo coger going allowance." 2>&1 1>>${LOG_DS}


FILE_TEMP="./temp_numero"

#### PASADO y FUTURO, con boolean e IDs ###
read -d '' CONSULTA_CON_IDs <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_dataset_con_ids_${TAG};

CREATE TABLE datos_desa.tb_dataset_con_ids_${TAG} AS 

SELECT *
FROM (

SELECT 
A.galgo_nombre_ix,
A.id_carrera_ix,
A.cg,
A.futuro,
A.id_carrera, 
A.galgo_nombre, 
A.time_sec, 
A.time_distance, 
A.peso_galgo, 
A.galgo_padre, 
A.galgo_madre, 
A.comment, 
A.stmhcp, 
A.by_dato, 
A.galgo_primero_o_segundo, 
A.venue, 
A.remarks, 
A.win_time, 
A.going, 
A.calculated_time, 
A.velocidad_real, 
A.velocidad_con_going AS TARGET,
A.experiencia, 
A.posicion, 
A.id_campeonato,
A.trap_factor,
A.experiencia_cualitativo, 
A.experiencia_en_clase, 
A.posicion_media_en_clase_por_experiencia,
A.distancia_centenas, 
A.dif_peso,
A.entrenador_posicion_avg,
A.entrenador_posicion_std,
A.eed,
A.trap,
A.mes,
A.sp,
A.clase,
A.distancia,
A.entrenador,
A.remarks_puntos_historico,
A.remarks_puntos_historico_10d,
A.remarks_puntos_historico_20d,
A.remarks_puntos_historico_50d,

B.vel_real_cortas_mediana, 
B.vel_real_cortas_max, 
B.vel_going_cortas_mediana, 
B.vel_going_cortas_max, 
B.vel_real_longmedias_mediana, 
B.vel_real_longmedias_max, 
B.vel_going_longmedias_mediana, 
B.vel_going_longmedias_max, 
B.vel_real_largas_mediana, 
B.vel_real_largas_max, 
B.vel_going_largas_mediana, 
B.vel_going_largas_max,
B.vgcortas_med_min,
B.vgcortas_med_max,
B.vgmedias_med_min,
B.vgmedias_med_max,
B.vglargas_med_min,
B.vglargas_med_max,

C.track,
C.dow_d,C.dow_l,C.dow_m,C.dow_x,C.dow_j,C.dow_v,C.dow_s,C.dow_finde,C.dow_laborable,
C.num_galgos, 
C.mes_norm,
C.hora,
C.premio_primero,
C.premio_segundo,
C.premio_otros,
C.premio_total_carrera,
C.going_allowance_segundos,
C.fc_1,C.fc_2,C.fc_pounds,C.tc_1,C.tc_2,C.tc_3,C.tc_pounds,
C.tempMin, 
C.tempMax, 
C.tempSpan,
C.venue_going_std,
C.venue_going_avg

  FROM datos_desa.tb_filtrada_carrerasgalgos_${TAG} A
  INNER JOIN datos_desa.tb_filtrada_galgos_${TAG} B ON (A.galgo_nombre_ix=B.galgo_nombre_ix)
  INNER JOIN datos_desa.tb_filtrada_carreras_${TAG} C ON (A.id_carrera_ix=C.id_carrera_ix)
) dentro

WHERE (futuro=true OR (futuro=false AND dentro.TARGET IS NOT NULL))
;

ALTER TABLE datos_desa.tb_dataset_con_ids_${TAG} ADD INDEX tb_dscids_idx(id_carrera_ix);
SELECT count(*) as num_dataset_con_ids FROM datos_desa.tb_dataset_con_ids_${TAG} LIMIT 5;
EOF

echo -e $(date +"%T")"$CONSULTA_CON_IDs" 2>&1 1>>${LOG_DS}
mysql -t --execute="$CONSULTA_CON_IDs" >>$LOG_DS

echo -e $(date +"%T")"PASADO y FUTURO (con boolean e IDs) --> datos_desa.tb_dataset_con_ids_${TAG}" 2>&1 1>>${LOG_DS}


#####################################################################################

############# IDs ##############
#1º Separar los pasados de los futuros, sacando 2 listas de IDs (id_carrera). Debo conocer el target de TODOS los pasados.
#2º Barajar (shuffle) esas 2 listas de IDs: usando RAND()
#################################
read -d '' CONSULTA_IDS_PASADOS_Y_FUTUROS <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_dataset_ids_pasados_${TAG};
CREATE TABLE datos_desa.tb_dataset_ids_pasados_${TAG} AS 
SELECT DISTINCT id_carrera FROM ( SELECT id_carrera FROM datos_desa.tb_dataset_con_ids_${TAG} WHERE futuro=false AND TARGET IS NOT NULL ORDER BY rand() ) dentro;
ALTER TABLE datos_desa.tb_dataset_ids_pasados_${TAG} ADD INDEX tb_dscids_p_idx(id_carrera);
SELECT count(*) as num_ids_pasados FROM datos_desa.tb_dataset_ids_pasados_${TAG} LIMIT 1;

DROP TABLE IF EXISTS datos_desa.tb_dataset_ids_futuros_${TAG};
CREATE TABLE datos_desa.tb_dataset_ids_futuros_${TAG} AS 
SELECT DISTINCT id_carrera FROM ( SELECT id_carrera FROM datos_desa.tb_dataset_con_ids_${TAG} WHERE futuro=true ORDER BY rand() ) dentro;
ALTER TABLE datos_desa.tb_dataset_ids_futuros_${TAG} ADD INDEX tb_dscids_f_idx(id_carrera);
SELECT count(*) as num_ids_futuros FROM datos_desa.tb_dataset_ids_futuros_${TAG} LIMIT 1;
EOF

echo -e $(date +"%T")"$CONSULTA_IDS_PASADOS_Y_FUTUROS" 2>&1 1>>${LOG_DS}
mysql -t --execute="$CONSULTA_IDS_PASADOS_Y_FUTUROS" >>$LOG_DS


########## Numeros ##########
mysql -N --execute="SELECT count(*) as num_ids_pasados FROM datos_desa.tb_dataset_ids_pasados_${TAG} LIMIT 1;" > ${FILE_TEMP}
numero_ids_pasados=$( cat ${FILE_TEMP})

numero_pasados_test=$(echo "$DATASET_TEST_PORCENTAJE * $numero_ids_pasados" | bc | cut -f1 -d".")
numero_pasados_validation=$(echo "$DATASET_VALIDATION_PORCENTAJE * $numero_ids_pasados" | bc | cut -f1 -d".")

if [ -z "$numero_ids_pasados" ]
then
  numero_ids_pasados=0
fi
if [ -z "$numero_pasados_test" ]
then
  numero_pasados_test=0
fi
if [ -z "$numero_pasados_validation" ]
then
  numero_pasados_validation=0
fi

numero_pasados_train=$(echo "$numero_ids_pasados-$numero_pasados_test-$numero_pasados_validation" | bc)

echo -e "${TAG}|DS-Pasados = "${numero_ids_pasados}" --> [TRAIN + TEST + *VALIDATION] = "${numero_pasados_train}" + "${numero_pasados_test}" + *"${numero_pasados_validation} >>$LOG_DS
echo -e "${TAG}|DS-Pasados = "${numero_ids_pasados}" --> [TRAIN + TEST + *VALIDATION] = "${numero_pasados_train}" + "${numero_pasados_test}" + *"${numero_pasados_validation}
echo -e "* Los usados para Validation seran menos, porque solo cogere los id_carrera de los que conozca el resultado de los 6 galgos que corrieron. Descarto las carreras en las que solo conozca algunos de los galgos que corrieron. Esto es util para calcular bien el SCORE." >>$LOG_DS

mysql -N --execute="SELECT count(*) as num_ids_futuros FROM datos_desa.tb_dataset_ids_futuros_${TAG} LIMIT 1;" > ${FILE_TEMP}
numero_ids_futuros=$( cat ${FILE_TEMP})
echo -e "${TAG}|DS-Futuros = ${numero_ids_futuros}" >>$LOG_DS
echo -e "${TAG}|DS-Futuros = ${numero_ids_futuros}"

######################################################################
#3º Crear estas 4 listas de IDs: PASADO-TRAIN, PASADO-TEST, PASADO-VALIDATION, FUTURA (ya creada).
######################################################################
echo -e $(date +"%T")"\nATENCION: El dataset pasado-VALIDATION me servira para calcular el SCORE. Por ello, en ese dataset solo cojo aquellas en las que conozca SUFICIENTES galgos que corrieron por carrera. NO cogere carreras en las que solo conozca POCOS galgos de los que corrieron, SINO siempre un numero suficiente!!" >>$LOG_DS

num_suficiente_galgos_conocidos=4
echo -e "Numero de galgos SUFICIENTE para considerar que la carrera es usable para SCORE ==>" ${num_suficiente_galgos_conocidos}"\n" >>$LOG_DS

read -d '' CONSULTA_4_LISTAS_IDS <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_dataset_ids_pasado_train_${TAG};

CREATE TABLE datos_desa.tb_dataset_ids_pasado_train_${TAG} AS 
SELECT rowid,id_carrera 
FROM ( SELECT @rowid:=@rowid+1 as rowid, A.id_carrera FROM datos_desa.tb_dataset_ids_pasados_${TAG} A, (SELECT @rowid:=0) as t_numfila ) dentro 
WHERE rowid >= 1 AND rowid <= ${numero_pasados_train}
ORDER BY rowid;


DROP TABLE IF EXISTS datos_desa.tb_dataset_ids_pasado_test_${TAG};

CREATE TABLE datos_desa.tb_dataset_ids_pasado_test_${TAG} AS 
SELECT rowid,id_carrera 
FROM ( SELECT @rowid:=@rowid+1 as rowid, A.id_carrera FROM datos_desa.tb_dataset_ids_pasados_${TAG} A, (SELECT @rowid:=0) as t_numfila ) dentro 
WHERE rowid > ${numero_pasados_train} AND rowid <= (${numero_pasados_train}+${numero_pasados_test})
ORDER BY rowid;


DROP TABLE IF EXISTS datos_desa.tb_dataset_ids_pasado_validation_${TAG};

CREATE TABLE datos_desa.tb_dataset_ids_pasado_validation_${TAG} AS 
SELECT rowid,id_carrera 
FROM ( SELECT @rowid:=@rowid+1 as rowid, A.id_carrera FROM datos_desa.tb_dataset_ids_pasados_${TAG} A, (SELECT @rowid:=0) as t_numfila ) dentro 
WHERE rowid > (${numero_pasados_train}+${numero_pasados_test})
AND id_carrera IN (  SELECT id_carrera FROM datos_desa.tb_dataset_con_ids_${TAG} GROUP BY id_carrera HAVING count(*) >= ${num_suficiente_galgos_conocidos} )
ORDER BY rowid;

SELECT count(*) AS num_carreras_validation_CONOCIDAS_COMPLETAS FROM datos_desa.tb_dataset_ids_pasado_validation_${TAG} LIMIT 1;
EOF

echo -e "$CONSULTA_4_LISTAS_IDS" 2>&1 1>>${LOG_DS}
mysql -t --execute="$CONSULTA_4_LISTAS_IDS" >>$LOG_DS

echo -e "PASADO_IDs -> TRAIN = datos_desa.tb_dataset_ids_pasado_train_${TAG}" 2>&1 1>>${LOG_DS}
echo -e "PASADO_IDs -> TEST = datos_desa.tb_dataset_ids_pasado_test_${TAG}" 2>&1 1>>${LOG_DS}
echo -e "PASADO_IDs -> VALIDATION = datos_desa.tb_dataset_ids_pasado_validation_${TAG}" 2>&1 1>>${LOG_DS}
echo -e "FUTURO_IDs -> datos_desa.tb_dataset_ids_futuros_${TAG}" 2>&1 1>>${LOG_DS}


######################################################################
#4º Columnas usadas (FEATURES), sin IDs ni target.
######################################################################
read -d '' FEATURES_COMUNES <<- EOF

-- futuro,
-- time_sec, 
-- time_distance, 
peso_galgo, 
-- stmhcp, 
-- by_dato, 
-- galgo_primero_o_segundo, 
-- venue, 
-- remarks, 
-- win_time, 
-- going, 
-- calculated_time, 
-- velocidad_real, 
-- TARGET,
experiencia, 
-- posicion, 
-- id_campeonato,
trap_factor,
-- experiencia_cualitativo, 
experiencia_en_clase, 
posicion_media_en_clase_por_experiencia,
distancia_centenas, 
dif_peso,
entrenador_posicion_avg,
entrenador_posicion_std,
eed,
-- trap,
-- mes,
sp,
-- clase,
distancia,
-- entrenador,
remarks_puntos_historico,
remarks_puntos_historico_10d,
remarks_puntos_historico_20d,
remarks_puntos_historico_50d,

vel_real_cortas_mediana, 
vel_real_cortas_max, 
vel_going_cortas_mediana, 
vel_going_cortas_max, 
vel_real_longmedias_mediana, 
vel_real_longmedias_max, 
vel_going_longmedias_mediana, 
vel_going_longmedias_max, 
vel_real_largas_mediana, 
vel_real_largas_max, 
vel_going_largas_mediana, 
vel_going_largas_max,
vgcortas_med_min,
vgcortas_med_max,
vgmedias_med_min,
vgmedias_med_max,
vglargas_med_min,
vglargas_med_max,

-- track,
dow_d,dow_l,dow_m,dow_x,dow_j,dow_v,dow_s,dow_finde,dow_laborable,
num_galgos, 
mes_norm,
hora,
premio_primero,
premio_segundo,
premio_otros,
premio_total_carrera,
-- going_allowance_segundos,
fc_1,fc_2,fc_pounds,tc_1,tc_2,tc_3,tc_pounds,
tempMin, 
tempMax, 
tempSpan,
venue_going_std,
venue_going_avg
EOF


#####################################################################################
#5º Crear estas 7 tablas sin IDs (pero haciendo JOIN con los IDs) y con solo las columnas deseadas: 
#PASADO-TRAIN-FEATURES, PASADO-TRAIN-TARGET
#PASADO-TEST-FEATURES, PASADO-TEST-TARGET
#PASADO-VALIDATION-FEATURES, PASADO-VALIDATION-TARGET
#FUTURO-FEATURES
#####################################################################################
echo -e "\n\nATENCION!!! Por cada id_carrera (CADA fila de tb_dataset_ids), deberiamos tenemos unos 6 galgos, que serán 6 filas en las tablas FINALES de features y targets!! (aunque hay muchas carreras incompletas, que nos serviran para entrenar el modelo, pero no para calcular el SCORE)" 2>&1 1>>${LOG_DS}
#####################################################################################
echo -e $(date +"%T")" PASADO-TRAIN..." 2>&1 1>>${LOG_DS}

read -d '' CONSULTA_DS_TRAIN <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_ds_pasado_train_features_${TAG};

CREATE TABLE datos_desa.tb_ds_pasado_train_features_${TAG} AS 
SELECT ${FEATURES_COMUNES} 
FROM datos_desa.tb_dataset_con_ids_${TAG} A
RIGHT JOIN datos_desa.tb_dataset_ids_pasado_train_${TAG} B 
ON (A.id_carrera=B.id_carrera AND A.TARGET IS NOT NULL);

SELECT count(*) as num_pasado_train_features FROM datos_desa.tb_ds_pasado_train_features_${TAG} LIMIT 1;


DROP TABLE IF EXISTS datos_desa.tb_ds_pasado_train_targets_${TAG};

CREATE TABLE datos_desa.tb_ds_pasado_train_targets_${TAG} AS 
SELECT TARGET 
FROM datos_desa.tb_dataset_con_ids_${TAG} A
RIGHT JOIN datos_desa.tb_dataset_ids_pasado_train_${TAG} B 
ON (A.id_carrera=B.id_carrera AND A.TARGET IS NOT NULL);

SELECT count(*) as num_pasado_train_targets FROM datos_desa.tb_ds_pasado_train_targets_${TAG} LIMIT 1;
EOF

echo -e "$CONSULTA_DS_TRAIN" 2>&1 1>>${LOG_DS}
mysql -t --execute="$CONSULTA_DS_TRAIN" 2>&1 1>>${LOG_DS}

echo -e "PASADO-TRAIN --> datos_desa.tb_ds_pasado_train_features_${TAG}   datos_desa.tb_ds_pasado_train_targets_${TAG}" 2>&1 1>>${LOG_DS}

#####################################################################################
echo -e $(date +"%T")" PASADO-TEST..." 2>&1 1>>${LOG_DS}

read -d '' CONSULTA_DS_TEST <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_ds_pasado_test_features_${TAG};

CREATE TABLE datos_desa.tb_ds_pasado_test_features_${TAG} AS 
SELECT ${FEATURES_COMUNES} 
FROM datos_desa.tb_dataset_con_ids_${TAG} A
RIGHT JOIN datos_desa.tb_dataset_ids_pasado_test_${TAG} B 
ON (A.id_carrera=B.id_carrera AND A.TARGET IS NOT NULL);

SELECT count(*) as num_pasado_test_features FROM datos_desa.tb_ds_pasado_test_features_${TAG} LIMIT 1;


DROP TABLE IF EXISTS datos_desa.tb_ds_pasado_test_targets_${TAG};

CREATE TABLE datos_desa.tb_ds_pasado_test_targets_${TAG} AS 
SELECT TARGET 
FROM datos_desa.tb_dataset_con_ids_${TAG} A
RIGHT JOIN datos_desa.tb_dataset_ids_pasado_test_${TAG} B 
ON (A.id_carrera=B.id_carrera AND A.TARGET IS NOT NULL);

SELECT count(*) as num_pasado_test_targets FROM datos_desa.tb_ds_pasado_test_targets_${TAG} LIMIT 1;
EOF

echo -e "$CONSULTA_DS_TEST" 2>&1 1>>${LOG_DS}
mysql -t --execute="$CONSULTA_DS_TEST" 2>&1 1>>${LOG_DS}

echo -e "PASADO-TEST --> datos_desa.tb_ds_pasado_test_features_${TAG}   datos_desa.tb_ds_pasado_test_targets_${TAG}" 2>&1 1>>${LOG_DS}

#####################################################################################
echo -e $(date +"%T")" PASADO-VALIDATION..." 2>&1 1>>${LOG_DS}

read -d '' CONSULTA_DS_VALIDATION <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_ds_pasado_validation_featuresytarget_${TAG};

CREATE TABLE datos_desa.tb_ds_pasado_validation_featuresytarget_${TAG} AS 
SELECT A.*
FROM datos_desa.tb_dataset_con_ids_${TAG} A
RIGHT JOIN datos_desa.tb_dataset_ids_pasado_validation_${TAG} B 
ON (A.id_carrera=B.id_carrera AND A.TARGET IS NOT NULL);


DROP TABLE IF EXISTS datos_desa.tb_ds_pasado_validation_features_${TAG};

CREATE TABLE datos_desa.tb_ds_pasado_validation_features_${TAG} AS 
SELECT ${FEATURES_COMUNES} 
FROM datos_desa.tb_ds_pasado_validation_featuresytarget_${TAG};

SELECT count(*) as num_pasado_validation_features FROM datos_desa.tb_ds_pasado_validation_features_${TAG} LIMIT 1;


DROP TABLE IF EXISTS datos_desa.tb_ds_pasado_validation_targets_${TAG};

CREATE TABLE datos_desa.tb_ds_pasado_validation_targets_${TAG} AS 
SELECT TARGET 
FROM datos_desa.tb_ds_pasado_validation_featuresytarget_${TAG};

SELECT count(*) as num_pasado_validation_targets FROM datos_desa.tb_ds_pasado_validation_targets_${TAG} LIMIT 1;
EOF

echo -e "$CONSULTA_DS_VALIDATION" 2>&1 1>>${LOG_DS}
mysql -t --execute="$CONSULTA_DS_VALIDATION" 2>&1 1>>${LOG_DS}

echo -e "PASADO-VALIDATION --> datos_desa.tb_ds_pasado_validation_features_${TAG}   datos_desa.tb_ds_pasado_validation_targets_${TAG}" 2>&1 1>>${LOG_DS}

#####################################################################################
echo -e $(date +"%T")" FUTURO-FEATURES..." 2>&1 1>>${LOG_DS}

read -d '' CONSULTA_DS_FUTURO_FEATURES <<- EOF
-- Con id_carrera y galgo_nombre.
DROP TABLE IF EXISTS datos_desa.tb_ds_futuro_features_id_${TAG};

CREATE TABLE datos_desa.tb_ds_futuro_features_id_${TAG} AS
SELECT A.*
FROM datos_desa.tb_dataset_con_ids_${TAG} A
RIGHT JOIN datos_desa.tb_dataset_ids_futuros_${TAG} B
ON (A.id_carrera=B.id_carrera)
;

SELECT count(*) as num_futuro_features FROM datos_desa.tb_ds_futuro_features_id_${TAG} LIMIT 1;


-- Sin id_carrera y galgo_nombre.
DROP TABLE IF EXISTS datos_desa.tb_ds_futuro_features_${TAG};

CREATE TABLE datos_desa.tb_ds_futuro_features_${TAG} AS 
SELECT ${FEATURES_COMUNES} 
FROM datos_desa.tb_ds_futuro_features_id_${TAG};

SELECT count(*) as num_futuro_features FROM datos_desa.tb_ds_futuro_features_${TAG} LIMIT 1;
EOF

echo -e "$CONSULTA_DS_FUTURO_FEATURES" 2>&1 1>>${LOG_DS}
mysql -t --execute="$CONSULTA_DS_FUTURO_FEATURES" 2>&1 1>>${LOG_DS}

echo -e "FUTURO-FEATURES --> datos_desa.tb_ds_futuro_features_${TAG}\n\n" 2>&1 1>>${LOG_DS}



######### Análisis del DATASET de PASADO-FEATURES (entrada) y FUTURO_FEATURES (entrada) #######################
#rm -f "${LOG_DS_COLPEN}"

analizarTabla "datos_desa" "tb_ds_pasado_train_features_${TAG}" "${LOG_DS_COLPEN}"
analizarTabla "datos_desa" "tb_ds_pasado_train_targets_${TAG}" "${LOG_DS_COLPEN}"

analizarTabla "datos_desa" "tb_ds_pasado_test_features_${TAG}" "${LOG_DS_COLPEN}"
analizarTabla "datos_desa" "tb_ds_pasado_test_targets_${TAG}" "${LOG_DS_COLPEN}"

analizarTabla "datos_desa" "tb_ds_pasado_validation_features_${TAG}" "${LOG_DS_COLPEN}"
analizarTabla "datos_desa" "tb_ds_pasado_validation_targets_${TAG}" "${LOG_DS_COLPEN}"

analizarTabla "datos_desa" "tb_ds_futuro_features_${TAG}" "${LOG_DS_COLPEN}"


echo -e "\n\n\n\n---------------- | 037 | DATASETS --------------" 2>&1 1>>${LOG_DS}
echo -e "datos_desa.tb_ds_pasado_train_features_${TAG}  <--> datos_desa.tb_ds_pasado_train_targets_${TAG}" 2>&1 1>>${LOG_DS}
echo -e "datos_desa.tb_ds_pasado_test_features_${TAG}  <--> datos_desa.tb_ds_pasado_test_targets_${TAG}" 2>&1 1>>${LOG_DS}
echo -e "datos_desa.tb_ds_pasado_validation_features_${TAG}  <--> datos_desa.tb_ds_pasado_validation_targets_${TAG}" 2>&1 1>>${LOG_DS}
echo -e "datos_desa.tb_ds_futuro_features_${TAG}  <--> TARGETS_NO (futuro)" 2>&1 1>>${LOG_DS}
echo -e "----------------------------------------------------\n\n\n" 2>&1 1>>${LOG_DS}


#####################################################################################
echo -e "Borrando temp..." 2>&1 1>>${LOG_DS}
rm -f ${FILE_TEMP}

###########################################################################

echo -e $(date +"%T")" | 037 | Datasets | FIN" >>$LOG_070



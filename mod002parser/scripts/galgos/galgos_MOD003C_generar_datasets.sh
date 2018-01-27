#!/bin/bash

source "/root/git/bdml/mod002parser/scripts/galgos/funciones.sh"


echo -e $(date +"%T")" Generador de DATASETS: INICIO" 2>&1 1>>${LOG_DS}

echo -e $(date +"%T")" Solo debo usar las columnas que conocere en el futuro. Por ejemplo, no puedo coger going allowance." 2>&1 1>>${LOG_DS}

TAG="${1}"

FILE_TEMP="./temp_numero"

#### PASADO y FUTURO, con boolean e IDs ###
read -d '' CONSULTA_CON_IDs <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_dataset_con_ids_${TAG};

CREATE TABLE datos_desa.tb_dataset_con_ids_${TAG} AS 
SELECT 

A.id_carrera, A.galgo_nombre, 
CASE WHEN (A.id_carrera<100000) THEN true ELSE false END AS futuro,

A.peso_galgo_norm, A.edad_en_dias_norm, A.scoring_remarks, A.experiencia, A.trap_factor, A.experiencia_en_clase, A.posicion_media_en_clase_por_experiencia, A.dif_peso, A.entrenador_posicion_norm, A.eed_norm, A.trap_norm, A.sp_norm,

B.vgcortas_max_norm, B.vgmedias_max_norm, B.vglargas_max_norm, B.vel_real_cortas_mediana_norm, B.vel_real_cortas_max_norm, B.vel_going_cortas_mediana_norm, B.vel_going_cortas_max_norm, B.vel_real_longmedias_mediana_norm, B.vel_real_longmedias_max_norm, B.vel_going_longmedias_mediana_norm, B.vel_going_longmedias_max_norm, B.vel_real_largas_mediana_norm, B.vel_real_largas_max_norm, B.vel_going_largas_mediana_norm, B.vel_going_largas_max_norm,

C.distancia_norm, C.num_galgos_norm, C.mes_norm, C.hora_norm, C.premio_primero_norm, C.premio_segundo_norm, C.premio_otros_norm, C.premio_total_carrera_norm, C.fc_1_norm, C.fc_2_norm, C.fc_pounds_norm, C.tc_1_norm, C.tc_2_norm, C.tc_3_norm, C.tc_pounds_norm, C.venue_going_std, C.venue_going_avg,

velocidad_con_going AS TARGET

FROM datos_desa.tb_filtrada_carrerasgalgos_${TAG} A
LEFT JOIN datos_desa.tb_filtrada_galgos_${TAG} B ON (A.galgo_nombre=B.galgo_nombre)
LEFT JOIN datos_desa.tb_filtrada_carreras_${TAG} C ON (A.id_carrera=C.id_carrera)
;

ALTER TABLE datos_desa.tb_dataset_con_ids_${TAG} ADD INDEX tb_dscids_idx(id_carrera);
SELECT count(*) as num_dataset_con_ids FROM datos_desa.tb_dataset_con_ids_${TAG} LIMIT 5;
EOF

#echo -e $(date +"%T")"$CONSULTA_CON_IDs" 2>&1 1>>${LOG_DS}
mysql -u root --password=datos1986 -t --execute="$CONSULTA_CON_IDs" >>$LOG_DS

echo -e "PASADO y FUTURO (con boolean e IDs) --> datos_desa.tb_dataset_con_ids_${TAG}" 2>&1 1>>${LOG_DS}


#####################################################################################

############# IDs ##############
#1º Separar los pasados de los futuros, sacando 2 listas de IDs (id_carrera). Debo conocer el target de TODOS los pasados.
#2º Barajar (shuffle) esas 2 listas de IDs: usando RAND()
#################################
read -d '' CONSULTA_IDS_PASADOS_Y_FUTUROS <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_dataset_ids_pasados_${TAG};
CREATE TABLE datos_desa.tb_dataset_ids_pasados_${TAG} AS ( SELECT id_carrera FROM datos_desa.tb_dataset_con_ids_${TAG} WHERE futuro=false AND TARGET IS NOT NULL ORDER BY rand() );
ALTER TABLE datos_desa.tb_dataset_ids_pasados_${TAG} ADD INDEX tb_dscids_p_idx(id_carrera);
SELECT count(*) as num_ids_pasados FROM datos_desa.tb_dataset_ids_pasados_${TAG} LIMIT 1;

DROP TABLE IF EXISTS datos_desa.tb_dataset_ids_futuros_${TAG};
CREATE TABLE datos_desa.tb_dataset_ids_futuros_${TAG} AS ( SELECT id_carrera FROM datos_desa.tb_dataset_con_ids_${TAG} WHERE futuro=true ORDER BY rand() );
ALTER TABLE datos_desa.tb_dataset_ids_futuros_${TAG} ADD INDEX tb_dscids_f_idx(id_carrera);
SELECT count(*) as num_ids_futuros FROM datos_desa.tb_dataset_ids_futuros_${TAG} LIMIT 1;
EOF

#echo -e $(date +"%T")"$CONSULTA_IDS_PASADOS_Y_FUTUROS" 2>&1 1>>${LOG_DS}
mysql -u root --password=datos1986 -t --execute="$CONSULTA_IDS_PASADOS_Y_FUTUROS" >>$LOG_DS


#Numeros
mysql -u root --password=datos1986 -N --execute="SELECT count(*) as num_ids_pasados FROM datos_desa.tb_dataset_ids_pasados_${TAG} LIMIT 1;" > ${FILE_TEMP}
numero_ids_pasados=$( cat ${FILE_TEMP})

numero_pasados_test=$(echo "0.15 * $numero_ids_pasados" | bc | cut -f1 -d".")
numero_pasados_validation=$(echo "0.15 * $numero_ids_pasados" | bc | cut -f1 -d".")
numero_pasados_train=$(echo "$numero_ids_pasados-$numero_pasados_test-$numero_pasados_validation" | bc)
echo -e "Pasados [TRAIN | TEST |VALIDATION] = "${numero_pasados_train}" | "${numero_pasados_test}" | "${numero_pasados_validation} >>$LOG_DS

mysql -u root --password=datos1986 -N --execute="SELECT count(*) as num_ids_futuros FROM datos_desa.tb_dataset_ids_futuros_${TAG} LIMIT 1;" > ${FILE_TEMP}
numero_ids_futuros=$( cat ${FILE_TEMP})
echo -e "Futuros = ${numero_ids_futuros}" >>$LOG_DS


######################################################################
#3º Crear estas 4 listas de IDs: PASADO-TRAIN, PASADO-TEST, PASADO-VALIDATION, FUTURA (ya creada).
######################################################################
read -d '' CONSULTA_4_LISTAS_IDS <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_dataset_ids_pasado_train_${TAG};

CREATE TABLE datos_desa.tb_dataset_ids_pasado_train_${TAG} AS 
SELECT rowid,id_carrera 
FROM ( SELECT @rowid:=@rowid+1 as rowid, A.id_carrera FROM datos_desa.tb_dataset_ids_pasados_SUBGRUPO_X A, (SELECT @rowid:=0) as t_numfila ) dentro 
WHERE rowid >= 1 AND rowid <= ${numero_pasados_train}
ORDER BY rowid;

SELECT count(*) as num_ids_pasados_train FROM datos_desa.tb_dataset_ids_pasado_train_${TAG} LIMIT 1;


DROP TABLE IF EXISTS datos_desa.tb_dataset_ids_pasado_test_${TAG};

CREATE TABLE datos_desa.tb_dataset_ids_pasado_test_${TAG} AS 
SELECT rowid,id_carrera 
FROM ( SELECT @rowid:=@rowid+1 as rowid, A.id_carrera FROM datos_desa.tb_dataset_ids_pasados_SUBGRUPO_X A, (SELECT @rowid:=0) as t_numfila ) dentro 
WHERE rowid > ${numero_pasados_train} AND rowid <= (${numero_pasados_train}+${numero_pasados_test})
ORDER BY rowid;

SELECT count(*) as num_ids_pasados_test FROM datos_desa.tb_dataset_ids_pasado_test_${TAG} LIMIT 1;


DROP TABLE IF EXISTS datos_desa.tb_dataset_ids_pasado_validation_${TAG};

CREATE TABLE datos_desa.tb_dataset_ids_pasado_validation_${TAG} AS 
SELECT rowid,id_carrera 
FROM ( SELECT @rowid:=@rowid+1 as rowid, A.id_carrera FROM datos_desa.tb_dataset_ids_pasados_SUBGRUPO_X A, (SELECT @rowid:=0) as t_numfila ) dentro 
WHERE rowid > (${numero_pasados_train}+${numero_pasados_test})
ORDER BY rowid;

SELECT count(*) as num_ids_pasados_validation FROM datos_desa.tb_dataset_ids_pasado_validation_${TAG} LIMIT 1;


SELECT count(*) as num_ids_futuros FROM datos_desa.tb_dataset_ids_futuros_${TAG} LIMIT 5;
EOF

#echo -e $(date +"%T")"$CONSULTA_4_LISTAS_IDS" 2>&1 1>>${LOG_DS}
mysql -u root --password=datos1986 -t --execute="$CONSULTA_4_LISTAS_IDS" >>$LOG_DS

echo -e "PASADO_IDs -> TRAIN = datos_desa.tb_dataset_ids_pasado_train_${TAG}" 2>&1 1>>${LOG_DS}
echo -e "PASADO_IDs -> TEST = datos_desa.tb_dataset_ids_pasado_test_${TAG}" 2>&1 1>>${LOG_DS}
echo -e "PASADO_IDs -> VALIDATION = datos_desa.tb_dataset_ids_pasado_validation_${TAG}" 2>&1 1>>${LOG_DS}
echo -e "FUTURO_IDs -> datos_desa.tb_dataset_ids_futuros_${TAG}" 2>&1 1>>${LOG_DS}



######################################################################
#4º Columnas usadas (FEATURES), sin IDs ni target.
######################################################################
read -d '' FEATURES_COMUNES <<- EOF
peso_galgo_norm, edad_en_dias_norm, scoring_remarks, experiencia, trap_factor, experiencia_en_clase, posicion_media_en_clase_por_experiencia, dif_peso, entrenador_posicion_norm, eed_norm, trap_norm, sp_norm,

vgcortas_max_norm, vgmedias_max_norm, vglargas_max_norm, vel_real_cortas_mediana_norm, vel_real_cortas_max_norm, vel_going_cortas_mediana_norm, vel_going_cortas_max_norm, vel_real_longmedias_mediana_norm, vel_real_longmedias_max_norm, vel_going_longmedias_mediana_norm, vel_going_longmedias_max_norm, vel_real_largas_mediana_norm, vel_real_largas_max_norm, vel_going_largas_mediana_norm, vel_going_largas_max_norm,

distancia_norm, num_galgos_norm, mes_norm, hora_norm, premio_primero_norm, premio_segundo_norm, premio_otros_norm, premio_total_carrera_norm, fc_1_norm, fc_2_norm, fc_pounds_norm, tc_1_norm, tc_2_norm, tc_3_norm, tc_pounds_norm, venue_going_std, venue_going_avg
EOF


#####################################################################################
#5º Crear estas 7 tablas sin IDs (pero haciendo INNER JOIN con los IDs) y con solo las columnas deseadas: 
#PASADO-TRAIN-FEATURES, PASADO-TRAIN-TARGET
#PASADO-TEST-FEATURES, PASADO-TEST-TARGET
#PASADO-VALIDATION-FEATURES, PASADO-VALIDATION-TARGET
#FUTURO-FEATURES
#####################################################################################
echo -e "\n\n ATENCION!!! Por cada id_carrera, tenemos unos 6 galgos, que serán 6 filas en las tablas de features y targets!!" 2>&1 1>>${LOG_DS}
#####################################################################################
echo -e $(date +"%T")" PASADO-TRAIN..." 2>&1 1>>${LOG_DS}

read -d '' CONSULTA_DS_TRAIN <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_ds_pasado_train_features_${TAG};

CREATE TABLE datos_desa.tb_ds_pasado_train_features_${TAG} AS 
SELECT ${FEATURES_COMUNES} 
FROM datos_desa.tb_dataset_con_ids_${TAG} A
INNER JOIN datos_desa.tb_dataset_ids_pasado_train_${TAG} B 
ON (A.id_carrera=B.id_carrera);

SELECT count(*) as num_pasado_train_features FROM datos_desa.tb_ds_pasado_train_features_${TAG} LIMIT 1;


DROP TABLE IF EXISTS datos_desa.tb_ds_pasado_train_targets_${TAG};

CREATE TABLE datos_desa.tb_ds_pasado_train_targets_${TAG} AS 
SELECT TARGET 
FROM datos_desa.tb_dataset_con_ids_${TAG} A
INNER JOIN datos_desa.tb_dataset_ids_pasado_train_${TAG} B 
ON (A.id_carrera=B.id_carrera);

SELECT count(*) as num_pasado_train_targets FROM datos_desa.tb_ds_pasado_train_targets_${TAG} LIMIT 1;
EOF

#echo -e $(date +"%T")"$CONSULTA_DS_TRAIN" 2>&1 1>>${LOG_DS}
mysql -u root --password=datos1986 -t --execute="$CONSULTA_DS_TRAIN" >>$LOG_DS

echo -e "PASADO-TRAIN --> datos_desa.tb_ds_pasado_train_features_${TAG}   datos_desa.tb_ds_pasado_train_targets_${TAG}" 2>&1 1>>${LOG_DS}

#####################################################################################
echo -e $(date +"%T")" PASADO-TEST..." 2>&1 1>>${LOG_DS}

read -d '' CONSULTA_DS_TEST <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_ds_pasado_test_features_${TAG};

CREATE TABLE datos_desa.tb_ds_pasado_test_features_${TAG} AS 
SELECT ${FEATURES_COMUNES} 
FROM datos_desa.tb_dataset_con_ids_${TAG} A
INNER JOIN datos_desa.tb_dataset_ids_pasado_test_${TAG} B 
ON (A.id_carrera=B.id_carrera);

SELECT count(*) as num_pasado_test_features FROM datos_desa.tb_ds_pasado_test_features_${TAG} LIMIT 1;


DROP TABLE IF EXISTS datos_desa.tb_ds_pasado_test_targets_${TAG};

CREATE TABLE datos_desa.tb_ds_pasado_test_targets_${TAG} AS 
SELECT TARGET 
FROM datos_desa.tb_dataset_con_ids_${TAG} A
INNER JOIN datos_desa.tb_dataset_ids_pasado_test_${TAG} B 
ON (A.id_carrera=B.id_carrera);

SELECT count(*) as num_pasado_test_targets FROM datos_desa.tb_ds_pasado_test_targets_${TAG} LIMIT 1;
EOF

#echo -e $(date +"%T")"$CONSULTA_DS_TEST" 2>&1 1>>${LOG_DS}
mysql -u root --password=datos1986 -t --execute="$CONSULTA_DS_TEST" >>$LOG_DS

echo -e "PASADO-TEST --> datos_desa.tb_ds_pasado_test_features_${TAG}   datos_desa.tb_ds_pasado_test_targets_${TAG}" 2>&1 1>>${LOG_DS}

#####################################################################################
echo -e $(date +"%T")" PASADO-VALIDATION..." 2>&1 1>>${LOG_DS}

read -d '' CONSULTA_DS_VALIDATION <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_ds_pasado_validation_features_${TAG};

CREATE TABLE datos_desa.tb_ds_pasado_validation_features_${TAG} AS 
SELECT ${FEATURES_COMUNES} 
FROM datos_desa.tb_dataset_con_ids_${TAG} A
INNER JOIN datos_desa.tb_dataset_ids_pasado_validation_${TAG} B 
ON (A.id_carrera=B.id_carrera);

SELECT count(*) as num_pasado_validation_features FROM datos_desa.tb_ds_pasado_validation_features_${TAG} LIMIT 1;


DROP TABLE IF EXISTS datos_desa.tb_ds_pasado_validation_targets_${TAG};

CREATE TABLE datos_desa.tb_ds_pasado_validation_targets_${TAG} AS 
SELECT TARGET 
FROM datos_desa.tb_dataset_con_ids_${TAG} A
INNER JOIN datos_desa.tb_dataset_ids_pasado_validation_${TAG} B 
ON (A.id_carrera=B.id_carrera);

SELECT count(*) as num_pasado_validation_targets FROM datos_desa.tb_ds_pasado_validation_targets_${TAG} LIMIT 1;
EOF

#echo -e $(date +"%T")"$CONSULTA_DS_VALIDATION" 2>&1 1>>${LOG_DS}
mysql -u root --password=datos1986 -t --execute="$CONSULTA_DS_VALIDATION" >>$LOG_DS

echo -e "PASADO-VALIDATION --> datos_desa.tb_ds_pasado_validation_features_${TAG}   datos_desa.tb_ds_pasado_validation_targets_${TAG}" 2>&1 1>>${LOG_DS}

#####################################################################################
echo -e $(date +"%T")" FUTURO-FEATURES..." 2>&1 1>>${LOG_DS}

read -d '' CONSULTA_DS_FUTURO_FEATURES <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_ds_futuro_features_${TAG};

CREATE TABLE datos_desa.tb_ds_futuro_features_${TAG} AS 
SELECT ${FEATURES_COMUNES} 
FROM datos_desa.tb_dataset_con_ids_${TAG} A
INNER JOIN datos_desa.tb_dataset_ids_futuros_${TAG} B
ON (A.id_carrera=B.id_carrera);

SELECT count(*) as num_futuro_features FROM datos_desa.tb_ds_futuro_features_${TAG} LIMIT 1;
EOF

#echo -e $(date +"%T")"$CONSULTA_DS_FUTURO_FEATURES" 2>&1 1>>${LOG_DS}
mysql -u root --password=datos1986 -t --execute="$CONSULTA_DS_FUTURO_FEATURES" >>$LOG_DS

echo -e "FUTURO-FEATURES --> datos_desa.tb_ds_futuro_features_${TAG}" 2>&1 1>>${LOG_DS}

#####################################################################################

rm -f ${FILE_TEMP}

echo -e $(date +"%T")" Generador de DATASETS (usando tablas filtradas): FIN\n\n" 2>&1 1>>${LOG_DS}




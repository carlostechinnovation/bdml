#!/bin/bash

source "/root/git/bdml/mod002parser/scripts/galgos/funciones.sh"


########## MAIN #########################

echo -e $(date +"%T")" Generador de DATASETS: INICIO" 2>&1 1>>${LOG_DS}

echo -e $(date +"%T")" Solo puedo coger las columnas que conocere en el futuro. Por ejemplo, no puedo coger going allowance." 2>&1 1>>${LOG_DS}

TAG="${1}"
echo -e $(date +"%T")" TAG=$TAG" 2>&1 1>>${LOG_DS}


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

SELECT * FROM datos_desa.tb_dataset_con_ids_${TAG} ORDER BY id_carrera LIMIT 5;
SELECT count(*) as num_dataset_con_ids FROM datos_desa.tb_dataset_con_ids_${TAG} LIMIT 5;
EOF

echo -e $(date +"%T")"$CONSULTA_CON_IDs" 2>&1 1>>${LOG_DS}
mysql -u root --password=datos1986 -t --execute="$CONSULTA_CON_IDs" >>$LOG_DS


#### PASADO: sin IDs ###
echo -e $(date +"%T")" Generando FEATURES-TRAINyTEST y TARGET-TRAINyTEST..."
#Solo cogemos los galgos y carreras PASADAS (id_carrera es un valor grande, NO ES el inventado por mi)

read -d '' CONSULTA_PASADO_SIN_IDs <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_features_pasado_sin_ids_${TAG};

CREATE TABLE datos_desa.tb_features_pasado_sin_ids_${TAG} AS 
SELECT 

peso_galgo_norm, edad_en_dias_norm, scoring_remarks, experiencia, trap_factor, experiencia_en_clase, posicion_media_en_clase_por_experiencia, dif_peso, entrenador_posicion_norm, eed_norm, trap_norm, sp_norm,

vgcortas_max_norm, vgmedias_max_norm, vglargas_max_norm, vel_real_cortas_mediana_norm, vel_real_cortas_max_norm, vel_going_cortas_mediana_norm, vel_going_cortas_max_norm, vel_real_longmedias_mediana_norm, vel_real_longmedias_max_norm, vel_going_longmedias_mediana_norm, vel_going_longmedias_max_norm, vel_real_largas_mediana_norm, vel_real_largas_max_norm, vel_going_largas_mediana_norm, vel_going_largas_max_norm,

distancia_norm, num_galgos_norm, mes_norm, hora_norm, premio_primero_norm, premio_segundo_norm, premio_otros_norm, premio_total_carrera_norm, fc_1_norm, fc_2_norm, fc_pounds_norm, tc_1_norm, tc_2_norm, tc_3_norm, tc_pounds_norm, venue_going_std, venue_going_avg

FROM datos_desa.tb_dataset_con_ids_${TAG}
WHERE futuro=0
;

SELECT * FROM datos_desa.tb_features_pasado_sin_ids_${TAG} ORDER BY id_carrera LIMIT 5;
SELECT count(*) as num_features_pasado_sin_ids FROM datos_desa.tb_features_pasado_sin_ids_${TAG} LIMIT 5;


DROP TABLE IF EXISTS datos_desa.tb_target_pasado_sin_ids_${TAG};

CREATE TABLE datos_desa.tb_target_pasado_sin_ids_${TAG} AS 
SELECT TARGET FROM datos_desa.tb_dataset_con_ids_${TAG} WHERE futuro=0;

SELECT * FROM datos_desa.tb_target_pasado_sin_ids_${TAG} ORDER BY id_carrera LIMIT 5;
SELECT count(*) as num_targets_pasado_sin_ids FROM datos_desa.tb_target_pasado_sin_ids_${TAG} LIMIT 5;
EOF

echo -e $(date +"%T")"$CONSULTA_PASADO_SIN_IDs" 2>&1 1>>${LOG_DS}
mysql -u root --password=datos1986 -t --execute="$CONSULTA_PASADO_SIN_IDs" >>$LOG_DS



#### FUTURO: sin IDs ###
echo -e $(date +"%T")" Generando FEATURES-PREDICCION (el modelo generara TARGET-PREDICCION)..."
#Solo cogemos los galgos y carreras FUTURAS (id_carrera es un valor pequeño, inventado por mi)

read -d '' CONSULTA_FUTURO_SIN_IDs <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_features_futuro_sin_ids_${TAG};

CREATE TABLE datos_desa.tb_features_futuro_sin_ids_${TAG} AS 
SELECT 

peso_galgo_norm, edad_en_dias_norm, scoring_remarks, experiencia, trap_factor, experiencia_en_clase, posicion_media_en_clase_por_experiencia, dif_peso, entrenador_posicion_norm, eed_norm, trap_norm, sp_norm,

vgcortas_max_norm, vgmedias_max_norm, vglargas_max_norm, vel_real_cortas_mediana_norm, vel_real_cortas_max_norm, vel_going_cortas_mediana_norm, vel_going_cortas_max_norm, vel_real_longmedias_mediana_norm, vel_real_longmedias_max_norm, vel_going_longmedias_mediana_norm, vel_going_longmedias_max_norm, vel_real_largas_mediana_norm, vel_real_largas_max_norm, vel_going_largas_mediana_norm, vel_going_largas_max_norm,

distancia_norm, num_galgos_norm, mes_norm, hora_norm, premio_primero_norm, premio_segundo_norm, premio_otros_norm, premio_total_carrera_norm, fc_1_norm, fc_2_norm, fc_pounds_norm, tc_1_norm, tc_2_norm, tc_3_norm, tc_pounds_norm, venue_going_std, venue_going_avg

FROM datos_desa.tb_dataset_con_ids_${TAG}
WHERE futuro=1
;

SELECT * FROM datos_desa.tb_features_futuro_sin_ids_${TAG} ORDER BY id_carrera LIMIT 5;
SELECT count(*) as num_features_pasado_sin_ids FROM datos_desa.tb_features_futuro_sin_ids_${TAG} LIMIT 5;
EOF

echo -e $(date +"%T")"$CONSULTA_PASADO_SIN_IDs" 2>&1 1>>${LOG_DS}
mysql -u root --password=datos1986 -t --execute="$CONSULTA_PASADO_SIN_IDs" >>$LOG_DS


echo -e $(date +"%T")" Generador de DATASETS (usando columnas elaboradas): FIN\n\n" 2>&1 1>>${LOG_DS}




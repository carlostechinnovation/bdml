#!/bin/bash


#Análisis de una carrera concreta extremo a extremo, que este en el dataset PASADO-VALIDATION y con 6 galgos, para ver si hay algun fallo:

FILE_TEMP="./temp_id_carrera_analisis"

mysql -u root --password=datos1986 -N --execute="SELECT A.id_carrera FROM datos_desa.tb_dataset_ids_pasado_validation_TOTAL A LEFT JOIN (SELECT id_carrera FROM datos_desa.tb_filtrada_carrerasgalgos_TOTAL GROUP BY id_carrera HAVING count(*)=6) B ON A.id_carrera=B.id_carrera LIMIT 1;" > ${FILE_TEMP}
id_carrera_analizada=$( cat ${FILE_TEMP})


read -d '' CONSULTA_ANALISIS_CARRERA <<- EOF
SELECT id_carrera FROM datos_desa.tb_filtrada_carreras_TOTAL WHERE id_carrera=${id_carrera_analizada} LIMIT 10;

SELECT A.galgo_nombre FROM datos_desa.tb_filtrada_galgos_TOTAL A WHERE A.galgo_nombre IN (SELECT galgo_nombre FROM datos_desa.tb_filtrada_carrerasgalgos_TOTAL WHERE id_carrera=${id_carrera_analizada} ) 
LIMIT 10;

SELECT id_carrera, galgo_nombre, velocidad_con_going_norm FROM datos_desa.tb_filtrada_carrerasgalgos_TOTAL WHERE id_carrera=${id_carrera_analizada} LIMIT 10;

SELECT id_carrera, galgo_nombre, futuro, vel_going_cortas_max_norm, vel_going_longmedias_max_norm, vel_going_largas_max_norm, distancia_norm, TARGET 
FROM datos_desa.tb_ds_pasado_validation_featuresytarget_TOTAL WHERE id_carrera=${id_carrera_analizada} LIMIT 10;







SELECT id_carrera, rowid, target_real, target_predicho FROM datos_desa.tb_val_TOTAL WHERE id_carrera=${id_carrera_analizada} LIMIT 10;

select * FROM datos_desa.tb_score_aciertos_TOTAL WHERE id_carrera=${id_carrera_analizada} LIMIT 10;

select * FROM datos_desa.tb_val_economico_TOTAL WHERE id_carrera=${id_carrera_analizada} LIMIT 10;
EOF

echo -e "$CONSULTA_ANALISIS_CARRERA"
mysql -u root --password=datos1986 -t --execute="$CONSULTA_ANALISIS_CARRERA"


echo -e "ATENCION: debo que los galgos de ENTRADA sean los mismos que los de SALIDA y que tengan precio SP !!!!!!!!!"







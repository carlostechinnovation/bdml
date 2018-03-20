#!/bin/bash

source "/root/git/bdml/mod002parser/scripts/galgos/funciones.sh"


####### PARAMETROS ###
SUBGRUPO="${1}"
TIEMPO="${2}"


echo -e $(date +"%T")" | 060 | Analisis caso concreto end-to-end | INICIO" >>$LOG_070
echo -e "MOD060_endtoend --> LOG = "${LOG_060_ENDTOEND}${TIEMPO}


#### Limpiar LOG ###
rm -f ${LOG_060_ENDTOEND}${TIEMPO}

#fichero temporal
FILE_TEMP="./temp_id_carrera_analisis"
rm -f ${FILE_TEMP}


echo -e "\n#########################################################################\n" 2>&1 1>>${LOG_060_ENDTOEND}${TIEMPO}

if [[ "$TIEMPO" == "FUTURA" ]]
then
  mysql -u root --password=datos1986 -N --execute="SELECT A.id_carrera FROM datos_desa.tb_dataset_ids_futuros_${SUBGRUPO} A LEFT JOIN (SELECT id_carrera FROM datos_desa.tb_filtrada_carrerasgalgos_${SUBGRUPO} WHERE id_carrera<1000 GROUP BY id_carrera HAVING count(*)=6) B ON (A.id_carrera=B.id_carrera) ORDER BY rand() LIMIT 1;" >> ${FILE_TEMP}
  id_carrera_analizada=$( cat ${FILE_TEMP})
  echo -e "Análisis extremo-extremo de carrera FUTURA (ds FUTURO-FEATURES, con 6 galgos): "$id_carrera_analizada 2>&1 1>>${LOG_060_ENDTOEND}${TIEMPO}

else
  mysql -u root --password=datos1986 -N --execute="SELECT A.id_carrera FROM datos_desa.tb_dataset_ids_pasado_validation_${SUBGRUPO} A LEFT JOIN (SELECT id_carrera FROM datos_desa.tb_filtrada_carrerasgalgos_${SUBGRUPO} WHERE id_carrera>100000 GROUP BY id_carrera HAVING count(*)=6) B ON (A.id_carrera=B.id_carrera) ORDER BY rand() LIMIT 1;" >> ${FILE_TEMP}
  id_carrera_analizada=$( cat ${FILE_TEMP})
  echo -e "Análisis extremo-extremo de carrera PASADA (ds PASADO-VALIDATION, con 6 galgos): "$id_carrera_analizada 2>&1 1>>${LOG_060_ENDTOEND}${TIEMPO}
fi


########################################################################################################

read -d '' CONSULTA_ANTES_DE_PREDECIR <<- EOF
SELECT id_carrera FROM datos_desa.tb_filtrada_carreras_${SUBGRUPO} WHERE id_carrera=${id_carrera_analizada} LIMIT 10;

SELECT A.galgo_nombre FROM datos_desa.tb_filtrada_galgos_${SUBGRUPO} A WHERE A.galgo_nombre IN (SELECT galgo_nombre FROM datos_desa.tb_filtrada_carrerasgalgos_${SUBGRUPO} WHERE id_carrera=${id_carrera_analizada} ) 
LIMIT 10;

SELECT id_carrera, galgo_nombre, velocidad_con_going_norm FROM datos_desa.tb_filtrada_carrerasgalgos_${SUBGRUPO} WHERE id_carrera=${id_carrera_analizada} LIMIT 10;

SELECT * FROM datos_desa.tb_ds_pasado_validation_featuresytarget_${SUBGRUPO} WHERE id_carrera=${id_carrera_analizada} LIMIT 10;
SELECT * FROM datos_desa.tb_ds_futuro_features_id_${SUBGRUPO} WHERE id_carrera=${id_carrera_analizada} LIMIT 10;
EOF

echo -e "\n------------------- Antes de predecir ---------\n" 2>&1 1>>${LOG_060_ENDTOEND}${TIEMPO}
echo -e "$CONSULTA_ANTES_DE_PREDECIR" 2>&1 1>>${LOG_060_ENDTOEND}${TIEMPO}
mysql -u root --password=datos1986 -t --execute="$CONSULTA_ANTES_DE_PREDECIR" 2>&1 1>>${LOG_060_ENDTOEND}${TIEMPO}

########################################################################################################

read -d '' CONSULTA_DESPUES_DE_PREDECIR_0 <<- EOF
SELECT id_carrera, rowid, target_real, target_predicho FROM datos_desa.tb_val_${SUBGRUPO} WHERE id_carrera=${id_carrera_analizada} LIMIT 10;
SELECT id_carrera, rowid, 'DESCONOCIDO' AS target_real, target_predicho FROM datos_desa.tb_fut_${SUBGRUPO} WHERE id_carrera=${id_carrera_analizada} LIMIT 10;
EOF

echo -e "\n-------------------Despues de predecir ---------\n" 2>&1 1>>${LOG_060_ENDTOEND}${TIEMPO}
echo -e "$CONSULTA_DESPUES_DE_PREDECIR_0" 2>&1 1>>${LOG_060_ENDTOEND}${TIEMPO}
mysql -u root --password=datos1986 -t --execute="$CONSULTA_DESPUES_DE_PREDECIR_0" 2>&1 1>>${LOG_060_ENDTOEND}${TIEMPO}

read -d '' CONSULTA_DESPUES_DE_PREDECIR_1o2 <<- EOF
SELECT * FROM datos_desa.tb_val_1o2_aciertos_connombre_${SUBGRUPO} WHERE id_carrera=${id_carrera_analizada} LIMIT 6;
-- NO calculamos 1o2 para FUT: ---SELECT * FROM datos_desa.tb_fut_1o2_connombre_${SUBGRUPO} WHERE id_carrera=${id_carrera_analizada} LIMIT 6;

-- Solo para PASADO (1o2), porque en MOD050 no hemos calculado la tabla economica para caso 1o2.
select * FROM datos_desa.tb_val_1o2_economico_${SUBGRUPO}_SP10099900 WHERE id_carrera=${id_carrera_analizada} LIMIT 10;
EOF

echo -e "\n-------------------Prediccion de que queda PRIMERO o SEGUNDO (1o2) (Ganador o colocado) ---------\n" 2>&1 1>>${LOG_060_ENDTOEND}${TIEMPO}
echo -e "$CONSULTA_DESPUES_DE_PREDECIR_1o2" 2>&1 1>>${LOG_060_ENDTOEND}${TIEMPO}
mysql -u root --password=datos1986 -t --execute="$CONSULTA_DESPUES_DE_PREDECIR_1o2" 2>&1 1>>${LOG_060_ENDTOEND}${TIEMPO}


read -d '' CONSULTA_DESPUES_DE_PREDECIR_1st <<- EOF
SELECT * FROM datos_desa.tb_val_1st_aciertos_connombre_${SUBGRUPO} WHERE id_carrera=${id_carrera_analizada} LIMIT 6;
SELECT * FROM datos_desa.tb_fut_1st_connombre_${SUBGRUPO} WHERE id_carrera=${id_carrera_analizada} LIMIT 6;

select * FROM datos_desa.tb_val_1st_riesgo_${SUBGRUPO} WHERE id_carrera=${id_carrera_analizada} LIMIT 10;
SELECT * FROM datos_desa.tb_fut_1st_final_${SUBGRUPO} WHERE id_carrera=${id_carrera_analizada} LIMIT 10;

select * FROM datos_desa.tb_val_1st_economico_${SUBGRUPO}_SP10099900 WHERE id_carrera=${id_carrera_analizada} LIMIT 10;
SELECT * FROM datos_desa.tb_fut_1st_final_riesgo_${SUBGRUPO} WHERE id_carrera=${id_carrera_analizada} LIMIT 10;
EOF

echo -e "\n--------------------Prediccion de que queda PRIMERO (1st) --------\n" 2>&1 1>>${LOG_060_ENDTOEND}${TIEMPO}
echo -e "$CONSULTA_DESPUES_DE_PREDECIR_1st" 2>&1 1>>${LOG_060_ENDTOEND}${TIEMPO}
mysql -u root --password=datos1986 -t --execute="$CONSULTA_DESPUES_DE_PREDECIR_1st" 2>&1 1>>${LOG_060_ENDTOEND}${TIEMPO}


########################################################################################################

echo -e "\n----------------------------\n" 2>&1 1>>${LOG_060_ENDTOEND}${TIEMPO}
echo -e "\nATENCION: debo COMPROBAR que los galgos de ENTRADA sean los mismos que los de SALIDA y que tengan precio SP !!!!!!!!!\n\n" 2>&1 1>>${LOG_060_ENDTOEND}${TIEMPO}

echo -e $(date +"%T")" | 060 | Analisis caso concreto end-to-end | FIN" >>$LOG_070






#!/bin/bash

source "/root/git/bdml/mod002parser/scripts/galgos/funciones.sh"


TAG="HORA_TARDE"

FILE_TEMP="./temp_numero"


echo -e "TAG=$TAG"

#Numeros
mysql --login-path=local -N --execute="SELECT count(*) as num_ids_pasados FROM datos_desa.tb_dataset_ids_pasados_${TAG} LIMIT 1;" > ${FILE_TEMP}
numero_ids_pasados=$( cat ${FILE_TEMP})

numero_pasados_test=$(echo "$DATASET_TEST_PORCENTAJE * $numero_ids_pasados" | bc | cut -f1 -d".")
numero_pasados_validation=$(echo "$DATASET_VALIDATION_PORCENTAJE * $numero_ids_pasados" | bc | cut -f1 -d".")
numero_pasados_train=$(echo "$numero_ids_pasados-$numero_pasados_test-$numero_pasados_validation" | bc)



if [ -z "$numero_pasados_test" ]
then
  echo -e "\n\n\nnumero_pasados_test VACIO\n\n\n\n\n"
  numero_pasados_test=0
fi


echo -e "${TAG}|DS-Pasados = #"${numero_ids_pasados}"# --> [TRAIN + TEST + *VALIDATION] = #"${numero_pasados_train}"# + #"${numero_pasados_test}"# + *#"${numero_pasados_validation}"#"


mysql --login-path=local -N --execute="SELECT count(*) as num_ids_futuros FROM datos_desa.tb_dataset_ids_futuros_${TAG} LIMIT 1;" > ${FILE_TEMP}
numero_ids_futuros=$( cat ${FILE_TEMP})

echo -e "${TAG}|DS-Futuros = ${numero_ids_futuros}"






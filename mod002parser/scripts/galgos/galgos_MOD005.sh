#!/bin/bash

echo -e "Modulo 005 - Prediccion"


#######################################
########### i001-Prediccion ###########
#######################################

mysql -u root --password=datos1986 --execute="DROP TABLE datos_desa.tb_galgos_dataset_prediccion_features_i001;"


echo -e "para probar, cojo 6 filas que ya tengo, pero lo normal es coger x filas de Internet que queramos predecir (hacer un sistema aparte que cargue y prepare estas features...)!!!!!!!!!!!!!!!!!"
read -d '' CONSULTA1 <<- EOF
CREATE TABLE datos_desa.tb_galgos_dataset_prediccion_features_i001 
AS 
SELECT * FROM datos_desa.tb_galgos_dataset_data_i001 LIMIT 10;
EOF

mysql -u root --password=datos1986 --execute="$CONSULTA1"

echo -e "Dataset - CASOS (features): " >&1
mysql -u root --password=datos1986 --execute="SELECT COUNT(*) as num_filas FROM datos_desa.tb_galgos_dataset_data_i001 LIMIT 1\W;" >&1

echo -e "Prediciendo..."
python3 '/home/carloslinux/Desktop/GIT_REPO_PYTHON_POC_ML/python_poc_ml/galgos/galgos_i001.py'

echo -e "Dataset - TARGETs predichos: " >&1
mysql -u root --password=datos1986 --execute="SELECT COUNT(*) as num_filas FROM datos_desa.tb_galgos_dataset_target_i001 LIMIT 1\W;" >&1
mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_galgos_dataset_target_i001 LIMIT 100\W;" >&1



echo -e "En esta prueba, el resultado ideal debería ser igual que los targets que ya conocemos:" >&1
mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_galgos_dataset_target_i001 LIMIT 10\W;" >&1






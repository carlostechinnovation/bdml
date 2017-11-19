#!/bin/bash

echo -e "Modulo 005 - Prediccion"


#######################################
########### i001-Prediccion ###########
#######################################

mysql -u root --password=datos1986 --execute="DROP TABLE IF EXISTS datos_desa.tb_galgos_dataset_prediccion_features_i001;"

####### temp
echo -e "para probar, cojo 10 las filas que ya tengo, pero lo normal es coger x filas de Internet que queramos predecir (hacer un sistema aparte que cargue y prepare estas features...)!!!!!!!!!!!!!!!!!"
mysql -u root --password=datos1986 --execute="CREATE TABLE datos_desa.tb_galgos_dataset_prediccion_features_i001 AS SELECT * FROM datos_desa.tb_galgos_dataset_data_i001 LIMIT 10;"
####### temp


echo -e "Dataset - CASOS (features): " >&1
mysql -u root --password=datos1986 --execute="SELECT COUNT(*) as num_filas FROM datos_desa.tb_galgos_dataset_data_i001 LIMIT 1\W;" >&1



echo -e "Prediciendo..."
python3 '/home/carloslinux/Desktop/GIT_REPO_PYTHON_POC_ML/python_poc_ml/galgos/galgos_i001_predictor.py'


echo -e "Dataset - TARGETs predichos: " >&1
mysql -u root --password=datos1986 --execute="DROP TABLE IF EXISTS datos_desa.tb_galgos_dataset_prediccion_target_i001;"
mysql -u root --password=datos1986 --execute="CREATE TABLE datos_desa.tb_galgos_dataset_prediccion_target_i001 (target INT);"
mysql -u root --password=datos1986 --execute="LOAD DATA LOCAL INFILE '/home/carloslinux/Desktop/DATOS_LIMPIO/galgos/i001_targets.txt' INTO TABLE datos_desa.tb_galgos_dataset_prediccion_target_i001 FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n' IGNORE 0 LINES\W;"
sleep 4s
mysql -u root --password=datos1986 --execute="SELECT 'todas' as tipo, COUNT(*) as num FROM datos_desa.tb_galgos_dataset_prediccion_target_i001 UNION SELECT 'unos' as tipo, COUNT(*) as num FROM datos_desa.tb_galgos_dataset_prediccion_target_i001 WHERE target=1\W;" >&1


####### temp
echo -e "En esta prueba, el resultado IDEAL debería ser igual que los targets que ya conocemos. Vamos a comparar y sacar el porcentaje de acierto:" >&1
mysql -u root --password=datos1986 --execute="SELECT target FROM datos_desa.tb_galgos_dataset_target_i001 LIMIT 10\W;" >&1
####### temp






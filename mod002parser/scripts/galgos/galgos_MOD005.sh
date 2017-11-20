#!/bin/bash

echo -e "Modulo 005 - Prediccion"

PATH_CONTADOR_GALGOS="./contador_galgos"

#Dada una URL de una carrera concreta de BET365, descargar y parsear las carreras de ese dia concreto
URL="https://www.bet365.es/?rn=80290266329&stf=1#/AC/B4/C101/D20171120/E20557816/F68876618/P11/"

echo -e "Entradas- features: cada FILA es un GALGO EN UNA CARRERA FUTURA"
read -d '' CONSULTA_COMPETIDORES <<- EOF

DROP TABLE IF EXISTS datos_desa.tb_galgos_apuesta;
CREATE TABLE datos_desa.tb_galgos_apuesta AS 
SELECT * 
FROM datos_desa.tb_galgos_i001_aux4 
WHERE galgo_analizado IN ('Honest John', 'Lowgate Belatrix', 'King Elvis', 'Romeo Mandate', 'King Eden', 'Westmead Turbo')
LIMIT 10;


DROP TABLE IF EXISTS datos_desa.tb_galgos_dataset_prediccion_features_i001;
CREATE TABLE datos_desa.tb_galgos_dataset_prediccion_features_i001 AS
SELECT 

mes,
dia,
hora,
distancia,
num_galgos,
premio_primero,
premio_segundo,
premio_otros,
premio_total_carrera,
going_allowance_segundos,

analizado_vel_real, 
analizado_vel_going,

max_competidores_vel_real,
min_competidores_vel_real,
avg_competidores_vel_real,
std_competidores_vel_real,
max_competidores_vel_going,
min_competidores_vel_going,
avg_competidores_vel_going,
std_competidores_vel_going

FROM datos_desa.tb_galgos_apuesta
LIMIT 10;
EOF

mysql -u root --password=datos1986 --execute="$CONSULTA_COMPETIDORES" >&1



echo -e "Dataset - Comprobacion de que deberia haber SOLO 6 galgos con sus features..." >&1
mysql -u root --password=datos1986 --execute="SELECT COUNT(*) as num_filas FROM datos_desa.tb_galgos_dataset_prediccion_features_i001 LIMIT 1\W;" -N > $PATH_CONTADOR_GALGOS

numero_galgos=$(cat ${PATH_CONTADOR_GALGOS})

if [ ${numero_galgos} -eq 6 ]
then
  
  mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_galgos_dataset_prediccion_features_i001 LIMIT 10\W;" >&1

  echo -e "Prediciendo los targets..."
  python3 '/home/carloslinux/Desktop/GIT_REPO_PYTHON_POC_ML/python_poc_ml/galgos/galgos_i001_predictor.py'


  echo -e "Dataset - TARGETs predichos: " >&1
  mysql -u root --password=datos1986 --execute="DROP TABLE IF EXISTS datos_desa.tb_galgos_dataset_prediccion_target_i001;"
  mysql -u root --password=datos1986 --execute="CREATE TABLE datos_desa.tb_galgos_dataset_prediccion_target_i001 (target INT);"
  mysql -u root --password=datos1986 --execute="LOAD DATA LOCAL INFILE '/home/carloslinux/Desktop/DATOS_LIMPIO/galgos/i001_targets.txt' INTO TABLE datos_desa.tb_galgos_dataset_prediccion_target_i001 FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n' IGNORE 0 LINES\W;"
  sleep 4s

  echo -e "Mostrando los galgos con sus targets..."
  mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_galgos_apuesta LIMIT 10\W;" >&1
  mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_galgos_dataset_prediccion_target_i001;" >&1

else
  echo -e "No tenemos datos de los 6 galgos!!! Solo conocemos datos de ${numero_galgos} galgos!!"
fi


echo -e "FIN"





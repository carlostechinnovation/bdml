#!/bin/bash

echo -e "Modulo 006 - ANALISIS POSTERIOR"

FOLDER_006="/home/carloslinux/Desktop/DATOS_LIMPIO/galgos/ANALISIS_POSTERIOR/"

rm -Rf "$FOLDER_006*"
#mkdir $FOLDER_006

mysql -u root --password=datos1986 --execute="SELECT id_carrera FROM datos_desa.tb_galgos_001_pre LIMIT 1\W;" -N > "${FOLDER_006}007_idcarrera_file"
idcarrera_organizada=$(cat "${FOLDER_006}007_idcarrera_file")
echo -e "Carrera analizada = $idcarrera_organizada"
echo -e "Path donde ponemos los CSVs = $FOLDER_006"


echo -e "TABLAS de datos originales (tras parsear webs): 000_tb_galgos_carreras.csv  000_tb_galgos_posiciones_en_carreras.csv  000_tb_galgos_historico.csv  000_tb_galgos_agregados.csv"

mysql -u root --password=datos1986 -t --execute="SELECT * FROM datos_desa.tb_galgos_carreras WHERE id_carrera=$idcarrera_organizada LIMIT 10\W;" > "${FOLDER_006}000_tb_galgos_carreras.csv"
mysql -u root --password=datos1986 -t --execute="SELECT * FROM datos_desa.tb_galgos_posiciones_en_carreras WHERE id_carrera=$idcarrera_organizada LIMIT 20\W;" > "${FOLDER_006}000_tb_galgos_posiciones_en_carreras.csv"
mysql -u root --password=datos1986 -t --execute="SELECT * FROM datos_desa.tb_galgos_historico WHERE galgo_nombre IN ( SELECT galgo_nombre FROM datos_desa.tb_galgos_posiciones_en_carreras WHERE id_carrera=$idcarrera_organizada ) LIMIT 1000\W;" > "${FOLDER_006}000_tb_galgos_historico.csv"
mysql -u root --password=datos1986 -t --execute="SELECT * FROM datos_desa.tb_galgos_agregados WHERE galgo_nombre IN ( SELECT galgo_nombre FROM datos_desa.tb_galgos_posiciones_en_carreras WHERE id_carrera=$idcarrera_organizada ) LIMIT 100\W;" > "${FOLDER_006}000_tb_galgos_agregados.csv"

echo -e "TABLAS de entrenamiento (pre): pre_001.csv  pre_002a.csv  pre_002b.csv  pre_003.csv  pre_004.csv  pre_005.csv  pre_FEATURES_IN.csv  pre_TARGET_IN.csv"

mysql -u root --password=datos1986 -t --execute="SELECT * FROM datos_desa.tb_galgos_001_pre WHERE id_carrera=$idcarrera_organizada LIMIT 100\W;" > "${FOLDER_006}pre_001.csv"
mysql -u root --password=datos1986 -t --execute="SELECT * FROM datos_desa.tb_galgos_002_pre WHERE id_carrera=$idcarrera_organizada LIMIT 100\W;" > "${FOLDER_006}pre_002a.csv"
mysql -u root --password=datos1986 -t --execute="SELECT * FROM datos_desa.tb_galgos_002_ordenadoporvelmediadistancia_pre WHERE id_carrera=$idcarrera_organizada LIMIT 100\W;" > "${FOLDER_006}pre_002b.csv"
mysql -u root --password=datos1986 -t --execute="SELECT * FROM datos_desa.tb_galgos_003_pre WHERE id_carrera=$idcarrera_organizada LIMIT 1000\W;" > "${FOLDER_006}pre_003.csv"
mysql -u root --password=datos1986 -t --execute="SELECT * FROM datos_desa.tb_galgos_004_pre WHERE id_carrera=$idcarrera_organizada ORDER BY posicion_analizado ASC LIMIT 1000\W;" > "${FOLDER_006}pre_004.csv"
mysql -u root --password=datos1986 -t --execute="SELECT * FROM datos_desa.tb_galgos_005_pre WHERE id_carrera=$idcarrera_organizada LIMIT 1000\W;" > "${FOLDER_006}pre_005.csv"
mysql -u root --password=datos1986 -t --execute="SELECT * FROM datos_desa.tb_galgos_data_pre LIMIT 0\W;" > "${FOLDER_006}pre_FEATURES_IN.csv"
mysql -u root --password=datos1986 -t --execute="SELECT * FROM datos_desa.tb_galgos_target_pre LIMIT 0\W;" > "${FOLDER_006}pre_TARGET_IN.csv"

echo -e "TABLAS de TEST (post)"

mysql -u root --password=datos1986 -t --execute="SELECT * FROM datos_desa.tb_galgos_001_post LIMIT 0\W;" > "${FOLDER_006}post_001.csv"
mysql -u root --password=datos1986 -t --execute="SELECT * FROM datos_desa.tb_galgos_002_post LIMIT 0\W;" > "${FOLDER_006}post_002a.csv"
mysql -u root --password=datos1986 -t --execute="SELECT * FROM datos_desa.tb_galgos_002_ordenadoporvelmediadistancia_post LIMIT 0\W;" > "${FOLDER_006}post_002b.csv"
mysql -u root --password=datos1986 -t --execute="SELECT * FROM datos_desa.tb_galgos_003_post LIMIT 0\W;" > "${FOLDER_006}post_003.csv"
mysql -u root --password=datos1986 -t --execute="SELECT * FROM datos_desa.tb_galgos_004_post LIMIT 0\W;" > "${FOLDER_006}post_004.csv"
mysql -u root --password=datos1986 -t --execute="SELECT * FROM datos_desa.tb_galgos_005_post LIMIT 0\W;" > "${FOLDER_006}post_005.csv"
mysql -u root --password=datos1986 -t --execute="SELECT * FROM datos_desa.tb_galgos_data_post LIMIT 0\W;" > "${FOLDER_006}post_FEATURES_IN.csv"
mysql -u root --password=datos1986 -t --execute="SELECT * FROM datos_desa.tb_galgos_target_post LIMIT 0\W;" > "${FOLDER_006}post_TARGET_IN.csv"


echo -e "Analisis posterior: FIN"





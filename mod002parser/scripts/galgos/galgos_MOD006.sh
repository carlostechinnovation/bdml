#!/bin/bash

echo -e "Modulo 006 - ANALISIS POSTERIOR"

FOLDER_006="/home/carloslinux/Desktop/DATOS_LIMPIO/galgos/ANALISIS_POSTERIOR/"

rm -Rf "$FOLDER_006*"
#mkdir $FOLDER_006

mysql -u root --password=datos1986 --execute="SELECT id_carrera FROM datos_desa.tb_galgos_001_gagst_pre LIMIT 1\W;" -N > "${FOLDER_006}007_idcarrera_file"
idcarrera_organizada=$(cat "${FOLDER_006}007_idcarrera_file")
echo -e "Carrera analizada = $idcarrera_organizada"
echo -e "Path donde ponemos los CSVs = $FOLDER_006"


echo -e "GAGST - TABLAS de datos originales (tras parsear webs)..."

mysql -u root --password=datos1986 -t --execute="SELECT * FROM datos_desa.tb_galgos_carreras WHERE id_carrera=$idcarrera_organizada LIMIT 10\W;" > "${FOLDER_006}000_tb_galgos_carreras.csv"
mysql -u root --password=datos1986 -t --execute="SELECT * FROM datos_desa.tb_galgos_posiciones_en_carreras WHERE id_carrera=$idcarrera_organizada LIMIT 20\W;" > "${FOLDER_006}000_tb_galgos_posiciones_en_carreras.csv"
mysql -u root --password=datos1986 -t --execute="SELECT * FROM datos_desa.tb_galgos_historico WHERE galgo_nombre IN ( SELECT galgo_nombre FROM datos_desa.tb_galgos_posiciones_en_carreras WHERE id_carrera=$idcarrera_organizada ) LIMIT 1000\W;" > "${FOLDER_006}000_tb_galgos_historico.csv"
mysql -u root --password=datos1986 -t --execute="SELECT * FROM datos_desa.tb_galgos_agregados WHERE galgo_nombre IN ( SELECT galgo_nombre FROM datos_desa.tb_galgos_posiciones_en_carreras WHERE id_carrera=$idcarrera_organizada ) LIMIT 100\W;" > "${FOLDER_006}000_tb_galgos_agregados.csv"

echo -e "GAGST - TABLAS de entrenamiento (pre)..."

mysql -u root --password=datos1986 -t --execute="SELECT * FROM datos_desa.tb_galgos_001_gagst_pre WHERE id_carrera=$idcarrera_organizada LIMIT 100\W;" > "${FOLDER_006}gagst_pre_001.csv"
mysql -u root --password=datos1986 -t --execute="SELECT * FROM datos_desa.tb_galgos_002_gagst_pre WHERE id_carrera=$idcarrera_organizada LIMIT 100\W;" > "${FOLDER_006}gagst_pre_002a.csv"
mysql -u root --password=datos1986 -t --execute="SELECT * FROM datos_desa.tb_galgos_002_ordenadoporvelmediadistancia_gagst_pre WHERE id_carrera=$idcarrera_organizada LIMIT 100\W;" > "${FOLDER_006}gagstpre_002b.csv"
mysql -u root --password=datos1986 -t --execute="SELECT * FROM datos_desa.tb_galgos_003_gagst_pre WHERE id_carrera=$idcarrera_organizada LIMIT 1000\W;" > "${FOLDER_006}gagst_pre_003.csv"
mysql -u root --password=datos1986 -t --execute="SELECT * FROM datos_desa.tb_galgos_004_gagst_pre WHERE id_carrera=$idcarrera_organizada ORDER BY posicion_analizado ASC LIMIT 1000\W;" > "${FOLDER_006}gagst_pre_004.csv"
mysql -u root --password=datos1986 -t --execute="SELECT * FROM datos_desa.tb_galgos_005_gagst_pre WHERE id_carrera=$idcarrera_organizada LIMIT 1000\W;" > "${FOLDER_006}gagst_pre_005.csv"
mysql -u root --password=datos1986 -t --execute="SELECT * FROM datos_desa.tb_galgos_data_gagst_pre LIMIT 0\W;" > "${FOLDER_006}gagst_pre_FEATURES_IN.csv"
mysql -u root --password=datos1986 -t --execute="SELECT * FROM datos_desa.tb_galgos_target_gagst_pre LIMIT 0\W;" > "${FOLDER_006}gagst_pre_TARGET_IN.csv"

echo -e "GAGST - TABLAS de TEST (post)..."

mysql -u root --password=datos1986 -t --execute="SELECT * FROM datos_desa.tb_galgos_001_gagst_post LIMIT 0\W;" > "${FOLDER_006}gagst_post_001.csv"
mysql -u root --password=datos1986 -t --execute="SELECT * FROM datos_desa.tb_galgos_002_gagst_post LIMIT 0\W;" > "${FOLDER_006}gagst_post_002a.csv"
mysql -u root --password=datos1986 -t --execute="SELECT * FROM datos_desa.tb_galgos_002_ordenadoporvelmediadistancia_gagst_post LIMIT 0\W;" > "${FOLDER_006}gagst_post_002b.csv"
mysql -u root --password=datos1986 -t --execute="SELECT * FROM datos_desa.tb_galgos_003_gagst_post LIMIT 0\W;" > "${FOLDER_006}gagst_post_003.csv"
mysql -u root --password=datos1986 -t --execute="SELECT * FROM datos_desa.tb_galgos_004_gagst_post LIMIT 0\W;" > "${FOLDER_006}gagst_post_004.csv"
mysql -u root --password=datos1986 -t --execute="SELECT * FROM datos_desa.tb_galgos_005_gagst_post LIMIT 0\W;" > "${FOLDER_006}gagst_post_005.csv"
mysql -u root --password=datos1986 -t --execute="SELECT * FROM datos_desa.tb_galgos_data_gagst_post LIMIT 0\W;" > "${FOLDER_006}gagst_post_FEATURES_IN.csv"
mysql -u root --password=datos1986 -t --execute="SELECT * FROM datos_desa.tb_galgos_target_gagst_post LIMIT 0\W;" > "${FOLDER_006}gagst_post_TARGET_IN.csv"


echo -e "Analisis posterior: FIN"





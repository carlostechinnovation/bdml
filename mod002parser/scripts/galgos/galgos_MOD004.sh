#!/bin/bash

echo -e "Modulo 004B - Modelos predictivos (nucleo)"

################# Análisis galgos_001: Modelo predictivo CLASIFICADOR

python3 '/home/carloslinux/Desktop/GIT_REPO_PYTHON_POC_ML/python_poc_ml/galgos/galgos_i001.py'




echo -e "Guardando datos CSV para analizar casos y subconjuntos a MANO..."
mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_galgos_carreras\W;" > "./tb_galgos_carreras.csv"
mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_galgos_posiciones_en_carreras\W;" > "./tb_galgos_posiciones_en_carreras.csv"
mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_galgos_historico\W;" > "./tb_galgos_historico.csv"
mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_galgos_agregados\W;" > "./tb_galgos_agregados.csv"

mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_galgos_i001_aux4\W;" >"./ENTRADAS_DISPONIBLES_Y_TARGET_REAL.csv"


echo -e "El sistema predictivo cogera el 10% ultimo de muestras, predecira los targets y los pondra aqui: /home/carloslinux/Desktop/DATOS_LIMPIO/galgos/i001_reglog_test_targets_predichos.txt"

echo -e "Modulo 004B - FIN\n\n\n\n"


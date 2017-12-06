#!/bin/bash

echo -e "Modulo 004B - Modelos predictivos (nucleo)"

PATH_MODELO_GANADOR='/home/carloslinux/Desktop/GIT_REPO_PYTHON_POC_ML/python_poc_ml/galgos/galgos_i001_MEJOR_MODELO.pkl'
rm -f $PATH_MODELO_GANADOR


################# Análisis galgos_001: Modelo predictivo CLASIFICADOR

python3 '/home/carloslinux/Desktop/GIT_REPO_PYTHON_POC_ML/python_poc_ml/galgos/galgos_i001.py' > $PATH_INFORME_MODELO


#echo -e "Guardando datos CSV para analizar casos y subconjuntos a MANO..."
#mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_galgos_carreras\W;" > "./tb_galgos_carreras.csv"
#mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_galgos_posiciones_en_carreras\W;" > "./tb_galgos_posiciones_en_carreras.csv"
#mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_galgos_historico\W;" > "./tb_galgos_historico.csv"
#mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_galgos_agregados\W;" > "./tb_galgos_agregados.csv"
#mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_galgos_data_pre\W;" >"./FEATURES_IN.csv"
#mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_galgos_target_pre\W;" >"./TARGET_IN.csv"


echo -e "Modulo 004B - FIN\n\n\n\n"


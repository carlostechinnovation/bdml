#!/bin/bash

echo -e $(date +"%T")"Modulo 004B - Modelos predictivos (nucleo)"

FOLDER_INFORMES="/home/carloslinux/Desktop/INFORMES/"



PATH_MODELO_GANADOR='/home/carloslinux/Desktop/GIT_REPO_PYTHON_POC_ML/python_poc_ml/galgos/galgos_gagst_MEJOR_MODELO.pkl'
rm -f $PATH_MODELO_GANADOR


################# Análisis galgos_001: Modelo predictivo CLASIFICADOR

python3 '/home/carloslinux/Desktop/GIT_REPO_PYTHON_POC_ML/python_poc_ml/galgos/galgos_gagst.py' > "${FOLDER_INFORMES}galgos_MOD004_gagst.out"

cat "${FOLDER_INFORMES}galgos_MOD004_gagst.out" | grep 'GAGST-Gana modelo'  >&1


echo -e $(date +"%T")"Modulo 004B - FIN\n\n"



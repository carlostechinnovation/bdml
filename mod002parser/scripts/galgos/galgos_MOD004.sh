#!/bin/bash

echo -e "Modulo 004B - Modelos predictivos (nucleo)"

PATH_MODELO_GANADOR='/home/carloslinux/Desktop/GIT_REPO_PYTHON_POC_ML/python_poc_ml/galgos/galgos_i001_MEJOR_MODELO.pkl'
rm -f $PATH_MODELO_GANADOR


################# Análisis galgos_001: Modelo predictivo CLASIFICADOR

python3 '/home/carloslinux/Desktop/GIT_REPO_PYTHON_POC_ML/python_poc_ml/galgos/galgos_i001.py' > "/home/carloslinux/Desktop/CODIGOS/workspace_java/bdml/mod002parser/scripts/galgos/galgos_MOD004.out"



echo -e "Modulo 004B - FIN\n\n\n\n"



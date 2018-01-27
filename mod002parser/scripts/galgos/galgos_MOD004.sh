#!/bin/bash

source "/root/git/bdml/mod002parser/scripts/galgos/funciones.sh"

#### Limpiar LOG ###
rm -f $LOG_ML

echo -e $(date +"%T")" Modulo 004B - Modelos predictivos (nucleo)" 2>&1 1>>${LOG_DS}

INFORME="/home/carloslinux/Desktop/INFORMES/galgos_MOD004.out"

echo -e $(date +"%T")" Informe --> ${INFORME}"  2>&1 1>>${LOG_DS}

PATH_MODELO_GANADOR='/home/carloslinux/Desktop/GIT_REPO_PYTHON_POC_ML/python_poc_ml/galgos/galgos_regresion_MEJOR_MODELO.pkl'
rm -f $PATH_MODELO_GANADOR


########### Modelo predictivo REGRESION ###########3
TAG="SUBGRUPO_X"

python3 '/home/carloslinux/Desktop/GIT_REPO_PYTHON_POC_ML/python_poc_ml/galgos/galgos_regresion_train_test.py' "_${TAG}" > "${INFORME}"

cat "${INFORME}" | grep 'Gana modelo'  >&1


echo -e $(date +"%T")"Modulo 004B - FIN\n\n" 2>&1 1>>${LOG_DS}



#!/bin/bash

source "/root/git/bdml/mod002parser/scripts/galgos/funciones.sh"


######################## PARAMETROS ############
if [ "$#" -ne 1 ]; then
    echo " Numero de parametros incorrecto!!!" 2>&1 1>>${LOG_ML}
fi

TAG="${1}"


echo -e $(date +"%T")" | 045 | Modelo predictivo (subgrupo: $TAG) | INICIO" >>$LOG_070
echo -e "MOD045 --> LOG = "${LOG_ML}

PATH_MODELO_GANADOR='/home/carloslinux/Desktop/GIT_REPO_PYTHON_POC_ML/python_poc_ml/galgos/galgos_regresion_MEJOR_MODELO.pkl'
rm -f $PATH_MODELO_GANADOR


########### Modelo predictivo REGRESION ###########
echo -e "\n\n\n----------------------------- 045 --------------------\n\n\n" 2>&1 1>>${LOG_ML}
echo -e $(date +"%T")" Entrenando el modelo con DS-TTV (todo lo que conocemos del pasado) para tener un modelo bien entrenado..." 2>&1 1>>${LOG_ML}

python3 '/home/carloslinux/Desktop/GIT_REPO_PYTHON_POC_ML/python_poc_ml/galgos/galgos_regresion_ttv_pasado.py' "_${TAG}" >> "${LOG_ML}"

echo -e $(date +"%T")" Modelo listo para predecir el futuro!" 2>&1 1>>${LOG_ML}

################################################
##############################################################

echo -e $(date +"%T")" | 040 | Modelos predictivos | FIN" >>$LOG_070






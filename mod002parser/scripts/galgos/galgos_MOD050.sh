#!/bin/bash

source "/root/git/bdml/mod002parser/scripts/galgos/funciones.sh"

TAG="${1}"

#### Limpiar LOG ###
rm -f $LOG_050


echo -e $(date +"%T")" Modulo 050 - PREDICCIÓN de carreras futuras: INICIO" 2>&1 1>>${LOG_050}
echo -e "MOD050 --> LOG = "${LOG_050}
<<<<<<< HEAD

########### Modelo predictivo REGRESION ###########
=======
>>>>>>> branch 'master' of https://github.com/carlostechinnovation/bdml.git

<<<<<<< HEAD

PATH_MODELO_GANADOR='/home/carloslinux/Desktop/GIT_REPO_PYTHON_POC_ML/python_poc_ml/galgos/galgos_regresion_MEJOR_MODELO.pkl'

echo -e $(date +"%T")" Ejecutando modelo (ya entrenado) sobre DS-FUTURO..." 2>&1 1>>${LOG_ML}
python3 '/home/carloslinux/Desktop/GIT_REPO_PYTHON_POC_ML/python_poc_ml/galgos/galgos_regresion_predictor.py' "_${TAG}" 2>&1 1>>${LOG_ML}


PATH_FILE_FUTURO_TARGETS="/home/carloslinux/Desktop/DATOS_LIMPIO/galgos/datos_desa.tb_ds_futuro_targets_${TAG}.txt"

echo -e $(date +"%T")" Ejemplo de targets FUTUROS predichos:" 2>&1 1>>${LOG_ML}
echo -e $(head -n 10 $PATH_FILE_FUTURO_TARGETS) 2>&1 1>>${LOG_ML}
=======
########### Modelo predictivo REGRESION ###########
>>>>>>> branch 'master' of https://github.com/carlostechinnovation/bdml.git




<<<<<<< HEAD
=======




>>>>>>> branch 'master' of https://github.com/carlostechinnovation/bdml.git
###################### MAIL ##########################
#cat "$PATH_INFORME_FINAL" | mail -s "GALGOS - Prediccion carreras futuras Sportium" carlosandresgarcia1986@gmail.com,fcacereslau@hotmail.com,luisandresgarcia@gmail.com

##################################################
<<<<<<< HEAD
=======

echo -e $(date +"%T")" Modulo 050 - PREDICCIÓN de carreras futuras: FIN" 2>&1 1>>${LOG_050}
>>>>>>> branch 'master' of https://github.com/carlostechinnovation/bdml.git

echo -e $(date +"%T")" Modulo 050 - PREDICCIÓN de carreras futuras: FIN" 2>&1 1>>${LOG_050}

#!/bin/bash

source "/home/carloslinux/git/bdml/mod002parser/scripts/galgos/funciones.sh"

######################## PARAMETROS ############
if [ "$#" -ne 1 ]; then
    echo " Numero de parametros incorrecto!!!" 2>&1 1>>${LOG_045}
fi

TAG="${1}"

#### Limpiar LOG ###
rm -f $LOG_045

echo -e $(date +"%T")" | 045 | Entreno con pasado-TTV (subgrupo: $TAG) | INICIO" >>$LOG_070
echo -e "MOD045 --> LOG = "${LOG_045}

echo -e "\n\n\n----------------------------- 045 --------------------\n\n\n" 2>&1 1>>${LOG_045}
echo -e $(date +"%T")" Entrenando el modelo con DS-TTV (todo lo que conocemos del pasado) para tener un modelo bien entrenado..." 2>&1 1>>${LOG_045}


########### PYTHON: Modelo predictivo REGRESION ###########
#PATH_MODELO_GANADOR='/home/carloslinux/Desktop/WORKSPACES/wksp_pycharm/python_poc_ml/galgos/galgos_regresion_MEJOR_MODELO.pkl'
#rm -f $PATH_MODELO_GANADOR

#python3 '/home/carloslinux/Desktop/WORKSPACES/wksp_pycharm/python_poc_ml/galgos/galgos_regresion_ttv_pasado.py' "_${TAG}" 2>&1 1>>"${LOG_045}"
#num_filas_modelo=$(cat "$PATH_MODELO_GANADOR" | wc -l)
#if [ ${num_filas_modelo} -eq 0 ]
#  then
#    echo -e "ERROR El modelo generado por Python (045) NO existe o esta vacio. Salida forzada. num_filas_modelo=$num_filas_modelo"
#    exit -1
#fi
#echo -e $(date +"%T")" Modelo listo para predecir el futuro! Path_modelo = "$PATH_MODELO_GANADOR 2>&1 1>>${LOG_045}


########### R: Modelo predictivo REGRESION ###########
Rscript '/home/carloslinux/Desktop/WORKSPACES/wksp_for_r/r_galgos/galgos_regresion_ttv_pasado.R' "2" "${TAG}" "1000000" 2>&1 1>>"${LOG_045}"


##############################################################

echo -e $(date +"%T")" | 045 | Entreno con pasado-TTV (subgrupo: $TAG) | FIN" >>$LOG_070



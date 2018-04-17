#!/bin/bash

echo -e $(date +"%T")"Modulo 005 - Prediccion PGA"


echo -e $(date +"%T")"ENTRADAS: carreras a predecir SPORTIUM (info carrera + galgo_nombre)" >&1
echo -e $(date +"%T")"SALIDA: tabla de predicciones (galgo_nombre + target-puntos)" >&1




#ENTRADA: Carreras futuras a predecir (Sportium)
mysql--execute="SELECT COUNT(*) as num_galgos_iniciales_SPORTIUM FROM datos_desa.tb_cg_semillas_sportium LIMIT 1\W;" 2>&1 1>>${PATH_LOG}






echo -e $(date +"%T")"FIN"





#!/bin/bash

echo -e "Modulo 005 - Prediccion PGA"


echo -e "ENTRADAS: carreras a predecir SPORTIUM (info carrera + galgo_nombre)" >&1
echo -e "SALIDA: tabla de predicciones (galgo_nombre + target-puntos)" >&1




#ENTRADA: Carreras futuras a predecir (Sportium)
mysql -u root --password=datos1986 --execute="SELECT COUNT(*) as num_galgos_iniciales_SPORTIUM FROM datos_desa.tb_carrerasgalgos_semillasfuturas LIMIT 1\W;" 2>&1 1>>${PATH_LOG}






echo -e "FIN"





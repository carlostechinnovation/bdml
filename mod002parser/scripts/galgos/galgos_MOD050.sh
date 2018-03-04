#!/bin/bash

source "/root/git/bdml/mod002parser/scripts/galgos/funciones.sh"

TAG="${1}"

#### Limpiar LOG ###
rm -f $LOG_050


echo -e $(date +"%T")" Modulo 050 - PREDICCIÓN de carreras futuras: INICIO" 2>&1 1>>${LOG_050}
echo -e "MOD050 --> LOG = "${LOG_050}

########### Modelo predictivo REGRESION ###########








###################### MAIL ##########################
#cat "$PATH_INFORME_FINAL" | mail -s "GALGOS - Prediccion carreras futuras Sportium" carlosandresgarcia1986@gmail.com,fcacereslau@hotmail.com,luisandresgarcia@gmail.com

##################################################

echo -e $(date +"%T")" Modulo 050 - PREDICCIÓN de carreras futuras: FIN" 2>&1 1>>${LOG_050}





#!/bin/bash

source "/root/git/bdml/mod002parser/scripts/galgos/funciones.sh"


#Borrar log
rm -f ${LOG_011}


echo -e $(date +"%T")" Galgos-Modulo 011 - Limpieza: INICIO" 2>&1 1>>${LOG_011}
echo -e "MOD011 --> LOG = "${LOG_011}


##########################################

#Limpiar datos brutos de SPORTIUM y de Betbright, usando las mismas funciones.

##########################################

echo -e $(date +"%T")" Galgos-Modulo 011 - Limpieza: FIN" 2>&1 1>>${LOG_011}




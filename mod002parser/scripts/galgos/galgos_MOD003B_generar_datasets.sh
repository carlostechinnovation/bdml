#!/bin/bash

source "/root/git/bdml/mod002parser/scripts/galgos/funciones.sh"




########## MAIN #########################

#### Limpiar LOG ###
rm -f $LOG_DS

echo -e $(date +"%T")"Generador de DATASETS: INICIO" 2>&1 1>>${LOG_DS}

#filtro_galgos=""
#filtro_galgos="WHERE PO1.galgo_nombre IN (${filtro_galgos_nombres})"
filtro_galgos="${1}"

#sufijo="_pre"
#sufijo="_post"
sufijo="${2}"




echo -e $(date +"%T")"Generador de DATASETS (usanndo columnas elaboradas): FIN\n\n" 2>&1 1>>${LOG_DS}



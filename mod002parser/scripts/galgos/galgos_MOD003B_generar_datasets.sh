#!/bin/bash

source "/root/git/bdml/mod002parser/scripts/galgos/funciones.sh"




########## MAIN #########################

#### Limpiar LOG ###
rm -f $LOG_DS

echo -e $(date +"%T")"Generador de DATASETS: INICIO" 2>&1 1>>${LOG_DS}

#filtro_galgos=""
#filtro_galgos="WHERE PO1.galgo_nombre IN (${filtro_galgos_nombres})"
filtro_galgos="${1}"

#sufijo="pre"
#sufijo="post"
sufijo="${2}"


if [[ "${sufijo}" = "pre" ]]
then
  echo -e $(date +"%T")"Generando dataset PRE..."
  #Solo cogemos los galgos y carreras PASADAS (id_carrera es un valor grande, NO ES el inventado por mi)

else
  echo -e $(date +"%T")"Generando dataset POST..."
  #Solo cogemos los galgos y carreras FUTURAS (id_carrera es un valor pequeño, inventado por mi)
  
fi




echo -e $(date +"%T")"Generador de DATASETS (usanndo columnas elaboradas): FIN\n\n" 2>&1 1>>${LOG_DS}



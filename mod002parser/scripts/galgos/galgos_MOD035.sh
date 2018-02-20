#!/bin/bash

source "/root/git/bdml/mod002parser/scripts/galgos/funciones.sh"

#### Limpiar LOG ###
rm -f $LOG_DS

echo -e $(date +"%T")" Modulo 003C - Generador de TABLAS FILTRADAS Y DATASETS (ETIQUETADOS POR TAG)..." 2>&1 1>>${LOG_DS}


if [ "$#" -ne 4 ]; then
    echo " Numero de parametros incorrecto!!!" 2>&1 1>>${LOG_DS}
fi

filtro_carreras="${1}"
filtro_galgos="${2}"
filtro_cg="${3}"
sufijo="${4}"


####### BLOQUE POR TAG ##########
echo -e $(date +"%T")" TAG=${sufijo}" 2>&1 1>>${LOG_DS}

"/root/git/bdml/mod002parser/scripts/galgos/galgos_MOD036_filtradas.sh" "$filtro_carreras" "$filtro_galgos" "$filtro_cg" "${sufijo}"

"/root/git/bdml/mod002parser/scripts/galgos/galgos_MOD037_datasets.sh" "${sufijo}"
####################



echo -e $(date +"%T")"Modulo 003C - FIN\n\n" 2>&1 1>>${LOG_DS}






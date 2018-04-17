#!/bin/bash

source "/home/carloslinux/git/bdml/mod002parser/scripts/galgos/funciones.sh"

#### Limpiar LOG ###
rm -f $LOG_DS


echo -e "MOD035 --> LOG = "${LOG_DS}


if [ "$#" -ne 4 ]; then
    echo " Numero de parametros incorrecto!!!" 2>&1 1>>${LOG_DS}
fi

filtro_carreras="${1}"
filtro_galgos="${2}"
filtro_cg="${3}"
sufijo="${4}"


####### BLOQUE POR TAG ##########
echo -e $(date +"%T")" 035-TAG=${sufijo}" 2>&1 1>>${LOG_DS}

echo -e $(date +"%T")" | 035 | Filtradas y datasets (subgrupo: $sufijo) | INICIO" >>$LOG_070

"/home/carloslinux/git/bdml/mod002parser/scripts/galgos/galgos_MOD036_filtradas.sh" "${filtro_carreras}" "${filtro_galgos}" "${filtro_cg}" "${sufijo}"

"/home/carloslinux/git/bdml/mod002parser/scripts/galgos/galgos_MOD037_datasets.sh" "${sufijo}"
####################


echo -e $(date +"%T")" | 035 | Filtradas y datasets (subgrupos) | FIN" >>$LOG_070






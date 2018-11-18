#!/bin/bash

source "/home/carloslinux/git/bdml/mod002parser/scripts/galgos/funciones.sh"


echo -e "MOD035 --> LOG = "${LOG_DS}

################## PARAMETROS #################
if [ "$#" -ne 4 ]; then
    echo " Numero de parametros incorrecto!!!" 2>&1 1>>${LOG_DS}
fi

filtro_carreras="${1}"
filtro_galgos="${2}"
filtro_cg="${3}"
sufijo="${4}"

echo -e "########################################### 035 ###########################################" 2>&1 1>>${LOG_DS}
echo -e "035 Input - filtro_carreras=${filtro_carreras}" 2>&1 1>>${LOG_DS}
echo -e "035 Input - filtro_galgos=${filtro_galgos}" 2>&1 1>>${LOG_DS}
echo -e "035 Input - filtro_cg=${filtro_cg}" 2>&1 1>>${LOG_DS}
echo -e "035 Input - sufijo=${sufijo}" 2>&1 1>>${LOG_DS}


####### BLOQUE POR TAG ##########
echo -e $(date +"%T")" 035-TAG=${sufijo}" 2>&1 1>>${LOG_DS}

echo -e $(date +"%T")" | 035 | Filtradas y datasets (subgrupo: $sufijo) | INICIO" >>$LOG_070

"/home/carloslinux/git/bdml/mod002parser/scripts/galgos/galgos_MOD036_filtradas.sh" "${filtro_carreras}" "${filtro_galgos}" "${filtro_cg}" "${sufijo}"

"/home/carloslinux/git/bdml/mod002parser/scripts/galgos/galgos_MOD037_datasets.sh" "${sufijo}"



#################### AHORRAR ESPACIO EN DISCO #######
echo -e $(date +"%T")" Borrando tablas innecesarias (filtradas) de TAG=${sufijo}" 2>&1 1>>${LOG_DS}

mysql -t --execute="DROP TABLE datos_desa.tb_filtrada_carreras_${sufijo}" 2>&1 1>>${LOG_DS}
mysql -t --execute="DROP TABLE datos_desa.tb_filtrada_galgos_${sufijo}" 2>&1 1>>${LOG_DS}
mysql -t --execute="DROP TABLE datos_desa.tb_filtrada_carrerasgalgos_${sufijo}" 2>&1 1>>${LOG_DS}


echo -e $(date +"%T")" Borrando tablas innecesarias (filtradas) de TAG=${sufijo} --> OK" 2>&1 1>>${LOG_DS}
####################


echo -e $(date +"%T")" | 035 | Filtradas y datasets (subgrupos) | FIN" >>$LOG_070






#!/bin/bash

source "/root/git/bdml/mod002parser/scripts/galgos/funciones.sh"

#### Limpiar LOG ###
rm -f $LOG_DS

echo -e $(date +"%T")"Modulo 003C - Generador de TABLAS FILTRADAS Y DATASETS (ETIQUETADOS POR TAG)..." 2>&1 1>>${LOG_DS}


TAG="SUBGRUPO_X"


####### BLOQUE POR TAG ##########
echo -e $(date +"%T")" TAG=${TAG}" 2>&1 1>>${LOG_DS}

echo -e $(date +"%T")"Generando TABLAS FILTRADAS..." 2>&1 1>>${LOG_DS}
"/root/git/bdml/mod002parser/scripts/galgos/galgos_MOD003C_generar_tablas_filtradas.sh" "" "" "" "${TAG}"

#echo -e $(date +"%T")"Generando DATASETS..." 2>&1 1>>${LOG_DS}
"/root/git/bdml/mod002parser/scripts/galgos/galgos_MOD003C_generar_datasets.sh" "${TAG}"
####################



echo -e $(date +"%T")"Modulo 003C - FIN\n\n" 2>&1 1>>${LOG_DS}






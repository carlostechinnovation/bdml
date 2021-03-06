#!/bin/bash

source "/home/carloslinux/git/bdml/mod002parser/scripts/galgos/funciones.sh"

#### Limpiar LOG ###
rm -f $LOG_CE

echo -e $(date +"%T")" | 030 | Columnas elaboradas | INICIO" >>$LOG_070

echo -e "MOD030 --> LOG = "${LOG_CE}

"/home/carloslinux/git/bdml/mod002parser/scripts/galgos/galgos_MOD031_columnas_elaboradas.sh" "pre"


stats_completitud=$(cat "${LOG_CE_STATS}" | grep '_velocidad_con_going_norm')
echo -e "\nMETRICA de COMPLETITUD de los datos historicos --> (tabla datos_desa.tb_elaborada_carrerasgalgos_pre, campo _velocidad_con_going_norm ): ${stats_completitud}\n" >>$LOG_070
echo -e "MAX|MIN|AVG|STD|NO_NULOS|NULOS --> El ratio NULOS/No_nulos debe ser bajo.\n" >>$LOG_070


echo -e $(date +"%T")" | 030 | Columnas elaboradas | FIN" >>$LOG_070






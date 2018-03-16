#!/bin/bash

source "/root/git/bdml/mod002parser/scripts/galgos/funciones.sh"

#### Limpiar LOG ###
rm -f $LOG_CE

echo -e $(date +"%T")" | 030 | Columnas elaboradas | INICIO" >>$LOG_070

echo -e "MOD030 --> LOG = "${LOG_CE}

"/root/git/bdml/mod002parser/scripts/galgos/galgos_MOD031_columnas_elaboradas.sh" "pre"


echo -e $(date +"%T")" | 030 | Columnas elaboradas | FIN" >>$LOG_070






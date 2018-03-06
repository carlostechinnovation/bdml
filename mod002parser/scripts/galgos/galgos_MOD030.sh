#!/bin/bash

source "/root/git/bdml/mod002parser/scripts/galgos/funciones.sh"

#### Limpiar LOG ###
rm -f $LOG_CE

echo -e $(date +"%T")" Modulo 030 - Generador de COLUMNAS ELABORADAS..." 2>&1 1>>${LOG_CE}

echo -e "MOD030 --> LOG = "${LOG_CE}

"/root/git/bdml/mod002parser/scripts/galgos/galgos_MOD031_columnas_elaboradas.sh" "pre"


echo -e $(date +"%T")" Modulo 030 - FIN\n\n" 2>&1 1>>${LOG_CE}






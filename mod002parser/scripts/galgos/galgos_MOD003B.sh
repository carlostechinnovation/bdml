#!/bin/bash

source "/root/git/bdml/mod002parser/scripts/galgos/funciones.sh"

#### Limpiar LOG ###
rm -f $LOG_CE

echo -e $(date +"%T")"Modulo 003B - Generador de COLUMNAS ELABORADAS..." 2>&1 1>>${LOG_CE}

"/root/git/bdml/mod002parser/scripts/galgos/galgos_MOD003B_generar_columnas_elaboradas.sh" "" "pre"


echo -e $(date +"%T")"Modulo 003B - FIN\n\n" 2>&1 1>>${LOG_CE}






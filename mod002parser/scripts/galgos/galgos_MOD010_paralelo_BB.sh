#!/bin/bash

source "/root/git/bdml/mod002parser/scripts/galgos/funciones.sh"

echo -e $(date +"%T")" | 010_BB | Descarga datos brutos BB | INICIO" >>$LOG_070
obtenerFuturasBetbright
echo -e $(date +"%T")" | 010_BB | Descarga datos brutos BB | FIN" >>$LOG_070


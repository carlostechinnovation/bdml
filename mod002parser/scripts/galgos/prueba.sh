#!/bin/bash

source "/root/git/bdml/mod002parser/scripts/galgos/funciones.sh"



SUBGRUPO_GANADOR_LINEAS=$(cat "$SUBGRUPO_GANADOR_FILE" | wc -l)
if [[ "$SUBGRUPO_GANADOR_LINEAS" -ne "1" ]]
  then
    echo "ERROR AL CALCULAR SUBGRUPO_GANADOR. Revisar fichero ( $SUBGRUPO_GANADOR_FILE ). Salimos con error controlado."
    exit -1
fi

echo -e "sigue"


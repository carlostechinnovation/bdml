#!/bin/bash


if [ $# -eq 0 ]
  then
    echo "ERROR Parametros de entrada incorrectos. Debes indicar: anio"
    exit -1
fi

export anio=${1}


echo "Borramos todos los ficheros brutos que tuvieramos de ese anio=${anio}..."
rm -f "/home/carloslinux/Desktop/DATOS_BRUTO/bolsa/YF_${anio}_*"


empresas="/home/carloslinux/Desktop/CODIGOS/workspace_java/bdml/mod002parser/scripts/bolsa/empresas_yahoo_finance.in"


while read -r line
do
    empresa="$line"
    node /home/carloslinux/Desktop/CODIGOS/workspace_java/bdml/mod002parser/scripts/bolsa/MOD001A_yahoo_finance.js ${empresa} ${anio}
done < "$empresas"




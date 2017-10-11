#!/bin/bash


if [ $# -eq 0 ]
  then
    echo "ERROR Parametros de entrada incorrectos. Debes indicar: anio"
    exit -1
fi

export anio=${1}


filename="/home/carloslinux/Desktop/GIT_REPO_BDML/bdml/mod002parser/scripts/empresas_yahoo_finance.in"
while read -r line
do
    empresa="$line"
    node MOD001A_yahoo_finance.js ${empresa} ${anio}
done < "$filename"




#!/bin/bash



echo -e "Modulo 002A - Parsear datos"

PATH_DIR_IN="/home/carloslinux/Desktop/DATOS_BRUTO/"
PATH_DIR_OUT="/home/carloslinux/Desktop/DATOS_LIMPIO/"
PATH_JAR="/home/carloslinux/Desktop/GIT_REPO_BDML/bdml/mod002parser/target/mod002parser-jar-with-dependencies.jar"

TAG_BOE="BOE"
TAG_GF="GOOGLEFINANCE"
TAG_BM="BOLSAMADRID"
TAG_INE="INE"
TAG_DM="DATOSMACRO"
TAG_YF="YF"

FILE_SENTENCIAS_CREATE_TABLE=${PATH_DIR_OUT}"sentencias_create_table"


if [ $# -eq 0 ]
  then
    echo "ERROR Parametro de entrada vacio. Debes indicar el dia/anio que quieres procesar!"
    exit -1
fi

export PARAM1=${1}
echo  -e "Procesando dia/anio="${PARAM1}


###### YAHOO FINANCE #########
yf_prefijo_jons_anualizados=${TAG_YF}"_"${PARAM1}"_"
echo -e "Procesando JSONs de Yahoo Finance. Patron: "${yf_prefijo_jons_anualizados}
yf_temp_files="${PATH_DIR_IN}MOD002A_ficherosParaProcesarDeYahooFinance_"${PARAM1}
ls ${PATH_DIR_IN} | grep ${yf_prefijo_jons_anualizados} > ${yf_temp_files}

while read -r line
do
    yf_nombre_fichero=${PATH_DIR_IN}"$line"
    yf_empresa=$(echo ${yf_nombre_fichero} | cut -d"_" -f4)
    echo -e "JSON bruto: "${yf_nombre_fichero}

    path_fichero_limpio=${PATH_DIR_OUT}${TAG_YF}"_"${PARAM1}"_"${yf_empresa}
    echo -e "CSV: "${path_fichero_limpio}
    rm -f ${path_fichero_limpio}

    #procesar JSON hacia fichero CSV
    node "./MOD002A_yahoo_finance.js" ${yf_nombre_fichero} > ${path_fichero_limpio}

    mysql -u root --password=datos1986 --execute="DELETE FROM datos_desa.tb_yf01 WHERE ticker='${yf_empresa}' and (date >= ${PARAM1}0101 AND date <= ${PARAM1}1231); LOAD DATA LOCAL INFILE '${path_fichero_limpio}' INTO TABLE datos_desa.tb_yf01 FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n' IGNORE 0 LINES;" >&1
    
done < "${yf_temp_files}"



echo  -e "Modulo 002A - FIN"





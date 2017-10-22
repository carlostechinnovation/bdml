#!/bin/bash

set -x

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



######## PARAMETROS: DIA ##################################
if [ $# -eq 0 ]
  then
    echo "ERROR Parametro de entrada vacio. Debes indicar el anio que quieres procesar!"
    exit -1
fi

anio=${1}
echo 'ID de ejecucion parseado = $anio'




###### YAHOO FINANCE (Solo ejecuto los lunes, porque realmente son datos historicos) (se podria ejecutar cada dia...) #########

mysql -u root --password=datos1986 --execute="CREATE TABLE IF NOT EXISTS datos_desa.tb_yf01_previa (ticker varchar(10) DEFAULT NULL, date int(8) DEFAULT NULL, open decimal(14,4) DEFAULT NULL, high decimal(14,4) DEFAULT NULL, low decimal(14,4) DEFAULT NULL, close decimal(14,4) DEFAULT NULL, volumen bigint(20) DEFAULT NULL) ENGINE=InnoDB DEFAULT CHARSET=latin1;"

mysql -u root --password=datos1986 --execute="CREATE TABLE IF NOT EXISTS datos_desa.tb_yf01 (ticker varchar(10) DEFAULT NULL, date int(8) DEFAULT NULL, open decimal(14,4) DEFAULT NULL, gap_high_low decimal(14,4) DEFAULT NULL, gap_close_open decimal(14,4) DEFAULT NULL, gap_high_close decimal(14,4) DEFAULT NULL, gap_close_low decimal(14,4) DEFAULT NULL, volumen bigint(20) DEFAULT NULL) ENGINE=InnoDB DEFAULT CHARSET=latin1;"



  yf_prefijo_jons_anualizados=${TAG_YF}"_"${anio}"_"
  echo -e "Procesando JSONs de Yahoo Finance. Patron: "${yf_prefijo_jons_anualizados}
  yf_temp_files="${PATH_DIR_IN}MOD002A_ficherosParaProcesarDeYahooFinance_"${anio}
  ls ${PATH_DIR_IN} | grep ${yf_prefijo_jons_anualizados} > ${yf_temp_files}

  while read -r line
  do
    yf_nombre_fichero="$line"
    yf_empresa=$(echo ${yf_nombre_fichero} | cut -d"_" -f4)

    path_fichero_limpio=${PATH_DIR_OUT}${TAG_YF}"_"${anio}"_"${yf_empresa}
    echo -e "CSV limpio: "${path_fichero_limpio}
    rm -f ${path_fichero_limpio}

    #procesar JSON hacia fichero CSV
    node "./MOD002A_yahoo_finance.js" ${PATH_DIR_IN}${yf_nombre_fichero} > ${path_fichero_limpio}

    mysql -u root --password=datos1986 --execute="TRUNCATE TABLE datos_desa.tb_yf01_previa;"

    mysql -u root --password=datos1986 --execute="LOAD DATA LOCAL INFILE '${path_fichero_limpio}' INTO TABLE datos_desa.tb_yf01_previa FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n' IGNORE 0 LINES;" >&1

sleep 1s    

    echo -e "Insertando empresa: "${yf_empresa}
    mysql -u root --password=datos1986 --execute="DELETE FROM datos_desa.tb_yf01 WHERE ticker=${yf_empresa} AND date >=${anio}0000 AND date <=${anio}9999;" >&1

    mysql -u root --password=datos1986 --execute="INSERT INTO datos_desa.tb_yf01 (ticker, date, open, gap_high_low, gap_close_open, gap_high_close, gap_close_low, volumen) SELECT ticker, date, open, (high-low) AS gap_high_low, (close-open) AS gap_close_open, (high-close) AS gap_high_close, (close-low) AS gap_close_low, volumen FROM datos_desa.tb_yf01_previa WHERE date>=19950000 AND date<=20500000;" >&1
    
sleep 1s

  done < "${yf_temp_files}"



echo -e "Filas insertadas en tabla de YAHOO FINANCE: "
mysql -u root --password=datos1986 --execute="SELECT COUNT(*) as contador FROM datos_desa.tb_yf01 LIMIT 1;"



echo  -e "Modulo 002A - FIN"





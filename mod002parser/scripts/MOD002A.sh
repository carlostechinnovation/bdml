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

FILE_SENTENCIAS_CREATE_TABLE=${PATH_DIR_OUT}"sentencias_create_table"


if [ $# -eq 0 ]
  then
    echo "ERROR Parametro de entrada vacio. Debes indicar el dia que quieres procesar!"
    exit -1
fi

export TAG_DIA_DESCARGA=${1}
echo  -e "Procesando dia="${TAG_DIA_DESCARGA}


########### BASE DE DATOS: básico ######
#sudo service mysql status
#sudo service mysql start
#sudo service mysql stop

#mysql -u root --password=datos1986 --execute="CREATE DATABASE datos_desa;"
#mysql -u root --password=datos1986 --execute="CREATE DATABASE datos_pro;"


############ EJEMPLO: Load fichero CSV completo #####
#mysql -u root --password=datos1986 --execute="CREATE TABLE datos_desa.tb_gf01_borrar ( amd int, accion varchar(255), valor FLOAT(7,2));" >&1
#mysql -u root --password=datos1986 --execute="LOAD DATA LOCAL INFILE '../DATOS_LIMPIO/test.csv' INTO TABLE datos_desa.tb_gf01_borrar FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n' IGNORE 1 LINES;" >&1
#mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_gf01_borrar LIMIT 10;" >&1
#mysql -u root --password=datos1986 --execute="DROP TABLE datos_desa.tb_gf01_borrar;" >&1
###########################


#######################
echo -e "Crear tablas SQL (solo la primera vez)"
rm $FILE_SENTENCIAS_CREATE_TABLE
java -jar ${PATH_JAR} "02"
SENTENCIAS_CREATE_TABLE=$(cat ${FILE_SENTENCIAS_CREATE_TABLE})
echo -e ${SENTENCIAS_CREATE_TABLE}
mysql -u root --password=datos1986 --execute="$SENTENCIAS_CREATE_TABLE" >&1

######################
echo -e "Procesar un dia (borro posibles cargas de ese dia y las cargo)"
java -jar ${PATH_JAR} "03" ${TAG_DIA_DESCARGA}
mysql -u root --password=datos1986 --execute="DELETE FROM datos_desa.tb_gf01 WHERE tag_dia=${TAG_DIA_DESCARGA}; LOAD DATA LOCAL INFILE '../DATOS_LIMPIO/${TAG_DIA_DESCARGA}_GOOGLEFINANCE_01_OUT' INTO TABLE datos_desa.tb_gf01 FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n' IGNORE 1 LINES;" >&1



echo  -e "Modulo 002A - FIN"





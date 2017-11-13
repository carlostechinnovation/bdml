#!/bin/bash

PATH_LOG="/home/carloslinux/Desktop/LOGS/galgos_descarga_bruto.log"
PATH_SCRIPTS="/home/carloslinux/Desktop/CODIGOS/workspace_java/bdml/mod002parser/scripts/galgos/"

echo "Galgos-Modulo 001A - Obtener datos en BRUTO" 2>&1 1>>${PATH_LOG}

PATH_CARPETA="/home/carloslinux/Desktop/DATOS_BRUTO/galgos/"
PATH_JAR="/home/carloslinux/Desktop/CODIGOS/workspace_java/bdml/mod002parser/target/mod002parser-jar-with-dependencies.jar"
FILE_SENTENCIAS_CREATE_TABLE="/home/carloslinux/Desktop/DATOS_LIMPIO/galgos/galgos_sentencias_create_table"

PATH_LIMPIO_CARRERAS="/home/carloslinux/Desktop/DATOS_LIMPIO/galgos/tb_galgos_carreras_file"
PATH_LIMPIO_HISTORICO="/home/carloslinux/Desktop/DATOS_LIMPIO/galgos/tb_galgos_historico_file"
PATH_LIMPIO_CARRERAS_WARNINGS="/home/carloslinux/Desktop/DATOS_LIMPIO/galgos/warnings_carreras"
PATH_LIMPIO_HISTORICO_WARNINGS="/home/carloslinux/Desktop/DATOS_LIMPIO/galgos/warnings_historico"
PATH_LIMPIO_ESTADISTICAS="/home/carloslinux/Desktop/DATOS_LIMPIO/galgos/galgos_limpio_estadisticas"

##########################################
TAG_GBGB="GBGB"
echo ${TAG_GBGB}'...' 2>&1 1>>${PATH_LOG}


echo -e "Borrando ficheros antiguos..." >&1
rm -f $PATH_LIMPIO_CARRERAS
rm -f $PATH_LIMPIO_HISTORICO
rm -f $PATH_LIMPIO_CARRERAS_WARNINGS
rm -f $PATH_LIMPIO_HISTORICO_WARNINGS

########## CREATE TABLES #############

echo -e "Borrar tablas:"
mysql -u root --password=datos1986 --execute="DROP TABLE IF EXISTS datos_desa.tb_galgos_carreras;" >&1
mysql -u root --password=datos1986 --execute="DROP TABLE IF EXISTS datos_desa.tb_galgos_historico;" >&1
sleep 4s

echo -e "Crear tablas SQL"
rm $FILE_SENTENCIAS_CREATE_TABLE
java -jar ${PATH_JAR} "04" "$FILE_SENTENCIAS_CREATE_TABLE"
SENTENCIAS_CREATE_TABLE=$(cat ${FILE_SENTENCIAS_CREATE_TABLE})
mysql -u root --password=datos1986 --execute="$SENTENCIAS_CREATE_TABLE" >&1


#GBGB Descargar+parsear las carreras de ese dia concreto y descargar+parsear los detalles (galgos y sus historicos)
java -jar ${PATH_JAR} "05" "${PATH_CARPETA}galgos_${TAG_GBGB}_bruto" 



echo -e "Insertando datos..." >&1
mysql -u root --password=datos1986 --execute="LOAD DATA LOCAL INFILE '${PATH_LIMPIO_CARRERAS}' INTO TABLE datos_desa.tb_galgos_carreras FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n' IGNORE 0 LINES\W;" >$PATH_LIMPIO_CARRERAS_WARNINGS
sleep 4s
mysql -u root --password=datos1986 --execute="LOAD DATA LOCAL INFILE '${PATH_LIMPIO_HISTORICO}' INTO TABLE datos_desa.tb_galgos_historico FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n' IGNORE 0 LINES\W;" >$PATH_LIMPIO_HISTORICO_WARNINGS
sleep 4s


echo -e "Filas insertadas en carreras: " >&1
mysql -u root --password=datos1986 --execute="SELECT COUNT(*) as contador FROM datos_desa.tb_galgos_carreras LIMIT 1\W;" >&1
echo -e "Filas insertadas en historico de galgos: " >$PATH_LIMPIO_ESTADISTICAS
mysql -u root --password=datos1986 --execute="SELECT COUNT(*) as contador FROM datos_desa.tb_galgos_historico LIMIT 1\W;" >&1
echo -e "Numero de galgos diferentes de los que conocemos su historico: " >>$PATH_LIMPIO_ESTADISTICAS
mysql -u root --password=datos1986 --execute="SELECT COUNT(DISTINCT galgo_nombre) as num_galgos FROM datos_desa.tb_galgos_historico LIMIT 1\W;">>$PATH_LIMPIO_ESTADISTICAS


echo "Galgos-Modulo 001A - FIN" 2>&1 1>>${PATH_LOG}




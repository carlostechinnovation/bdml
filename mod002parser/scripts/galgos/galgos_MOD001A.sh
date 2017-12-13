#!/bin/bash

PATH_LOG="/home/carloslinux/Desktop/LOGS/galgos_descarga_bruto.log"
PATH_SCRIPTS="/home/carloslinux/Desktop/CODIGOS/workspace_java/bdml/mod002parser/scripts/galgos/"


echo -e "Path del log: ${PATH_LOG}">&1
rm -f ${PATH_LOG}

echo -e "Galgos-Modulo 001A - Obtener datos en BRUTO" 2>&1 1>>${PATH_LOG}

PATH_BRUTO="/home/carloslinux/Desktop/DATOS_BRUTO/galgos/"
PATH_LIMPIO="/home/carloslinux/Desktop/DATOS_LIMPIO/galgos/"
PATH_JAR="/home/carloslinux/Desktop/CODIGOS/workspace_java/bdml/mod002parser/target/mod002parser-jar-with-dependencies.jar"
FILE_SENTENCIAS_CREATE_TABLE="/home/carloslinux/Desktop/DATOS_LIMPIO/galgos/galgos_sentencias_create_table"

PATH_FILE_GALGOS_INICIALES="/home/carloslinux/Desktop/DATOS_LIMPIO/galgos/galgos_iniciales.txt"
PATH_FILE_GALGOS_INICIALES_FULL="/home/carloslinux/Desktop/DATOS_LIMPIO/galgos/galgos_iniciales.txt_full"
PATH_LIMPIO_CARRERAS="/home/carloslinux/Desktop/DATOS_LIMPIO/galgos/tb_galgos_carreras_file"
PATH_LIMPIO_POSICIONES="/home/carloslinux/Desktop/DATOS_LIMPIO/galgos/tb_galgos_posiciones_en_carreras_file"
PATH_LIMPIO_HISTORICO="/home/carloslinux/Desktop/DATOS_LIMPIO/galgos/tb_galgos_historico_file"
PATH_LIMPIO_AGREGADOS="/home/carloslinux/Desktop/DATOS_LIMPIO/galgos/tb_galgos_agregados_file"

PATH_LIMPIO_GALGOS_INICIALES_WARNINGS="/home/carloslinux/Desktop/DATOS_LIMPIO/galgos/warnings_galgos_iniciales"
PATH_LIMPIO_CARRERAS_WARNINGS="/home/carloslinux/Desktop/DATOS_LIMPIO/galgos/warnings_carreras"
PATH_LIMPIO_POSICIONES_WARNINGS="/home/carloslinux/Desktop/DATOS_LIMPIO/galgos/warnings_posiciones"
PATH_LIMPIO_HISTORICO_WARNINGS="/home/carloslinux/Desktop/DATOS_LIMPIO/galgos/warnings_historico"
PATH_LIMPIO_AGREGADOS_WARNINGS="/home/carloslinux/Desktop/DATOS_LIMPIO/galgos/warnings_agregados"

PATH_LIMPIO_ESTADISTICAS="/home/carloslinux/Desktop/DATOS_LIMPIO/galgos/galgos_limpio_estadisticas"

##########################################
TAG_GBGB="GBGB"
echo -e ${TAG_GBGB}'...' 2>&1 1>>${PATH_LOG}


echo -e "Borrando ficheros antiguos..." 2>&1 1>>${PATH_LOG}
rm -f "$PATH_BRUTO*"
rm -f "$PATH_LIMPIO*"

########## CREATE TABLES #############

echo -e "Borrar tablas:"
mysql -u root --password=datos1986 --execute="DROP TABLE IF EXISTS datos_desa.tb_galgos_carreragalgo\W;" 2>&1 1>>${PATH_LOG}
mysql -u root --password=datos1986 --execute="DROP TABLE IF EXISTS datos_desa.tb_galgos_carreras\W;" 2>&1 1>>${PATH_LOG}
mysql -u root --password=datos1986 --execute="DROP TABLE IF EXISTS datos_desa.tb_galgos_posiciones_en_carreras\W;" 2>&1 1>>${PATH_LOG}
mysql -u root --password=datos1986 --execute="DROP TABLE IF EXISTS datos_desa.tb_galgos_historico\W;" 2>&1 1>>${PATH_LOG}
mysql -u root --password=datos1986 --execute="DROP TABLE IF EXISTS datos_desa.tb_galgos_agregados\W;" 2>&1 1>>${PATH_LOG}
sleep 4s

echo -e "Crear tablas SQL"prefijoPathDatosBruto 2>&1 1>>${PATH_LOG}
rm $FILE_SENTENCIAS_CREATE_TABLE
java -jar ${PATH_JAR} "04" "$FILE_SENTENCIAS_CREATE_TABLE" 2>&1 1>>${PATH_LOG}
SENTENCIAS_CREATE_TABLE=$(cat ${FILE_SENTENCIAS_CREATE_TABLE})
mysql -u root --password=datos1986 --execute="$SENTENCIAS_CREATE_TABLE" 2>&1 1>>${PATH_LOG}



#SPORTIUM: Descarga de todas las carreras de hoy (FUTURAS) en las que PUEDO apostar

java -jar ${PATH_JAR} "07" "${PATH_BRUTO}semillas" "${PATH_FILE_GALGOS_INICIALES}" 2>&1 1>>${PATH_LOG}
echo -e "SPORTIUM Insertando galgos semilla..." 2>&1 1>>${PATH_LOG}
mysql -u root --password=datos1986 --execute="LOAD DATA LOCAL INFILE '${PATH_FILE_GALGOS_INICIALES_FULL}' INTO TABLE datos_desa.tb_galgos_carreragalgo FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n' IGNORE 0 LINES\W;" >$PATH_LIMPIO_GALGOS_INICIALES_WARNINGS
mysql -u root --password=datos1986 --execute="SELECT COUNT(*) as num_galgos_iniciales_SPORTIUM FROM datos_desa.tb_galgos_carreragalgo LIMIT 1\W;" 2>&1 1>>${PATH_LOG}



#GBGB Descarga de DATOS BRUTOS históricos (embuclándose) de todas las carreras en las que han corrido los galgos iniciales y en iteraciones derivadas
java -jar ${PATH_JAR} "05" "${PATH_BRUTO}galgos_${TAG_GBGB}_bruto" "${PATH_FILE_GALGOS_INICIALES}" 2>&1 1>>${PATH_LOG}


echo -e "Insertando datos..." 2>&1 1>>${PATH_LOG}
mysql -u root --password=datos1986 --execute="LOAD DATA LOCAL INFILE '${PATH_LIMPIO_CARRERAS}' INTO TABLE datos_desa.tb_galgos_carreras FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n' IGNORE 0 LINES\W;" >$PATH_LIMPIO_CARRERAS_WARNINGS
sleep 4s
mysql -u root --password=datos1986 --execute="LOAD DATA LOCAL INFILE '${PATH_LIMPIO_POSICIONES}' INTO TABLE datos_desa.tb_galgos_posiciones_en_carreras FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n' IGNORE 0 LINES\W;" >$PATH_LIMPIO_POSICIONES_WARNINGS
sleep 4s
mysql -u root --password=datos1986 --execute="LOAD DATA LOCAL INFILE '${PATH_LIMPIO_HISTORICO}' INTO TABLE datos_desa.tb_galgos_historico FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n' IGNORE 0 LINES\W;" >$PATH_LIMPIO_HISTORICO_WARNINGS
sleep 4s
mysql -u root --password=datos1986 --execute="LOAD DATA LOCAL INFILE '${PATH_LIMPIO_AGREGADOS}' INTO TABLE datos_desa.tb_galgos_agregados FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n' IGNORE 0 LINES\W;" >$PATH_LIMPIO_AGREGADOS_WARNINGS
sleep 4s


echo -e "Filas insertadas en carreras: " 2>&1 1>>${PATH_LOG}
mysql -u root --password=datos1986 --execute="SELECT COUNT(*) as num_carreras FROM datos_desa.tb_galgos_carreras LIMIT 1\W;" 2>&1 1>>${PATH_LOG}
echo -e "Filas insertadas en posiciones_en_carreras: " 2>&1 1>>${PATH_LOG}
mysql -u root --password=datos1986 --execute="SELECT COUNT(*) as num_posiciones FROM datos_desa.tb_galgos_posiciones_en_carreras LIMIT 1\W;" 2>&1 1>>${PATH_LOG}
echo -e "Filas insertadas en historico de galgos: " >$PATH_LIMPIO_ESTADISTICAS
mysql -u root --password=datos1986 --execute="SELECT COUNT(*) as num_historicos FROM datos_desa.tb_galgos_historico LIMIT 1\W;" 2>&1 1>>${PATH_LOG}
echo -e "Filas insertadas en historico de galgos: " >$PATH_LIMPIO_ESTADISTICAS
mysql -u root --password=datos1986 --execute="SELECT COUNT(*) as num_agregados FROM datos_desa.tb_galgos_agregados LIMIT 1\W;" 2>&1 1>>${PATH_LOG}

echo -e "Numero de galgos diferentes de los que conocemos su historico: " >>$PATH_LIMPIO_ESTADISTICAS
mysql -u root --password=datos1986 --execute="SELECT COUNT(DISTINCT galgo_nombre) as num_galgos_diferentes FROM datos_desa.tb_galgos_historico LIMIT 1\W;">>$PATH_LIMPIO_ESTADISTICAS

echo "Galgos-Modulo 001A - FIN" 2>&1 1>>${PATH_LOG}




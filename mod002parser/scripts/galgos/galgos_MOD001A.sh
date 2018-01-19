#!/bin/bash

source "/root/git/bdml/mod002parser/scripts/galgos/funciones.sh"

TAG_GBGB="GBGB"
PATH_SCRIPTS="/root/git/bdml/mod002parser/scripts/galgos/"

PATH_BRUTO="/home/carloslinux/Desktop/DATOS_BRUTO/galgos/"
PATH_LIMPIO="/home/carloslinux/Desktop/DATOS_LIMPIO/galgos/"
PATH_JAR="/root/git/bdml/mod002parser/target/mod002parser-jar-with-dependencies.jar"
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


echo -e "Path del log: ${LOG_DESCARGA_BRUTO}" 2>&1 1>>${LOG_DESCARGA_BRUTO}
rm -f ${LOG_DESCARGA_BRUTO}

echo -e "Galgos-Modulo 001A - Obtener datos en BRUTO" 2>&1 1>>${LOG_DESCARGA_BRUTO}

##########################################
echo -e "Borrando ficheros antiguos..." 2>&1 1>>${LOG_DESCARGA_BRUTO}
rm -f "$PATH_BRUTO/*"
rm -f "$PATH_LIMPIO/*"
rm -f "${PATH_FILE_GALGOS_INICIALES}"
rm -f "${PATH_FILE_GALGOS_INICIALES_FULL}"

##########################################
echo -e "Borrando tablas..." 2>&1 1>>${LOG_DESCARGA_BRUTO}

consultar "DROP TABLE IF EXISTS datos_desa.tb_carrerasgalgos_semillasfuturas\W;" "${LOG_DESCARGA_BRUTO}" "-tN"
consultar "DROP TABLE IF EXISTS datos_desa.tb_galgos_carreras\W;" "${LOG_DESCARGA_BRUTO}" "-tN"
consultar "DROP TABLE IF EXISTS datos_desa.tb_galgos_posiciones_en_carreras\W;" "${LOG_DESCARGA_BRUTO}" "-tN"
consultar "DROP TABLE IF EXISTS datos_desa.tb_galgos_historico\W;" "${LOG_DESCARGA_BRUTO}" "-tN"
consultar "DROP TABLE IF EXISTS datos_desa.tb_galgos_agregados\W;" "${LOG_DESCARGA_BRUTO}" "-tN"
sleep 4s

##########################################
echo -e "Generando fichero de SENTENCIAS SQL (varios CREATE TABLE) con prefijo="prefijoPathDatosBruto 2>&1 1>>${LOG_DESCARGA_BRUTO}

rm $FILE_SENTENCIAS_CREATE_TABLE
java -jar ${PATH_JAR} "GALGOS_01" "$FILE_SENTENCIAS_CREATE_TABLE" 2>&1 1>>${LOG_DESCARGA_BRUTO}
SENTENCIAS_CREATE_TABLE=$(cat ${FILE_SENTENCIAS_CREATE_TABLE})
consultar "$SENTENCIAS_CREATE_TABLE" "${LOG_DESCARGA_BRUTO}" "-tN"

##########################################
echo -e "SPORTIUM - Descargando todas las carreras FUTURAS en las que PUEDO apostar y sus galgos (semillas)..." 2>&1 1>>${LOG_DESCARGA_BRUTO}

java -jar ${PATH_JAR} "GALGOS_02" "${PATH_BRUTO}semillas" "${PATH_FILE_GALGOS_INICIALES}" 2>&1 1>>${LOG_DESCARGA_BRUTO}
consultar_sobreescribirsalida "LOAD DATA LOCAL INFILE '${PATH_FILE_GALGOS_INICIALES_FULL}' INTO TABLE datos_desa.tb_carrerasgalgos_semillasfuturas FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n' IGNORE 0 LINES\W;" "$PATH_LIMPIO_GALGOS_INICIALES_WARNINGS"
consultar "SELECT COUNT(*) as num_galgos_iniciales_SPORTIUM FROM datos_desa.tb_carrerasgalgos_semillasfuturas LIMIT 1\W;" "${LOG_DESCARGA_BRUTO}" "-t"


##########################################
echo -e "GBGB - Descarga de DATOS BRUTOS históricos (embuclándose) de todas las carreras en las que han corrido los galgos semilla y los de carreras derivadas..." 2>&1 1>>${LOG_DESCARGA_BRUTO}
java -jar ${PATH_JAR} "GALGOS_03" "${PATH_BRUTO}galgos_${TAG_GBGB}_bruto" "${PATH_FILE_GALGOS_INICIALES}" 2>&1 1>>${LOG_DESCARGA_BRUTO}

consultar_sobreescribirsalida "LOAD DATA LOCAL INFILE '${PATH_LIMPIO_CARRERAS}' INTO TABLE datos_desa.tb_galgos_carreras FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n' IGNORE 0 LINES\W;" "$PATH_LIMPIO_CARRERAS_WARNINGS"

consultar_sobreescribirsalida "LOAD DATA LOCAL INFILE '${PATH_LIMPIO_POSICIONES}' INTO TABLE datos_desa.tb_galgos_posiciones_en_carreras FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n' IGNORE 0 LINES\W;" "$PATH_LIMPIO_POSICIONES_WARNINGS"

consultar_sobreescribirsalida "LOAD DATA LOCAL INFILE '${PATH_LIMPIO_HISTORICO}' INTO TABLE datos_desa.tb_galgos_historico FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n' IGNORE 0 LINES\W;" "$PATH_LIMPIO_HISTORICO_WARNINGS"

consultar_sobreescribirsalida "LOAD DATA LOCAL INFILE '${PATH_LIMPIO_AGREGADOS}' INTO TABLE datos_desa.tb_galgos_agregados FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n' IGNORE 0 LINES\W;" "$PATH_LIMPIO_AGREGADOS_WARNINGS"


##########################################
echo -e "GBGB - Comprobando tablas de datos HISTORICOS recien creadas..." 2>&1 1>>${LOG_DESCARGA_BRUTO}

mostrar_tabla "CARRERAS" "datos_desa.tb_galgos_carreras" "${LOG_DESCARGA_BRUTO}"
mostrar_tabla "POSICIONES EN CARRERAS" "datos_desa.tb_galgos_posiciones_en_carreras" "${LOG_DESCARGA_BRUTO}"
mostrar_tabla "GALGOS HISTORICO" "datos_desa.tb_galgos_historico" "${LOG_DESCARGA_BRUTO}"
mostrar_tabla "GALGOS AGREGADO" "datos_desa.tb_galgos_agregados" "${LOG_DESCARGA_BRUTO}"

echo -e "\nNumero de galgos diferentes de los que conocemos su historico: " >>$PATH_LIMPIO_ESTADISTICAS
mysql -u root --password=datos1986 --execute="SELECT COUNT(DISTINCT galgo_nombre) as num_galgos_diferentes FROM datos_desa.tb_galgos_historico LIMIT 1\W;">>$PATH_LIMPIO_ESTADISTICAS

##########################################
echo -e "SEMILLAS - Metiendo filas artificiales con los datos conocidos de las semillas..." 2>&1 1>>${LOG_DESCARGA_BRUTO}

#Pendiente descargar dato "SP" si se conoce en ese instante

read -d '' CONSULTA_SEMILLAS_FILAS_ARTIFICIALES <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_carrerasgalgos_semillasfuturas_b;

CREATE TABLE datos_desa.tb_carrerasgalgos_semillasfuturas_b AS
SELECT DHE  
FROM ( SELECT CONCAT(dia,hora,estadio) AS DHE, dentro1.* FROM datos_desa.tb_carrerasgalgos_semillasfuturas dentro1) dentro2 
GROUP BY DHE 
ORDER BY DHE DESC;

SELECT * FROM datos_desa.tb_carrerasgalgos_semillasfuturas_b LIMIT 5;
SELECT count(*) as num_filas_b FROM datos_desa.tb_carrerasgalgos_semillasfuturas_b LIMIT 5;


DROP TABLE IF EXISTS datos_desa.tb_carrerasgalgos_semillasfuturas_c;

CREATE TABLE datos_desa.tb_carrerasgalgos_semillasfuturas_c AS
SELECT  
B.*,

CASE
  WHEN (B.DHE = @curDHE) THEN (@curRow := @curRow)
  ELSE (@curRow := @curRow + 1 )
END AS DHE_incr

FROM datos_desa.tb_carrerasgalgos_semillasfuturas_b B,
(SELECT @curRow := 0, @curDHE := '') R
ORDER BY DHE ASC;

SELECT * FROM datos_desa.tb_carrerasgalgos_semillasfuturas_c LIMIT 5;
SELECT count(*) as num_filas_c FROM datos_desa.tb_carrerasgalgos_semillasfuturas_c LIMIT 5;


DROP TABLE IF EXISTS datos_desa.tb_carrerasgalgos_semillasfuturas_d;

CREATE TABLE datos_desa.tb_carrerasgalgos_semillasfuturas_d AS
SELECT 
INICIAL.* , C.DHE_incr AS id_carrera_artificial
FROM ( SELECT CONCAT(dia,hora,estadio) AS DHE, dentro1.* FROM datos_desa.tb_carrerasgalgos_semillasfuturas dentro1) INICIAL
LEFT JOIN datos_desa.tb_carrerasgalgos_semillasfuturas_c C
ON (INICIAL.DHE=C.DHE)
;

SELECT * FROM datos_desa.tb_carrerasgalgos_semillasfuturas_d LIMIT 5;
SELECT count(*) as num_filas_d FROM datos_desa.tb_carrerasgalgos_semillasfuturas_d LIMIT 5;




set @min_id_carreras_artificiales=(select MIN(id_carrera_artificial) FROM datos_desa.tb_carrerasgalgos_semillasfuturas_d);
set @max_id_carreras_artificiales=(select MAX(id_carrera_artificial) FROM datos_desa.tb_carrerasgalgos_semillasfuturas_d);

DELETE FROM datos_desa.tb_galgos_carreras 
WHERE ( id_carrera >= @min_id_carreras_artificiales AND id_carrera <= @max_id_carreras_artificiales);


INSERT INTO datos_desa.tb_galgos_carreras
SELECT 
MAX(id_carrera_artificial) AS id_carrera, 
0 AS id_campeonato, 
MAX(estadio) AS track, 
NULL AS clase, 
CONVERT(SUBSTRING( CAST(MAX(dia) AS CHAR(8)), 1,4), UNSIGNED INTEGER) AS anio, 
CONVERT(SUBSTRING( CAST(MAX(dia) AS CHAR(8)), 5,2), UNSIGNED INTEGER) AS mes, 
CONVERT(SUBSTRING( CAST(MAX(dia) AS CHAR(8)), 7,2), UNSIGNED INTEGER) AS dia, 
CONVERT(SUBSTRING( CAST(MAX(hora) AS CHAR(4)), 1,2), UNSIGNED INTEGER)  AS hora, 
CONVERT(SUBSTRING( CAST(MAX(hora) AS CHAR(4)), 3,2), UNSIGNED INTEGER)  AS minuto, 
NULL AS distancia, 
count(*)  AS num_galgos,
NULL AS premio_primero, NULL AS premio_segundo, NULL AS premio_otros, NULL AS premio_total_carrera, NULL AS going_allowance_segundos, 
NULL AS fc_1, NULL AS fc_2, NULL AS fc_pounds, 
NULL AS tc_1, NULL AS tc_2, NULL AS tc_3, NULL AS tc_pounds
FROM datos_desa.tb_carrerasgalgos_semillasfuturas_d A
GROUP BY DHE;

SELECT count(*) FROM datos_desa.tb_galgos_carreras 
WHERE ( id_carrera >= @min_id_carreras_artificiales AND id_carrera <= @max_id_carreras_artificiales);

SELECT * FROM datos_desa.tb_galgos_carreras 
WHERE ( id_carrera >= @min_id_carreras_artificiales AND id_carrera <= @max_id_carreras_artificiales)
ORDER BY id_carrera ASC LIMIT 10;



DELETE FROM datos_desa.tb_galgos_posiciones_en_carreras 
WHERE ( id_carrera >= @min_id_carreras_artificiales AND id_carrera <= @max_id_carreras_artificiales);


INSERT INTO datos_desa.tb_galgos_posiciones_en_carreras
SELECT 
id_carrera_artificial AS id_carrera,
0 AS id_campeonato,
NULL AS posicion,
galgo_nombre AS galgo_nombre,
trap AS trap,
NULL AS sp,
NULL AS time_sec,
NULL AS time_distance,
NULL AS peso_galgo,
NULL AS entrenador_nombre,
NULL AS galgo_padre,
NULL AS galgo_madre,
NULL AS nacimiento,
NULL AS comment,
NULL AS edad_en_dias
FROM datos_desa.tb_carrerasgalgos_semillasfuturas_d;


SELECT count(*) FROM datos_desa.tb_galgos_posiciones_en_carreras 
WHERE ( id_carrera >= @min_id_carreras_artificiales AND id_carrera <= @max_id_carreras_artificiales);

SELECT * FROM datos_desa.tb_galgos_posiciones_en_carreras 
WHERE ( id_carrera >= @min_id_carreras_artificiales AND id_carrera <= @max_id_carreras_artificiales)
ORDER BY id_carrera ASC LIMIT 10;



DELETE FROM datos_desa.tb_galgos_historico 
WHERE ( id_carrera >= @min_id_carreras_artificiales AND id_carrera <= @max_id_carreras_artificiales);


INSERT INTO datos_desa.tb_galgos_historico
SELECT 
galgo_nombre,
NULL AS entrenador,
id_carrera_artificial AS id_carrera,
0 AS id_campeonato,
CONVERT(SUBSTRING( CAST(dia AS CHAR(8)), 1,4), UNSIGNED INTEGER) AS anio, 
CONVERT(SUBSTRING( CAST(dia AS CHAR(8)), 5,2), UNSIGNED INTEGER) AS mes, 
CONVERT(SUBSTRING( CAST(dia AS CHAR(8)), 7,2), UNSIGNED INTEGER) AS dia, 
NULL AS distancia,
trap AS trap,
NULL AS stmhcp,
NULL AS posicion,
NULL AS by_dato,
NULL AS galgo_primero_o_segundo,
estadio AS venue,
NULL AS remarks,
NULL AS win_time,
NULL AS going,
NULL AS sp,
NULL AS clase,
NULL AS calculated_time,
NULL AS velocidad_real,
NULL AS velocidad_con_going,
NULL AS scoring_remarks
FROM datos_desa.tb_carrerasgalgos_semillasfuturas_d;


SELECT count(*) FROM datos_desa.tb_galgos_historico 
WHERE ( id_carrera >= @min_id_carreras_artificiales AND id_carrera <= @max_id_carreras_artificiales);

SELECT * FROM datos_desa.tb_galgos_historico 
WHERE ( id_carrera >= @min_id_carreras_artificiales AND id_carrera <= @max_id_carreras_artificiales)
ORDER BY id_carrera ASC LIMIT 10;

EOF

#echo -e "$CONSULTA_SEMILLAS_FILAS_ARTIFICIALES" 2>&1 >&1
mysql -u root --password=datos1986 --execute="$CONSULTA_SEMILLAS_FILAS_ARTIFICIALES" >>$LOG_CE


##########################################

echo "Galgos-Modulo 001A - FIN" 2>&1 1>>${LOG_DESCARGA_BRUTO}




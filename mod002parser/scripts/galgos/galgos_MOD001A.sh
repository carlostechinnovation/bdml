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


echo -e $(date +"%T")" Path del log: ${LOG_DESCARGA_BRUTO}" 2>&1 1>>${LOG_DESCARGA_BRUTO}
rm -f ${LOG_DESCARGA_BRUTO}

echo -e $(date +"%T")" Galgos-Modulo 001A - Obtener datos en BRUTO" 2>&1 1>>${LOG_DESCARGA_BRUTO}

##########################################
echo -e $(date +"%T")" Borrando ficheros antiguos..." 2>&1 1>>${LOG_DESCARGA_BRUTO}
rm -f "$PATH_BRUTO/*"
rm -f "$PATH_LIMPIO/*"
rm -f "${PATH_FILE_GALGOS_INICIALES}"
rm -f "${PATH_FILE_GALGOS_INICIALES_FULL}"

##########################################
echo -e $(date +"%T")" Borrando tablas..." 2>&1 1>>${LOG_DESCARGA_BRUTO}

consultar "DROP TABLE IF EXISTS datos_desa.tb_carrerasgalgos_semillasfuturas\W;" "${LOG_DESCARGA_BRUTO}" "-tN"
consultar "DROP TABLE IF EXISTS datos_desa.tb_galgos_carreras\W;" "${LOG_DESCARGA_BRUTO}" "-tN"
consultar "DROP TABLE IF EXISTS datos_desa.tb_galgos_posiciones_en_carreras\W;" "${LOG_DESCARGA_BRUTO}" "-tN"
consultar "DROP TABLE IF EXISTS datos_desa.tb_galgos_historico\W;" "${LOG_DESCARGA_BRUTO}" "-tN"
consultar "DROP TABLE IF EXISTS datos_desa.tb_galgos_agregados\W;" "${LOG_DESCARGA_BRUTO}" "-tN"
sleep 4s

##########################################
echo -e $(date +"%T")" Generando fichero de SENTENCIAS SQL (varios CREATE TABLE) con prefijo="prefijoPathDatosBruto 2>&1 1>>${LOG_DESCARGA_BRUTO}

rm $FILE_SENTENCIAS_CREATE_TABLE
java -jar ${PATH_JAR} "GALGOS_01" "$FILE_SENTENCIAS_CREATE_TABLE" 2>&1 1>>${LOG_DESCARGA_BRUTO}
SENTENCIAS_CREATE_TABLE=$(cat ${FILE_SENTENCIAS_CREATE_TABLE})
consultar "$SENTENCIAS_CREATE_TABLE" "${LOG_DESCARGA_BRUTO}" "-tN"

##########################################
echo -e $(date +"%T")" SPORTIUM - Descargando todas las carreras FUTURAS en las que PUEDO apostar y sus galgos (semillas)..." 2>&1 1>>${LOG_DESCARGA_BRUTO}

java -jar ${PATH_JAR} "GALGOS_02" "${PATH_BRUTO}semillas" "${PATH_FILE_GALGOS_INICIALES}" 2>&1 1>>${LOG_DESCARGA_BRUTO}
consultar_sobreescribirsalida "LOAD DATA LOCAL INFILE '${PATH_FILE_GALGOS_INICIALES_FULL}' INTO TABLE datos_desa.tb_carrerasgalgos_semillasfuturas FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n' IGNORE 0 LINES\W;" "$PATH_LIMPIO_GALGOS_INICIALES_WARNINGS"
consultar "SELECT COUNT(*) as num_galgos_iniciales_SPORTIUM FROM datos_desa.tb_carrerasgalgos_semillasfuturas LIMIT 1\W;" "${LOG_DESCARGA_BRUTO}" "-t"


##########################################
echo -e $(date +"%T")" GBGB - Descarga de DATOS BRUTOS históricos (embuclándose) de todas las carreras en las que han corrido los galgos semilla y los de carreras derivadas..." 2>&1 1>>${LOG_DESCARGA_BRUTO}
#java -jar ${PATH_JAR} "GALGOS_03" "${PATH_BRUTO}galgos_${TAG_GBGB}_bruto" "${PATH_FILE_GALGOS_INICIALES}" 2>&1 1>>${LOG_DESCARGA_BRUTO}

consultar_sobreescribirsalida "LOAD DATA LOCAL INFILE '${PATH_LIMPIO_CARRERAS}' INTO TABLE datos_desa.tb_galgos_carreras FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n' IGNORE 0 LINES\W;" "$PATH_LIMPIO_CARRERAS_WARNINGS"

consultar_sobreescribirsalida "LOAD DATA LOCAL INFILE '${PATH_LIMPIO_POSICIONES}' INTO TABLE datos_desa.tb_galgos_posiciones_en_carreras FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n' IGNORE 0 LINES\W;" "$PATH_LIMPIO_POSICIONES_WARNINGS"

consultar_sobreescribirsalida "LOAD DATA LOCAL INFILE '${PATH_LIMPIO_HISTORICO}' INTO TABLE datos_desa.tb_galgos_historico FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n' IGNORE 0 LINES\W;" "$PATH_LIMPIO_HISTORICO_WARNINGS"

consultar_sobreescribirsalida "LOAD DATA LOCAL INFILE '${PATH_LIMPIO_AGREGADOS}' INTO TABLE datos_desa.tb_galgos_agregados FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n' IGNORE 0 LINES\W;" "$PATH_LIMPIO_AGREGADOS_WARNINGS"


##########################################
echo -e $(date +"%T")" GBGB - Comprobando tablas de datos HISTORICOS recien creadas..." 2>&1 1>>${LOG_DESCARGA_BRUTO}

mostrar_tabla "CARRERAS" "datos_desa.tb_galgos_carreras" "${LOG_DESCARGA_BRUTO}"
mostrar_tabla "POSICIONES EN CARRERAS" "datos_desa.tb_galgos_posiciones_en_carreras" "${LOG_DESCARGA_BRUTO}"
mostrar_tabla "GALGOS HISTORICO" "datos_desa.tb_galgos_historico" "${LOG_DESCARGA_BRUTO}"
mostrar_tabla "GALGOS AGREGADO" "datos_desa.tb_galgos_agregados" "${LOG_DESCARGA_BRUTO}"

echo -e $(date +"%T")"\nNumero de galgos diferentes de los que conocemos su historico: " >>$PATH_LIMPIO_ESTADISTICAS
mysql -u root --password=datos1986 --execute="SELECT COUNT(DISTINCT galgo_nombre) as num_galgos_diferentes FROM datos_desa.tb_galgos_historico LIMIT 1\W;">>$PATH_LIMPIO_ESTADISTICAS

##########################################
echo -e $(date +"%T")"SEMILLAS - Metiendo filas artificiales con los datos conocidos de las semillas..." 2>&1 1>>${LOG_DESCARGA_BRUTO}

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

#echo -e $(date +"%T")"$CONSULTA_SEMILLAS_FILAS_ARTIFICIALES" 2>&1 >&1
mysql -u root --password=datos1986 --execute="$CONSULTA_SEMILLAS_FILAS_ARTIFICIALES" >>$LOG_CE


##########################################
echo -e $(date +"%T")"NORMALIZACION NUMERICA - Normalizamos los campos NUMERICOS (que tenga sentido) de las tablas brutas iniciales (para que las tablas derivadas ya trabajen con datos normalizados)..." 2>&1 1>>${LOG_DESCARGA_BRUTO}

read -d '' CONSULTA_NORMALIZACIONES <<- EOF

set @min_hora=(select MIN(hora) FROM datos_desa.tb_galgos_carreras);
set @max_hora=(select MAX(hora) FROM datos_desa.tb_galgos_carreras);
set @min_distancia=(select MIN(distancia) FROM datos_desa.tb_galgos_carreras);
set @max_distancia=(select MAX(distancia) FROM datos_desa.tb_galgos_carreras);
set @min_num_galgos=(select MIN(num_galgos) FROM datos_desa.tb_galgos_carreras);
set @max_num_galgos=(select MAX(num_galgos) FROM datos_desa.tb_galgos_carreras);
set @min_premio_primero=(select MIN(premio_primero) FROM datos_desa.tb_galgos_carreras);
set @max_premio_primero=(select MAX(premio_primero) FROM datos_desa.tb_galgos_carreras);
set @min_premio_segundo=(select MIN(premio_segundo) FROM datos_desa.tb_galgos_carreras);
set @max_premio_segundo=(select MAX(premio_segundo) FROM datos_desa.tb_galgos_carreras);
set @min_premio_otros=(select MIN(premio_otros) FROM datos_desa.tb_galgos_carreras);
set @max_premio_otros=(select MAX(premio_otros) FROM datos_desa.tb_galgos_carreras);
set @min_premio_total_carrera=(select MIN(premio_total_carrera) FROM datos_desa.tb_galgos_carreras);
set @max_premio_total_carrera=(select MAX(premio_total_carrera) FROM datos_desa.tb_galgos_carreras);
set @min_going_allowance_segundos=(select MIN(going_allowance_segundos) FROM datos_desa.tb_galgos_carreras);
set @max_going_allowance_segundos=(select MAX(going_allowance_segundos) FROM datos_desa.tb_galgos_carreras);
set @min_fc_1=(select MIN(fc_1) FROM datos_desa.tb_galgos_carreras);
set @max_fc_1=(select MAX(fc_1) FROM datos_desa.tb_galgos_carreras);
set @min_fc_2=(select MIN(fc_2) FROM datos_desa.tb_galgos_carreras);
set @max_fc_2=(select MAX(fc_2) FROM datos_desa.tb_galgos_carreras);
set @min_fc_pounds=(select MIN(fc_pounds) FROM datos_desa.tb_galgos_carreras);
set @max_fc_pounds=(select MAX(fc_pounds) FROM datos_desa.tb_galgos_carreras);
set @min_tc_1=(select MIN(tc_1) FROM datos_desa.tb_galgos_carreras);
set @max_tc_1=(select MAX(tc_1) FROM datos_desa.tb_galgos_carreras);
set @min_tc_2=(select MIN(tc_2) FROM datos_desa.tb_galgos_carreras);
set @max_tc_2=(select MAX(tc_2) FROM datos_desa.tb_galgos_carreras);
set @min_tc_3=(select MIN(tc_3) FROM datos_desa.tb_galgos_carreras);
set @max_tc_3=(select MAX(tc_3) FROM datos_desa.tb_galgos_carreras);

DROP TABLE IF EXISTS datos_desa.tb_galgos_carreras_norm;

CREATE TABLE datos_desa.tb_galgos_carreras_norm AS 
SELECT 
id_carrera,
id_campeonato,
track,
clase,
anio,
mes, CASE WHEN (mes <=7) THEN (-1/6 + mes/6) WHEN (mes >7) THEN (5/12 - 5*mes/144) ELSE 0.5 END AS mes_norm,
dia,
hora, (hora - @min_hora)/(@max_hora - @min_hora) AS hora_norm,
minuto,
distancia, (distancia - @min_distancia)/(@max_distancia - @min_distancia) AS distancia_norm,
num_galgos, (num_galgos - @min_num_galgos)/(@max_num_galgos - @min_num_galgos) AS num_galgos_norm,
premio_primero, (premio_primero - @min_premio_primero)/(@max_premio_primero - @min_premio_primero) AS premio_primero_norm,
premio_segundo, (premio_segundo - @min_premio_segundo)/(@max_premio_segundo - @min_premio_segundo) AS premio_segundo_norm,
premio_otros, (premio_otros - @min_premio_otros)/(@max_premio_otros - @min_premio_otros) AS premio_otros_norm,
premio_total_carrera, (premio_total_carrera - @min_premio_total_carrera)/(@max_premio_total_carrera - @min_premio_total_carrera) AS premio_total_carrera_norm,
going_allowance_segundos, (going_allowance_segundos - @min_going_allowance_segundos)/(@max_going_allowance_segundos - @min_going_allowance_segundos) AS going_allowance_segundos_norm,
fc_1, (fc_1 - @min_fc_1)/(@max_fc_1 - @min_fc_1) AS fc_1_norm,
fc_2, (fc_2 - @min_fc_2)/(@max_fc_2 - @min_fc_2) AS fc_2_norm,
fc_pounds, (fc_pounds - @min_fc_pounds)/(@max_fc_pounds - @min_fc_pounds) AS fc_pounds_norm,
tc_1, (tc_1 - @min_tc_1)/(@max_tc_1 - @min_tc_1) AS tc_1_norm,
tc_2, (tc_2 - @min_tc_2)/(@max_tc_2 - @min_tc_2) AS tc_2_norm,
tc_3, (tc_3 - @min_tc_3)/(@max_tc_3 - @min_tc_3) AS tc_3_norm,
tc_pounds, (tc_pounds - @min_tc_pounds)/(@max_tc_pounds - @min_tc_pounds) AS tc_pounds_norm
FROM datos_desa.tb_galgos_carreras;

SELECT * FROM datos_desa.tb_galgos_carreras_norm LIMIT 5;
SELECT count(*) as num_carreras_norm FROM datos_desa.tb_galgos_carreras_norm LIMIT 5;




set @min_posicion=(select MIN(posicion) FROM datos_desa.tb_galgos_posiciones_en_carreras);
set @max_posicion=(select MAX(posicion) FROM datos_desa.tb_galgos_posiciones_en_carreras);
set @min_trap=(select MIN(trap) FROM datos_desa.tb_galgos_posiciones_en_carreras);
set @max_trap=(select MAX(trap) FROM datos_desa.tb_galgos_posiciones_en_carreras);
set @min_sp=(select MIN(sp) FROM datos_desa.tb_galgos_posiciones_en_carreras);
set @max_sp=(select MAX(sp) FROM datos_desa.tb_galgos_posiciones_en_carreras);
set @min_time_sec=(select MIN(time_sec) FROM datos_desa.tb_galgos_posiciones_en_carreras);
set @max_time_sec=(select MAX(time_sec) FROM datos_desa.tb_galgos_posiciones_en_carreras);
set @min_time_distance=(select MIN(time_distance) FROM datos_desa.tb_galgos_posiciones_en_carreras);
set @max_time_distance=(select MAX(time_distance) FROM datos_desa.tb_galgos_posiciones_en_carreras);
set @min_peso_galgo=(select MIN(peso_galgo) FROM datos_desa.tb_galgos_posiciones_en_carreras);
set @max_peso_galgo=(select MAX(peso_galgo) FROM datos_desa.tb_galgos_posiciones_en_carreras);
set @min_nacimiento=(select MIN(nacimiento) FROM datos_desa.tb_galgos_posiciones_en_carreras);
set @max_nacimiento=(select MAX(nacimiento) FROM datos_desa.tb_galgos_posiciones_en_carreras);
set @min_edad_en_dias=(select MIN(edad_en_dias) FROM datos_desa.tb_galgos_posiciones_en_carreras);
set @max_edad_en_dias=(select MAX(edad_en_dias) FROM datos_desa.tb_galgos_posiciones_en_carreras);


DROP TABLE IF EXISTS datos_desa.tb_galgos_posiciones_en_carreras_norm;

CREATE TABLE datos_desa.tb_galgos_posiciones_en_carreras_norm AS 
SELECT 
id_carrera,
id_campeonato,
posicion, (posicion - @min_posicion)/(@max_posicion - @min_posicion) AS posicion_norm,
galgo_nombre,
trap, (trap - @min_trap)/(@max_trap - @min_trap) AS trap_norm,
sp, (sp - @min_sp)/(@max_sp - @min_sp) AS sp_norm,
time_sec, (time_sec - @min_time_sec)/(@max_time_sec - @min_time_sec) AS time_sec_norm,
time_distance, (time_distance - @min_time_distance)/(@max_time_distance - @min_time_distance) AS time_distance_norm,
peso_galgo, (peso_galgo - @min_peso_galgo)/(@max_peso_galgo - @min_peso_galgo) AS peso_galgo_norm,
entrenador_nombre,
galgo_padre,
galgo_madre,
nacimiento,
comment,
edad_en_dias, (edad_en_dias - @min_edad_en_dias)/(@max_edad_en_dias - @min_edad_en_dias) AS edad_en_dias_norm

FROM datos_desa.tb_galgos_posiciones_en_carreras;

SELECT * FROM datos_desa.tb_galgos_posiciones_en_carreras_norm LIMIT 5;
SELECT count(*) as num_posiciones_en_carreras_norm FROM datos_desa.tb_galgos_posiciones_en_carreras_norm LIMIT 5;


set @min_distancia=(select MIN(distancia) FROM datos_desa.tb_galgos_historico);
set @max_distancia=(select MAX(distancia) FROM datos_desa.tb_galgos_historico);
set @min_trap=(select MIN(trap) FROM datos_desa.tb_galgos_historico);
set @max_trap=(select MAX(trap) FROM datos_desa.tb_galgos_historico);
set @min_stmhcp=(select MIN(stmhcp) FROM datos_desa.tb_galgos_historico);
set @max_stmhcp=(select MAX(stmhcp) FROM datos_desa.tb_galgos_historico);
set @min_posicion=(select MIN(posicion) FROM datos_desa.tb_galgos_historico);
set @max_posicion=(select MAX(posicion) FROM datos_desa.tb_galgos_historico);
set @min_win_time=(select MIN(win_time) FROM datos_desa.tb_galgos_historico);
set @max_win_time=(select MAX(win_time) FROM datos_desa.tb_galgos_historico);
set @min_sp=(select MIN(sp) FROM datos_desa.tb_galgos_historico);
set @max_sp=(select MAX(sp) FROM datos_desa.tb_galgos_historico);
set @min_calculated_time=(select MIN(calculated_time) FROM datos_desa.tb_galgos_historico);
set @max_calculated_time=(select MAX(calculated_time) FROM datos_desa.tb_galgos_historico);
set @min_velocidad_real=(select MIN(velocidad_real) FROM datos_desa.tb_galgos_historico);
set @max_velocidad_real=(select MAX(velocidad_real) FROM datos_desa.tb_galgos_historico);
set @min_velocidad_con_going=(select MIN(velocidad_con_going) FROM datos_desa.tb_galgos_historico);
set @max_velocidad_con_going=(select MAX(velocidad_con_going) FROM datos_desa.tb_galgos_historico);


DROP TABLE IF EXISTS datos_desa.tb_galgos_historico_norm;

CREATE TABLE datos_desa.tb_galgos_historico_norm AS 
SELECT 
galgo_nombre, entrenador, id_carrera, id_campeonato, anio,
mes, CASE WHEN (mes <=7) THEN (-1/6 + mes/6) WHEN (mes >7) THEN (5/12 - 5*mes/144) ELSE 0.5 END AS mes_norm,
dia,
distancia, (distancia - @min_distancia)/(@max_distancia - @min_distancia) AS distancia_norm,
trap, (trap - @min_trap)/(@max_trap - @min_trap) AS trap_norm,
stmhcp, (stmhcp - @min_stmhcp)/(@max_stmhcp - @min_stmhcp) AS stmhcp_norm,
posicion, (posicion - @min_posicion)/(@max_posicion - @min_posicion) AS posicion_norm,
by_dato,
galgo_primero_o_segundo,
venue,
remarks,
win_time, (win_time - @min_win_time)/(@max_win_time - @min_win_time) AS win_time_norm,
going,
sp, (sp - @min_sp)/(@max_sp - @min_sp) AS sp_norm,
clase,
calculated_time, (calculated_time - @min_calculated_time)/(@max_calculated_time - @min_calculated_time) AS calculated_time_norm,
velocidad_real, (velocidad_real - @min_velocidad_real)/(@max_velocidad_real - @min_velocidad_real) AS velocidad_real_norm,
velocidad_con_going, (velocidad_con_going - @min_velocidad_con_going)/(@max_velocidad_con_going - @min_velocidad_con_going) AS velocidad_con_going_norm,
scoring_remarks

FROM datos_desa.tb_galgos_historico;

ALTER TABLE datos_desa.tb_galgos_historico_norm ADD INDEX tb_galgos_historico_norm_idx(id_carrera, galgo_nombre);

SELECT * FROM datos_desa.tb_galgos_historico_norm LIMIT 5;
SELECT count(*) as num_XX_norm FROM datos_desa.tb_galgos_historico_norm LIMIT 5;


set @min_vel_real_cortas_mediana=(select MIN(vel_real_cortas_mediana) FROM datos_desa.tb_galgos_agregados);
set @max_vel_real_cortas_mediana=(select MAX(vel_real_cortas_mediana) FROM datos_desa.tb_galgos_agregados);
set @min_vel_real_cortas_max=(select MIN(vel_real_cortas_max) FROM datos_desa.tb_galgos_agregados);
set @max_vel_real_cortas_max=(select MAX(vel_real_cortas_max) FROM datos_desa.tb_galgos_agregados);
set @min_vel_going_cortas_mediana=(select MIN(vel_going_cortas_mediana) FROM datos_desa.tb_galgos_agregados);
set @max_vel_going_cortas_mediana=(select MAX(vel_going_cortas_mediana) FROM datos_desa.tb_galgos_agregados);
set @min_vel_going_cortas_max=(select MIN(vel_going_cortas_max) FROM datos_desa.tb_galgos_agregados);
set @max_vel_going_cortas_max=(select MAX(vel_going_cortas_max) FROM datos_desa.tb_galgos_agregados);
set @min_vel_real_longmedias_mediana=(select MIN(vel_real_longmedias_mediana) FROM datos_desa.tb_galgos_agregados);
set @max_vel_real_longmedias_mediana=(select MAX(vel_real_longmedias_mediana) FROM datos_desa.tb_galgos_agregados);
set @min_vel_real_longmedias_max=(select MIN(vel_real_longmedias_max) FROM datos_desa.tb_galgos_agregados);
set @max_vel_real_longmedias_max=(select MAX(vel_real_longmedias_max) FROM datos_desa.tb_galgos_agregados);
set @min_vel_going_longmedias_mediana=(select MIN(vel_going_longmedias_mediana) FROM datos_desa.tb_galgos_agregados);
set @max_vel_going_longmedias_mediana=(select MAX(vel_going_longmedias_mediana) FROM datos_desa.tb_galgos_agregados);
set @min_vel_going_longmedias_max=(select MIN(vel_going_longmedias_max) FROM datos_desa.tb_galgos_agregados);
set @max_vel_going_longmedias_max=(select MAX(vel_going_longmedias_max) FROM datos_desa.tb_galgos_agregados);
set @min_vel_real_largas_mediana=(select MIN(vel_real_largas_mediana) FROM datos_desa.tb_galgos_agregados);
set @max_vel_real_largas_mediana=(select MAX(vel_real_largas_mediana) FROM datos_desa.tb_galgos_agregados);
set @min_vel_real_largas_max=(select MIN(vel_real_largas_max) FROM datos_desa.tb_galgos_agregados);
set @max_vel_real_largas_max=(select MAX(vel_real_largas_max) FROM datos_desa.tb_galgos_agregados);
set @min_vel_going_largas_mediana=(select MIN(vel_going_largas_mediana) FROM datos_desa.tb_galgos_agregados);
set @max_vel_going_largas_mediana=(select MAX(vel_going_largas_mediana) FROM datos_desa.tb_galgos_agregados);
set @min_vel_going_largas_max=(select MIN(vel_going_largas_max) FROM datos_desa.tb_galgos_agregados);
set @max_vel_going_largas_max=(select MAX(vel_going_largas_max) FROM datos_desa.tb_galgos_agregados);


DROP TABLE IF EXISTS datos_desa.tb_galgos_agregados_norm;

CREATE TABLE datos_desa.tb_galgos_agregados_norm AS 
SELECT 
galgo_nombre,
vel_real_cortas_mediana, (vel_real_cortas_mediana - @min_vel_real_cortas_mediana)/(@max_vel_real_cortas_mediana - @min_vel_real_cortas_mediana) AS vel_real_cortas_mediana_norm,
vel_real_cortas_max, (vel_real_cortas_max - @min_vel_real_cortas_max)/(@max_vel_real_cortas_max - @min_vel_real_cortas_max) AS vel_real_cortas_max_norm,
vel_going_cortas_mediana, (vel_going_cortas_mediana - @min_vel_going_cortas_mediana)/(@max_vel_going_cortas_mediana - @min_vel_going_cortas_mediana) AS vel_going_cortas_mediana_norm,
vel_going_cortas_max, (vel_going_cortas_max - @min_vel_going_cortas_max)/(@max_vel_going_cortas_max - @min_vel_going_cortas_max) AS vel_going_cortas_max_norm,
vel_real_longmedias_mediana, (vel_real_longmedias_mediana - @min_vel_real_longmedias_mediana)/(@max_vel_real_longmedias_mediana - @min_vel_real_longmedias_mediana) AS vel_real_longmedias_mediana_norm,
vel_real_longmedias_max, (vel_real_longmedias_max - @min_vel_real_longmedias_max)/(@max_vel_real_longmedias_max - @min_vel_real_longmedias_max) AS vel_real_longmedias_max_norm,
vel_going_longmedias_mediana, (vel_going_longmedias_mediana - @min_vel_going_longmedias_mediana)/(@max_vel_going_longmedias_mediana - @min_vel_going_longmedias_mediana) AS vel_going_longmedias_mediana_norm,
vel_going_longmedias_max, (vel_going_longmedias_max - @min_vel_going_longmedias_max)/(@max_vel_going_longmedias_max - @min_vel_going_longmedias_max) AS vel_going_longmedias_max_norm,
vel_real_largas_mediana, (vel_real_largas_mediana - @min_vel_real_largas_mediana)/(@max_vel_real_largas_mediana - @min_vel_real_largas_mediana) AS vel_real_largas_mediana_norm,
vel_real_largas_max, (vel_real_largas_max - @min_vel_real_largas_max)/(@max_vel_real_largas_max - @min_vel_real_largas_max) AS vel_real_largas_max_norm,
vel_going_largas_mediana, (vel_going_largas_mediana - @min_vel_going_largas_mediana)/(@max_vel_going_largas_mediana - @min_vel_going_largas_mediana) AS vel_going_largas_mediana_norm,
vel_going_largas_max, (vel_going_largas_max - @min_vel_going_largas_max)/(@max_vel_going_largas_max - @min_vel_going_largas_max) AS vel_going_largas_max_norm

FROM datos_desa.tb_galgos_agregados;

SELECT * FROM datos_desa.tb_galgos_agregados_norm LIMIT 5;
SELECT count(*) as num_galgos_agregados_norm FROM datos_desa.tb_galgos_agregados_norm LIMIT 5;

EOF

#echo -e $(date +"%T")"$CONSULTA_NORMALIZACIONES" 2>&1 >&1
mysql -u root --password=datos1986 --execute="$CONSULTA_NORMALIZACIONES" >>$LOG_CE


##########################################

echo -e $(date +"%T")"Galgos-Modulo 001A - FIN" 2>&1 1>>${LOG_DESCARGA_BRUTO}




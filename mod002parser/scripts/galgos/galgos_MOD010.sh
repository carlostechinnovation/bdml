#!/bin/bash

source "/root/git/bdml/mod002parser/scripts/galgos/funciones.sh"

TAG_GBGB="GBGB"

FILE_SENTENCIAS_CREATE_TABLE="/home/carloslinux/Desktop/DATOS_LIMPIO/galgos/galgos_sentencias_create_table"

PATH_FILE_GALGOS_INICIALES="/home/carloslinux/Desktop/DATOS_LIMPIO/galgos/galgos_iniciales.txt"
PATH_FILE_GALGOS_INICIALES_FULL="${PATH_FILE_GALGOS_INICIALES}_full"

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


echo -e $(date +"%T")" Galgos-Modulo 010 - Obtener datos en BRUTO" 2>&1 1>>${LOG_DESCARGA_BRUTO}
echo -e "MOD010 --> LOG = "${LOG_DESCARGA_BRUTO}

##########################################
echo -e $(date +"%T")" Borrando ficheros antiguos..." 2>&1 1>>${LOG_DESCARGA_BRUTO}
rm -f "$PATH_BRUTO*"
rm -f "$PATH_LIMPIO*"
rm -f "${PATH_FILE_GALGOS_INICIALES}"
rm -f "${PATH_FILE_GALGOS_INICIALES_FULL}"


##########################################
echo -e $(date +"%T")" Borrando tablas..." 2>&1 1>>${LOG_DESCARGA_BRUTO}

consultar "DROP TABLE IF EXISTS datos_desa.tb_cg_semillas_sportium\W;" "${LOG_DESCARGA_BRUTO}" "-tN"

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




#################### FUTURAS - SPORTIUM ######################
echo -e $(date +"%T")" Descargando todas las carreras FUTURAS en las que PUEDO apostar y sus galgos (semillas)..." 2>&1 1>>${LOG_DESCARGA_BRUTO}


java -jar ${PATH_JAR} "GALGOS_02_SPORTIUM" "${PATH_BRUTO}semillas_sportium" "${PATH_FILE_GALGOS_INICIALES}" 2>&1 1>>${LOG_DESCARGA_BRUTO}
consultar_sobreescribirsalida "TRUNCATE TABLE datos_desa.tb_cg_semillas_sportium\W;" "$PATH_LIMPIO_GALGOS_INICIALES_WARNINGS"
consultar_sobreescribirsalida "LOAD DATA LOCAL INFILE '${PATH_FILE_GALGOS_INICIALES_FULL}' INTO TABLE datos_desa.tb_cg_semillas_sportium FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n' IGNORE 0 LINES\W;" "$PATH_LIMPIO_GALGOS_INICIALES_WARNINGS"
consultar "SELECT COUNT(*) as num_galgos_iniciales FROM datos_desa.tb_cg_semillas_sportium LIMIT 1\W;" "${LOG_DESCARGA_BRUTO}" "-t"




###################### FUTURAS - SPORTIUM - DETALLE ####################
echo -e $(date +"%T")" GBGB - Descarga de DATOS BRUTOS históricos (embuclándose) de todas las carreras en las que han corrido los galgos semilla y los de carreras derivadas..." 2>&1 1>>${LOG_DESCARGA_BRUTO}
java -jar ${PATH_JAR} "GALGOS_03" "${PATH_BRUTO}galgos_${TAG_GBGB}_bruto" "${PATH_FILE_GALGOS_INICIALES}" 2>&1 1>>${LOG_DESCARGA_BRUTO}


consultar_sobreescribirsalida "TRUNCATE TABLE datos_desa.tb_galgos_carreras\W;" "$PATH_LIMPIO_GALGOS_INICIALES_WARNINGS"
consultar_sobreescribirsalida "LOAD DATA LOCAL INFILE '${PATH_LIMPIO_CARRERAS}' INTO TABLE datos_desa.tb_galgos_carreras FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n' IGNORE 0 LINES\W;" "$PATH_LIMPIO_CARRERAS_WARNINGS"


consultar_sobreescribirsalida "TRUNCATE TABLE datos_desa.tb_galgos_posiciones_en_carreras\W;" "$PATH_LIMPIO_GALGOS_INICIALES_WARNINGS"
consultar_sobreescribirsalida "LOAD DATA LOCAL INFILE '${PATH_LIMPIO_POSICIONES}' INTO TABLE datos_desa.tb_galgos_posiciones_en_carreras FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n' IGNORE 0 LINES\W;" "$PATH_LIMPIO_POSICIONES_WARNINGS"


consultar_sobreescribirsalida "TRUNCATE TABLE datos_desa.tb_galgos_historico\W;" "$PATH_LIMPIO_GALGOS_INICIALES_WARNINGS"
consultar_sobreescribirsalida "LOAD DATA LOCAL INFILE '${PATH_LIMPIO_HISTORICO}' INTO TABLE datos_desa.tb_galgos_historico FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n' IGNORE 0 LINES\W;" "$PATH_LIMPIO_HISTORICO_WARNINGS"


consultar_sobreescribirsalida "TRUNCATE TABLE datos_desa.tb_galgos_agregados\W;" "$PATH_LIMPIO_GALGOS_INICIALES_WARNINGS"
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
echo -e "\n\n\n"$(date +"%T")"SEMILLAS - Metiendo filas artificiales con los datos conocidos de las semillas..." 2>&1 1>>${LOG_DESCARGA_BRUTO}


#Pendiente descargar dato "SP" si se conoce en ese instante


read -d '' CONSULTA_SEMILLAS_FILAS_ARTIFICIALES <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_cg_semillas_sportium_b;

CREATE TABLE datos_desa.tb_cg_semillas_sportium_b AS
SELECT DHE  
FROM ( SELECT CONCAT(dia,hora,estadio) AS DHE, dentro1.* FROM datos_desa.tb_cg_semillas_sportium dentro1) dentro2 
GROUP BY DHE 
ORDER BY DHE DESC;

SELECT * FROM datos_desa.tb_cg_semillas_sportium_b LIMIT 5;
SELECT count(*) as num_filas_b FROM datos_desa.tb_cg_semillas_sportium_b LIMIT 5;


DROP TABLE IF EXISTS datos_desa.tb_cg_semillas_sportium_c;

CREATE TABLE datos_desa.tb_cg_semillas_sportium_c AS
SELECT  
B.*,

CASE
  WHEN (B.DHE = @curDHE) THEN (@curRow := @curRow)
  ELSE (@curRow := @curRow + 1 )
END AS DHE_incr

FROM datos_desa.tb_cg_semillas_sportium_b B,
(SELECT @curRow := 0, @curDHE := '') R
ORDER BY DHE ASC;

SELECT * FROM datos_desa.tb_cg_semillas_sportium_c LIMIT 5;
SELECT count(*) as num_filas_c FROM datos_desa.tb_cg_semillas_sportium_c LIMIT 5;


DROP TABLE IF EXISTS datos_desa.tb_cg_semillas_sportium_d;

CREATE TABLE datos_desa.tb_cg_semillas_sportium_d AS
SELECT 
INICIAL.* , C.DHE_incr AS id_carrera_artificial
FROM ( SELECT CONCAT(dia,hora,estadio) AS DHE, dentro1.* FROM datos_desa.tb_cg_semillas_sportium dentro1) INICIAL
LEFT JOIN datos_desa.tb_cg_semillas_sportium_c C
ON (INICIAL.DHE=C.DHE)
;

SELECT * FROM datos_desa.tb_cg_semillas_sportium_d LIMIT 5;
SELECT count(*) as num_filas_d FROM datos_desa.tb_cg_semillas_sportium_d LIMIT 5;


set @min_id_carreras_artificiales=(select MIN(id_carrera_artificial) FROM datos_desa.tb_cg_semillas_sportium_d);
set @max_id_carreras_artificiales=(select MAX(id_carrera_artificial) FROM datos_desa.tb_cg_semillas_sportium_d);

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
FROM datos_desa.tb_cg_semillas_sportium_d A
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
FROM datos_desa.tb_cg_semillas_sportium_d;


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
FROM datos_desa.tb_cg_semillas_sportium_d;


SELECT count(*) FROM datos_desa.tb_galgos_historico 
WHERE ( id_carrera >= @min_id_carreras_artificiales AND id_carrera <= @max_id_carreras_artificiales);


SELECT * FROM datos_desa.tb_galgos_historico 
WHERE ( id_carrera >= @min_id_carreras_artificiales AND id_carrera <= @max_id_carreras_artificiales)
ORDER BY id_carrera ASC LIMIT 10;
EOF


#echo -e $(date +"%T")"$CONSULTA_SEMILLAS_FILAS_ARTIFICIALES" 2>&1 1>>${LOG_DESCARGA_BRUTO}
mysql -u root --password=datos1986 --execute="$CONSULTA_SEMILLAS_FILAS_ARTIFICIALES" 2>&1 1>>${LOG_DESCARGA_BRUTO}




##########################################
echo -e $(date +"%T")" NORMALIZACION NUMERICA - Normalizamos los campos NUMERICOS (que tenga sentido) de las tablas brutas iniciales (para que las tablas derivadas ya trabajen con datos normalizados)..." 2>&1 1>>${LOG_DESCARGA_BRUTO}


read -d '' CONSULTA_NORMALIZACIONES <<- EOF
set @min_hora=(select MIN(hora) FROM datos_desa.tb_galgos_carreras);
set @diff_hora=(select CASE WHEN MIN(hora)=0 THEN MAX(hora) ELSE MAX(hora)-MIN(hora) END FROM datos_desa.tb_galgos_carreras);
set @min_distancia=(select MIN(distancia) FROM datos_desa.tb_galgos_carreras);
set @diff_distancia=(select CASE WHEN MIN(distancia)=0 THEN MAX(distancia) ELSE MAX(distancia)-MIN(distancia) END FROM datos_desa.tb_galgos_carreras);
set @min_num_galgos=(select MIN(num_galgos) FROM datos_desa.tb_galgos_carreras);
set @diff_num_galgos=(select CASE WHEN MIN(num_galgos)=0 THEN MAX(num_galgos) ELSE MAX(num_galgos)-MIN(num_galgos) END FROM datos_desa.tb_galgos_carreras);
set @min_premio_primero=(select MIN(premio_primero) FROM datos_desa.tb_galgos_carreras);
set @diff_premio_primero=(select CASE WHEN MIN(premio_primero)=0 THEN MAX(premio_primero) ELSE MAX(premio_primero)-MIN(premio_primero) END FROM datos_desa.tb_galgos_carreras);
set @min_premio_segundo=(select MIN(premio_segundo) FROM datos_desa.tb_galgos_carreras);
set @diff_premio_segundo=(select CASE WHEN MIN(premio_segundo)=0 THEN MAX(premio_segundo) ELSE MAX(premio_segundo)-MIN(premio_segundo) END FROM datos_desa.tb_galgos_carreras);
set @min_premio_otros=(select MIN(premio_otros) FROM datos_desa.tb_galgos_carreras);
set @diff_premio_otros=(select CASE WHEN MIN(premio_otros)=0 THEN MAX(premio_otros) ELSE MAX(premio_otros)-MIN(premio_otros) END FROM datos_desa.tb_galgos_carreras);
set @min_premio_total_carrera=(select MIN(premio_total_carrera) FROM datos_desa.tb_galgos_carreras);
set @diff_premio_total_carrera=(select CASE WHEN MIN(premio_total_carrera)=0 THEN MAX(premio_total_carrera) ELSE MAX(premio_total_carrera)-MIN(premio_total_carrera) END FROM datos_desa.tb_galgos_carreras);
set @min_going_allowance_segundos=(select MIN(going_allowance_segundos) FROM datos_desa.tb_galgos_carreras);
set @diff_going_allowance_segundos=(select CASE WHEN MIN(going_allowance_segundos)=0 THEN MAX(going_allowance_segundos) ELSE MAX(going_allowance_segundos)-MIN(going_allowance_segundos) END FROM datos_desa.tb_galgos_carreras);
set @min_fc_1=(select MIN(fc_1) FROM datos_desa.tb_galgos_carreras);
set @diff_fc_1=(select CASE WHEN MIN(fc_1)=0 THEN MAX(fc_1) ELSE MAX(fc_1)-MIN(fc_1) END FROM datos_desa.tb_galgos_carreras);
set @min_fc_2=(select MIN(fc_2) FROM datos_desa.tb_galgos_carreras);
set @diff_fc_2=(select CASE WHEN MIN(fc_2)=0 THEN MAX(fc_2) ELSE MAX(fc_2)-MIN(fc_2) END FROM datos_desa.tb_galgos_carreras);
set @min_fc_pounds=(select MIN(fc_pounds) FROM datos_desa.tb_galgos_carreras);
set @diff_fc_pounds=(select CASE WHEN MIN(fc_pounds)=0 THEN MAX(fc_pounds) ELSE MAX(fc_pounds)-MIN(fc_pounds) END FROM datos_desa.tb_galgos_carreras);
set @min_tc_1=(select MIN(tc_1) FROM datos_desa.tb_galgos_carreras);
set @diff_tc_1=(select CASE WHEN MIN(tc_1)=0 THEN MAX(tc_1) ELSE MAX(tc_1)-MIN(tc_1) END FROM datos_desa.tb_galgos_carreras);
set @min_tc_2=(select MIN(tc_2) FROM datos_desa.tb_galgos_carreras);
set @diff_tc_2=(select CASE WHEN MIN(tc_2)=0 THEN MAX(tc_2) ELSE MAX(tc_2)-MIN(tc_2) END FROM datos_desa.tb_galgos_carreras);
set @min_tc_3=(select MIN(tc_3) FROM datos_desa.tb_galgos_carreras);
set @diff_tc_3=(select CASE WHEN MIN(tc_3)=0 THEN MAX(tc_3) ELSE MAX(tc_3)-MIN(tc_3) END FROM datos_desa.tb_galgos_carreras);


DROP TABLE IF EXISTS datos_desa.tb_galgos_carreras_norm;

CREATE TABLE datos_desa.tb_galgos_carreras_norm AS 
SELECT 
dentro.*,
CASE WHEN dlmxjvs=1 THEN 1 ELSE 0 END AS dow_d,
CASE WHEN dlmxjvs=2 THEN 1 ELSE 0 END AS dow_l,
CASE WHEN dlmxjvs=3 THEN 1 ELSE 0 END AS dow_m,
CASE WHEN dlmxjvs=4 THEN 1 ELSE 0 END AS dow_x,
CASE WHEN dlmxjvs=5 THEN 1 ELSE 0 END AS dow_j,
CASE WHEN dlmxjvs=6 THEN 1 ELSE 0 END AS dow_v,
CASE WHEN dlmxjvs=7 THEN 1 ELSE 0 END AS dow_s,
CASE WHEN (dlmxjvs=7 OR dlmxjvs=1) THEN 1 ELSE 0 END AS dow_finde,
CASE WHEN (dlmxjvs<>7 AND dlmxjvs<>1) THEN 1 ELSE 0 END AS dow_laborable

FROM (
  SELECT 
  id_carrera,
  id_campeonato,
  track,
  clase,
  DAYOFWEEK(concat(anio,'-',  LPAD(cast(mes as char), 2, '0')    ,'-',dia)) AS dlmxjvs,
  anio,
  mes, 
  CASE WHEN (mes <=7) THEN (-1/6 + mes/6) WHEN (mes >7) THEN (5/12 - 5*mes/144) ELSE 0.5 END AS mes_norm,
  dia,
  hora, 
  CASE WHEN (hora IS NULL OR @diff_hora=0) THEN NULL ELSE ((hora - @min_hora)/@diff_hora) END AS hora_norm,
  minuto,
  distancia, 
  CASE WHEN (distancia IS NULL OR @diff_distancia=0) THEN NULL ELSE ((distancia - @min_distancia)/@diff_distancia) END AS distancia_norm,
  num_galgos,
  CASE WHEN (num_galgos IS NULL OR @diff_num_galgos=0) THEN NULL ELSE ((num_galgos - @min_num_galgos)/@diff_num_galgos) END AS num_galgos_norm,
  premio_primero, 
  CASE WHEN (premio_primero IS NULL OR @diff_premio_primero=0) THEN NULL ELSE ((premio_primero - @min_premio_primero)/@diff_premio_primero) END AS premio_primero_norm,
  premio_segundo, 
  CASE WHEN (premio_segundo IS NULL OR @diff_premio_segundo=0) THEN NULL ELSE ((premio_segundo - @min_premio_segundo)/@diff_premio_segundo) END AS premio_segundo_norm,
  premio_otros, 
  CASE WHEN (premio_otros IS NULL OR @diff_premio_otros=0) THEN NULL ELSE ((premio_otros - @min_premio_otros)/@diff_premio_otros) END AS premio_otros_norm,
  premio_total_carrera, 
  CASE WHEN (premio_total_carrera IS NULL OR @diff_premio_total_carrera=0) THEN NULL ELSE ((premio_total_carrera - @min_premio_total_carrera)/@diff_premio_total_carrera) END AS premio_total_carrera_norm,
  going_allowance_segundos, 
  CASE WHEN (going_allowance_segundos IS NULL OR @diff_going_allowance_segundos=0) THEN NULL ELSE ((going_allowance_segundos - @min_going_allowance_segundos)/@diff_going_allowance_segundos) END AS going_allowance_segundos_norm,
  fc_1, 
  CASE WHEN (fc_1 IS NULL OR @diff_fc_1=0) THEN NULL ELSE ((fc_1 - @min_fc_1)/@diff_fc_1) END AS fc_1_norm,
  fc_2, 
  CASE WHEN (fc_2 IS NULL OR @diff_fc_2=0) THEN NULL ELSE ((fc_2 - @min_fc_2)/@diff_fc_2) END AS fc_2_norm,
  fc_pounds, 
  CASE WHEN (fc_pounds IS NULL OR @diff_fc_pounds=0) THEN NULL ELSE ((fc_pounds - @min_fc_pounds)/@diff_fc_pounds) END AS fc_pounds_norm,
  tc_1, 
  CASE WHEN (tc_1 IS NULL OR @diff_tc_1=0) THEN NULL ELSE ((tc_1 - @min_tc_1)/@diff_tc_1) END AS tc_1_norm,
  tc_2, 
  CASE WHEN (tc_2 IS NULL OR @diff_tc_2=0) THEN NULL ELSE ((tc_2 - @min_tc_2)/@diff_tc_2) END AS tc_2_norm,
  tc_3, 
  CASE WHEN (tc_3 IS NULL OR @diff_tc_3=0) THEN NULL ELSE ((tc_3 - @min_tc_3)/@diff_tc_3) END AS tc_3_norm,
  tc_pounds, 
  CASE WHEN (tc_pounds IS NULL OR @diff_tc_pounds=0) THEN NULL ELSE ((tc_pounds - @min_tc_pounds)/@diff_tc_pounds) END AS tc_pounds_norm
  FROM datos_desa.tb_galgos_carreras
) dentro;


SELECT * FROM datos_desa.tb_galgos_carreras_norm LIMIT 5;
SELECT count(*) as num_carreras_norm FROM datos_desa.tb_galgos_carreras_norm LIMIT 5;



set @min_posicion=(select MIN(posicion) FROM datos_desa.tb_galgos_posiciones_en_carreras);
set @diff_posicion=(select CASE WHEN MIN(posicion)=0 THEN MAX(posicion) ELSE MAX(posicion)-MIN(posicion) END FROM datos_desa.tb_galgos_posiciones_en_carreras);
set @min_trap=(select MIN(trap) FROM datos_desa.tb_galgos_posiciones_en_carreras);
set @diff_trap=(select CASE WHEN MIN(trap)=0 THEN MAX(trap) ELSE MAX(trap)-MIN(trap) END FROM datos_desa.tb_galgos_posiciones_en_carreras);
set @min_sp=(select MIN(sp) FROM datos_desa.tb_galgos_posiciones_en_carreras);
set @diff_sp=(select CASE WHEN MIN(sp)=0 THEN MAX(sp) ELSE MAX(sp)-MIN(sp) END FROM datos_desa.tb_galgos_posiciones_en_carreras);
set @min_time_sec=(select MIN(time_sec) FROM datos_desa.tb_galgos_posiciones_en_carreras);
set @diff_time_sec=(select CASE WHEN MIN(time_sec)=0 THEN MAX(time_sec) ELSE MAX(time_sec)-MIN(time_sec) END FROM datos_desa.tb_galgos_posiciones_en_carreras);
set @min_time_distance=(select MIN(time_distance) FROM datos_desa.tb_galgos_posiciones_en_carreras);
set @diff_time_distance=(select CASE WHEN MIN(time_distance)=0 THEN MAX(time_distance) ELSE MAX(time_distance)-MIN(time_distance) END FROM datos_desa.tb_galgos_posiciones_en_carreras);
set @min_peso_galgo=(select MIN(peso_galgo) FROM datos_desa.tb_galgos_posiciones_en_carreras);
set @diff_peso_galgo=(select CASE WHEN MIN(peso_galgo)=0 THEN MAX(peso_galgo) ELSE MAX(peso_galgo)-MIN(peso_galgo) END FROM datos_desa.tb_galgos_posiciones_en_carreras);
set @min_nacimiento=(select MIN(nacimiento) FROM datos_desa.tb_galgos_posiciones_en_carreras);
set @diff_nacimiento=(select CASE WHEN MIN(nacimiento)=0 THEN MAX(nacimiento) ELSE MAX(nacimiento)-MIN(nacimiento) END FROM datos_desa.tb_galgos_posiciones_en_carreras);
set @min_edad_en_dias=(select MIN(edad_en_dias) FROM datos_desa.tb_galgos_posiciones_en_carreras);
set @diff_edad_en_dias=(select CASE WHEN MIN(edad_en_dias)=0 THEN MAX(edad_en_dias) ELSE MAX(edad_en_dias)-MIN(edad_en_dias) END FROM datos_desa.tb_galgos_posiciones_en_carreras);


DROP TABLE IF EXISTS datos_desa.tb_galgos_posiciones_en_carreras_norm;

CREATE TABLE datos_desa.tb_galgos_posiciones_en_carreras_norm AS 
SELECT 
id_carrera,
id_campeonato,
posicion, 
CASE WHEN (posicion IS NULL OR @diff_posicion=0) THEN NULL ELSE ((posicion - @min_posicion)/@diff_posicion) END AS posicion_norm,
galgo_nombre,
trap, 
CASE WHEN (trap IS NULL OR @diff_trap=0) THEN NULL ELSE ((trap - @min_trap)/@diff_trap) END AS trap_norm,
sp, 
CASE WHEN (sp IS NULL OR @diff_sp=0) THEN NULL ELSE ((sp - @min_sp)/@diff_sp) END AS sp_norm,
time_sec, 
CASE WHEN (time_sec IS NULL OR @diff_time_sec=0) THEN NULL ELSE ((time_sec - @min_time_sec)/@diff_time_sec) END AS time_sec_norm,
time_distance, 
CASE WHEN (time_distance IS NULL OR @diff_time_distance=0) THEN NULL ELSE ((time_distance - @min_time_distance)/@diff_time_distance) END AS time_distance_norm,
peso_galgo, 
CASE WHEN (peso_galgo IS NULL OR @diff_peso_galgo=0) THEN NULL ELSE ((peso_galgo - @min_peso_galgo)/@diff_peso_galgo) END AS peso_galgo_norm,
entrenador_nombre,
galgo_padre,
galgo_madre,
nacimiento,
comment,
edad_en_dias, 
CASE WHEN (edad_en_dias IS NULL OR @diff_edad_en_dias=0) THEN NULL ELSE ((edad_en_dias - @min_edad_en_dias)/@diff_edad_en_dias) END AS edad_en_dias_norm

FROM datos_desa.tb_galgos_posiciones_en_carreras;

ALTER TABLE datos_desa.tb_galgos_posiciones_en_carreras_norm ADD INDEX tb_GPECN_idx(id_carrera,galgo_nombre);

SELECT * FROM datos_desa.tb_galgos_posiciones_en_carreras_norm LIMIT 5;
SELECT count(*) as num_posiciones_en_carreras_norm FROM datos_desa.tb_galgos_posiciones_en_carreras_norm LIMIT 5;


set @min_distancia=(select MIN(distancia) FROM datos_desa.tb_galgos_historico);
set @diff_distancia=(select CASE WHEN MIN(distancia)=0 THEN MAX(distancia) ELSE MAX(distancia)-MIN(distancia) END FROM datos_desa.tb_galgos_historico);
set @min_trap=(select MIN(trap) FROM datos_desa.tb_galgos_historico);
set @diff_trap=(select CASE WHEN MIN(trap)=0 THEN MAX(trap) ELSE MAX(trap)-MIN(trap) END FROM datos_desa.tb_galgos_historico);
set @min_stmhcp=(select MIN(stmhcp) FROM datos_desa.tb_galgos_historico);
set @diff_stmhcp=(select CASE WHEN MIN(stmhcp)=0 THEN MAX(stmhcp) ELSE MAX(stmhcp)-MIN(stmhcp) END FROM datos_desa.tb_galgos_historico);
set @min_posicion=(select MIN(posicion) FROM datos_desa.tb_galgos_historico);
set @diff_posicion=(select CASE WHEN MIN(posicion)=0 THEN MAX(posicion) ELSE MAX(posicion)-MIN(posicion) END FROM datos_desa.tb_galgos_historico);
set @min_win_time=(select MIN(win_time) FROM datos_desa.tb_galgos_historico);
set @diff_win_time=(select CASE WHEN MIN(win_time)=0 THEN MAX(win_time) ELSE MAX(win_time)-MIN(win_time) END FROM datos_desa.tb_galgos_historico);
set @min_sp=(select MIN(sp) FROM datos_desa.tb_galgos_historico);
set @diff_sp=(select CASE WHEN MIN(sp)=0 THEN MAX(sp) ELSE MAX(sp)-MIN(sp) END FROM datos_desa.tb_galgos_historico);
set @min_calculated_time=(select MIN(calculated_time) FROM datos_desa.tb_galgos_historico);
set @diff_calculated_time=(select CASE WHEN MIN(calculated_time)=0 THEN MAX(calculated_time) ELSE MAX(calculated_time)-MIN(calculated_time) END FROM datos_desa.tb_galgos_historico);
set @min_velocidad_real=(select MIN(velocidad_real) FROM datos_desa.tb_galgos_historico);
set @diff_velocidad_real=(select CASE WHEN MIN(velocidad_real)=0 THEN MAX(velocidad_real) ELSE MAX(velocidad_real)-MIN(velocidad_real) END FROM datos_desa.tb_galgos_historico);
set @min_velocidad_con_going=(select MIN(velocidad_con_going) FROM datos_desa.tb_galgos_historico);
set @diff_velocidad_con_going=(select CASE WHEN MIN(velocidad_con_going)=0 THEN MAX(velocidad_con_going) ELSE MAX(velocidad_con_going)-MIN(velocidad_con_going) END FROM datos_desa.tb_galgos_historico);


DROP TABLE IF EXISTS datos_desa.tb_galgos_historico_norm;

CREATE TABLE datos_desa.tb_galgos_historico_norm AS 
SELECT 
galgo_nombre, entrenador, id_carrera, id_campeonato, anio,
mes, CASE WHEN (mes <=7) THEN (-1/6 + mes/6) WHEN (mes >7) THEN (5/12 - 5*mes/144) ELSE 0.5 END AS mes_norm,
dia,
distancia, 
CASE WHEN (distancia IS NULL OR @diff_distancia=0) THEN NULL ELSE ((distancia - @min_distancia)/@diff_distancia) END AS distancia_norm,
trap, 
CASE WHEN (trap IS NULL OR @diff_trap=0) THEN NULL ELSE ((trap - @min_trap)/@diff_trap) END AS trap_norm,
stmhcp, 
CASE WHEN (stmhcp IS NULL OR @diff_stmhcp=0) THEN NULL ELSE ((stmhcp - @min_stmhcp)/@diff_stmhcp) END AS stmhcp_norm,
posicion, 
CASE WHEN (posicion IS NULL OR @diff_posicion=0) THEN NULL ELSE ((posicion - @min_posicion)/@diff_posicion) END AS posicion_norm,
by_dato,
galgo_primero_o_segundo,
venue,
remarks,
win_time, 
CASE WHEN (win_time IS NULL OR @diff_win_time=0) THEN NULL ELSE ((win_time - @min_win_time)/@diff_win_time) END AS win_time_norm,
going,
sp, 
CASE WHEN (sp IS NULL OR @diff_sp=0) THEN NULL ELSE ((sp - @min_sp)/@diff_sp) END AS sp_norm,
clase,
calculated_time, 
CASE WHEN (calculated_time IS NULL OR @diff_calculated_time=0) THEN NULL ELSE ((calculated_time - @min_calculated_time)/@diff_calculated_time) END AS calculated_time_norm,
velocidad_real, 
CASE WHEN (velocidad_real IS NULL OR @diff_velocidad_real=0) THEN NULL ELSE ((velocidad_real - @min_velocidad_real)/@diff_velocidad_real) END AS velocidad_real_norm,
velocidad_con_going, 
CASE WHEN (velocidad_con_going IS NULL OR @diff_velocidad_con_going=0) THEN NULL ELSE ((velocidad_con_going - @min_velocidad_con_going)/@diff_velocidad_con_going) END AS velocidad_con_going_norm,
scoring_remarks

FROM datos_desa.tb_galgos_historico;

ALTER TABLE datos_desa.tb_galgos_historico_norm ADD INDEX tb_galgos_historico_norm_idx1(id_carrera, galgo_nombre);
ALTER TABLE datos_desa.tb_galgos_historico_norm ADD INDEX tb_galgos_historico_norm_idx2(galgo_nombre,clase);

SELECT * FROM datos_desa.tb_galgos_historico_norm LIMIT 5;
SELECT count(*) as num_XX_norm FROM datos_desa.tb_galgos_historico_norm LIMIT 5;


set @min_vel_real_cortas_mediana=(select MIN(vel_real_cortas_mediana) FROM datos_desa.tb_galgos_agregados);
set @diff_vel_real_cortas_mediana=(select CASE WHEN MIN(vel_real_cortas_mediana)=0 THEN MAX(vel_real_cortas_mediana) ELSE MAX(vel_real_cortas_mediana)-MIN(vel_real_cortas_mediana) END FROM datos_desa.tb_galgos_agregados);
set @min_vel_real_cortas_max=(select MIN(vel_real_cortas_max) FROM datos_desa.tb_galgos_agregados);
set @diff_vel_real_cortas_max=(select CASE WHEN MIN(vel_real_cortas_max)=0 THEN MAX(vel_real_cortas_max) ELSE MAX(vel_real_cortas_max)-MIN(vel_real_cortas_max) END FROM datos_desa.tb_galgos_agregados);
set @min_vel_going_cortas_mediana=(select MIN(vel_going_cortas_mediana) FROM datos_desa.tb_galgos_agregados);
set @diff_vel_going_cortas_mediana=(select CASE WHEN MIN(vel_going_cortas_mediana)=0 THEN MAX(vel_going_cortas_mediana) ELSE MAX(vel_going_cortas_mediana)-MIN(vel_going_cortas_mediana) END FROM datos_desa.tb_galgos_agregados);
set @min_vel_going_cortas_max=(select MIN(vel_going_cortas_max) FROM datos_desa.tb_galgos_agregados);
set @diff_vel_going_cortas_max=(select CASE WHEN MIN(vel_going_cortas_max)=0 THEN MAX(vel_going_cortas_max) ELSE MAX(vel_going_cortas_max)-MIN(vel_going_cortas_max) END FROM datos_desa.tb_galgos_agregados);
set @min_vel_real_longmedias_mediana=(select MIN(vel_real_longmedias_mediana) FROM datos_desa.tb_galgos_agregados);
set @diff_vel_real_longmedias_mediana=(select CASE WHEN MIN(vel_real_longmedias_mediana)=0 THEN MAX(vel_real_longmedias_mediana) ELSE MAX(vel_real_longmedias_mediana)-MIN(vel_real_longmedias_mediana) END FROM datos_desa.tb_galgos_agregados);
set @min_vel_real_longmedias_max=(select MIN(vel_real_longmedias_max) FROM datos_desa.tb_galgos_agregados);
set @diff_vel_real_longmedias_max=(select CASE WHEN MIN(vel_real_longmedias_max)=0 THEN MAX(vel_real_longmedias_max) ELSE MAX(vel_real_longmedias_max)-MIN(vel_real_longmedias_max) END FROM datos_desa.tb_galgos_agregados);
set @min_vel_going_longmedias_mediana=(select MIN(vel_going_longmedias_mediana) FROM datos_desa.tb_galgos_agregados);
set @diff_vel_going_longmedias_mediana=(select CASE WHEN MIN(vel_going_longmedias_mediana)=0 THEN MAX(vel_going_longmedias_mediana) ELSE MAX(vel_going_longmedias_mediana)-MIN(vel_going_longmedias_mediana) END FROM datos_desa.tb_galgos_agregados);
set @min_vel_going_longmedias_max=(select MIN(vel_going_longmedias_max) FROM datos_desa.tb_galgos_agregados);
set @diff_vel_going_longmedias_max=(select CASE WHEN MIN(vel_going_longmedias_max)=0 THEN MAX(vel_going_longmedias_max) ELSE MAX(vel_going_longmedias_max)-MIN(vel_going_longmedias_max) END FROM datos_desa.tb_galgos_agregados);
set @min_vel_real_largas_mediana=(select MIN(vel_real_largas_mediana) FROM datos_desa.tb_galgos_agregados);
set @diff_vel_real_largas_mediana=(select CASE WHEN MIN(vel_real_largas_mediana)=0 THEN MAX(vel_real_largas_mediana) ELSE MAX(vel_real_largas_mediana)-MIN(vel_real_largas_mediana) END FROM datos_desa.tb_galgos_agregados);
set @min_vel_real_largas_max=(select MIN(vel_real_largas_max) FROM datos_desa.tb_galgos_agregados);
set @diff_vel_real_largas_max=(select CASE WHEN MIN(vel_real_largas_max)=0 THEN MAX(vel_real_largas_max) ELSE MAX(vel_real_largas_max)-MIN(vel_real_largas_max) END FROM datos_desa.tb_galgos_agregados);
set @min_vel_going_largas_mediana=(select MIN(vel_going_largas_mediana) FROM datos_desa.tb_galgos_agregados);
set @diff_vel_going_largas_mediana=(select CASE WHEN MIN(vel_going_largas_mediana)=0 THEN MAX(vel_going_largas_mediana) ELSE MAX(vel_going_largas_mediana)-MIN(vel_going_largas_mediana) END FROM datos_desa.tb_galgos_agregados);
set @min_vel_going_largas_max=(select MIN(vel_going_largas_max) FROM datos_desa.tb_galgos_agregados);
set @diff_vel_going_largas_max=(select CASE WHEN MIN(vel_going_largas_max)=0 THEN MAX(vel_going_largas_max) ELSE MAX(vel_going_largas_max)-MIN(vel_going_largas_max) END FROM datos_desa.tb_galgos_agregados);


DROP TABLE IF EXISTS datos_desa.tb_galgos_agregados_norm;
CREATE TABLE datos_desa.tb_galgos_agregados_norm AS 
SELECT 
galgo_nombre,
vel_real_cortas_mediana, 
CASE WHEN (vel_real_cortas_mediana IS NULL OR @diff_vel_real_cortas_mediana=0) THEN NULL ELSE ((vel_real_cortas_mediana - @min_vel_real_cortas_mediana)/@diff_vel_real_cortas_mediana) END AS vel_real_cortas_mediana_norm,
vel_real_cortas_max, 
CASE WHEN (vel_real_cortas_max IS NULL OR @diff_vel_real_cortas_max=0) THEN NULL ELSE ((vel_real_cortas_max - @min_vel_real_cortas_max)/@diff_vel_real_cortas_max) END AS vel_real_cortas_max_norm,
vel_going_cortas_mediana, 
CASE WHEN (vel_going_cortas_mediana IS NULL OR @diff_vel_going_cortas_mediana=0) THEN NULL ELSE ((vel_going_cortas_mediana - @min_vel_going_cortas_mediana)/@diff_vel_going_cortas_mediana) END AS vel_going_cortas_mediana_norm,
vel_going_cortas_max, 
CASE WHEN (vel_going_cortas_max IS NULL OR @diff_vel_going_cortas_max=0) THEN NULL ELSE ((vel_going_cortas_max - @min_vel_going_cortas_max)/@diff_vel_going_cortas_max) END AS vel_going_cortas_max_norm,
vel_real_longmedias_mediana, 
CASE WHEN (vel_real_longmedias_mediana IS NULL OR @diff_vel_real_longmedias_mediana=0) THEN NULL ELSE ((vel_real_longmedias_mediana - @min_vel_real_longmedias_mediana)/@diff_vel_real_longmedias_mediana) END AS vel_real_longmedias_mediana_norm,
vel_real_longmedias_max, 
CASE WHEN (vel_real_longmedias_max IS NULL OR @diff_vel_real_longmedias_max=0) THEN NULL ELSE ((vel_real_longmedias_max - @min_vel_real_longmedias_max)/@diff_vel_real_longmedias_max) END AS vel_real_longmedias_max_norm,
vel_going_longmedias_mediana, 
CASE WHEN (vel_going_longmedias_mediana IS NULL OR @diff_vel_going_longmedias_mediana=0) THEN NULL ELSE ((vel_going_longmedias_mediana - @min_vel_going_longmedias_mediana)/@diff_vel_going_longmedias_mediana) END AS vel_going_longmedias_mediana_norm,
vel_going_longmedias_max, 
CASE WHEN (vel_going_longmedias_max IS NULL OR @diff_vel_going_longmedias_max=0) THEN NULL ELSE ((vel_going_longmedias_max - @min_vel_going_longmedias_max)/@diff_vel_going_longmedias_max) END AS vel_going_longmedias_max_norm,
vel_real_largas_mediana, 
CASE WHEN (vel_real_largas_mediana IS NULL OR @diff_vel_real_largas_mediana=0) THEN NULL ELSE ((vel_real_largas_mediana - @min_vel_real_largas_mediana)/@diff_vel_real_largas_mediana) END AS vel_real_largas_mediana_norm,
vel_real_largas_max, 
CASE WHEN (vel_real_largas_max IS NULL OR @diff_vel_real_largas_max=0) THEN NULL ELSE ((vel_real_largas_max - @min_vel_real_largas_max)/@diff_vel_real_largas_max) END AS vel_real_largas_max_norm,
vel_going_largas_mediana, 
CASE WHEN (vel_going_largas_mediana IS NULL OR @diff_vel_going_largas_mediana=0) THEN NULL ELSE ((vel_going_largas_mediana - @min_vel_going_largas_mediana)/@diff_vel_going_largas_mediana) END AS vel_going_largas_mediana_norm,
vel_going_largas_max, 
CASE WHEN (vel_going_largas_max IS NULL OR @diff_vel_going_largas_max=0) THEN NULL ELSE ((vel_going_largas_max - @min_vel_going_largas_max)/@diff_vel_going_largas_max) END AS vel_going_largas_max_norm

FROM datos_desa.tb_galgos_agregados;

SELECT * FROM datos_desa.tb_galgos_agregados_norm LIMIT 5;
SELECT count(*) as num_galgos_agregados_norm FROM datos_desa.tb_galgos_agregados_norm LIMIT 5;

EOF

#echo -e "$CONSULTA_NORMALIZACIONES" 2>&1 1>>${LOG_DESCARGA_BRUTO}
mysql -u root --password=datos1986 --execute="$CONSULTA_NORMALIZACIONES" 2>&1 1>>${LOG_DESCARGA_BRUTO}


##########################################

echo -e $(date +"%T")" Galgos-Modulo 010 - FIN" 2>&1 1>>${LOG_DESCARGA_BRUTO}




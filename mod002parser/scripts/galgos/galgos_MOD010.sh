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


echo -e $(date +"%T")" | 010 | Descarga datos brutos | INICIO" >>$LOG_070
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
PATH_BRUTO_SEMILLAS_SPORTIUM="${PATH_BRUTO}semillas_sportium"

echo -e $(date +"%T")" Borrando las paginas BRUTAS de detalle (carreras FUTURAS)..." 2>&1 1>>${LOG_DESCARGA_BRUTO}
rm -fR "${PATH_BRUTO_SEMILLAS_SPORTIUM}_BRUTOCARRERADET*"

echo -e $(date +"%T")" Descargando todas las carreras FUTURAS en las que PUEDO apostar y sus galgos (semillas)..." 2>&1 1>>${LOG_DESCARGA_BRUTO}
java -jar ${PATH_JAR} "GALGOS_02_SPORTIUM" "${PATH_BRUTO_SEMILLAS_SPORTIUM}" "${PATH_FILE_GALGOS_INICIALES}" 2>&1 1>>${LOG_DESCARGA_BRUTO}
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
echo -e "\n\n\n"$(date +"%T")"SEMILLAS (FUTURAS) - Metiendo filas artificiales con los datos conocidos de las semillas:" 2>&1 1>>${LOG_DESCARGA_BRUTO}

#Pendiente descargar dato "SP" si se conoce en ese instante

read -d '' CONSULTA_SEMILLAS_FILAS_ARTIFICIALES_TABLASBASE <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_cg_semillas_sportium_b;

CREATE TABLE datos_desa.tb_cg_semillas_sportium_b AS
SELECT DHE
FROM ( SELECT CONCAT(dia,hora,estadio) AS DHE, dentro1.* FROM datos_desa.tb_cg_semillas_sportium dentro1) dentro2 
GROUP BY DHE 
ORDER BY DHE DESC;

SELECT * FROM datos_desa.tb_cg_semillas_sportium_b LIMIT 5;
SELECT count(*) AS num_semillas_sportium_b FROM datos_desa.tb_cg_semillas_sportium_b LIMIT 5;


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
SELECT count(*) as num_semillas_sportium_c FROM datos_desa.tb_cg_semillas_sportium_c LIMIT 5;


DROP TABLE IF EXISTS datos_desa.tb_cg_semillas_sportium_d;

CREATE TABLE datos_desa.tb_cg_semillas_sportium_d AS
SELECT 
INICIAL.* , C.DHE_incr AS id_carrera_artificial
FROM ( SELECT CONCAT(dia,hora,estadio) AS DHE, dentro1.* FROM datos_desa.tb_cg_semillas_sportium dentro1) INICIAL
LEFT JOIN datos_desa.tb_cg_semillas_sportium_c C
ON (INICIAL.DHE=C.DHE)
;

SELECT * FROM datos_desa.tb_cg_semillas_sportium_d LIMIT 5;
SELECT count(*) as num_semillas_sportium_d FROM datos_desa.tb_cg_semillas_sportium_d LIMIT 5;


set @min_id_carreras_artificiales=(select MIN(id_carrera_artificial) FROM datos_desa.tb_cg_semillas_sportium_d);
set @max_id_carreras_artificiales=(select MAX(id_carrera_artificial) FROM datos_desa.tb_cg_semillas_sportium_d);


DROP TABLE IF EXISTS datos_desa.tb_galgo_y_su_entrenador;

CREATE TABLE datos_desa.tb_galgo_y_su_entrenador AS
SELECT galgo_nombre, entrenador FROM datos_desa.tb_galgos_historico 
WHERE entrenador IS NOT NULL AND entrenador <> '' AND entrenador <> 'unknown'
 GROUP BY galgo_nombre, entrenador;

SELECT count(*) AS num_GyE FROM datos_desa.tb_galgo_y_su_entrenador LIMIT 10;
SELECT * FROM datos_desa.tb_galgo_y_su_entrenador LIMIT 10;


DROP TABLE IF EXISTS datos_desa.tb_galgos_clase_mas_reciente;

CREATE TABLE datos_desa.tb_galgos_clase_mas_reciente AS
SELECT 
A.galgo_nombre AS galgo_nombre, 
A.clase AS clase_reciente
FROM  datos_desa.tb_galgos_historico A 
INNER JOIN (
  SELECT galgo_nombre, MAX(id_carrera) AS id_carrera_mas_reciente
  FROM datos_desa.tb_galgos_historico GH 
  GROUP BY galgo_nombre
) B
ON (A.galgo_nombre=B.galgo_nombre AND A.id_carrera=B.id_carrera_mas_reciente);

SELECT * FROM datos_desa.tb_galgos_clase_mas_reciente LIMIT 5;


DROP TABLE IF EXISTS datos_desa.tb_galgos_y_carrera_clase_mas_reciente;

CREATE TABLE datos_desa.tb_galgos_y_carrera_clase_mas_reciente AS
SELECT A.galgo_nombre, A.id_carrera_artificial, B.clase_reciente
FROM datos_desa.tb_cg_semillas_sportium_d A
LEFT JOIN datos_desa.tb_galgos_clase_mas_reciente B ON (A.galgo_nombre=B.galgo_nombre);

SELECT * FROM datos_desa.tb_galgos_y_carrera_clase_mas_reciente LIMIT 12;


DROP TABLE IF EXISTS datos_desa.tb_clases_recientes_en_carrera_futura;

CREATE TABLE datos_desa.tb_clases_recientes_en_carrera_futura AS
SELECT id_carrera_artificial, clase_reciente, count(*) AS contador
  FROM datos_desa.tb_galgos_y_carrera_clase_mas_reciente
  GROUP BY id_carrera_artificial, clase_reciente
  ORDER BY id_carrera_artificial ASC, contador DESC;
  
SELECT * FROM datos_desa.tb_clases_recientes_en_carrera_futura LIMIT 12;


DROP TABLE IF EXISTS datos_desa.tb_carreras_futuras_con_clase_reciente_mas_repetida;

CREATE TABLE datos_desa.tb_carreras_futuras_con_clase_reciente_mas_repetida AS
SELECT FUERA.*
FROM
datos_desa.tb_clases_recientes_en_carrera_futura FUERA
INNER JOIN
(
  SELECT 
  A.id_carrera_artificial, B.contador_max
  FROM (SELECT DISTINCT id_carrera_artificial FROM datos_desa.tb_clases_recientes_en_carrera_futura) A
  LEFT JOIN 
  (SELECT id_carrera_artificial, MAX(contador) AS contador_max FROM datos_desa.tb_clases_recientes_en_carrera_futura GROUP BY id_carrera_artificial) B
  ON (A.id_carrera_artificial=B.id_carrera_artificial)
) DENTRO
ON (FUERA.id_carrera_artificial=DENTRO.id_carrera_artificial AND FUERA.contador=DENTRO.contador_max)
;

SELECT * FROM datos_desa.tb_carreras_futuras_con_clase_reciente_mas_repetida LIMIT 12;

EOF


read -d '' CONSULTA_SEMILLAS_FILAS_ARTIFICIALES_CARRERAS <<- EOF

set @min_id_carreras_artificiales=(select MIN(id_carrera_artificial) FROM datos_desa.tb_cg_semillas_sportium_d);
set @max_id_carreras_artificiales=(select MAX(id_carrera_artificial) FROM datos_desa.tb_cg_semillas_sportium_d);


DELETE FROM datos_desa.tb_galgos_carreras 
WHERE ( id_carrera >= @min_id_carreras_artificiales AND id_carrera <= @max_id_carreras_artificiales);


INSERT INTO datos_desa.tb_galgos_carreras
SELECT
DENTRO.id_carrera, DENTRO.id_campeonato, DENTRO.track, 
FUERA.clase_reciente AS clase,
DENTRO.anio, DENTRO.mes, DENTRO.dia, DENTRO.hora, DENTRO.minuto, 
DENTRO.distancia,
DENTRO.num_galgos,
DENTRO.premio_primero, DENTRO.premio_segundo, DENTRO.premio_otros ,  DENTRO.premio_total_carrera ,  DENTRO.going_allowance_segundos ,
DENTRO.fc_1 ,  DENTRO.fc_2 ,  DENTRO.fc_pounds ,
DENTRO.tc_1 , DENTRO.tc_2 , DENTRO.tc_3 , DENTRO.tc_pounds
FROM (
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
  GROUP BY DHE
) DENTRO
LEFT JOIN datos_desa.tb_carreras_futuras_con_clase_reciente_mas_repetida FUERA 
ON (DENTRO.id_carrera=FUERA.id_carrera_artificial)
;


SELECT count(*) AS num_GC_futuras FROM datos_desa.tb_galgos_carreras 
WHERE ( id_carrera >= @min_id_carreras_artificiales AND id_carrera <= @max_id_carreras_artificiales);


SELECT * FROM datos_desa.tb_galgos_carreras 
WHERE ( id_carrera >= @min_id_carreras_artificiales AND id_carrera <= @max_id_carreras_artificiales)
ORDER BY id_carrera ASC LIMIT 10;
EOF


read -d '' CONSULTA_SEMILLAS_FILAS_ARTIFICIALES_HISTORICO <<- EOF

set @min_id_carreras_artificiales=(select MIN(id_carrera_artificial) FROM datos_desa.tb_cg_semillas_sportium_d);
set @max_id_carreras_artificiales=(select MAX(id_carrera_artificial) FROM datos_desa.tb_cg_semillas_sportium_d);


DELETE FROM datos_desa.tb_galgos_historico 
WHERE ( id_carrera >= @min_id_carreras_artificiales AND id_carrera <= @max_id_carreras_artificiales);


INSERT INTO datos_desa.tb_galgos_historico

SELECT 
A.galgo_nombre AS galgo_nombre,
B.entrenador AS entrenador,
A.id_carrera_artificial AS id_carrera,
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
C.clase_reciente AS clase,
NULL AS calculated_time,
NULL AS velocidad_real,
NULL AS velocidad_con_going,
NULL AS scoring_remarks
FROM datos_desa.tb_cg_semillas_sportium_d A

LEFT JOIN datos_desa.tb_galgo_y_su_entrenador B
ON (A.galgo_nombre=B.galgo_nombre)

LEFT JOIN datos_desa.tb_carreras_futuras_con_clase_reciente_mas_repetida C 
ON (A.id_carrera_artificial=C.id_carrera_artificial)
;


SELECT count(*) AS num_GH_futuras FROM datos_desa.tb_galgos_historico 
WHERE ( id_carrera >= @min_id_carreras_artificiales AND id_carrera <= @max_id_carreras_artificiales);


SELECT * FROM datos_desa.tb_galgos_historico 
WHERE ( id_carrera >= @min_id_carreras_artificiales AND id_carrera <= @max_id_carreras_artificiales)
ORDER BY id_carrera ASC LIMIT 10;
EOF


read -d '' CONSULTA_SEMILLAS_FILAS_ARTIFICIALES_POSICIONES <<- EOF

set @min_id_carreras_artificiales=(select MIN(id_carrera_artificial) FROM datos_desa.tb_cg_semillas_sportium_d);
set @max_id_carreras_artificiales=(select MAX(id_carrera_artificial) FROM datos_desa.tb_cg_semillas_sportium_d);


DROP TABLE IF EXISTS datos_desa.tb_galgos_nacimientos;

CREATE TABLE datos_desa.tb_galgos_nacimientos AS
SELECT galgo_nombre, MAX(nacimiento) AS nacimiento, MAX(galgo_padre) AS galgo_padre, MAX(galgo_madre) AS galgo_madre
FROM datos_desa.tb_galgos_posiciones_en_carreras 
GROUP BY galgo_nombre;

SELECT count(*) FROM datos_desa.tb_galgos_nacimientos LIMIT 5;
SELECT * FROM datos_desa.tb_galgos_nacimientos LIMIT 5;


DROP TABLE IF EXISTS datos_desa.tb_galgos_peso_mas_reciente;

CREATE TABLE datos_desa.tb_galgos_peso_mas_reciente AS
SELECT 
A.galgo_nombre AS galgo_nombre, 
A.peso_galgo AS peso_reciente
FROM  datos_desa.tb_galgos_posiciones_en_carreras A 

INNER JOIN (
  SELECT galgo_nombre, MAX(id_carrera) AS id_carrera_mas_reciente
  FROM datos_desa.tb_galgos_historico GH 
  GROUP BY galgo_nombre
) B
ON (A.galgo_nombre=B.galgo_nombre AND A.id_carrera=B.id_carrera_mas_reciente);


DELETE FROM datos_desa.tb_galgos_posiciones_en_carreras 
WHERE ( id_carrera >= @min_id_carreras_artificiales AND id_carrera <= @max_id_carreras_artificiales);

INSERT INTO datos_desa.tb_galgos_posiciones_en_carreras
SELECT 
A.id_carrera_artificial AS id_carrera,
0 AS id_campeonato,
NULL AS posicion,
A.galgo_nombre AS galgo_nombre,
trap AS trap,
NULL AS sp,
NULL AS time_sec,
NULL AS time_distance,
D.peso_reciente AS peso_galgo,
B.entrenador AS entrenador_nombre,
C.galgo_padre AS galgo_padre,
C.galgo_madre AS galgo_madre,
C.nacimiento AS nacimiento,
NULL AS comment,
DATEDIFF(dia, C.nacimiento) AS edad_en_dias
FROM datos_desa.tb_cg_semillas_sportium_d A

LEFT JOIN datos_desa.tb_galgo_y_su_entrenador B ON (A.galgo_nombre=B.galgo_nombre)

LEFT JOIN datos_desa.tb_galgos_nacimientos C ON (A.galgo_nombre=C.galgo_nombre)

LEFT JOIN datos_desa.tb_galgos_peso_mas_reciente D ON (A.galgo_nombre=D.galgo_nombre)
;

SELECT count(*) AS num_galgos_POS_futuras FROM datos_desa.tb_galgos_posiciones_en_carreras 
WHERE ( id_carrera >= @min_id_carreras_artificiales AND id_carrera <= @max_id_carreras_artificiales);


SELECT * FROM datos_desa.tb_galgos_posiciones_en_carreras 
WHERE ( id_carrera >= @min_id_carreras_artificiales AND id_carrera <= @max_id_carreras_artificiales)
ORDER BY id_carrera ASC LIMIT 10;
EOF

echo -e $(date +"%T")" SEMILLAS (FUTURAS) - Tablas base..." 2>&1 1>>${LOG_DESCARGA_BRUTO}
echo -e "$CONSULTA_SEMILLAS_FILAS_ARTIFICIALES_TABLASBASE" 2>&1 1>>${LOG_DESCARGA_BRUTO}
mysql -u root --password=datos1986 --execute="$CONSULTA_SEMILLAS_FILAS_ARTIFICIALES_TABLASBASE" 2>&1 1>>${LOG_DESCARGA_BRUTO}

echo -e $(date +"%T")" SEMILLAS (FUTURAS) - Carreras..." 2>&1 1>>${LOG_DESCARGA_BRUTO}
echo -e "$CONSULTA_SEMILLAS_FILAS_ARTIFICIALES_CARRERAS" 2>&1 1>>${LOG_DESCARGA_BRUTO}
mysql -u root --password=datos1986 --execute="$CONSULTA_SEMILLAS_FILAS_ARTIFICIALES_CARRERAS" 2>&1 1>>${LOG_DESCARGA_BRUTO}

echo -e $(date +"%T")" SEMILLAS (FUTURAS) - Historico..." 2>&1 1>>${LOG_DESCARGA_BRUTO}
echo -e "$CONSULTA_SEMILLAS_FILAS_ARTIFICIALES_HISTORICO" 2>&1 1>>${LOG_DESCARGA_BRUTO}
mysql -u root --password=datos1986 --execute="$CONSULTA_SEMILLAS_FILAS_ARTIFICIALES_HISTORICO" 2>&1 1>>${LOG_DESCARGA_BRUTO}

echo -e $(date +"%T")" SEMILLAS (FUTURAS) - Posiciones..." 2>&1 1>>${LOG_DESCARGA_BRUTO}
echo -e "$CONSULTA_SEMILLAS_FILAS_ARTIFICIALES_POSICIONES" 2>&1 1>>${LOG_DESCARGA_BRUTO}
mysql -u root --password=datos1986 --execute="$CONSULTA_SEMILLAS_FILAS_ARTIFICIALES_POSICIONES" 2>&1 1>>${LOG_DESCARGA_BRUTO}


##########################################

echo -e $(date +"%T")" | 010 | Descarga datos brutos | FIN" >>$LOG_070




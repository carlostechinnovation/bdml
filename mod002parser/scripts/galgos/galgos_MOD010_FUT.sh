#!/bin/bash

source "/root/git/bdml/mod002parser/scripts/galgos/funciones.sh"

#Borrar log
rm -f ${LOG_010_FUT}


echo -e $(date +"%T")" | 010_FUT | Insertar datos FUTUROS en datos brutos | INICIO" >>$LOG_070
echo -e "MOD010_FUT --> LOG = "${LOG_010_FUT}


##########################################
echo -e $(date +"%T")" SEMILLAS (FUTURAS) - Metiendo filas artificiales con los datos conocidos de las semillas:" 2>&1 1>>${LOG_010_FUT}

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
INICIAL.* ,
CAST(CONV(C.DHE_incr,10,0) AS UNSIGNED INTEGER) AS id_carrera_artificial
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
SELECT id_carrera_artificial, MAX(clase_reciente) AS clase_reciente, MAX(contador) AS contador
FROM (
  SELECT FUERA.*  FROM datos_desa.tb_clases_recientes_en_carrera_futura FUERA
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
) FUERA2
GROUP BY id_carrera_artificial;

SELECT * FROM datos_desa.tb_carreras_futuras_con_clase_reciente_mas_repetida LIMIT 12;
EOF

echo -e $(date +"%T")" SEMILLAS (FUTURAS) - Tablas base..." 2>&1 1>>${LOG_010_FUT}
echo -e "$CONSULTA_SEMILLAS_FILAS_ARTIFICIALES_TABLASBASE" 2>&1 1>>${LOG_010_FUT}
mysql -u root --password=datos1986 --execute="$CONSULTA_SEMILLAS_FILAS_ARTIFICIALES_TABLASBASE" 2>&1 1>>${LOG_010_FUT}
echo -e "\n-------------------------------------" 2>&1 1>>${LOG_010_FUT}


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

echo -e $(date +"%T")" SEMILLAS (FUTURAS) - Carreras..." 2>&1 1>>${LOG_010_FUT}
echo -e "$CONSULTA_SEMILLAS_FILAS_ARTIFICIALES_CARRERAS" 2>&1 1>>${LOG_010_FUT}
mysql -u root --password=datos1986 --execute="$CONSULTA_SEMILLAS_FILAS_ARTIFICIALES_CARRERAS" 2>&1 1>>${LOG_010_FUT}
echo -e "\n-------------------------------------" 2>&1 1>>${LOG_010_FUT}


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

echo -e $(date +"%T")" SEMILLAS (FUTURAS) - Historico..." 2>&1 1>>${LOG_010_FUT}
echo -e "$CONSULTA_SEMILLAS_FILAS_ARTIFICIALES_HISTORICO" 2>&1 1>>${LOG_010_FUT}
mysql -u root --password=datos1986 --execute="$CONSULTA_SEMILLAS_FILAS_ARTIFICIALES_HISTORICO" 2>&1 1>>${LOG_010_FUT}
echo -e "\n-------------------------------------" 2>&1 1>>${LOG_010_FUT}


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

echo -e $(date +"%T")" SEMILLAS (FUTURAS) - Posiciones..." 2>&1 1>>${LOG_010_FUT}
echo -e "$CONSULTA_SEMILLAS_FILAS_ARTIFICIALES_POSICIONES" 2>&1 1>>${LOG_010_FUT}
mysql -u root --password=datos1986 --execute="$CONSULTA_SEMILLAS_FILAS_ARTIFICIALES_POSICIONES" 2>&1 1>>${LOG_010_FUT}
echo -e "\n-------------------------------------" 2>&1 1>>${LOG_010_FUT}


##########################################
echo -e $(date +"%T")" | 010 | Descarga datos brutos | FIN" >>$LOG_070




#!/bin/bash

source "/home/carloslinux/git/bdml/mod002parser/scripts/galgos/funciones.sh" 


################ TABLAS de INDICES ####################################################################################
function generarTablasIndices ()
{
echo -e "\n""\n---- TABLAS DE INDICES -------- " 2>&1 1>>${LOG_013}

echo -e "Tablas ORIGINALES:" 2>&1 1>>${LOG_013}
echo -e "datos_desa.tb_galgos_carreras_LIM --> id_carrera" 2>&1 1>>${LOG_013}
echo -e "datos_desa.tb_galgos_posiciones_en_carreras_LIM --> (id_carrera, galgo_nombre)" 2>&1 1>>${LOG_013}
echo -e "datos_desa.tb_galgos_historico_LIM --> (id_carrera, galgo_nombre)" 2>&1 1>>${LOG_013}
echo -e "datos_desa.tb_galgos_agregados_LIM --> galgo_nombre" 2>&1 1>>${LOG_013}

echo -e " Tablas de columnas ELABORADAS (provienen de usar las originales, así que tienen las mismas claves):" 2>&1 1>>${LOG_013}
echo -e "datos_desa.tb_ce_x1b --> galgo_nombre" 2>&1 1>>${LOG_013}
echo -e "datos_desa.tb_ce_x2b --> (id_carrera, galgo_nombre)" 2>&1 1>>${LOG_013}
echo -e "datos_desa.tb_ce_x3b --> trap (se usa con carrera+galgo)" 2>&1 1>>${LOG_013}
echo -e "datos_desa.tb_ce_x4 --> (id_carrera, galgo_nombre)" 2>&1 1>>${LOG_013}
echo -e "datos_desa.tb_ce_x5 --> (id_carrera, galgo_nombre)" 2>&1 1>>${LOG_013}
echo -e "datos_desa.tb_ce_x6e --> (id_carrera, galgo_nombre)" 2>&1 1>>${LOG_013}
echo -e "datos_desa.tb_ce_x7d --> (id_carrera, galgo_nombre)" 2>&1 1>>${LOG_013}
echo -e "datos_desa.tb_ce_x8b --> track (se usa con carrera)" 2>&1 1>>${LOG_013}
echo -e "datos_desa.tb_ce_x9b --> entrenador (se usa con galgo)" 2>&1 1>>${LOG_013}
echo -e "datos_desa.tb_ce_x10b --> (id_carrera, galgo_nombre)" 2>&1 1>>${LOG_013}
echo -e "datos_desa.tb_ce_x11 --> galgo_nombre" 2>&1 1>>${LOG_013}
echo -e "datos_desa.tb_ce_x12b --> id_carrera" 2>&1 1>>${LOG_013}
echo -e "datos_desa.tb_ce_x13 --> (id_carrera, galgo_nombre)" 2>&1 1>>${LOG_013}


echo -e "\n\n-------- 3 Tablas auxiliares con todas las claves extraidas y haciendo DISTINCT (serán las tablas MAESTRAS de índices)-------" 2>&1 1>>${LOG_013}

read -d '' CONSULTA_IDS <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_ids_carreras;
CREATE TABLE datos_desa.tb_ids_carreras AS 
SELECT DISTINCT id_carrera 
FROM (
  SELECT DISTINCT id_carrera FROM datos_desa.tb_galgos_carreras_LIM
  UNION DISTINCT
  SELECT DISTINCT id_carrera FROM datos_desa.tb_galgos_posiciones_en_carreras_LIM
  UNION DISTINCT
  SELECT DISTINCT id_carrera FROM datos_desa.tb_galgos_historico_LIM
) dentro
;
ALTER TABLE datos_desa.tb_ids_carreras ADD INDEX tb_ids_carreras_idx(id_carrera);
SELECT count(*) as num_ids_carreras FROM datos_desa.tb_ids_carreras LIMIT 5;
SELECT * FROM datos_desa.tb_ids_carreras LIMIT 5;


DROP TABLE IF EXISTS datos_desa.tb_ids_galgos;
CREATE TABLE datos_desa.tb_ids_galgos AS 
SELECT DISTINCT galgo_nombre 
FROM (
  SELECT DISTINCT galgo_nombre FROM datos_desa.tb_galgos_posiciones_en_carreras_LIM
  UNION DISTINCT
  SELECT DISTINCT galgo_nombre FROM datos_desa.tb_galgos_historico_LIM
  UNION DISTINCT
  SELECT DISTINCT galgo_nombre FROM datos_desa.tb_galgos_agregados_LIM
) dentro;
ALTER TABLE datos_desa.tb_ids_galgos ADD INDEX tb_ids_galgos_idx(galgo_nombre);
SELECT count(*) AS num_ids_galgos FROM datos_desa.tb_ids_galgos LIMIT 5;
SELECT * FROM datos_desa.tb_ids_galgos LIMIT 5;


DROP TABLE IF EXISTS datos_desa.tb_ids_carrerasgalgos;
CREATE TABLE datos_desa.tb_ids_carrerasgalgos AS
SELECT 
cg, 
cast( substring_index(cg,"|",1)  AS unsigned integer) as id_carrera,
substring_index(cg,"|",-1) AS galgo_nombre
FROM (
  SELECT DISTINCT cg
  FROM (
    SELECT CONCAT(id_carrera,'|',galgo_nombre) as cg FROM datos_desa.tb_galgos_posiciones_en_carreras_LIM
    UNION DISTINCT
    SELECT CONCAT(id_carrera,'|',galgo_nombre) as cg FROM datos_desa.tb_galgos_historico_LIM
  ) dentro
) fuera;

ALTER TABLE datos_desa.tb_ids_carrerasgalgos ADD INDEX tb_ids_carrerasgalgos_idx(id_carrera,galgo_nombre);
SELECT count(*) as num_ids_cg FROM datos_desa.tb_ids_carrerasgalgos LIMIT 5;
SELECT * FROM datos_desa.tb_ids_carrerasgalgos LIMIT 5;
EOF


echo -e "\n$CONSULTA_IDS" 2>&1 1>>${LOG_013}
mysql --execute="$CONSULTA_IDS" 2>&1 1>>${LOG_013}

echo -e "\n"" Comprobacion: las 3 tablas de IDs no deben tener duplicados" 2>&1 1>>${LOG_013}
mysql --execute="SELECT id_carrera, count(*) as num_ids_carreras FROM datos_desa.tb_ids_carreras GROUP BY id_carrera HAVING num_ids_carreras>=2 LIMIT 5;" 2>&1 1>>${LOG_013}
mysql --execute="SELECT galgo_nombre, count(*) as num_ids_galgos FROM datos_desa.tb_ids_galgos GROUP BY galgo_nombre HAVING num_ids_galgos>=2 LIMIT 5;" 2>&1 1>>${LOG_013}
mysql --execute="SELECT cg, count(*) as num_ids_cg FROM datos_desa.tb_ids_carrerasgalgos GROUP BY cg HAVING num_ids_cg>=2 LIMIT 5;" 2>&1 1>>${LOG_013}

}


################ TABLAS PREPARADAS (con columnas elaboradas) ####################################################################################
### ATENCION: MySQL no soporta FULL OUTER JOIN, asi que tenemos 2 opciones:
# - Opcion 1: hacer LEFT OJ + RIGHT OJ, sin null por la izquierda
# - Opcion 2: crear tablas auxiliares de indices (carreras ó galgos ó carrera+galgo), hacer DISTINCT. Luego usar esas tablas haciendo solo LEFT JOINs.

function generarTablasElaboradas ()
{

echo -e "\n\n ---- TABLA ELABORADA 1: [ carrera -> columnas ]" 2>&1 1>>${LOG_013}

read -d '' CONSULTA_ELAB1 <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_elaborada_carreras;

CREATE TABLE datos_desa.tb_elaborada_carreras AS 

SELECT
fuera2.*,
CASE WHEN (distancia<=349) THEN distancia ELSE NULL END as distancia_solo_cortas,
CASE WHEN (distancia>349 AND distancia<=549) THEN distancia ELSE NULL END as distancia_solo_medias,
CASE WHEN (distancia>549) THEN distancia ELSE NULL END as distancia_solo_largas

FROM
(

SELECT 
IFNULL(dentro.id_carrera, GH.id_carrera) AS id_carrera,
IFNULL(dentro.id_campeonato, GH.id_campeonato) AS id_campeonato,
IFNULL(dentro.track, GH.track) AS track,
IFNULL(dentro.clase, GH.clase) AS clase,
IFNULL(dentro.distancia, GH.distancia) AS distancia,

CASE WHEN dlmxjvs=1 THEN 1 ELSE 0 END AS dow_d,
CASE WHEN dlmxjvs=2 THEN 1 ELSE 0 END AS dow_l,
CASE WHEN dlmxjvs=3 THEN 1 ELSE 0 END AS dow_m,
CASE WHEN dlmxjvs=4 THEN 1 ELSE 0 END AS dow_x,
CASE WHEN dlmxjvs=5 THEN 1 ELSE 0 END AS dow_j,
CASE WHEN dlmxjvs=6 THEN 1 ELSE 0 END AS dow_v,
CASE WHEN dlmxjvs=7 THEN 1 ELSE 0 END AS dow_s,
CASE WHEN (dlmxjvs=6 OR dlmxjvs=7 OR dlmxjvs=1) THEN 1 ELSE 0 END AS dow_finde,
CASE WHEN (dlmxjvs<>6 AND dlmxjvs<>7 AND dlmxjvs<>1) THEN 1 ELSE 0 END AS dow_laborable,

num_galgos, 
ROUND(mes_norm,2) AS mes_norm,
hora,premio_primero,premio_segundo,premio_otros,premio_total_carrera,going_allowance_segundos,
fc_1,fc_2,fc_pounds,tc_1,tc_2,tc_3,tc_pounds,

tempMin, tempMax, tempSpan,

ROUND( D.venue_going_std,2 ) AS venue_going_std,
ROUND( D.venue_going_avg,2 ) AS venue_going_avg

FROM (
  SELECT 
  A.id_carrera,

  B.id_campeonato, B.track, B.clase, 
  ROUND(B.distancia,2) AS distancia,
  DAYOFWEEK(concat(B.anio,'-',  LPAD(cast(B.mes as char), 2, '0')    ,'-',B.dia)) AS dlmxjvs,

  ROUND(B.num_galgos,2) AS num_galgos,
  CASE WHEN (B.mes <=7) THEN (-1/6 + B.mes/6) WHEN (B.mes >7) THEN (5/12 - 5* B.mes/144) ELSE 0.5 END AS mes_norm,
  ROUND(B.hora,2 ) AS hora,
  ROUND( B.premio_primero,2) AS premio_primero,
  ROUND( B.premio_segundo,2) AS premio_segundo,
  ROUND( B.premio_otros,2 ) AS premio_otros,
  ROUND( B.premio_total_carrera,2 ) AS premio_total_carrera,
  ROUND( B.going_allowance_segundos,2 ) AS going_allowance_segundos,
  ROUND( B.fc_1,2) AS fc_1,
  ROUND( B.fc_2 ,2 ) AS fc_2,
  ROUND( B.fc_pounds,2 ) AS fc_pounds,
  ROUND( B.tc_1,2 ) AS tc_1,
  ROUND( B.tc_2,2) AS tc_2,
  ROUND( B.tc_3,2) AS tc_3,
  ROUND( B.tc_pounds,2) AS tc_pounds,

  B.tempMin, B.tempMax, B.tempSpan

  FROM datos_desa.tb_ids_carreras A
  LEFT OUTER JOIN datos_desa.tb_galgos_carreras_LIM B ON (A.id_carrera=B.id_carrera)

) dentro

LEFT JOIN (
  SELECT id_carrera, MAX(id_campeonato) AS id_campeonato, MAX(venue) AS track, MAX(clase) AS clase, MAX(distancia) AS distancia
  FROM datos_desa.tb_galgos_historico_LIM GROUP BY id_carrera
) GH
ON (dentro.id_carrera=GH.id_carrera)

LEFT JOIN datos_desa.tb_ce_x8b D 
ON (dentro.track=D.track)

WHERE tempSpan >3 AND tempSpan <14

) fuera2
;


ALTER TABLE datos_desa.tb_elaborada_carreras ADD INDEX tb_elaborada_carreras_idx(id_carrera);
SELECT * FROM datos_desa.tb_elaborada_carreras ORDER BY id_carrera LIMIT 5;
SELECT count(*) as num_elab_carreras FROM datos_desa.tb_elaborada_carreras LIMIT 5;
EOF

echo -e "\n$CONSULTA_ELAB1" 2>&1 1>>${LOG_013}
mysql -t --execute="$CONSULTA_ELAB1" >>${LOG_013}


echo -e "\n\n ---- TABLA ELABORADA 2: [ galgo -> columnas ]" 2>&1 1>>${LOG_013}
read -d '' CONSULTA_ELAB2 <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_elaborada_galgos;

CREATE TABLE datos_desa.tb_elaborada_galgos AS 
SELECT 
A.*,

B.vel_real_cortas_mediana, 
B.vel_real_cortas_max, 
B.vel_going_cortas_mediana, 
B.vel_going_cortas_max, 
B.vel_real_longmedias_mediana, 
B.vel_real_longmedias_max, 
B.vel_going_longmedias_mediana, 
B.vel_going_longmedias_max, 
B.vel_real_largas_mediana, 
B.vel_real_largas_max, 
B.vel_going_largas_mediana, 
B.vel_going_largas_max,

C.vgcortas_med_min,
C.vgcortas_med_max,
C.vgmedias_med_min,
C.vgmedias_med_max,
C.vglargas_med_min,
C.vglargas_med_max

FROM datos_desa.tb_ids_galgos A
LEFT JOIN datos_desa.tb_galgos_agregados_LIM B ON (A.galgo_nombre=B.galgo_nombre)
LEFT JOIN datos_desa.tb_ce_x1b C ON (A.galgo_nombre=C.galgo_nombre)
-- LEFT JOIN datos_desa.tb_ce_x11 D ON (A.galgo_nombre=D.galgo_nombre)

;

ALTER TABLE datos_desa.tb_elaborada_galgos ADD INDEX tb_elaborada_galgos_idx(galgo_nombre);
SELECT * FROM datos_desa.tb_elaborada_galgos ORDER BY galgo_nombre LIMIT 5;
SELECT count(*) as num_elab_galgos FROM datos_desa.tb_elaborada_galgos LIMIT 5;
EOF

echo -e "\n$CONSULTA_ELAB2" 2>&1 1>>${LOG_013}
mysql -t --execute="$CONSULTA_ELAB2" >>${LOG_013}


echo -e "\n\n ---- TABLA ELABORADA 3: [ carrera+galgo -> columnas ]" 2>&1 1>>${LOG_013}
read -d '' CONSULTA_ELAB3_PARTE1 <<- EOF

-- SIMULAMOS FULL OUTER JOIN mediante LEFT y RIGHT-connullizda (alternativa porque MYSQL no soporta FULL)
DROP TABLE IF EXISTS datos_desa.tb_elaborada_carrerasgalgos_fullouterjoin1;

CREATE TABLE datos_desa.tb_elaborada_carrerasgalgos_fullouterjoin1 AS
SELECT 
B.id_carrera,B.galgo_nombre,
B.time_sec, B.time_distance, B.peso_galgo, B.galgo_padre, B.galgo_madre, B.comment, B.edad_en_dias,
C.distancia,  C.stmhcp, C.by_dato, C.galgo_primero_o_segundo, C.venue, C.remarks, C.win_time, C.going, C.clase, C.calculated_time, C.velocidad_real, C.velocidad_con_going,
IFNULL(B.posicion,C.posicion) AS posicion,
IFNULL(B.sp, C.sp) AS sp,
IFNULL(B.id_campeonato, C.id_campeonato) AS id_campeonato,
IFNULL(B.trap, C.trap) AS trap,
C.anio,C.mes,C.dia,
IFNULL(B.entrenador_nombre, C.entrenador) AS entrenador
FROM datos_desa.tb_galgos_posiciones_en_carreras_LIM B
LEFT JOIN datos_desa.tb_galgos_historico_LIM C ON (B.id_carrera=C.id_carrera AND B.galgo_nombre=C.galgo_nombre)

UNION ALL

SELECT 
B.id_carrera,B.galgo_nombre,
B.time_sec, B.time_distance, B.peso_galgo, B.galgo_padre, B.galgo_madre, B.comment, B.edad_en_dias,
C.distancia,  C.stmhcp, C.by_dato, C.galgo_primero_o_segundo, C.venue, C.remarks, C.win_time, C.going, C.clase, C.calculated_time, C.velocidad_real, C.velocidad_con_going,
IFNULL(B.posicion,C.posicion) AS posicion,
IFNULL(B.sp, C.sp) AS sp,
IFNULL(B.id_campeonato, C.id_campeonato) AS id_campeonato,
IFNULL(B.trap, C.trap) AS trap,
C.anio,C.mes,C.dia,
IFNULL(B.entrenador_nombre, C.entrenador) AS entrenador
FROM datos_desa.tb_galgos_posiciones_en_carreras_LIM B
RIGHT JOIN datos_desa.tb_galgos_historico_LIM C ON (B.id_carrera=C.id_carrera AND B.galgo_nombre=C.galgo_nombre)
WHERE (B.id_carrera IS NULL AND B.galgo_nombre IS NULL)
;

ALTER TABLE datos_desa.tb_elaborada_carrerasgalgos_fullouterjoin1 ADD INDEX tb_ecg_foj1ids_idx(id_carrera,galgo_nombre);


DROP TABLE IF EXISTS datos_desa.tb_elaborada_carrerasgalgos_aux1;

CREATE TABLE datos_desa.tb_elaborada_carrerasgalgos_aux1 AS
SELECT 
  A.*,
  B.time_sec, B.time_distance, B.peso_galgo, B.galgo_padre, B.galgo_madre, B.comment, B.edad_en_dias,
  B.distancia,  B.stmhcp, B.by_dato, B.galgo_primero_o_segundo, B.venue, B.remarks, B.win_time, 
  B.going, B.clase, B.calculated_time, B.velocidad_real, B.velocidad_con_going,
  D.experiencia,
  B.posicion, B.sp, B.id_campeonato, B.trap,
  IFNULL(B.anio, D.anio) AS anio,
  IFNULL(B.mes, D.mes) AS mes,
  IFNULL(B.dia, D.dia) AS dia,
  B.entrenador

  FROM datos_desa.tb_ids_carrerasgalgos A
  LEFT JOIN datos_desa.tb_elaborada_carrerasgalgos_fullouterjoin1 B ON (A.id_carrera=B.id_carrera AND A.galgo_nombre=B.galgo_nombre)
  LEFT JOIN datos_desa.tb_ce_x2b D ON (A.id_carrera=D.id_carrera AND A.galgo_nombre=D.galgo_nombre)
;



ALTER TABLE datos_desa.tb_elaborada_carrerasgalgos_aux1 ADD INDEX tb_elaborada_carrerasgalgos_aux1_idx1(trap);
ALTER TABLE datos_desa.tb_elaborada_carrerasgalgos_aux1 ADD INDEX tb_elaborada_carrerasgalgos_aux1_idx2(id_carrera, galgo_nombre);
ALTER TABLE datos_desa.tb_elaborada_carrerasgalgos_aux1 ADD INDEX tb_elaborada_carrerasgalgos_aux1_idx3(id_carrera, galgo_nombre, clase);
ALTER TABLE datos_desa.tb_elaborada_carrerasgalgos_aux1 ADD INDEX tb_elaborada_carrerasgalgos_aux1_idx4(entrenador);

EOF

echo -e "\n$CONSULTA_ELAB3_PARTE1" 2>&1 1>>${LOG_013}
mysql -t --execute="$CONSULTA_ELAB3_PARTE1" >>${LOG_013}

read -d '' CONSULTA_ELAB3 <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_elaborada_carrerasgalgos;

CREATE TABLE datos_desa.tb_elaborada_carrerasgalgos AS 
SELECT
dentro.cg,
CASE WHEN (dentro.id_carrera<100000) THEN true ELSE false END AS futuro,
dentro.id_carrera, 
dentro.galgo_nombre, 
CAST( dentro.time_sec AS DECIMAL(8,6) ) AS time_sec, 
CAST( dentro.time_distance AS DECIMAL(8,6) ) AS time_distance, 
CAST( dentro.peso_galgo AS DECIMAL(8,6) ) AS peso_galgo, 
dentro.galgo_padre, 
dentro.galgo_madre, 
dentro.comment, 
dentro.stmhcp, 
dentro.by_dato, 
dentro.galgo_primero_o_segundo, 
dentro.venue, 
dentro.remarks, 
dentro.win_time, 
dentro.going, 
dentro.calculated_time, 
ROUND( dentro.velocidad_real,2 ) AS velocidad_real, 
ROUND( dentro.velocidad_con_going,2) AS velocidad_con_going, 
ROUND( dentro.experiencia,2) AS experiencia, 
dentro.posicion, 
dentro.id_campeonato,
ROUND( E.trap_factor,2 ) AS trap_factor,
H.experiencia_cualitativo, 
H.experiencia_en_clase, 
ROUND(H.posicion_media_en_clase_por_experiencia,2) AS posicion_media_en_clase_por_experiencia,
I.distancia_centenas, 
ROUND( I.dif_peso,2 ) AS dif_peso,
ROUND( J.posicion_avg,2 ) AS entrenador_posicion_avg,
ROUND( J.posicion_std,2 ) AS entrenador_posicion_std,
ROUND( IFNULL(dentro.edad_en_dias, K.edad_en_dias) ,2 ) AS eed, -- Me fio mas de la pagina de posiciones en carreras que del historico
dentro.trap,
IFNULL(dentro.mes, H.mes) AS mes,
ROUND( IFNULL(dentro.sp,F.sp) ,2 ) AS sp,
IFNULL(dentro.clase, IFNULL(G.clase, H.clase) ) AS clase,
IFNULL(dentro.distancia, I.distancia) AS distancia,
IFNULL(dentro.entrenador, J.entrenador) AS entrenador,
ROUND(L.remarks_puntos_historico,2) AS remarks_puntos_historico,
ROUND(L.remarks_puntos_historico_10d,2) AS remarks_puntos_historico_10d,
ROUND(L.remarks_puntos_historico_20d,2) AS remarks_puntos_historico_20d,
ROUND(L.remarks_puntos_historico_50d,2) AS remarks_puntos_historico_50d

FROM datos_desa.tb_elaborada_carrerasgalgos_aux1 dentro
LEFT JOIN datos_desa.tb_ce_x3b E ON (dentro.trap=E.trap)
LEFT JOIN datos_desa.tb_ce_x4 F ON (dentro.id_carrera=F.id_carrera AND dentro.galgo_nombre=F.galgo_nombre)
LEFT JOIN datos_desa.tb_ce_x5 G ON (dentro.id_carrera=G.id_carrera AND dentro.galgo_nombre=G.galgo_nombre)
LEFT JOIN datos_desa.tb_ce_x6e H ON (dentro.id_carrera=H.id_carrera AND dentro.galgo_nombre=H.galgo_nombre AND dentro.clase=H.clase)
LEFT JOIN datos_desa.tb_ce_x7d I ON (dentro.id_carrera=I.id_carrera AND dentro.galgo_nombre=I.galgo_nombre)
LEFT JOIN datos_desa.tb_ce_x9b J ON (dentro.entrenador=J.entrenador)
LEFT JOIN datos_desa.tb_ce_x10b K ON (dentro.id_carrera=K.id_carrera AND dentro.galgo_nombre=K.galgo_nombre)
LEFT JOIN datos_desa.tb_ce_x13 L ON (dentro.id_carrera=L.id_carrera AND dentro.galgo_nombre=L.galgo_nombre)

WHERE L.remarks_puntos_historico_50d <0.55
AND L.remarks_puntos_historico_20d <0.65
AND L.remarks_puntos_historico_10d <0.65
AND I.dif_peso <11
AND J.posicion_avg >2 AND J.posicion_avg <4
AND J.posicion_std >1 AND J.posicion_std <2 
;

ALTER TABLE datos_desa.tb_elaborada_carrerasgalgos ADD INDEX tb_elaborada_carrerasgalgos_idx(id_carrera,galgo_nombre);
SELECT * FROM datos_desa.tb_elaborada_carrerasgalgos ORDER BY cg LIMIT 5;
SELECT count(*) as num_elab_cg FROM datos_desa.tb_elaborada_carrerasgalgos LIMIT 5;

EOF

echo -e "\n$CONSULTA_ELAB3" 2>&1 1>>${LOG_013}
mysql -t --execute="$CONSULTA_ELAB3" >>${LOG_013}


echo -e "\n\n Comprobacion: las 3 tablas de columnas ELABORADAS no deben tener duplicados (por clave)" 2>&1 1>>${LOG_013}
mysql --execute="SELECT id_carrera, count(*) as num_ids_carreras FROM datos_desa.tb_elaborada_carreras GROUP BY id_carrera HAVING num_ids_carreras>=2 LIMIT 5;" 2>&1 1>>${LOG_013}
mysql --execute="SELECT galgo_nombre, count(*) as num_ids_galgos FROM datos_desa.tb_elaborada_galgos GROUP BY galgo_nombre HAVING num_ids_galgos>=2 LIMIT 5;" 2>&1 1>>${LOG_013}
mysql --execute="SELECT cg, count(*) as num_ids_cg FROM datos_desa.tb_elaborada_carrerasgalgos GROUP BY cg HAVING num_ids_cg>=2 LIMIT 5;" 2>&1 1>>${LOG_013}


echo -e "\n----------- | 013 | Tablas de COLUMNAS ELABORADAS --------------" 2>&1 1>>${LOG_013}
echo -e "datos_desa.tb_elaborada_carreras" 2>&1 1>>${LOG_013}
echo -e "datos_desa.tb_elaborada_galgos" 2>&1 1>>${LOG_013}
echo -e "datos_desa.tb_elaborada_carrerasgalgos" 2>&1 1>>${LOG_013}
echo -e "----------------------------------------------------\n\n\n" 2>&1 1>>${LOG_013}

}


################ BORRAR TABLAS INTERMEDIAS (para no tener tablas inmanejables al final) (no usar eso cuando debugueamos) #############################################
function borrarTablasInnecesarias ()
{
sufijo="${1}"

echo -e " Borrando tablas innecesarias..." 2>&1 1>>${LOG_013}
read -d '' CONSULTA_DROP_TABLAS_INNECESARIAS <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_ce_x1a;
DROP TABLE IF EXISTS datos_desa.tb_ce_x1b;
DROP TABLE IF EXISTS datos_desa.tb_ce_x2a;
DROP TABLE IF EXISTS datos_desa.tb_ce_x2b;
DROP TABLE IF EXISTS datos_desa.tb_ce_x3a;
DROP TABLE IF EXISTS datos_desa.tb_ce_x3b;
DROP TABLE IF EXISTS datos_desa.tb_ce_x4;
DROP TABLE IF EXISTS datos_desa.tb_ce_x5;
DROP TABLE IF EXISTS datos_desa.tb_ce_x6e;
DROP TABLE IF EXISTS datos_desa.tb_ce_x7a;
DROP TABLE IF EXISTS datos_desa.tb_ce_x7b;
DROP TABLE IF EXISTS datos_desa.tb_ce_x7c;
DROP TABLE IF EXISTS datos_desa.tb_ce_x7d;
DROP TABLE IF EXISTS datos_desa.tb_ce_x8a;
DROP TABLE IF EXISTS datos_desa.tb_ce_x8b;
DROP TABLE IF EXISTS datos_desa.tb_ce_x9a;
DROP TABLE IF EXISTS datos_desa.tb_ce_x9b;
DROP TABLE IF EXISTS datos_desa.tb_ce_x10a;
DROP TABLE IF EXISTS datos_desa.tb_ce_x10b;
DROP TABLE IF EXISTS datos_desa.tb_ce_x11;
DROP TABLE IF EXISTS datos_desa.tb_ce_x12a;
DROP TABLE IF EXISTS datos_desa.tb_ce_x12b;
DROP TABLE IF EXISTS datos_desa.tb_gh_y_remarkspuntos_norm3;
DROP TABLE IF EXISTS datos_desa.tb_ce_x13;

DROP TABLE IF EXISTS datos_desa.tb_elaborada_carrerasgalgos_fullouterjoin1;
DROP TABLE IF EXISTS datos_desa.tb_elaborada_carrerasgalgos_aux1;
EOF

echo -e "\n$CONSULTA_DROP_TABLAS_INNECESARIAS" 2>&1 1>>${LOG_013}
mysql -t --execute="$CONSULTA_DROP_TABLAS_INNECESARIAS" >>${LOG_013}

}



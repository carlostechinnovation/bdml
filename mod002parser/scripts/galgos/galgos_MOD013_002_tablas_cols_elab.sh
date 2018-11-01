#!/bin/bash

source "/home/carloslinux/git/bdml/mod002parser/scripts/galgos/funciones.sh"


################ TABLAS de INDICES ####################################################################################
function generarTablasIndices ()
{
echo -e "\n""\n---- TABLAS DE INDICES -------- " 2>&1 1>>${LOG_013}

echo -e "Tablas ORIGINALES:" 2>&1 1>>${LOG_013}
echo -e "datos_desa.tb_galgos_carreras_norm --> id_carrera" 2>&1 1>>${LOG_013}
echo -e "datos_desa.tb_galgos_posiciones_en_carreras_norm --> (id_carrera, galgo_nombre)" 2>&1 1>>${LOG_013}
echo -e "datos_desa.tb_galgos_historico_norm --> (id_carrera, galgo_nombre)" 2>&1 1>>${LOG_013}
echo -e "datos_desa.tb_galgos_agregados_norm --> galgo_nombre" 2>&1 1>>${LOG_013}

echo -e " Tablas de columnas ELABORADAS (provienen de usar las originales, así que tienen las mismas claves):" 2>&1 1>>${LOG_013}
echo -e "datos_desa.tb_ce_x1b --> galgo_nombre" 2>&1 1>>${LOG_013}
echo -e "datos_desa.tb_ce_x2b --> (id_carrera, galgo_nombre)" 2>&1 1>>${LOG_013}
echo -e "datos_desa.tb_ce_x3b --> trap (se usa con carrera+galgo)" 2>&1 1>>${LOG_013}
echo -e "datos_desa.datos_desa.tb_ce_x4 --> (id_carrera, galgo_nombre)" 2>&1 1>>${LOG_013}
echo -e "datos_desa.tb_ce_x5 --> (id_carrera, galgo_nombre)" 2>&1 1>>${LOG_013}
echo -e "datos_desa.tb_ce_x6e --> (id_carrera, galgo_nombre)" 2>&1 1>>${LOG_013}
echo -e "datos_desa.tb_ce_x7d --> (id_carrera, galgo_nombre)" 2>&1 1>>${LOG_013}
echo -e "datos_desa.tb_ce_x8b --> track (se usa con carrera)" 2>&1 1>>${LOG_013}
echo -e "datos_desa.tb_ce_x9b --> entrenador (se usa con galgo)" 2>&1 1>>${LOG_013}
echo -e "datos_desa.tb_ce_x10b --> (id_carrera, galgo_nombre)" 2>&1 1>>${LOG_013}
echo -e "datos_desa.tb_ce_x11 --> galgo_nombre" 2>&1 1>>${LOG_013}
echo -e "datos_desa.tb_ce_x12b --> id_carrera" 2>&1 1>>${LOG_013}
echo -e "datos_desa.tb_ce_x13 --> (id_carrera, galgo_nombre)" 2>&1 1>>${LOG_013}


echo -e "\n""\n-------- 3 Tablas auxiliares con todas las claves extraidas y haciendo DISTINCT (serán las tablas MAESTRAS de índices)-------" 2>&1 1>>${LOG_013}

read -d '' CONSULTA_IDS <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_ids_carreras;
CREATE TABLE datos_desa.tb_ids_carreras AS 
SELECT DISTINCT id_carrera 
FROM (
  SELECT DISTINCT id_carrera FROM datos_desa.tb_galgos_carreras_norm
  UNION DISTINCT
  SELECT DISTINCT id_carrera FROM datos_desa.tb_galgos_posiciones_en_carreras_norm
  UNION DISTINCT
  SELECT DISTINCT id_carrera FROM datos_desa.tb_galgos_historico_norm
) dentro
;
ALTER TABLE datos_desa.tb_ids_carreras ADD INDEX tb_ids_carreras_idx(id_carrera);
SELECT count(*) as num_ids_carreras FROM datos_desa.tb_ids_carreras LIMIT 5;
SELECT * FROM datos_desa.tb_ids_carreras LIMIT 5;


DROP TABLE IF EXISTS datos_desa.tb_ids_galgos;
CREATE TABLE datos_desa.tb_ids_galgos AS 
SELECT DISTINCT galgo_nombre 
FROM (
  SELECT DISTINCT galgo_nombre FROM datos_desa.tb_galgos_posiciones_en_carreras_norm
  UNION DISTINCT
  SELECT DISTINCT galgo_nombre FROM datos_desa.tb_galgos_historico_norm
  UNION DISTINCT
  SELECT DISTINCT galgo_nombre FROM datos_desa.tb_galgos_agregados_norm
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
    SELECT CONCAT(id_carrera,'|',galgo_nombre) as cg FROM datos_desa.tb_galgos_posiciones_en_carreras_norm
    UNION DISTINCT
    SELECT CONCAT(id_carrera,'|',galgo_nombre) as cg FROM datos_desa.tb_galgos_historico_norm
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
IFNULL(dentro.id_carrera, GH.id_carrera) AS id_carrera,
IFNULL(dentro.id_campeonato, GH.id_campeonato) AS id_campeonato,
IFNULL(dentro.track, GH.track) AS track,
IFNULL(dentro.clase, GH.clase) AS clase,
IFNULL(dentro.distancia_norm, GH.distancia_norm) AS distancia_norm,
dow_d, dow_l, dow_m, dow_x, dow_j, dow_v, dow_s, dow_finde, dow_laborable,
num_galgos_norm, mes_norm,hora_norm,premio_primero_norm,premio_segundo_norm,premio_otros_norm,premio_total_carrera_norm,going_allowance_segundos_norm,
fc_1_norm,fc_2_norm,fc_pounds_norm,tc_1_norm,tc_2_norm,tc_3_norm,tc_pounds_norm,

tempMin_norm, tempMax_norm, tempSpan_norm,

CAST( D.venue_going_std AS DECIMAL(8,6) ) AS venue_going_std,
CAST( D.venue_going_avg AS DECIMAL(8,6) ) AS venue_going_avg

FROM (
  SELECT 
  A.id_carrera,

  B.id_campeonato, B.track, B.clase, CAST(B.distancia_norm AS DECIMAL(8,6)) AS distancia_norm,
  B.dow_d, B.dow_l, B.dow_m, B.dow_x, B.dow_j, B.dow_v, B.dow_s, B.dow_finde, B.dow_laborable,

  CAST(C.num_galgos_norm AS DECIMAL(8,6)) AS num_galgos_norm,
  CAST( IFNULL(B.mes_norm, C.mes_norm) AS DECIMAL(8,6) ) AS mes_norm,
  CAST( IFNULL(B.hora_norm, C.hora_norm) AS DECIMAL(8,6) ) AS hora_norm,
  CAST( IFNULL(B.premio_primero_norm, C.premio_primero_norm) AS DECIMAL(8,6) ) AS premio_primero_norm,
  CAST( IFNULL(B.premio_segundo_norm, C.premio_segundo_norm) AS DECIMAL(8,6) ) AS premio_segundo_norm,
  CAST( IFNULL(B.premio_otros_norm, C.premio_otros_norm) AS DECIMAL(8,6) ) AS premio_otros_norm,
  CAST( IFNULL(B.premio_total_carrera_norm, C.premio_total_carrera_norm) AS DECIMAL(8,6) ) AS premio_total_carrera_norm,
  CAST( IFNULL(B.going_allowance_segundos_norm, C.going_allowance_segundos_norm) AS DECIMAL(8,6) ) AS going_allowance_segundos_norm,
  CAST( IFNULL(B.fc_1_norm, C.fc_1_norm) AS DECIMAL(8,6) ) AS fc_1_norm,
  CAST( IFNULL(B.fc_2_norm, C.fc_2_norm) AS DECIMAL(8,6) ) AS fc_2_norm,
  CAST( IFNULL(B.fc_pounds_norm, C.fc_pounds_norm) AS DECIMAL(8,6) ) AS fc_pounds_norm,
  CAST( IFNULL(B.tc_1_norm, C.tc_1_norm) AS DECIMAL(8,6) ) AS tc_1_norm,
  CAST( IFNULL(B.tc_2_norm, C.tc_2_norm) AS DECIMAL(8,6) ) AS tc_2_norm,
  CAST( IFNULL(B.tc_3_norm, C.tc_3_norm) AS DECIMAL(8,6) ) AS tc_3_norm,
  CAST( IFNULL(B.tc_pounds_norm, C.tc_pounds_norm) AS DECIMAL(8,6) ) AS tc_pounds_norm,

  B.tempMin_norm, B.tempMax_norm, B.tempSpan_norm

  FROM datos_desa.tb_ids_carreras A
  LEFT OUTER JOIN datos_desa.tb_galgos_carreras_norm B ON (A.id_carrera=B.id_carrera)
  LEFT JOIN datos_desa.tb_ce_x12b C ON (A.id_carrera=C.id_carrera)
) dentro

LEFT JOIN (
  SELECT id_carrera, MAX(id_campeonato) AS id_campeonato, MAX(venue) AS track, MAX(clase) AS clase, MAX(distancia_norm) AS distancia_norm
  FROM datos_desa.tb_galgos_historico_norm GROUP BY id_carrera
) GH
ON (dentro.id_carrera=GH.id_carrera)

LEFT JOIN datos_desa.tb_ce_x8b D 
ON (dentro.track=D.track)
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

-- CAST( C.vgcortas_max_norm AS DECIMAL(8,6) ) AS vgcortas_max_norm, 
-- CAST( C.vgmedias_max_norm AS DECIMAL(8,6) ) AS vgmedias_max_norm, 
-- CAST( C.vglargas_max_norm AS DECIMAL(8,6) ) AS vglargas_max_norm,

CAST( D.vel_real_cortas_mediana_norm AS DECIMAL(8,6) ) AS vel_real_cortas_mediana_norm, 
CAST( D.vel_real_cortas_max_norm AS DECIMAL(8,6) ) AS vel_real_cortas_max_norm, 
CAST( D.vel_going_cortas_mediana_norm AS DECIMAL(8,6) ) AS vel_going_cortas_mediana_norm, 
CAST( D.vel_going_cortas_max_norm AS DECIMAL(8,6) ) AS vel_going_cortas_max_norm, 
CAST( D.vel_real_longmedias_mediana_norm AS DECIMAL(8,6) ) AS vel_real_longmedias_mediana_norm, 
CAST( D.vel_real_longmedias_max_norm AS DECIMAL(8,6) ) AS vel_real_longmedias_max_norm, 
CAST( D.vel_going_longmedias_mediana_norm AS DECIMAL(8,6) ) AS vel_going_longmedias_mediana_norm, 
CAST( D.vel_going_longmedias_max_norm AS DECIMAL(8,6) ) AS vel_going_longmedias_max_norm, 
CAST( D.vel_real_largas_mediana_norm AS DECIMAL(8,6) ) AS vel_real_largas_mediana_norm, 
CAST( D.vel_real_largas_max_norm AS DECIMAL(8,6) ) AS vel_real_largas_max_norm, 
CAST( D.vel_going_largas_mediana_norm AS DECIMAL(8,6) ) AS vel_going_largas_mediana_norm, 
CAST( D.vel_going_largas_max_norm AS DECIMAL(8,6) ) AS vel_going_largas_max_norm

FROM datos_desa.tb_ids_galgos A
LEFT JOIN datos_desa.tb_galgos_agregados_norm B ON (A.galgo_nombre=B.galgo_nombre)
LEFT JOIN datos_desa.tb_ce_x1b C ON (A.galgo_nombre=C.galgo_nombre)
LEFT JOIN datos_desa.tb_ce_x11 D ON (A.galgo_nombre=D.galgo_nombre)
;

ALTER TABLE datos_desa.tb_elaborada_galgos ADD INDEX tb_elaborada_galgos_idx(galgo_nombre);
SELECT * FROM datos_desa.tb_elaborada_galgos ORDER BY galgo_nombre LIMIT 5;
SELECT count(*) as num_elab_galgos FROM datos_desa.tb_elaborada_galgos LIMIT 5;
EOF

echo -e "\n$CONSULTA_ELAB2" 2>&1 1>>${LOG_013}
mysql -t --execute="$CONSULTA_ELAB2" >>${LOG_013}


echo -e "\n\n ---- TABLA ELABORADA 3: [ carrera+galgo -> columnas ]" 2>&1 1>>${LOG_013}
read -d '' CONSULTA_ELAB3 <<- EOF

-- SIMULAMOS FULL OUTER JOIN mediante LEFT y RIGHT-connullizda (alternativa porque MYSQL no soporta FULL)
DROP TABLE IF EXISTS datos_desa.tb_elaborada_carrerasgalgos_fullouterjoin1;

CREATE TABLE datos_desa.tb_elaborada_carrerasgalgos_fullouterjoin1 AS
SELECT 
B.id_carrera,B.galgo_nombre,
B.time_sec_norm, B.time_distance_norm, B.peso_galgo_norm, B.galgo_padre, B.galgo_madre, B.comment, B.edad_en_dias_norm,
C.distancia_norm,  C.stmhcp, C.by_dato, C.galgo_primero_o_segundo, C.venue, C.remarks, C.win_time, C.going, C.clase, C.calculated_time, C.velocidad_real_norm, C.velocidad_con_going_norm,
IFNULL(B.posicion,C.posicion) AS posicion,
IFNULL(B.sp_norm, C.sp_norm) AS sp_norm,
IFNULL(B.id_campeonato, C.id_campeonato) AS id_campeonato,
IFNULL(B.trap, C.trap) AS trap,
IFNULL(B.trap_norm, C.trap_norm) AS trap_norm,
C.anio,C.mes,C.dia,
IFNULL(B.entrenador_nombre, C.entrenador) AS entrenador
FROM datos_desa.tb_galgos_posiciones_en_carreras_norm B
LEFT JOIN datos_desa.tb_galgos_historico_norm C ON (B.id_carrera=C.id_carrera AND B.galgo_nombre=C.galgo_nombre)

UNION ALL

SELECT 
B.id_carrera,B.galgo_nombre,
B.time_sec_norm, B.time_distance_norm, B.peso_galgo_norm, B.galgo_padre, B.galgo_madre, B.comment, B.edad_en_dias_norm,
C.distancia_norm,  C.stmhcp, C.by_dato, C.galgo_primero_o_segundo, C.venue, C.remarks, C.win_time, C.going, C.clase, C.calculated_time, C.velocidad_real_norm, C.velocidad_con_going_norm,
IFNULL(B.posicion,C.posicion) AS posicion,
IFNULL(B.sp_norm, C.sp_norm) AS sp_norm,
IFNULL(B.id_campeonato, C.id_campeonato) AS id_campeonato,
IFNULL(B.trap, C.trap) AS trap,
IFNULL(B.trap_norm, C.trap_norm) AS trap_norm,
C.anio,C.mes,C.dia,
IFNULL(B.entrenador_nombre, C.entrenador) AS entrenador
FROM datos_desa.tb_galgos_posiciones_en_carreras_norm B
RIGHT JOIN datos_desa.tb_galgos_historico_norm C ON (B.id_carrera=C.id_carrera AND B.galgo_nombre=C.galgo_nombre)
WHERE (B.id_carrera IS NULL AND B.galgo_nombre IS NULL)
;

ALTER TABLE datos_desa.tb_elaborada_carrerasgalgos_fullouterjoin1 ADD INDEX tb_ecg_foj1ids_idx(id_carrera,galgo_nombre);


DROP TABLE IF EXISTS datos_desa.tb_elaborada_carrerasgalgos_aux1;

CREATE TABLE datos_desa.tb_elaborada_carrerasgalgos_aux1 AS
SELECT 
  A.*,
  B.time_sec_norm, B.time_distance_norm, B.peso_galgo_norm, B.galgo_padre, B.galgo_madre, B.comment, B.edad_en_dias_norm,
  B.distancia_norm,  B.stmhcp, B.by_dato, B.galgo_primero_o_segundo, B.venue, B.remarks, B.win_time, B.going, B.clase, B.calculated_time, B.velocidad_real_norm, B.velocidad_con_going_norm,
  D.experiencia,
  B.posicion, B.sp_norm, B.id_campeonato, B.trap, B.trap_norm,
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

DROP TABLE IF EXISTS datos_desa.tb_elaborada_carrerasgalgos;

CREATE TABLE datos_desa.tb_elaborada_carrerasgalgos AS 
SELECT
dentro.cg,
CASE WHEN (dentro.id_carrera<100000) THEN true ELSE false END AS futuro,
dentro.id_carrera, 
dentro.galgo_nombre, 
CAST( dentro.time_sec_norm AS DECIMAL(8,6) ) AS time_sec_norm, 
CAST( dentro.time_distance_norm AS DECIMAL(8,6) ) AS time_distance_norm, 
CAST( dentro.peso_galgo_norm AS DECIMAL(8,6) ) AS peso_galgo_norm, 
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
CAST( dentro.velocidad_real_norm AS DECIMAL(8,6) ) AS velocidad_real_norm, 
CAST( dentro.velocidad_con_going_norm AS DECIMAL(8,6) ) AS velocidad_con_going_norm, 
CAST( dentro.experiencia AS DECIMAL(8,6) ) AS experiencia, 
dentro.posicion, 
dentro.id_campeonato,
CAST( E.trap_factor AS DECIMAL(8,6) ) AS trap_factor,
H.experiencia_cualitativo, 
H.experiencia_en_clase, 
H.posicion_media_en_clase_por_experiencia,
I.distancia_centenas, 
CAST( I.dif_peso AS DECIMAL(8,6) ) AS dif_peso,
CAST( J.entrenador_posicion_norm AS DECIMAL(8,6) ) AS entrenador_posicion_norm,
CAST( IFNULL(dentro.edad_en_dias_norm,K.eed_norm) AS DECIMAL(8,6) ) AS eed_norm, -- Me fio mas de la pagina de posiciones en carreras que del historico
dentro.trap_norm,
IFNULL(dentro.mes, H.mes) AS mes,
CAST( IFNULL(dentro.sp_norm,F.sp_norm) AS DECIMAL(8,6) ) AS sp_norm,
IFNULL(dentro.clase, IFNULL(G.clase, H.clase) ) AS clase,
IFNULL(dentro.distancia_norm, I.distancia_norm) AS distancia_norm,
IFNULL(dentro.entrenador, J.entrenador) AS entrenador,
L.remarks_puntos_historico,
L.remarks_puntos_historico_10d,
L.remarks_puntos_historico_20d,
L.remarks_puntos_historico_50d

FROM datos_desa.tb_elaborada_carrerasgalgos_aux1 dentro
LEFT JOIN datos_desa.tb_ce_x3b E ON (dentro.trap=E.trap)
LEFT JOIN datos_desa.tb_ce_x4 F ON (dentro.id_carrera=F.id_carrera AND dentro.galgo_nombre=F.galgo_nombre)
LEFT JOIN datos_desa.tb_ce_x5 G ON (dentro.id_carrera=G.id_carrera AND dentro.galgo_nombre=G.galgo_nombre)
LEFT JOIN datos_desa.tb_ce_x6e H ON (dentro.id_carrera=H.id_carrera AND dentro.galgo_nombre=H.galgo_nombre AND dentro.clase=H.clase)
LEFT JOIN datos_desa.tb_ce_x7d I ON (dentro.id_carrera=I.id_carrera AND dentro.galgo_nombre=I.galgo_nombre)
LEFT JOIN datos_desa.tb_ce_x9b J ON (dentro.entrenador=J.entrenador)
LEFT JOIN datos_desa.tb_ce_x10b K ON (dentro.id_carrera=K.id_carrera AND dentro.galgo_nombre=K.galgo_nombre)
LEFT JOIN datos_desa.tb_ce_x13 L ON (dentro.id_carrera=L.id_carrera AND dentro.galgo_nombre=L.galgo_nombre)
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





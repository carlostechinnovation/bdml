#!/bin/bash

source "/home/carloslinux/git/bdml/mod002parser/scripts/galgos/funciones.sh"


##########################################################################################
function calcularVariableX1 ()
{

echo -e "\n ---- X1: [(galgo) -> velocidad_max_going]" 2>&1 1>>${LOG_013}
echo -e "Parametros: -->${1}" 2>&1 1>>${LOG_013}


read -d '' CONSULTA_X1 <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_ce_x1a;

CREATE TABLE datos_desa.tb_ce_x1a AS SELECT 1 AS distancia_tipo, MIN(vel_going_cortas_max) AS valor_min, MAX(vel_going_cortas_max) AS valor_max FROM datos_desa.tb_galgos_agregados_norm 
UNION 
SELECT 2 AS distancia_tipo, MIN(vel_going_longmedias_max) AS valor_min, MAX(vel_going_longmedias_max) AS valor_max FROM datos_desa.tb_galgos_agregados_norm 
UNION 
SELECT 3 AS distancia_tipo, MIN(vel_going_largas_max) AS valor_min, MAX(vel_going_largas_max) AS valor_max FROM datos_desa.tb_galgos_agregados_norm;

SELECT * FROM datos_desa.tb_ce_x1a LIMIT 5;
SELECT count(*) as num_x1a FROM datos_desa.tb_ce_x1a LIMIT 5;


DROP TABLE IF EXISTS datos_desa.tb_ce_x1b;

CREATE TABLE datos_desa.tb_ce_x1b AS 
SELECT galgo_nombre,

((vel_going_cortas_max - (select valor_min FROM datos_desa.tb_ce_x1a WHERE distancia_tipo=1) ) / (select valor_max FROM datos_desa.tb_ce_x1a WHERE distancia_tipo=1))-0.5 AS vgcortas_max_norm,

((vel_going_longmedias_max - (select valor_min FROM datos_desa.tb_ce_x1a WHERE distancia_tipo=2) ) / (select valor_max FROM datos_desa.tb_ce_x1a WHERE distancia_tipo=2))-0.5 AS vgmedias_max_norm,

((vel_going_largas_max - (select valor_min FROM datos_desa.tb_ce_x1a WHERE distancia_tipo=3) ) / (select valor_max FROM datos_desa.tb_ce_x1a WHERE distancia_tipo=3))-0.5 AS vglargas_max_norm

FROM datos_desa.tb_galgos_agregados_norm;

ALTER TABLE datos_desa.tb_ce_x1b ADD INDEX tb_ce_x1b_idx(galgo_nombre);
SELECT * FROM datos_desa.tb_ce_x1b LIMIT 5;
SELECT count(*) as num_x1b FROM datos_desa.tb_ce_x1b LIMIT 5;
EOF


echo -e "$CONSULTA_X1" 2>&1 1>>${LOG_013}
mysql --execute="$CONSULTA_X1" >>${LOG_013}
}


##########################################################################################
function calcularVariableX2 ()
{

echo -e "\n ---- X2: [(carrera, galgo) ->experiencia]" 2>&1 1>>${LOG_013}
echo -e "Parametros: -->${1}" 2>&1 1>>${LOG_013}

read -d '' CONSULTA_X2 <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_ce_x2a;

CREATE TABLE datos_desa.tb_ce_x2a AS
SELECT 
id_carrera, galgo_nombre, 
anio,mes,dia,

CASE galgo_nombre 
  WHEN @curGalgoNombre THEN @curRow := @curRow + 1 
  ELSE (@curRow := 1 AND @curGalgoNombre := galgo_nombre )
END AS experiencia

FROM datos_desa.tb_galgos_historico_norm GH,
(SELECT @curRow := 0, @curGalgoNombre := '') R
ORDER BY galgo_nombre ASC, anio ASC, mes ASC, dia ASC;

SELECT * FROM datos_desa.tb_ce_x2a LIMIT 5;
SELECT count(*) as num_x2a FROM datos_desa.tb_ce_x2a LIMIT 5;

set @min_experiencia=(select MIN(experiencia) FROM datos_desa.tb_ce_x2a);
set @diff_experiencia=(select CASE WHEN MIN(experiencia)=0 THEN MAX(experiencia) ELSE MAX(experiencia)-MIN(experiencia) END FROM datos_desa.tb_ce_x2a);


DROP TABLE IF EXISTS datos_desa.tb_ce_x2b;

CREATE TABLE datos_desa.tb_ce_x2b AS 
SELECT id_carrera, galgo_nombre, anio, mes, dia, 
CASE WHEN (experiencia IS NULL OR @diff_experiencia=0) THEN NULL ELSE ((experiencia - @min_experiencia)/@diff_experiencia)-0.5 END AS experiencia
FROM datos_desa.tb_ce_x2a;

ALTER TABLE datos_desa.tb_ce_x2b ADD INDEX tb_ce_x2b_idx(id_carrera, galgo_nombre);
SELECT * FROM datos_desa.tb_ce_x2b LIMIT 5;
SELECT count(*) as num_x2b FROM datos_desa.tb_ce_x2b LIMIT 5;
EOF

echo -e "$CONSULTA_X2" 2>&1 1>>${LOG_013}
mysql --execute="$CONSULTA_X2" >>${LOG_013}

}


##########################################################################################
function calcularVariableX3 ()
{

echo -e "\n ---- X3: [(carrera, galgo) -> (TRAP, trap_factor)]" 2>&1 1>>${LOG_013}
echo -e "Parametros: -->${1}" 2>&1 1>>${LOG_013}


read -d '' CONSULTA_X3 <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_ce_x3a;

CREATE TABLE datos_desa.tb_ce_x3a AS 
SELECT dentro.trap, SUM(dentro.contador) AS trap_suma 
FROM (select trap,posicion,count(*) as contador FROM datos_desa.tb_galgos_historico_norm GROUP BY trap,posicion ORDER BY trap ASC, posicion ASC) dentro 
WHERE posicion IN (1,2) 
GROUP BY dentro.trap;

SELECT * FROM datos_desa.tb_ce_x3a LIMIT 5;
SELECT count(*) as num_x3a FROM datos_desa.tb_ce_x3a LIMIT 5;

set @min_trap_puntos=(select MIN(trap_suma) FROM datos_desa.tb_ce_x3a);
set @diff_trap_puntos=(select CASE WHEN MIN(trap_suma)=0 THEN MAX(trap_suma) ELSE MAX(trap_suma)-MIN(trap_suma) END FROM datos_desa.tb_ce_x3a);


DROP TABLE IF EXISTS datos_desa.tb_ce_x3b;

CREATE TABLE datos_desa.tb_ce_x3b AS 
SELECT trap, 
CASE WHEN (trap_suma IS NULL OR @diff_trap_puntos=0) THEN NULL ELSE ((trap_suma - @min_trap_puntos)/@diff_trap_puntos)-0.5 END AS trap_factor
FROM datos_desa.tb_ce_x3a;

ALTER TABLE datos_desa.tb_ce_x3b ADD INDEX tb_ce_x3b_idx(trap);
SELECT * FROM datos_desa.tb_ce_x3b LIMIT 5;
SELECT count(*) as num_x3b FROM datos_desa.tb_ce_x3b LIMIT 5;
EOF

echo -e "$CONSULTA_X3" 2>&1 1>>${LOG_013}
mysql --execute="$CONSULTA_X3" >>${LOG_013}

}


##########################################################################################
function calcularVariableX4 ()
{

echo -e "\n ---- X4: [(carrera, galgo) -> (starting price)]" 2>&1 1>>${LOG_013}
echo -e "Parametros: -->${1}" 2>&1 1>>${LOG_013}

read -d '' CONSULTA_X4 <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_ce_x4;
CREATE TABLE datos_desa.tb_ce_x4 AS 
SELECT id_carrera, galgo_nombre, sp_norm 
FROM datos_desa.tb_galgos_historico_norm  GH;

ALTER TABLE datos_desa.tb_ce_x4 ADD INDEX tb_ce_x4_idx(id_carrera, galgo_nombre);
SELECT * FROM datos_desa.tb_ce_x4 LIMIT 5;
SELECT count(*) as num_x4 FROM datos_desa.tb_ce_x4 LIMIT 5;
EOF

echo -e "$CONSULTA_X4" 2>&1 1>>${LOG_013}
mysql --execute="$CONSULTA_X4" >>${LOG_013}
}


##########################################################################################
function calcularVariableX5 ()
{

echo -e "\n"" ---- X5: [(carrera, galgo) -> (clase)]" 2>&1 1>>${LOG_013}
echo -e "Parametros: -->${1}" 2>&1 1>>${LOG_013}

mysql --execute="DROP TABLE IF EXISTS datos_desa.tb_ce_x5;" >>${LOG_013}
mysql --execute="CREATE TABLE datos_desa.tb_ce_x5 AS SELECT id_carrera, galgo_nombre, clase FROM datos_desa.tb_galgos_historico_norm  GH;" >>${LOG_013}
mysql --execute="ALTER TABLE datos_desa.tb_ce_x5 ADD INDEX tb_ce_x5_idx(id_carrera, galgo_nombre);" >>${LOG_013}
mysql --execute="SELECT * FROM datos_desa.tb_ce_x5 LIMIT 5;" >>${LOG_013}
mysql --execute="SELECT count(*) as num_x5 FROM datos_desa.tb_ce_x5 LIMIT 5;" >>${LOG_013}
}


##########################################################################################
function calcularVariableX6 ()
{

echo -e "\n"" ---- X6 - POSICION media por experiencia en una clase. Un perro que corre en una carrera tiene X experiencia corriendo en esa clase. Asignamos la posición media que le correspondería tener a ese perro por tener esa experiencia X en esa clase. Agrupamos por rangos de experiencia (baja, media, alta) en función de unos umbrales calculados empiricamente." 2>&1 1>>${LOG_013}

echo -e " X6: [(carrera, galgo, clase) -> (posicion_media según su experiencia en esa clase)]" 2>&1 1>>${LOG_013}
echo -e " Parametros: -->${1}" 2>&1 1>>${LOG_013}

read -d '' CONSULTA_X6A <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_ce_x6a;

CREATE TABLE datos_desa.tb_ce_x6a AS 
SELECT 
galgo_nombre, 
clase, 
COUNT(posicion) AS experiencia_en_clase, 
AVG(posicion) AS posicion_media_en_clase
FROM datos_desa.tb_galgos_historico_norm  
GROUP BY galgo_nombre, clase;

SELECT * FROM datos_desa.tb_ce_x6a LIMIT 5;
SELECT count(*) as num_x6a FROM datos_desa.tb_ce_x6a LIMIT 5;
EOF

echo -e "\n$CONSULTA_X6A" 2>&1 1>>${LOG_013}
mysql --execute="$CONSULTA_X6A" >>${LOG_013}
sleep 2s

read -d '' CONSULTA_X6B <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_ce_x6b;

CREATE TABLE datos_desa.tb_ce_x6b AS 
SELECT clase, 
CASE WHEN experiencia_en_clase>=13 THEN 'alta' 
     WHEN (experiencia_en_clase>=5 AND experiencia_en_clase<13) THEN 'media' 
     ELSE 'baja' 
END AS experiencia_cualitativo, 
AVG(posicion_media_en_clase) AS posicion_media_en_clase_por_experiencia 
FROM datos_desa.tb_ce_x6a 
GROUP BY clase, experiencia_cualitativo 
ORDER BY clase ASC, experiencia_cualitativo ASC;

ALTER TABLE datos_desa.tb_ce_x6b ADD INDEX tb_ce_x6b_idx(clase, experiencia_cualitativo);

SELECT * FROM datos_desa.tb_ce_x6b LIMIT 5;
SELECT count(*) as num_x6b FROM datos_desa.tb_ce_x6b LIMIT 5;

set @min_posicion_media_en_clase_por_experiencia=(select MIN(posicion_media_en_clase_por_experiencia) FROM datos_desa.tb_ce_x6b);

set @diff_posicion_media_en_clase_por_experiencia=(select CASE WHEN MIN(posicion_media_en_clase_por_experiencia)=0 THEN MAX(posicion_media_en_clase_por_experiencia) ELSE MAX(posicion_media_en_clase_por_experiencia) - MIN(posicion_media_en_clase_por_experiencia) END FROM datos_desa.tb_ce_x6b);

SELECT @min_posicion_media_en_clase_por_experiencia AS c1, @diff_posicion_media_en_clase_por_experiencia AS c2 FROM datos_desa.tb_ce_x6b LIMIT 10;
EOF

echo -e "\n$CONSULTA_X6B" 2>&1 1>>${LOG_013}
mysql --execute="$CONSULTA_X6B" >>${LOG_013}
sleep 2s

read -d '' CONSULTA_X6C <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_ce_x6c0;

CREATE TABLE datos_desa.tb_ce_x6c0 AS
SELECT GH.galgo_nombre, GH.id_carrera, GH.anio*10000+GH.mes*100+GH.dia AS amd, GH2.anio*10000+GH2.mes*100+GH2.dia AS amd2, GH.clase AS clase
FROM datos_desa.tb_galgos_historico_norm GH
LEFT JOIN datos_desa.tb_galgos_historico_norm GH2 ON (GH.galgo_nombre=GH2.galgo_nombre AND GH.clase=GH2.clase)
;

ALTER TABLE datos_desa.tb_ce_x6c0 ADD INDEX tb_ce_x6c0_idx1(amd);
ALTER TABLE datos_desa.tb_ce_x6c0 ADD INDEX tb_ce_x6c0_idx2(amd2);
ALTER TABLE datos_desa.tb_ce_x6c0 ADD INDEX tb_ce_x6c0_idx3(amd,amd2);


DROP TABLE IF EXISTS datos_desa.tb_ce_x6c;

CREATE TABLE datos_desa.tb_ce_x6c AS
SELECT galgo_nombre, id_carrera, count(*) AS experiencia_en_clase 
  FROM (
    SELECT galgo_nombre, clase, amd, amd2, id_carrera  
    FROM datos_desa.tb_ce_x6c0 dentro
    WHERE dentro.amd >= dentro.amd2
  ) fuera
GROUP BY galgo_nombre, id_carrera;

ALTER TABLE datos_desa.tb_ce_x6c ADD INDEX tb_ce_x6c_idx1(id_carrera, galgo_nombre);

SELECT * FROM datos_desa.tb_ce_x6c LIMIT 5;
SELECT count(*) as num_x6c FROM datos_desa.tb_ce_x6c LIMIT 5;
EOF

echo -e "\n$CONSULTA_X6C" 2>&1 1>>${LOG_013}
mysql --execute="$CONSULTA_X6C" 2>&1 1>>${LOG_013}
sleep 2s

read -d '' CONSULTA_X6D <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_ce_x6e_aux1;

CREATE TABLE datos_desa.tb_ce_x6e_aux1 AS 
SELECT GH.anio, GH.mes, GH.dia, GH.id_carrera, GH.galgo_nombre, GH.clase,  
  X6C.experiencia_en_clase,
  CASE WHEN (X6C.experiencia_en_clase>=13) THEN 'alta' 
     WHEN (X6C.experiencia_en_clase>=5 AND X6C.experiencia_en_clase<13) THEN 'media'
     ELSE 'baja' 
  END AS experiencia_cualitativo

  FROM datos_desa.tb_galgos_historico_norm GH 
  LEFT JOIN datos_desa.tb_ce_x6c X6C ON (GH.id_carrera=X6C.id_carrera AND GH.galgo_nombre=X6C.galgo_nombre)
;

ALTER TABLE datos_desa.tb_ce_x6e_aux1 ADD INDEX tb_ce_x6e_aux1_idx1(galgo_nombre, clase);
ALTER TABLE datos_desa.tb_ce_x6e_aux1 ADD INDEX tb_ce_x6e_aux1_idx2(clase, experiencia_cualitativo);
SELECT * FROM datos_desa.tb_ce_x6e_aux1 LIMIT 5;
SELECT count(*) as num_x6e_aux1 FROM datos_desa.tb_ce_x6e_aux1 LIMIT 5;

EOF


echo -e "\n$CONSULTA_X6D" 2>&1 1>>${LOG_013}
mysql --execute="$CONSULTA_X6D" 2>&1 1>>${LOG_013}
sleep 2s

read -d '' CONSULTA_X6E <<- EOF
set @min_experiencia_en_clase=(select MIN(experiencia_en_clase) AS min_eec FROM datos_desa.tb_ce_x6e_aux1);

set @diff_experiencia_en_clase=(select CASE WHEN MIN(experiencia_en_clase)=0 THEN MAX(experiencia_en_clase) ELSE MAX(experiencia_en_clase) - MIN(experiencia_en_clase) END AS dif_eec FROM datos_desa.tb_ce_x6e_aux1);

set @min_posicion_media_en_clase_por_experiencia=(select MIN(posicion_media_en_clase_por_experiencia) FROM datos_desa.tb_ce_x6b);

set @diff_posicion_media_en_clase_por_experiencia=(select CASE WHEN MIN(posicion_media_en_clase_por_experiencia)=0 THEN MAX(posicion_media_en_clase_por_experiencia) ELSE MAX(posicion_media_en_clase_por_experiencia) - MIN(posicion_media_en_clase_por_experiencia) END FROM datos_desa.tb_ce_x6b);


DROP TABLE IF EXISTS datos_desa.tb_ce_x6e;

CREATE TABLE datos_desa.tb_ce_x6e AS 
SELECT

cruce1.experiencia_en_clase AS c1,
@diff_experiencia_en_clase AS c2,
@min_experiencia_en_clase AS c3,
X6B.posicion_media_en_clase_por_experiencia AS c4,
@diff_posicion_media_en_clase_por_experiencia AS c5,
@min_posicion_media_en_clase_por_experiencia AS c6,

cruce1.id_carrera,
cruce1.galgo_nombre,
cruce1.clase,
CASE WHEN (cruce1.experiencia_en_clase IS NULL OR @diff_experiencia_en_clase=0) THEN NULL ELSE ((cruce1.experiencia_en_clase - @min_experiencia_en_clase)/@diff_experiencia_en_clase)-0.5 END AS experiencia_en_clase,
cruce1.experiencia_cualitativo,
CASE WHEN (X6B.posicion_media_en_clase_por_experiencia IS NULL OR @diff_posicion_media_en_clase_por_experiencia=0) THEN NULL ELSE ((X6B.posicion_media_en_clase_por_experiencia - @min_posicion_media_en_clase_por_experiencia)/@diff_posicion_media_en_clase_por_experiencia)-0.5 END AS posicion_media_en_clase_por_experiencia,
anio, mes, dia
FROM datos_desa.tb_ce_x6e_aux1 cruce1
LEFT JOIN datos_desa.tb_ce_x6b X6B ON (cruce1.clase=X6B.clase AND cruce1.experiencia_cualitativo=X6B.experiencia_cualitativo)
;

ALTER TABLE datos_desa.tb_ce_x6e ADD INDEX tb_ce_x6e_idx(id_carrera, galgo_nombre, clase);
SELECT * FROM datos_desa.tb_ce_x6e LIMIT 5;
SELECT count(*) as num_x6e FROM datos_desa.tb_ce_x6e LIMIT 5;
EOF


echo -e "\n-----------------------------------------\n" 2>&1 1>>${LOG_013}
echo -e "\n${CONSULTA_X6E}" 2>&1 1>>${LOG_013}
mysql --execute="${CONSULTA_X6E}" 2>&1 1>>${LOG_013}

# Limpieza
mysql --execute="DROP TABLE IF EXISTS datos_desa.tb_ce_x6a;" 2>&1 1>>${LOG_013}
mysql --execute="DROP TABLE IF EXISTS datos_desa.tb_ce_x6b;" 2>&1 1>>${LOG_013}
mysql --execute="DROP TABLE IF EXISTS datos_desa.tb_ce_x6c0;" 2>&1 1>>${LOG_013}
mysql --execute="DROP TABLE IF EXISTS datos_desa.tb_ce_x6c;" 2>&1 1>>${LOG_013}
mysql --execute="DROP TABLE IF EXISTS datos_desa.tb_ce_x6e_aux1;" 2>&1 1>>${LOG_013}
}

##########################################################################################
function calcularVariableX7 ()
{

echo -e "\n ---- X7: diferencia relativa de peso del galgo respecto al PESO MEDIO de los galgos que corren en esa DISTANCIA (centenas de metros). Toma valores NULL cuando no hemos descargado las filas de la tabla de posiciones en carrera (que es la que tiene el peso de cada galgo)." 2>&1 1>>${LOG_013}

echo -e " X7: [(carrera, galgo) -> (diferencia respecto al peso medio en esa distancia_centenas)]" 2>&1 1>>${LOG_013}
echo -e " Parametros: -->${1}" 2>&1 1>>${LOG_013}

read -d '' CONSULTA_X7A <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_ce_x7a;

CREATE TABLE datos_desa.tb_ce_x7a AS 
SELECT PO.id_carrera, PO.posicion, PO.peso_galgo, GH.distancia, (GH.distancia/100 - GH.distancia%100/100) AS distancia_centenas 
FROM datos_desa.tb_galgos_posiciones_en_carreras_norm PO 
LEFT JOIN (select id_carrera, MAX(distancia) AS distancia FROM datos_desa.tb_galgos_historico_norm GROUP BY id_carrera) GH 
ON PO.id_carrera=GH.id_carrera 
WHERE PO.posicion IN (1,2) AND GH.distancia IS NOT NULL 
ORDER BY PO.id_carrera ASC, PO.posicion ASC;

SELECT * FROM datos_desa.tb_ce_x7a LIMIT 5;
SELECT count(*) as num_x7a FROM datos_desa.tb_ce_x7a LIMIT 5;
EOF

echo -e "\n$CONSULTA_X7A" 2>&1 1>>${LOG_013}
mysql --execute="$CONSULTA_X7A" >>${LOG_013}
sleep 2s

read -d '' CONSULTA_X7B <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_ce_x7b;

CREATE TABLE datos_desa.tb_ce_x7b AS 
SELECT distancia_centenas, AVG(peso_galgo) AS peso_medio, count(*) as num_a FROM datos_desa.tb_ce_x7a GROUP BY distancia_centenas ORDER BY distancia_centenas ASC;

SELECT * FROM datos_desa.tb_ce_x7b LIMIT 5;
SELECT count(*) as num_x7b FROM datos_desa.tb_ce_x7b LIMIT 5;
EOF

echo -e "\n$CONSULTA_X7B" 2>&1 1>>${LOG_013}
mysql --execute="$CONSULTA_X7B" >>${LOG_013}
sleep 2s

read -d '' CONSULTA_X7C <<- EOF

DROP TABLE IF EXISTS datos_desa.tb_ce_x7c;

CREATE TABLE datos_desa.tb_ce_x7c AS 
SELECT id_carrera, galgo_nombre, dentro.distancia_centenas, dentro.distancia, ABS(dentro.peso_galgo - X7B.peso_medio) AS dif_peso  
FROM
(
  select GH.galgo_nombre, GH.id_carrera, (GH.distancia/100 - GH.distancia%100/100) AS distancia_centenas, GH.distancia, PO.peso_galgo 
  FROM datos_desa.tb_galgos_historico_norm GH
  LEFT JOIN (SELECT galgo_nombre, MAX(peso_galgo) AS peso_galgo FROM datos_desa.tb_galgos_posiciones_en_carreras_norm GROUP BY galgo_nombre) PO
  ON (GH.galgo_nombre=PO.galgo_nombre)
) dentro
LEFT JOIN datos_desa.tb_ce_x7b X7B 
ON (dentro.distancia_centenas=X7B.distancia_centenas)
ORDER BY id_carrera, galgo_nombre;

SELECT * FROM datos_desa.tb_ce_x7c LIMIT 5;
SELECT count(*) as num_x7c FROM datos_desa.tb_ce_x7c LIMIT 5;
EOF

echo -e "\n$CONSULTA_X7C" 2>&1 1>>${LOG_013}
mysql --execute="$CONSULTA_X7C" >>${LOG_013}
sleep 2s

read -d '' CONSULTA_X7D <<- EOF

set @min_dif_peso=(select MIN(dif_peso) FROM datos_desa.tb_ce_x7c);
set @diff_dif_peso=(select CASE WHEN MIN(dif_peso)=0 THEN MAX(dif_peso) ELSE MAX(dif_peso)-MIN(dif_peso) END FROM datos_desa.tb_ce_x7c);
set @min_distancia=(select MIN(distancia) FROM datos_desa.tb_ce_x7c);
set @diff_distancia=(select CASE WHEN MIN(distancia)=0 THEN MAX(distancia) ELSE MAX(distancia)-MIN(distancia) END FROM datos_desa.tb_ce_x7c);


DROP TABLE IF EXISTS datos_desa.tb_ce_x7d;

CREATE TABLE datos_desa.tb_ce_x7d AS 
SELECT id_carrera, galgo_nombre, distancia_centenas, 
CASE WHEN (distancia IS NULL OR @diff_distancia=0) THEN NULL ELSE ((distancia - @min_distancia)/@diff_distancia)-0.5 END AS distancia_norm,
CASE WHEN (dif_peso IS NULL OR @diff_dif_peso=0) THEN NULL ELSE ((dif_peso - @min_dif_peso)/@diff_dif_peso)-0.5 END AS dif_peso
FROM datos_desa.tb_ce_x7c;

ALTER TABLE datos_desa.tb_ce_x7d ADD INDEX tb_ce_x7d_idx(id_carrera, galgo_nombre);
SELECT * FROM datos_desa.tb_ce_x7d LIMIT 5;
SELECT count(*) as num_x7d FROM datos_desa.tb_ce_x7d LIMIT 5;
EOF

echo -e "\n$CONSULTA_X7D" 2>&1 1>>${LOG_013}
mysql --execute="$CONSULTA_X7D" >>${LOG_013}
sleep 2s
}


##########################################################################################
function calcularVariableX8 ()
{

echo -e "\n ---- X8: [carrera -> (going_avg, going_std)]. \nIndica si el estadio tiene mucha correccion (going allowance), normalmente debido al viento, lluvia, etc." 2>&1 1>>${LOG_013}
echo -e " Parametros: -->${1}" 2>&1 1>>${LOG_013}

read -d '' CONSULTA_X8 <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_ce_x8a;

CREATE TABLE datos_desa.tb_ce_x8a AS 
SELECT track, STD(going_abs) AS venue_going_std, AVG(going_abs) AS venue_going_avg 
FROM (select track, ABS(going_allowance_segundos) AS going_abs FROM datos_desa.tb_galgos_carreras_norm) dentro 
GROUP BY dentro.track
;
SELECT * FROM datos_desa.tb_ce_x8a LIMIT 5;
SELECT count(*) as num_x8a FROM datos_desa.tb_ce_x8a LIMIT 5;

set @min_vgs=(select MIN(venue_going_std) FROM datos_desa.tb_ce_x8a);
set @diff_vgs=(select CASE WHEN MIN(venue_going_std)=0 THEN MAX(venue_going_std) ELSE MAX(venue_going_std)-MIN(venue_going_std) END FROM datos_desa.tb_ce_x8a);
set @min_vga=(select MIN(venue_going_avg) FROM datos_desa.tb_ce_x8a);
set @diff_vga=(select CASE WHEN MIN(venue_going_avg)=0 THEN MAX(venue_going_avg) ELSE MAX(venue_going_avg)-MIN(venue_going_avg) END FROM datos_desa.tb_ce_x8a);


DROP TABLE IF EXISTS datos_desa.tb_ce_x8b;

CREATE TABLE datos_desa.tb_ce_x8b AS 
SELECT track,
CASE WHEN (venue_going_std IS NULL OR @diff_vgs=0) THEN NULL ELSE ((venue_going_std - @min_vgs)/@diff_vgs)-0.5 END AS venue_going_std,
CASE WHEN (venue_going_avg IS NULL OR @diff_vga=0) THEN NULL ELSE ((venue_going_avg - @min_vga)/@diff_vga)-0.5 END AS venue_going_avg
FROM datos_desa.tb_ce_x8a;

ALTER TABLE datos_desa.tb_ce_x8b ADD INDEX tb_ce_x8b_idx(track);
SELECT * FROM datos_desa.tb_ce_x8b LIMIT 5;
SELECT count(*) as num_x8a FROM datos_desa.tb_ce_x8b LIMIT 5;
EOF

echo -e "\n$CONSULTA_X8" 2>&1 1>>${LOG_013}
mysql --execute="$CONSULTA_X8" >>${LOG_013}
}


##########################################################################################
function calcularVariableX9 ()
{

echo -e "\n ---- X9: [entrenador -> puntos]. Calidad del ENTRENADOR" 2>&1 1>>${LOG_013}
echo -e " Parametros: -->${1}" 2>&1 1>>${LOG_013}

read -d '' CONSULTA_X9 <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_ce_x9a;

CREATE TABLE datos_desa.tb_ce_x9a AS 
SELECT entrenador, AVG(posicion) AS posicion_avg, STD(posicion) AS posicion_std 
FROM datos_desa.tb_galgos_historico_norm 
GROUP BY entrenador;

SELECT * FROM datos_desa.tb_ce_x9a LIMIT 5;
SELECT count(*) as num_x9a FROM datos_desa.tb_ce_x9a LIMIT 5;


DROP TABLE IF EXISTS datos_desa.tb_ce_x9b;

CREATE TABLE datos_desa.tb_ce_x9b AS 
SELECT entrenador, ((6-posicion_avg)/5)-0.5 AS entrenador_posicion_norm FROM datos_desa.tb_ce_x9a;

ALTER TABLE datos_desa.tb_ce_x9b ADD INDEX tb_ce_x9b_idx(entrenador);
SELECT * FROM datos_desa.tb_ce_x9b LIMIT 5;
SELECT count(*) as num_x9b FROM datos_desa.tb_ce_x9b LIMIT 5;
EOF

echo -e "\n$CONSULTA_X9" 2>&1 1>>${LOG_013}
mysql --execute="$CONSULTA_X9" >>${LOG_013}
}


##########################################################################################
function calcularVariableX10 ()
{

echo -e "\n ---- X10: [(carrera, galgo) -> (edad_en_dias)]" 2>&1 1>>${LOG_013}
echo -e " Parametros: -->${1}" 2>&1 1>>${LOG_013}

read -d '' CONSULTA_X10 <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_ce_x10a;

CREATE TABLE datos_desa.tb_ce_x10a AS 
SELECT id_carrera, galgo_nombre, edad_en_dias
FROM datos_desa.tb_galgos_historico_norm;

SELECT * FROM datos_desa.tb_ce_x10a LIMIT 5;
SELECT count(*) as num_x10a FROM datos_desa.tb_ce_x10a LIMIT 5;

set @min_eed=(select MIN(edad_en_dias) FROM datos_desa.tb_ce_x10a);
set @diff_eed=(select CASE WHEN MIN(edad_en_dias)=0 THEN MAX(edad_en_dias) ELSE MAX(edad_en_dias)-MIN(edad_en_dias) END FROM datos_desa.tb_ce_x10a);


DROP TABLE IF EXISTS datos_desa.tb_ce_x10b;

CREATE TABLE datos_desa.tb_ce_x10b AS 
SELECT id_carrera, galgo_nombre,
CASE WHEN (edad_en_dias IS NULL OR @diff_eed=0) THEN NULL ELSE ((edad_en_dias - @min_eed)/@diff_eed)-0.5 END AS eed_norm
FROM datos_desa.tb_ce_x10a;

ALTER TABLE datos_desa.tb_ce_x10b ADD INDEX tb_ce_x10b_idx(id_carrera, galgo_nombre);
SELECT * FROM datos_desa.tb_ce_x10b LIMIT 5;
SELECT count(*) as num_x10b FROM datos_desa.tb_ce_x10b LIMIT 5;
EOF

echo -e "\n$CONSULTA_X10" 2>&1 1>>${LOG_013}
mysql --execute="$CONSULTA_X10" >>${LOG_013}
}

##########################################################################################
function calcularVariableX11 ()
{

echo -e "\n ---- X11: [(galgo) -> (agregados normalizados del galgo)]" 2>&1 1>>${LOG_013}
echo -e " Parametros: -->${1}" 2>&1 1>>${LOG_013}

#vel_real_cortas_mediana | vel_real_cortas_max | vel_going_cortas_mediana | vel_going_cortas_max | 
#vel_real_longmedias_mediana | vel_real_longmedias_max | vel_going_longmedias_mediana | vel_going_longmedias_max | 
#vel_real_largas_mediana | vel_real_largas_max | vel_going_largas_mediana | vel_going_largas_max

read -d '' CONSULTA_X11 <<- EOF
set @min_vrc_med=(select MIN(vel_real_cortas_mediana) FROM datos_desa.tb_galgos_agregados_norm);
set @diff_vrc_med=(select CASE WHEN MIN(vel_real_cortas_mediana)=0 THEN MAX(vel_real_cortas_mediana) ELSE MAX(vel_real_cortas_mediana)-MIN(vel_real_cortas_mediana) END FROM datos_desa.tb_galgos_agregados_norm);
set @min_vrc_max=(select MIN(vel_real_cortas_max) FROM datos_desa.tb_galgos_agregados_norm);
set @diff_vrc_max=(select CASE WHEN MIN(vel_real_cortas_max)=0 THEN MAX(vel_real_cortas_max) ELSE MAX(vel_real_cortas_max)-MIN(vel_real_cortas_max) END FROM datos_desa.tb_galgos_agregados_norm);
set @min_vgc_med=(select MIN(vel_going_cortas_mediana) FROM datos_desa.tb_galgos_agregados_norm);
set @diff_vgc_med=(select CASE WHEN MIN(vel_going_cortas_mediana)=0 THEN MAX(vel_going_cortas_mediana) ELSE MAX(vel_going_cortas_mediana)-MIN(vel_going_cortas_mediana) END FROM datos_desa.tb_galgos_agregados_norm);
set @min_vgc_max=(select MIN(vel_going_cortas_max) FROM datos_desa.tb_galgos_agregados_norm);
set @diff_vgc_max=(select CASE WHEN MIN(vel_going_cortas_max)=0 THEN MAX(vel_going_cortas_max) ELSE MAX(vel_going_cortas_max)-MIN(vel_going_cortas_max) END FROM datos_desa.tb_galgos_agregados_norm);

set @min_vrlm_med=(select MIN(vel_real_longmedias_mediana) FROM datos_desa.tb_galgos_agregados_norm);
set @diff_vrlm_med=(select CASE WHEN MIN(vel_real_longmedias_mediana)=0 THEN MAX(vel_real_longmedias_mediana) ELSE MAX(vel_real_longmedias_mediana)-MIN(vel_real_longmedias_mediana) END FROM datos_desa.tb_galgos_agregados_norm);
set @min_vrlm_max=(select MIN(vel_real_longmedias_max) FROM datos_desa.tb_galgos_agregados_norm);
set @diff_vrlm_max=(select CASE WHEN MIN(vel_real_longmedias_max)=0 THEN MAX(vel_real_longmedias_max) ELSE MAX(vel_real_longmedias_max)-MIN(vel_real_longmedias_max) END FROM datos_desa.tb_galgos_agregados_norm);
set @min_vglm_med=(select MIN(vel_going_longmedias_mediana) FROM datos_desa.tb_galgos_agregados_norm);
set @diff_vglm_med=(select CASE WHEN MIN(vel_going_longmedias_mediana)=0 THEN MAX(vel_going_longmedias_mediana) ELSE MAX(vel_going_longmedias_mediana)-MIN(vel_going_longmedias_mediana) END FROM datos_desa.tb_galgos_agregados_norm);
set @min_vglm_max=(select MIN(vel_going_longmedias_max) FROM datos_desa.tb_galgos_agregados_norm);
set @diff_vglm_max=(select CASE WHEN MIN(vel_going_longmedias_max)=0 THEN MAX(vel_going_longmedias_max) ELSE MAX(vel_going_longmedias_max)-MIN(vel_going_longmedias_max) END FROM datos_desa.tb_galgos_agregados_norm);

set @min_vrl_med=(select MIN(vel_real_largas_mediana) FROM datos_desa.tb_galgos_agregados_norm);
set @diff_vrl_med=(select CASE WHEN MIN(vel_real_largas_mediana)=0 THEN MAX(vel_real_largas_mediana) ELSE MAX(vel_real_largas_mediana)-MIN(vel_real_largas_mediana) END FROM datos_desa.tb_galgos_agregados_norm);
set @min_vrl_max=(select MIN(vel_real_largas_max) FROM datos_desa.tb_galgos_agregados_norm);
set @diff_vrl_max=(select CASE WHEN MIN(vel_real_largas_max)=0 THEN MAX(vel_real_largas_max) ELSE MAX(vel_real_largas_max)-MIN(vel_real_largas_max) END FROM datos_desa.tb_galgos_agregados_norm);
set @min_vgl_med=(select MIN(vel_going_largas_mediana) FROM datos_desa.tb_galgos_agregados_norm);
set @diff_vgl_med=(select CASE WHEN MIN(vel_going_largas_mediana)=0 THEN MAX(vel_going_largas_mediana) ELSE MAX(vel_going_largas_mediana)-MIN(vel_going_largas_mediana) END FROM datos_desa.tb_galgos_agregados_norm);
set @min_vgl_max=(select MIN(vel_going_largas_max) FROM datos_desa.tb_galgos_agregados_norm);
set @diff_vgl_max=(select CASE WHEN MIN(vel_going_largas_max)=0 THEN MAX(vel_going_largas_max) ELSE MAX(vel_going_largas_max)-MIN(vel_going_largas_max) END FROM datos_desa.tb_galgos_agregados_norm);


DROP TABLE IF EXISTS datos_desa.tb_ce_x11;

CREATE TABLE datos_desa.tb_ce_x11 AS 
SELECT galgo_nombre,

vel_real_cortas_mediana,
CASE WHEN (vel_real_cortas_mediana IS NULL OR @diff_vrc_med=0) THEN NULL ELSE ((vel_real_cortas_mediana - @min_vrc_med)/@diff_vrc_med)-0.5 END AS vel_real_cortas_mediana_norm,
vel_real_cortas_max,
CASE WHEN (vel_real_cortas_max IS NULL OR @diff_vrc_max=0) THEN NULL ELSE ((vel_real_cortas_max - @min_vrc_max)/@diff_vrc_max)-0.5 END AS vel_real_cortas_max_norm,
vel_going_cortas_mediana,
CASE WHEN (vel_going_cortas_mediana IS NULL OR @diff_vgc_med=0) THEN NULL ELSE ((vel_going_cortas_mediana - @min_vgc_med)/@diff_vgc_med)-0.5 END AS vel_going_cortas_mediana_norm,
vel_going_cortas_max,
CASE WHEN (vel_going_cortas_max IS NULL OR @diff_vgc_max=0) THEN NULL ELSE ((vel_going_cortas_max - @min_vgc_max)/@diff_vgc_max)-0.5 END AS vel_going_cortas_max_norm,

vel_real_longmedias_mediana,
CASE WHEN (vel_real_longmedias_mediana IS NULL OR @diff_vrlm_med=0) THEN NULL ELSE ((vel_real_longmedias_mediana - @min_vrlm_med)/@diff_vrlm_med)-0.5 END AS vel_real_longmedias_mediana_norm,
vel_real_longmedias_max,
CASE WHEN (vel_real_longmedias_max IS NULL OR @diff_vrlm_max=0) THEN NULL ELSE ((vel_real_longmedias_max - @min_vrlm_max)/@diff_vrlm_max)-0.5 END AS vel_real_longmedias_max_norm,
vel_going_longmedias_mediana,
CASE WHEN (vel_going_longmedias_mediana IS NULL OR @diff_vglm_med=0) THEN NULL ELSE ((vel_going_longmedias_mediana - @min_vglm_med)/@diff_vglm_med)-0.5 END AS vel_going_longmedias_mediana_norm,
vel_going_longmedias_max,
CASE WHEN (vel_going_longmedias_max IS NULL OR @diff_vglm_max=0) THEN NULL ELSE ((vel_going_longmedias_max - @min_vglm_max)/@diff_vglm_max)-0.5 END AS vel_going_longmedias_max_norm,

vel_real_largas_mediana,
CASE WHEN (vel_real_largas_mediana IS NULL OR @diff_vrl_med=0) THEN NULL ELSE ((vel_real_largas_mediana - @min_vrl_med)/@diff_vrl_med)-0.5 END AS vel_real_largas_mediana_norm,
vel_real_largas_max,
CASE WHEN (vel_real_largas_max IS NULL OR @diff_vrl_max=0) THEN NULL ELSE ((vel_real_largas_max - @min_vrl_max)/@diff_vrl_max)-0.5 END AS vel_real_largas_max_norm,
vel_going_largas_mediana,
CASE WHEN (vel_going_largas_mediana IS NULL OR @diff_vgl_med=0) THEN NULL ELSE ((vel_going_largas_mediana - @min_vgl_med)/@diff_vgl_med)-0.5 END AS vel_going_largas_mediana_norm,
vel_going_largas_max,
CASE WHEN (vel_going_largas_max IS NULL OR @diff_vgl_max=0) THEN NULL ELSE ((vel_going_largas_max - @min_vgl_max)/@diff_vgl_max)-0.5 END AS vel_going_largas_max_norm

FROM datos_desa.tb_galgos_agregados_norm;

ALTER TABLE datos_desa.tb_ce_x11 ADD INDEX tb_ce_x11_idx(galgo_nombre);
SELECT * FROM datos_desa.tb_ce_x11 LIMIT 5;
SELECT count(*) as num_x11 FROM datos_desa.tb_ce_x11 LIMIT 5;
EOF

echo -e "\n$CONSULTA_X11" 2>&1 1>>${LOG_013}
mysql --execute="$CONSULTA_X11" >>${LOG_013}
}

##########################################################################################
function calcularVariableX12 ()
{

echo -e "\n ---- X12: [ carrera -> (propiedades normalizadas de la carrera)]" 2>&1 1>>${LOG_013}
echo -e " Parametros: -->${1}" 2>&1 1>>${LOG_013}

echo -e " PENDIENTE Leer el track (pista) y sacar las caracteristicas de su ubicacion fisica (norte, sur, cerca del mar, altitud, numero de espectadores presenciales, tamaño de la pista...)" 2>&1 1>>${LOG_013}

echo -e " PENDIENTE Leer la clase (tipo de competición) y crear categorias (boolean): tipo A, OR, S... --> SELECT DISTINCT clase FROM datos_desa.tb_galgos_carreras LIMIT 100;" 2>&1 1>>${LOG_013}

read -d '' CONSULTA_X12 <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_ce_x12a;

CREATE TABLE datos_desa.tb_ce_x12a AS 
SELECT
id_carrera,
CASE WHEN (mes <=7) THEN (-1/6 + mes/6) WHEN (mes >7) THEN (5/12 - 5*mes/144) ELSE 0.5 END AS mes,
hora,
num_galgos,
premio_primero, premio_segundo, premio_otros, premio_total_carrera,
going_allowance_segundos,
fc_1, fc_2, fc_pounds, tc_1, tc_2, tc_3, tc_pounds
FROM datos_desa.tb_galgos_carreras_norm;

SELECT * FROM datos_desa.tb_ce_x12a LIMIT 5;
SELECT count(*) as num_x12a FROM datos_desa.tb_ce_x12a LIMIT 5;

set @min_hora=(select MIN(hora) FROM datos_desa.tb_ce_x12a);
set @diff_hora=(select CASE WHEN MIN(hora)=0 THEN MAX(hora) ELSE MAX(hora)-MIN(hora) END FROM datos_desa.tb_ce_x12a);
set @min_num_galgos=(select MIN(num_galgos) FROM datos_desa.tb_ce_x12a);
set @diff_num_galgos=(select CASE WHEN MIN(num_galgos)=0 THEN MAX(num_galgos) ELSE MAX(num_galgos)-MIN(num_galgos) END FROM datos_desa.tb_ce_x12a);
set @min_premio_primero=(select MIN(premio_primero) FROM datos_desa.tb_ce_x12a);
set @diff_premio_primero=(select CASE WHEN MIN(premio_primero)=0 THEN MAX(premio_primero) ELSE MAX(premio_primero)-MIN(premio_primero) END FROM datos_desa.tb_ce_x12a);
set @min_premio_segundo=(select MIN(premio_segundo) FROM datos_desa.tb_ce_x12a);
set @diff_premio_segundo=(select CASE WHEN MIN(premio_segundo)=0 THEN MAX(premio_segundo) ELSE MAX(premio_segundo)-MIN(premio_segundo) END FROM datos_desa.tb_ce_x12a);
set @min_premio_otros=(select MIN(premio_otros) FROM datos_desa.tb_ce_x12a);
set @diff_premio_otros=(select CASE WHEN MIN(premio_otros)=0 THEN MAX(premio_otros) ELSE MAX(premio_otros)-MIN(premio_otros) END FROM datos_desa.tb_ce_x12a);
set @min_premio_total_carrera=(select MIN(premio_total_carrera) FROM datos_desa.tb_ce_x12a);
set @diff_premio_total_carrera=(select CASE WHEN MIN(premio_total_carrera)=0 THEN MAX(premio_total_carrera) ELSE MAX(premio_total_carrera)-MIN(premio_total_carrera) END FROM datos_desa.tb_ce_x12a);
set @min_going_allowance_segundos=(select MIN(going_allowance_segundos) FROM datos_desa.tb_ce_x12a);
set @diff_going_allowance_segundos=(select CASE WHEN MIN(going_allowance_segundos)=0 THEN MAX(going_allowance_segundos) ELSE MAX(going_allowance_segundos)-MIN(going_allowance_segundos) END FROM datos_desa.tb_ce_x12a);
set @min_fc_1=(select MIN(fc_1) FROM datos_desa.tb_ce_x12a);
set @diff_fc_1=(select CASE WHEN MIN(fc_1)=0 THEN MAX(fc_1) ELSE MAX(fc_1)-MIN(fc_1) END FROM datos_desa.tb_ce_x12a);
set @min_fc_2=(select MIN(fc_2) FROM datos_desa.tb_ce_x12a);
set @diff_fc_2=(select CASE WHEN MIN(fc_2)=0 THEN MAX(fc_2) ELSE MAX(fc_2)-MIN(fc_2) END FROM datos_desa.tb_ce_x12a);
set @min_fc_pounds=(select MIN(fc_pounds) FROM datos_desa.tb_ce_x12a);
set @diff_fc_pounds=(select CASE WHEN MIN(fc_pounds)=0 THEN MAX(fc_pounds) ELSE MAX(fc_pounds)-MIN(fc_pounds) END FROM datos_desa.tb_ce_x12a);
set @min_tc_1=(select MIN(tc_1) FROM datos_desa.tb_ce_x12a);
set @diff_tc_1=(select CASE WHEN MIN(tc_1)=0 THEN MAX(tc_1) ELSE MAX(tc_1)-MIN(tc_1) END FROM datos_desa.tb_ce_x12a);
set @min_tc_2=(select MIN(tc_2) FROM datos_desa.tb_ce_x12a);
set @diff_tc_2=(select CASE WHEN MIN(tc_2)=0 THEN MAX(tc_2) ELSE MAX(tc_2)-MIN(tc_2) END FROM datos_desa.tb_ce_x12a);
set @min_tc_3=(select MIN(tc_3) FROM datos_desa.tb_ce_x12a);
set @diff_tc_3=(select CASE WHEN MIN(tc_3)=0 THEN MAX(tc_3) ELSE MAX(tc_3)-MIN(tc_3) END FROM datos_desa.tb_ce_x12a);
set @min_tc_pounds=(select MIN(tc_pounds) FROM datos_desa.tb_ce_x12a);
set @diff_tc_pounds=(select CASE WHEN MIN(tc_pounds)=0 THEN MAX(tc_pounds) ELSE MAX(tc_pounds)-MIN(tc_pounds) END FROM datos_desa.tb_ce_x12a);


DROP TABLE IF EXISTS datos_desa.tb_ce_x12b;

CREATE TABLE datos_desa.tb_ce_x12b AS 
SELECT 
id_carrera,
mes AS mes_norm,
CASE WHEN (hora IS NULL OR @diff_hora=0) THEN NULL ELSE ((hora - @min_hora)/@diff_hora)-0.5 END AS hora_norm,
CASE WHEN (num_galgos IS NULL OR @diff_num_galgos=0) THEN NULL ELSE ((num_galgos - @min_num_galgos)/@diff_num_galgos)-0.5 END AS num_galgos_norm,
CASE WHEN (premio_primero IS NULL OR @diff_premio_primero=0) THEN NULL ELSE ((premio_primero - @min_premio_primero)/@diff_premio_primero)-0.5 END AS premio_primero_norm,
CASE WHEN (premio_segundo IS NULL OR @diff_premio_segundo=0) THEN NULL ELSE ((premio_segundo - @min_premio_segundo)/@diff_premio_segundo)-0.5 END AS premio_segundo_norm,
CASE WHEN (premio_otros IS NULL OR @diff_premio_otros=0) THEN NULL ELSE ((premio_otros - @min_premio_otros)/@diff_premio_otros)-0.5 END AS premio_otros_norm,
CASE WHEN (premio_total_carrera IS NULL OR @diff_premio_total_carrera=0) THEN NULL ELSE ((premio_total_carrera - @min_premio_total_carrera)/@diff_premio_total_carrera)-0.5 END AS premio_total_carrera_norm,
CASE WHEN (going_allowance_segundos IS NULL OR @diff_going_allowance_segundos=0) THEN NULL ELSE ((going_allowance_segundos - @min_going_allowance_segundos)/@diff_going_allowance_segundos)-0.5 END AS going_allowance_segundos_norm,
CASE WHEN (fc_1 IS NULL OR @diff_fc_1=0) THEN NULL ELSE ((fc_1 - @min_fc_1)/@diff_fc_1)-0.5 END AS fc_1_norm,
CASE WHEN (fc_2 IS NULL OR @diff_fc_2=0) THEN NULL ELSE ((fc_2 - @min_fc_2)/@diff_fc_2)-0.5 END AS fc_2_norm,
CASE WHEN (fc_pounds IS NULL OR @diff_fc_pounds=0) THEN NULL ELSE ((fc_pounds - @min_fc_pounds)/@diff_fc_pounds)-0.5 END AS fc_pounds_norm,
CASE WHEN (tc_1 IS NULL OR @diff_tc_1=0) THEN NULL ELSE ((tc_1 - @min_tc_1)/@diff_tc_1)-0.5 END AS tc_1_norm,
CASE WHEN (tc_2 IS NULL OR @diff_tc_2=0) THEN NULL ELSE ((tc_2 - @min_tc_2)/@diff_tc_2)-0.5 END AS tc_2_norm,
CASE WHEN (tc_3 IS NULL OR @diff_tc_3=0) THEN NULL ELSE ((tc_3 - @min_tc_3)/@diff_tc_3)-0.5 END AS tc_3_norm,
CASE WHEN (tc_pounds IS NULL OR @diff_tc_pounds=0) THEN NULL ELSE ((tc_pounds - @min_tc_pounds)/@diff_tc_pounds)-0.5 END AS tc_pounds_norm
FROM datos_desa.tb_ce_x12a;

ALTER TABLE datos_desa.tb_ce_x12b ADD INDEX tb_ce_x12b_idx(id_carrera);
SELECT * FROM datos_desa.tb_ce_x12b LIMIT 5;
SELECT count(*) as num_x12b FROM datos_desa.tb_ce_x12b LIMIT 5;
EOF

echo -e "\n$CONSULTA_X12" 2>&1 1>>${LOG_013}
mysql --execute="$CONSULTA_X12" >>${LOG_013}
}

##########################################################################################
function calcularVariableX13 ()
{

echo -e "\n ---- X13: [(carrera, galgo) -> (scoring_remarks de los ultimos 10/20/50/TODOS los dias anteriores)]" 2>&1 1>>${LOG_013}
echo -e " Media de SCORING_REMARKS considerando las carreras de los 10/20/50 dias anteriores" 2>&1 1>>${LOG_013}
echo -e " Parametros: -->${1}" 2>&1 1>>${LOG_013}


echo -e "cruzarGHyRemarksPuntos: GH LEFT JOIN remarks_puntos. Los puntos finales seran una media/mediana de la 'posición normalizada mirando solo remarks'" 2>&1 1>>${LOG_013}

read -d '' CONSULTA_GH_CRUCE_REMARKS_PUNTOS1 <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_gh_y_remarkspuntos_norm;

CREATE TABLE datos_desa.tb_gh_y_remarkspuntos_norm AS
SELECT galgo_nombre, id_carrera, fecha, AVG(remark_puntos_norm) AS remarks_puntos_norm 
FROM (
    SELECT galgo_nombre, id_carrera, GH.posicion, remarks, RP.remark, RP.remark_puntos_norm,
    DATE(concat(anio,'-',mes,'-',dia)) AS fecha
    FROM datos_desa.tb_galgos_historico_norm GH
    LEFT JOIN (SELECT remark, concat('%',remark,'%') AS remark_buscar, posicion, remark_puntos_norm FROM datos_desa.tb_remarks_puntos) RP
    ON (GH.posicion=RP.posicion AND GH.remarks LIKE RP.remark_buscar )
    ORDER BY galgo_nombre, id_carrera
) dentro
GROUP BY galgo_nombre, id_carrera, fecha
ORDER BY galgo_nombre ASC, fecha ASC
;

ALTER TABLE datos_desa.tb_gh_y_remarkspuntos_norm ADD INDEX tb_gh_y_remarkspuntos_norm_idx1(galgo_nombre, id_carrera);
ALTER TABLE datos_desa.tb_gh_y_remarkspuntos_norm ADD INDEX tb_gh_y_remarkspuntos_norm_idx2(galgo_nombre, fecha);

SELECT count(*) AS num_ghyrmp FROM datos_desa.tb_gh_y_remarkspuntos_norm LIMIT 5;
SELECT * FROM datos_desa.tb_gh_y_remarkspuntos_norm LIMIT 10;
EOF

echo -e "\n\n\n$CONSULTA_GH_CRUCE_REMARKS_PUNTOS1" 2>&1 1>>${LOG_013}
mysql --execute="$CONSULTA_GH_CRUCE_REMARKS_PUNTOS1" 2>&1 1>>${LOG_013}


read -d '' CONSULTA_GH_CRUCE_REMARKS_PUNTOS2 <<- EOF
-- Para cada columna de la izquierda, genero filas por la derecha (con los AAAAMMDD menores que el de la fila actual) 
DROP TABLE IF EXISTS datos_desa.tb_gh_y_remarkspuntos_norm2;

CREATE TABLE datos_desa.tb_gh_y_remarkspuntos_norm2 AS
SELECT 
A.galgo_nombre AS a_nombre, A.id_carrera AS a_idc, A.fecha AS a_fechaint, A.remarks_puntos_norm AS a_puntos, 
B.galgo_nombre AS b_nombre, B.id_carrera AS b_idc, B.fecha AS b_fechaint, B.remarks_puntos_norm AS b_puntos,
DATEDIFF(A.fecha, B.fecha) AS diff_fecha
FROM datos_desa.tb_gh_y_remarkspuntos_norm A
LEFT OUTER JOIN datos_desa.tb_gh_y_remarkspuntos_norm B ON (A.galgo_nombre=B.galgo_nombre AND A.fecha >= B.fecha  )
ORDER BY a_nombre ASC, a_fechaint DESC
;

ALTER TABLE datos_desa.tb_gh_y_remarkspuntos_norm2 ADD INDEX tb_gh_y_remarkspuntos_norm2_idx1(a_nombre, a_fechaint);
ALTER TABLE datos_desa.tb_gh_y_remarkspuntos_norm2 ADD INDEX tb_gh_y_remarkspuntos_norm2_idx2(a_nombre, a_idc, a_fechaint);
SELECT count(*) AS num_ghyrmp2 FROM datos_desa.tb_gh_y_remarkspuntos_norm2 LIMIT 10;
SELECT * FROM datos_desa.tb_gh_y_remarkspuntos_norm2 LIMIT 10;
EOF

echo -e "\n\n\n\n$CONSULTA_GH_CRUCE_REMARKS_PUNTOS2" 2>&1 1>>${LOG_013}
mysql --execute="$CONSULTA_GH_CRUCE_REMARKS_PUNTOS2" 2>&1 1>>${LOG_013}


read -d '' CONSULTA_GH_CRUCE_REMARKS_PUNTOS3 <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_gh_y_remarkspuntos_norm3;

CREATE TABLE datos_desa.tb_gh_y_remarkspuntos_norm3 AS

SELECT 
T_todos.galgo_nombre, T_todos.id_carrera, T_todos.fecha, 

T_todos.remarks_puntos_historico -0.5 AS remarks_puntos_historico,

-- En caso de valores NULL, cojo el valor medio mas cercano usando el historico
-- T10D.remarks_puntos_historico_10d,
-- T20D.remarks_puntos_historico_20d,
-- T50D.remarks_puntos_historico_50d

CASE WHEN (T10D.remarks_puntos_historico_10d IS NOT NULL) THEN T10D.remarks_puntos_historico_10d -0.5 
WHEN (T20D.remarks_puntos_historico_20d IS NOT NULL) THEN T20D.remarks_puntos_historico_20d -0.5
WHEN (T50D.remarks_puntos_historico_50d IS NOT NULL) THEN T50D.remarks_puntos_historico_50d -0.5
ELSE NULL
END AS  remarks_puntos_historico_10d,

CASE WHEN (T20D.remarks_puntos_historico_20d IS NOT NULL) THEN T20D.remarks_puntos_historico_20d -0.5
WHEN (T50D.remarks_puntos_historico_50d IS NOT NULL) THEN T50D.remarks_puntos_historico_50d -0.5
ELSE NULL
END AS remarks_puntos_historico_20d,

(T50D.remarks_puntos_historico_50d -0.5) AS remarks_puntos_historico_50d

FROM 
  (SELECT a_nombre AS galgo_nombre, a_idc AS id_carrera,  a_fechaint AS fecha, AVG(b_puntos) as remarks_puntos_historico FROM datos_desa.tb_gh_y_remarkspuntos_norm2 GROUP BY a_nombre, a_idc, a_fechaint ) T_todos
  
  LEFT JOIN 
  (SELECT a_nombre AS galgo_nombre, a_fechaint AS fecha, AVG(b_puntos) as remarks_puntos_historico_10d FROM datos_desa.tb_gh_y_remarkspuntos_norm2 WHERE diff_fecha<=10 GROUP BY a_nombre, a_fechaint ) T10D
  ON (T_todos.galgo_nombre = T10D.galgo_nombre AND T_todos.fecha = T10D.fecha)

  LEFT JOIN 
  (SELECT a_nombre AS galgo_nombre, a_fechaint AS fecha, AVG(b_puntos) as remarks_puntos_historico_20d FROM datos_desa.tb_gh_y_remarkspuntos_norm2 WHERE diff_fecha<=20 GROUP BY a_nombre, a_fechaint ) T20D
  ON (T_todos.galgo_nombre = T20D.galgo_nombre AND T_todos.fecha = T20D.fecha)

  LEFT JOIN 
  (SELECT a_nombre AS galgo_nombre, a_fechaint AS fecha, AVG(b_puntos) as remarks_puntos_historico_50d FROM datos_desa.tb_gh_y_remarkspuntos_norm2 WHERE diff_fecha<=50 GROUP BY a_nombre, a_fechaint ) T50D
  ON (T_todos.galgo_nombre = T50D.galgo_nombre AND T_todos.fecha = T50D.fecha)
;

ALTER TABLE datos_desa.tb_gh_y_remarkspuntos_norm3 ADD INDEX tb_gh_y_remarkspuntos_norm3_idx(galgo_nombre, id_carrera);
SELECT count(*) AS num_ghyrmp3 FROM datos_desa.tb_gh_y_remarkspuntos_norm3 LIMIT 10;
SELECT * FROM datos_desa.tb_gh_y_remarkspuntos_norm3 LIMIT 10;
EOF

echo -e "\n\n\n$CONSULTA_GH_CRUCE_REMARKS_PUNTOS3" 2>&1 1>>${LOG_013}
mysql --execute="$CONSULTA_GH_CRUCE_REMARKS_PUNTOS3" 2>&1 1>>${LOG_013}

# Limpieza
mysql --execute="DROP TABLE IF EXISTS datos_desa.tb_gh_y_remarkspuntos_norm1;" 2>&1 1>>${LOG_013}
mysql --execute="DROP TABLE IF EXISTS datos_desa.tb_gh_y_remarkspuntos_norm2;" 2>&1 1>>${LOG_013}


############

read -d '' CONSULTA_X13 <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_ce_x13;

CREATE TABLE datos_desa.tb_ce_x13 AS 
SELECT GHRPNM3.* FROM datos_desa.tb_gh_y_remarkspuntos_norm3 GHRPNM3;

ALTER TABLE datos_desa.tb_ce_x13 ADD INDEX tb_ce_x13_idx(galgo_nombre, id_carrera);
SELECT * FROM datos_desa.tb_ce_x13 LIMIT 5;
SELECT count(*) AS num_x13 FROM datos_desa.tb_ce_x13 LIMIT 5;
EOF

echo -e "\n\n\n\n$CONSULTA_X13" 2>&1 1>>${LOG_013}
mysql --execute="$CONSULTA_X13" >>${LOG_013}
}


##########################################################################################




#!/bin/bash

source "/root/git/bdml/mod002parser/scripts/galgos/funciones.sh"

echo -e "Los galgos SEMILLAS deberian tener el SP (STARTING PRICE) si lo conocemos en el instante de la descarga" 2>&1 1>>${LOG_CE}


##########################################################################################
function calcularVariableX1 ()
{
sufijo="${1}"
echo -e "\n ---- X1: [(galgo) -> velocidad_max_going]" 2>&1 1>>${LOG_CE}
echo -e "Parametros: -->${1}" 2>&1 1>>${LOG_CE}


read -d '' CONSULTA_X1 <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x1a;

CREATE TABLE datos_desa.tb_ce_${sufijo}_x1a AS SELECT 1 AS distancia_tipo, MIN(vel_going_cortas_max) AS valor_min, MAX(vel_going_cortas_max) AS valor_max FROM datos_desa.tb_galgos_agregados_norm 
UNION 
SELECT 2 AS distancia_tipo, MIN(vel_going_longmedias_max) AS valor_min, MAX(vel_going_longmedias_max) AS valor_max FROM datos_desa.tb_galgos_agregados_norm 
UNION 
SELECT 3 AS distancia_tipo, MIN(vel_going_largas_max) AS valor_min, MAX(vel_going_largas_max) AS valor_max FROM datos_desa.tb_galgos_agregados_norm;

SELECT * FROM datos_desa.tb_ce_${sufijo}_x1a LIMIT 5;
SELECT count(*) as num_x1a FROM datos_desa.tb_ce_${sufijo}_x1a LIMIT 5;


DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x1b;

CREATE TABLE datos_desa.tb_ce_${sufijo}_x1b AS 
SELECT galgo_nombre,

(vel_going_cortas_max - (select valor_min FROM datos_desa.tb_ce_${sufijo}_x1a WHERE distancia_tipo=1) ) / (select valor_max FROM datos_desa.tb_ce_${sufijo}_x1a WHERE distancia_tipo=1) AS vgcortas_max_norm,

(vel_going_longmedias_max - (select valor_min FROM datos_desa.tb_ce_${sufijo}_x1a WHERE distancia_tipo=2) ) / (select valor_max FROM datos_desa.tb_ce_${sufijo}_x1a WHERE distancia_tipo=2) AS vgmedias_max_norm,

(vel_going_largas_max - (select valor_min FROM datos_desa.tb_ce_${sufijo}_x1a WHERE distancia_tipo=3) ) / (select valor_max FROM datos_desa.tb_ce_${sufijo}_x1a WHERE distancia_tipo=3) AS vglargas_max_norm

FROM datos_desa.tb_galgos_agregados_norm;

ALTER TABLE datos_desa.tb_ce_${sufijo}_x1b ADD INDEX tb_ce_${sufijo}_x1b_idx(galgo_nombre);
SELECT * FROM datos_desa.tb_ce_${sufijo}_x1b LIMIT 5;
SELECT count(*) as num_x1b FROM datos_desa.tb_ce_${sufijo}_x1b LIMIT 5;
EOF


#echo -e "$CONSULTA_X1" 2>&1 1>>${LOG_CE}
mysql --login-path=local --execute="$CONSULTA_X1" >>$LOG_CE
}


##########################################################################################
function calcularVariableX2 ()
{
sufijo="${1}"
echo -e "\n ---- X2: [(carrera, galgo) ->experiencia]" 2>&1 1>>${LOG_CE}
echo -e "Parametros: -->${1}" 2>&1 1>>${LOG_CE}

read -d '' CONSULTA_X2 <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x2a;

CREATE TABLE datos_desa.tb_ce_${sufijo}_x2a AS
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

SELECT * FROM datos_desa.tb_ce_${sufijo}_x2a LIMIT 5;
SELECT count(*) as num_x2a FROM datos_desa.tb_ce_${sufijo}_x2a LIMIT 5;

set @min_experiencia=(select MIN(experiencia) FROM datos_desa.tb_ce_${sufijo}_x2a);
set @diff_experiencia=(select CASE WHEN MIN(experiencia)=0 THEN MAX(experiencia) ELSE MAX(experiencia)-MIN(experiencia) END FROM datos_desa.tb_ce_${sufijo}_x2a);


DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x2b;

CREATE TABLE datos_desa.tb_ce_${sufijo}_x2b AS 
SELECT id_carrera, galgo_nombre, anio, mes, dia, 
CASE WHEN (experiencia IS NULL OR @diff_experiencia=0) THEN NULL ELSE ((experiencia - @min_experiencia)/@diff_experiencia) END AS experiencia
FROM datos_desa.tb_ce_${sufijo}_x2a;

ALTER TABLE datos_desa.tb_ce_${sufijo}_x2b ADD INDEX tb_ce_${sufijo}_x2b_idx(id_carrera, galgo_nombre);
SELECT * FROM datos_desa.tb_ce_${sufijo}_x2b LIMIT 5;
SELECT count(*) as num_x2b FROM datos_desa.tb_ce_${sufijo}_x2b LIMIT 5;
EOF

#echo -e "$CONSULTA_X2" 2>&1 1>>${LOG_CE}
mysql --login-path=local --execute="$CONSULTA_X2" >>$LOG_CE

}


##########################################################################################
function calcularVariableX3 ()
{
sufijo="${1}"
echo -e "\n ---- X3: [(carrera, galgo) -> (TRAP, trap_factor)]" 2>&1 1>>${LOG_CE}
echo -e "Parametros: -->${1}" 2>&1 1>>${LOG_CE}


read -d '' CONSULTA_X3 <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x3a;

CREATE TABLE datos_desa.tb_ce_${sufijo}_x3a AS 
SELECT dentro.trap, SUM(dentro.contador) AS trap_suma 
FROM (select trap,posicion,count(*) as contador FROM datos_desa.tb_galgos_historico_norm GROUP BY trap,posicion ORDER BY trap ASC, posicion ASC) dentro 
WHERE posicion IN (1,2) 
GROUP BY dentro.trap;

SELECT * FROM datos_desa.tb_ce_${sufijo}_x3a LIMIT 5;
SELECT count(*) as num_x3a FROM datos_desa.tb_ce_${sufijo}_x3a LIMIT 5;

set @min_trap_puntos=(select MIN(trap_suma) FROM datos_desa.tb_ce_${sufijo}_x3a);
set @diff_trap_puntos=(select CASE WHEN MIN(trap_suma)=0 THEN MAX(trap_suma) ELSE MAX(trap_suma)-MIN(trap_suma) END FROM datos_desa.tb_ce_${sufijo}_x3a);


DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x3b;

CREATE TABLE datos_desa.tb_ce_${sufijo}_x3b AS 
SELECT trap, 
CASE WHEN (trap_suma IS NULL OR @diff_trap_puntos=0) THEN NULL ELSE ((trap_suma - @min_trap_puntos)/@diff_trap_puntos) END AS trap_factor
FROM datos_desa.tb_ce_${sufijo}_x3a;

ALTER TABLE datos_desa.tb_ce_${sufijo}_x3b ADD INDEX tb_ce_${sufijo}_x3b_idx(trap);
SELECT * FROM datos_desa.tb_ce_${sufijo}_x3b LIMIT 5;
SELECT count(*) as num_x3b FROM datos_desa.tb_ce_${sufijo}_x3b LIMIT 5;
EOF

#echo -e "$CONSULTA_X3" 2>&1 1>>${LOG_CE}
mysql --login-path=local --execute="$CONSULTA_X3" >>$LOG_CE

}


##########################################################################################
function calcularVariableX4 ()
{
sufijo="${1}"
echo -e "\n ---- X4: [(carrera, galgo) -> (starting price)]" 2>&1 1>>${LOG_CE}
echo -e "Parametros: -->${1}" 2>&1 1>>${LOG_CE}

read -d '' CONSULTA_X4 <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x4;
CREATE TABLE datos_desa.tb_ce_${sufijo}_x4 AS 
SELECT id_carrera, galgo_nombre, sp_norm 
FROM datos_desa.tb_galgos_historico_norm  GH;

ALTER TABLE datos_desa.tb_ce_${sufijo}_x4 ADD INDEX tb_ce_${sufijo}_x4_idx(id_carrera, galgo_nombre);
SELECT * FROM datos_desa.tb_ce_${sufijo}_x4 LIMIT 5;
SELECT count(*) as num_x4 FROM datos_desa.tb_ce_${sufijo}_x4 LIMIT 5;
EOF

#echo -e "$CONSULTA_X4" 2>&1 1>>${LOG_CE}
mysql --login-path=local --execute="$CONSULTA_X4" >>$LOG_CE
}


##########################################################################################
function calcularVariableX5 ()
{
sufijo="${1}"
echo -e "\n"" ---- X5: [(carrera, galgo) -> (clase)]" 2>&1 1>>${LOG_CE}
echo -e "Parametros: -->${1}" 2>&1 1>>${LOG_CE}

mysql --login-path=local --execute="DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x5;" >>$LOG_CE
mysql --login-path=local --execute="CREATE TABLE datos_desa.tb_ce_${sufijo}_x5 AS SELECT id_carrera, galgo_nombre, clase FROM datos_desa.tb_galgos_historico_norm  GH;" >>$LOG_CE
mysql --login-path=local --execute="ALTER TABLE datos_desa.tb_ce_${sufijo}_x5 ADD INDEX tb_ce_${sufijo}_x5_idx(id_carrera, galgo_nombre);" >>$LOG_CE
mysql --login-path=local --execute="SELECT * FROM datos_desa.tb_ce_${sufijo}_x5 LIMIT 5;" >>$LOG_CE
mysql --login-path=local --execute="SELECT count(*) as num_x5 FROM datos_desa.tb_ce_${sufijo}_x5 LIMIT 5;" >>$LOG_CE
}


##########################################################################################
function calcularVariableX6 ()
{
sufijo="${1}"
echo -e "\n"" ---- X6 - POSICION media por experiencia en una clase. Un perro que corre en una carrera tiene X experiencia corriendo en esa clase. Asignamos la posición media que le correspondería tener a ese perro por tener esa experiencia X en esa clase. Agrupamos por rangos de experiencia (baja, media, alta) en función de unos umbrales calculados empiricamente." 2>&1 1>>${LOG_CE}

echo -e " X6: [(carrera, galgo, clase) -> (posicion_media según su experiencia en esa clase)]" 2>&1 1>>${LOG_CE}
echo -e " Parametros: -->${1}" 2>&1 1>>${LOG_CE}

read -d '' CONSULTA_X6A <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x6a;

CREATE TABLE datos_desa.tb_ce_${sufijo}_x6a AS 
SELECT 
galgo_nombre, 
clase, 
COUNT(posicion) AS experiencia_en_clase, 
AVG(posicion) AS posicion_media_en_clase
FROM datos_desa.tb_galgos_historico_norm  
GROUP BY galgo_nombre, clase;

SELECT * FROM datos_desa.tb_ce_${sufijo}_x6a LIMIT 5;
SELECT count(*) as num_x6a FROM datos_desa.tb_ce_${sufijo}_x6a LIMIT 5;
EOF

#echo -e "\n$CONSULTA_X6A" 2>&1 1>>${LOG_CE}
mysql --login-path=local --execute="$CONSULTA_X6A" >>$LOG_CE


read -d '' CONSULTA_X6B <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x6b;

CREATE TABLE datos_desa.tb_ce_${sufijo}_x6b AS 
SELECT clase, 
CASE WHEN experiencia_en_clase>=13 THEN 'alta' 
     WHEN (experiencia_en_clase>=5 AND experiencia_en_clase<13) THEN 'media' 
     ELSE 'baja' 
END AS experiencia_cualitativo, 
AVG(posicion_media_en_clase) AS posicion_media_en_clase_por_experiencia 
FROM datos_desa.tb_ce_${sufijo}_x6a 
GROUP BY clase, experiencia_cualitativo 
ORDER BY clase ASC, experiencia_cualitativo ASC;

ALTER TABLE datos_desa.tb_ce_${sufijo}_x6b ADD INDEX tb_ce_${sufijo}_x6b_idx(clase, experiencia_cualitativo);

SELECT * FROM datos_desa.tb_ce_${sufijo}_x6b LIMIT 5;
SELECT count(*) as num_x6b FROM datos_desa.tb_ce_${sufijo}_x6b LIMIT 5;

set @min_posicion_media_en_clase_por_experiencia=(select MIN(posicion_media_en_clase_por_experiencia) FROM datos_desa.tb_ce_${sufijo}_x6b);
set @diff_posicion_media_en_clase_por_experiencia=(select CASE WHEN MIN(posicion_media_en_clase_por_experiencia)=0 THEN MAX(posicion_media_en_clase_por_experiencia) ELSE MAX(posicion_media_en_clase_por_experiencia)-MIN(posicion_media_en_clase_por_experiencia) END FROM datos_desa.tb_ce_${sufijo}_x6b);
EOF

#echo -e "\n$CONSULTA_X6B" 2>&1 1>>${LOG_CE}
mysql --login-path=local --execute="$CONSULTA_X6B" >>$LOG_CE


read -d '' CONSULTA_X6C <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x6c0;

CREATE TABLE datos_desa.tb_ce_${sufijo}_x6c0 AS
SELECT GH.galgo_nombre, GH.id_carrera, GH.anio*10000+GH.mes*100+GH.dia AS amd, GH2.anio*10000+GH2.mes*100+GH2.dia AS amd2, GH.clase AS clase
FROM datos_desa.tb_galgos_historico_norm GH
LEFT JOIN datos_desa.tb_galgos_historico_norm GH2 ON (GH.galgo_nombre=GH2.galgo_nombre AND GH.clase=GH2.clase)
;

DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x6c;

CREATE TABLE datos_desa.tb_ce_${sufijo}_x6c AS
SELECT galgo_nombre, id_carrera, count(*) AS experiencia_en_clase 
  FROM (
    SELECT galgo_nombre, clase, amd, amd2, id_carrera  
    FROM datos_desa.tb_ce_${sufijo}_x6c0 dentro
    WHERE dentro.amd >= dentro.amd2
  ) fuera
GROUP BY galgo_nombre, id_carrera;

ALTER TABLE datos_desa.tb_ce_${sufijo}_x6c ADD INDEX tb_ce_${sufijo}_x6c_idx1(id_carrera, galgo_nombre);

SELECT * FROM datos_desa.tb_ce_${sufijo}_x6c LIMIT 5;
SELECT count(*) as num_x6c FROM datos_desa.tb_ce_${sufijo}_x6c LIMIT 5;
EOF

#echo -e "\n$CONSULTA_X6C" 2>&1 1>>${LOG_CE}
mysql --login-path=local --execute="$CONSULTA_X6C" 2>&1 1>>$LOG_CE


read -d '' CONSULTA_X6DE <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x6e_aux1;

CREATE TABLE datos_desa.tb_ce_${sufijo}_x6e_aux1 AS 
SELECT GH.anio, GH.mes, GH.dia, GH.id_carrera, GH.galgo_nombre, GH.clase,  
  X6C.experiencia_en_clase,
  CASE WHEN (X6C.experiencia_en_clase>=13) THEN 'alta' 
     WHEN (X6C.experiencia_en_clase>=5 AND X6C.experiencia_en_clase<13) THEN 'media'
     ELSE 'baja' 
  END AS experiencia_cualitativo

  FROM datos_desa.tb_galgos_historico_norm GH 
  LEFT JOIN datos_desa.tb_ce_${sufijo}_x6c X6C ON (GH.id_carrera=X6C.id_carrera AND GH.galgo_nombre=X6C.galgo_nombre)
;

ALTER TABLE datos_desa.tb_ce_${sufijo}_x6e_aux1 ADD INDEX tb_ce_${sufijo}_x6e_aux1_idx1(galgo_nombre, clase);
ALTER TABLE datos_desa.tb_ce_${sufijo}_x6e_aux1 ADD INDEX tb_ce_${sufijo}_x6e_aux1_idx2(clase, experiencia_cualitativo);
SELECT * FROM datos_desa.tb_ce_${sufijo}_x6e_aux1 LIMIT 5;
SELECT count(*) as num_x6e FROM datos_desa.tb_ce_${sufijo}_x6e_aux1 LIMIT 5;

set @min_experiencia_en_clase=(select MIN(experiencia_en_clase) AS min_eec FROM datos_desa.tb_ce_${sufijo}_x6c);
set @diff_experiencia_en_clase=(select CASE WHEN MIN(experiencia_en_clase)=0 THEN MAX(experiencia_en_clase) ELSE MAX(experiencia_en_clase)-MIN(experiencia_en_clase) END AS dif_eec FROM datos_desa.tb_ce_${sufijo}_x6c);


DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x6e;

CREATE TABLE datos_desa.tb_ce_${sufijo}_x6e AS 
SELECT
cruce1.id_carrera,
cruce1.galgo_nombre,
cruce1.clase,
CASE WHEN (cruce1.experiencia_en_clase IS NULL OR @diff_experiencia_en_clase=0) THEN NULL ELSE ((cruce1.experiencia_en_clase - @min_experiencia_en_clase)/@diff_experiencia_en_clase) END AS experiencia_en_clase,
cruce1.experiencia_cualitativo,
CASE WHEN (X6B.posicion_media_en_clase_por_experiencia IS NULL OR @diff_posicion_media_en_clase_por_experiencia=0) THEN NULL ELSE ((X6B.posicion_media_en_clase_por_experiencia - @min_posicion_media_en_clase_por_experiencia)/@diff_posicion_media_en_clase_por_experiencia) END AS posicion_media_en_clase_por_experiencia,

anio, mes, dia

FROM datos_desa.tb_ce_${sufijo}_x6e_aux1 cruce1
LEFT JOIN datos_desa.tb_ce_${sufijo}_x6b X6B ON (cruce1.clase=X6B.clase AND cruce1.experiencia_cualitativo=X6B.experiencia_cualitativo)
;

ALTER TABLE datos_desa.tb_ce_${sufijo}_x6e ADD INDEX tb_ce_${sufijo}_x6e_idx(id_carrera, galgo_nombre, clase);
SELECT * FROM datos_desa.tb_ce_${sufijo}_x6e LIMIT 5;
SELECT count(*) as num_x6e FROM datos_desa.tb_ce_${sufijo}_x6e LIMIT 5;
EOF


echo -e "\n$CONSULTA_X6DE" 2>&1 1>>${LOG_CE}
mysql --login-path=local --execute="$CONSULTA_X6DE" 2>&1 1>>$LOG_CE
}

##########################################################################################
function calcularVariableX7 ()
{
sufijo="${1}"
echo -e "\n ---- X7: diferencia relativa de peso del galgo respecto al PESO MEDIO de los galgos que corren en esa DISTANCIA (centenas de metros). Toma valores NULL cuando no hemos descargado las filas de la tabla de posiciones en carrera (que es la que tiene el peso de cada galgo)." 2>&1 1>>${LOG_CE}

echo -e " X7: [(carrera, galgo) -> (diferencia respecto al peso medio en esa distancia_centenas)]" 2>&1 1>>${LOG_CE}
echo -e " Parametros: -->${1}" 2>&1 1>>${LOG_CE}

read -d '' CONSULTA_X7CD <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x7a;

CREATE TABLE datos_desa.tb_ce_${sufijo}_x7a AS 
SELECT PO.id_carrera, PO.posicion, PO.peso_galgo, GH.distancia, (GH.distancia/100 - GH.distancia%100/100) AS distancia_centenas 
FROM datos_desa.tb_galgos_posiciones_en_carreras_norm PO 
LEFT JOIN (select id_carrera, MAX(distancia) AS distancia FROM datos_desa.tb_galgos_historico_norm GROUP BY id_carrera) GH 
ON PO.id_carrera=GH.id_carrera WHERE PO.posicion IN (1,2) ORDER BY PO.id_carrera ASC, PO.posicion ASC;

SELECT * FROM datos_desa.tb_ce_${sufijo}_x7a LIMIT 5;
SELECT count(*) as num_x7a FROM datos_desa.tb_ce_${sufijo}_x7a LIMIT 5;


DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x7b;

CREATE TABLE datos_desa.tb_ce_${sufijo}_x7b AS 
SELECT distancia_centenas, AVG(peso_galgo) AS peso_medio, COUNT(*) 
FROM datos_desa.tb_ce_${sufijo}_x7a GROUP BY distancia_centenas ORDER BY distancia_centenas ASC;

SELECT * FROM datos_desa.tb_ce_${sufijo}_x7b LIMIT 5;
SELECT count(*) as num_x7b FROM datos_desa.tb_ce_${sufijo}_x7b LIMIT 5;


DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x7c;

CREATE TABLE datos_desa.tb_ce_${sufijo}_x7c AS 
SELECT id_carrera, galgo_nombre, dentro.distancia_centenas, dentro.distancia, ABS(dentro.peso_galgo - X7B.peso_medio) AS dif_peso  
FROM
(
  select GH.galgo_nombre, GH.id_carrera, (GH.distancia/100 - GH.distancia%100/100) AS distancia_centenas, GH.distancia, PO.peso_galgo 
  FROM datos_desa.tb_galgos_historico_norm GH
  LEFT JOIN (SELECT galgo_nombre, MAX(peso_galgo) AS peso_galgo FROM datos_desa.tb_galgos_posiciones_en_carreras_norm GROUP BY galgo_nombre) PO
  ON (GH.galgo_nombre=PO.galgo_nombre)
) dentro
LEFT JOIN datos_desa.tb_ce_${sufijo}_x7b X7B 
ON (dentro.distancia_centenas=X7B.distancia_centenas)
ORDER BY id_carrera, galgo_nombre;

SELECT * FROM datos_desa.tb_ce_${sufijo}_x7c LIMIT 5;
SELECT count(*) as num_x7c FROM datos_desa.tb_ce_${sufijo}_x7c LIMIT 5;


set @min_dif_peso=(select MIN(dif_peso) FROM datos_desa.tb_ce_${sufijo}_x7c);
set @diff_dif_peso=(select CASE WHEN MIN(dif_peso)=0 THEN MAX(dif_peso) ELSE MAX(dif_peso)-MIN(dif_peso) END FROM datos_desa.tb_ce_${sufijo}_x7c);
set @min_distancia=(select MIN(distancia) FROM datos_desa.tb_ce_${sufijo}_x7c);
set @diff_distancia=(select CASE WHEN MIN(distancia)=0 THEN MAX(distancia) ELSE MAX(distancia)-MIN(distancia) END FROM datos_desa.tb_ce_${sufijo}_x7c);

DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x7d;

CREATE TABLE datos_desa.tb_ce_${sufijo}_x7d AS 
SELECT id_carrera, galgo_nombre, distancia_centenas, 
CASE WHEN (distancia IS NULL OR @diff_distancia=0) THEN NULL ELSE ((distancia - @min_distancia)/@diff_distancia) END AS distancia_norm,
CASE WHEN (dif_peso IS NULL OR @diff_dif_peso=0) THEN NULL ELSE ((dif_peso - @min_dif_peso)/@diff_dif_peso) END AS dif_peso
FROM datos_desa.tb_ce_${sufijo}_x7c;

ALTER TABLE datos_desa.tb_ce_${sufijo}_x7d ADD INDEX tb_ce_${sufijo}_x7d_idx(id_carrera, galgo_nombre);
SELECT * FROM datos_desa.tb_ce_${sufijo}_x7d LIMIT 5;
SELECT count(*) as num_x7d FROM datos_desa.tb_ce_${sufijo}_x7d LIMIT 5;
EOF

#echo -e "\n$CONSULTA_X7CD" 2>&1 1>>${LOG_CE}
mysql --login-path=local --execute="$CONSULTA_X7CD" >>$LOG_CE
}


##########################################################################################
function calcularVariableX8 ()
{
sufijo="${1}"
echo -e "\n ---- X8: [carrera -> (going_avg, going_std)]. \nIndica si el estadio tiene mucha correccion (going allowance), normalmente debido al viento, lluvia, etc." 2>&1 1>>${LOG_CE}
echo -e " Parametros: -->${1}" 2>&1 1>>${LOG_CE}

read -d '' CONSULTA_X8 <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x8a;

CREATE TABLE datos_desa.tb_ce_${sufijo}_x8a AS 
SELECT track, STD(going_abs) AS venue_going_std, AVG(going_abs) AS venue_going_avg 
FROM (select track, ABS(going_allowance_segundos) AS going_abs FROM datos_desa.tb_galgos_carreras_norm) dentro 
GROUP BY dentro.track
;
SELECT * FROM datos_desa.tb_ce_${sufijo}_x8a LIMIT 5;
SELECT count(*) as num_x8a FROM datos_desa.tb_ce_${sufijo}_x8a LIMIT 5;

set @min_vgs=(select MIN(venue_going_std) FROM datos_desa.tb_ce_${sufijo}_x8a);
set @diff_vgs=(select CASE WHEN MIN(venue_going_std)=0 THEN MAX(venue_going_std) ELSE MAX(venue_going_std)-MIN(venue_going_std) END FROM datos_desa.tb_ce_${sufijo}_x8a);
set @min_vga=(select MIN(venue_going_avg) FROM datos_desa.tb_ce_${sufijo}_x8a);
set @diff_vga=(select CASE WHEN MIN(venue_going_avg)=0 THEN MAX(venue_going_avg) ELSE MAX(venue_going_avg)-MIN(venue_going_avg) END FROM datos_desa.tb_ce_${sufijo}_x8a);


DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x8b;

CREATE TABLE datos_desa.tb_ce_${sufijo}_x8b AS 
SELECT track,
CASE WHEN (venue_going_std IS NULL OR @diff_vgs=0) THEN NULL ELSE ((venue_going_std - @min_vgs)/@diff_vgs) END AS venue_going_std,
CASE WHEN (venue_going_avg IS NULL OR @diff_vga=0) THEN NULL ELSE ((venue_going_avg - @min_vga)/@diff_vga) END AS venue_going_avg
FROM datos_desa.tb_ce_${sufijo}_x8a;

ALTER TABLE datos_desa.tb_ce_${sufijo}_x8b ADD INDEX tb_ce_${sufijo}_x8b_idx(track);
SELECT * FROM datos_desa.tb_ce_${sufijo}_x8b LIMIT 5;
SELECT count(*) as num_x8a FROM datos_desa.tb_ce_${sufijo}_x8b LIMIT 5;
EOF

#echo -e "\n$CONSULTA_X8" 2>&1 1>>${LOG_CE}
mysql --login-path=local --execute="$CONSULTA_X8" >>$LOG_CE
}


##########################################################################################
function calcularVariableX9 ()
{
sufijo="${1}"
echo -e "\n ---- X9: [entrenador -> puntos]. Calidad del ENTRENADOR" 2>&1 1>>${LOG_CE}
echo -e " Parametros: -->${1}" 2>&1 1>>${LOG_CE}

read -d '' CONSULTA_X9 <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x9a;

CREATE TABLE datos_desa.tb_ce_${sufijo}_x9a AS 
SELECT entrenador, AVG(posicion) AS posicion_avg, STD(posicion) AS posicion_std 
FROM datos_desa.tb_galgos_historico_norm 
GROUP BY entrenador;

SELECT * FROM datos_desa.tb_ce_${sufijo}_x9a LIMIT 5;
SELECT count(*) as num_x9a FROM datos_desa.tb_ce_${sufijo}_x9a LIMIT 5;


DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x9b;

CREATE TABLE datos_desa.tb_ce_${sufijo}_x9b AS 
SELECT entrenador, (6-posicion_avg)/5 AS entrenador_posicion_norm FROM datos_desa.tb_ce_${sufijo}_x9a;

ALTER TABLE datos_desa.tb_ce_${sufijo}_x9b ADD INDEX tb_ce_${sufijo}_x9b_idx(entrenador);
SELECT * FROM datos_desa.tb_ce_${sufijo}_x9b LIMIT 5;
SELECT count(*) as num_x9b FROM datos_desa.tb_ce_${sufijo}_x9b LIMIT 5;
EOF

#echo -e "\n$CONSULTA_X9" 2>&1 1>>${LOG_CE}
mysql --login-path=local --execute="$CONSULTA_X9" >>$LOG_CE
}


##########################################################################################
function calcularVariableX10 ()
{
sufijo="${1}"
echo -e "\n ---- X10: [(carrera, galgo) -> (edad_en_dias)]" 2>&1 1>>${LOG_CE}
echo -e " Parametros: -->${1}" 2>&1 1>>${LOG_CE}

read -d '' CONSULTA_X10 <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x10a;

CREATE TABLE datos_desa.tb_ce_${sufijo}_x10a AS 
SELECT id_carrera, galgo_nombre, edad_en_dias
FROM datos_desa.tb_galgos_historico_norm;

SELECT * FROM datos_desa.tb_ce_${sufijo}_x10a LIMIT 5;
SELECT count(*) as num_x10a FROM datos_desa.tb_ce_${sufijo}_x10a LIMIT 5;

set @min_eed=(select MIN(edad_en_dias) FROM datos_desa.tb_ce_${sufijo}_x10a);
set @diff_eed=(select CASE WHEN MIN(edad_en_dias)=0 THEN MAX(edad_en_dias) ELSE MAX(edad_en_dias)-MIN(edad_en_dias) END FROM datos_desa.tb_ce_${sufijo}_x10a);


DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x10b;

CREATE TABLE datos_desa.tb_ce_${sufijo}_x10b AS 
SELECT id_carrera, galgo_nombre,
CASE WHEN (edad_en_dias IS NULL OR @diff_eed=0) THEN NULL ELSE ((edad_en_dias - @min_eed)/@diff_eed) END AS eed_norm
FROM datos_desa.tb_ce_${sufijo}_x10a;

ALTER TABLE datos_desa.tb_ce_${sufijo}_x10b ADD INDEX tb_ce_${sufijo}_x10b_idx(id_carrera, galgo_nombre);
SELECT * FROM datos_desa.tb_ce_${sufijo}_x10b LIMIT 5;
SELECT count(*) as num_x10b FROM datos_desa.tb_ce_${sufijo}_x10b LIMIT 5;
EOF

echo -e "\n$CONSULTA_X10" 2>&1 1>>${LOG_CE}
mysql --login-path=local --execute="$CONSULTA_X10" >>$LOG_CE
}

##########################################################################################
function calcularVariableX11 ()
{
sufijo="${1}"
echo -e "\n ---- X11: [(galgo) -> (agregados normalizados del galgo)]" 2>&1 1>>${LOG_CE}
echo -e " Parametros: -->${1}" 2>&1 1>>${LOG_CE}

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


DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x11;

CREATE TABLE datos_desa.tb_ce_${sufijo}_x11 AS 
SELECT galgo_nombre,

vel_real_cortas_mediana,
CASE WHEN (vel_real_cortas_mediana IS NULL OR @diff_vrc_med=0) THEN NULL ELSE ((vel_real_cortas_mediana - @min_vrc_med)/@diff_vrc_med) END AS vel_real_cortas_mediana_norm,
vel_real_cortas_max,
CASE WHEN (vel_real_cortas_max IS NULL OR @diff_vrc_max=0) THEN NULL ELSE ((vel_real_cortas_max - @min_vrc_max)/@diff_vrc_max) END AS vel_real_cortas_max_norm,
vel_going_cortas_mediana,
CASE WHEN (vel_going_cortas_mediana IS NULL OR @diff_vgc_med=0) THEN NULL ELSE ((vel_going_cortas_mediana - @min_vgc_med)/@diff_vgc_med) END AS vel_going_cortas_mediana_norm,
vel_going_cortas_max,
CASE WHEN (vel_going_cortas_max IS NULL OR @diff_vgc_max=0) THEN NULL ELSE ((vel_going_cortas_max - @min_vgc_max)/@diff_vgc_max) END AS vel_going_cortas_max_norm,

vel_real_longmedias_mediana,
CASE WHEN (vel_real_longmedias_mediana IS NULL OR @diff_vrlm_med=0) THEN NULL ELSE ((vel_real_longmedias_mediana - @min_vrlm_med)/@diff_vrlm_med) END AS vel_real_longmedias_mediana_norm,
vel_real_longmedias_max,
CASE WHEN (vel_real_longmedias_max IS NULL OR @diff_vrlm_max=0) THEN NULL ELSE ((vel_real_longmedias_max - @min_vrlm_max)/@diff_vrlm_max) END AS vel_real_longmedias_max_norm,
vel_going_longmedias_mediana,
CASE WHEN (vel_going_longmedias_mediana IS NULL OR @diff_vglm_med=0) THEN NULL ELSE ((vel_going_longmedias_mediana - @min_vglm_med)/@diff_vglm_med) END AS vel_going_longmedias_mediana_norm,
vel_going_longmedias_max,
CASE WHEN (vel_going_longmedias_max IS NULL OR @diff_vglm_max=0) THEN NULL ELSE ((vel_going_longmedias_max - @min_vglm_max)/@diff_vglm_max) END AS vel_going_longmedias_max_norm,

vel_real_largas_mediana,
CASE WHEN (vel_real_largas_mediana IS NULL OR @diff_vrl_med=0) THEN NULL ELSE ((vel_real_largas_mediana - @min_vrl_med)/@diff_vrl_med) END AS vel_real_largas_mediana_norm,
vel_real_largas_max,
CASE WHEN (vel_real_largas_max IS NULL OR @diff_vrl_max=0) THEN NULL ELSE ((vel_real_largas_max - @min_vrl_max)/@diff_vrl_max) END AS vel_real_largas_max_norm,
vel_going_largas_mediana,
CASE WHEN (vel_going_largas_mediana IS NULL OR @diff_vgl_med=0) THEN NULL ELSE ((vel_going_largas_mediana - @min_vgl_med)/@diff_vgl_med) END AS vel_going_largas_mediana_norm,
vel_going_largas_max,
CASE WHEN (vel_going_largas_max IS NULL OR @diff_vgl_max=0) THEN NULL ELSE ((vel_going_largas_max - @min_vgl_max)/@diff_vgl_max) END AS vel_going_largas_max_norm

FROM datos_desa.tb_galgos_agregados_norm;

ALTER TABLE datos_desa.tb_ce_${sufijo}_x11 ADD INDEX tb_ce_${sufijo}_x11_idx(galgo_nombre);
SELECT * FROM datos_desa.tb_ce_${sufijo}_x11 LIMIT 5;
SELECT count(*) as num_x11 FROM datos_desa.tb_ce_${sufijo}_x11 LIMIT 5;
EOF

#echo -e "\n$CONSULTA_X11" 2>&1 1>>${LOG_CE}
mysql --login-path=local --execute="$CONSULTA_X11" >>$LOG_CE
}

##########################################################################################
function calcularVariableX12 ()
{
sufijo="${1}"
echo -e "\n ---- X12: [ carrera -> (propiedades normalizadas de la carrera)]" 2>&1 1>>${LOG_CE}
echo -e " Parametros: -->${1}" 2>&1 1>>${LOG_CE}

echo -e " PENDIENTE Leer el track (pista) y sacar las caracteristicas de su ubicacion fisica (norte, sur, cerca del mar, altitud, numero de espectadores presenciales, tamaño de la pista...)" 2>&1 1>>${LOG_CE}

echo -e " PENDIENTE Leer la clase (tipo de competición) y crear categorias (boolean): tipo A, OR, S... --> SELECT DISTINCT clase FROM datos_desa.tb_galgos_carreras LIMIT 100;" 2>&1 1>>${LOG_CE}

read -d '' CONSULTA_X12 <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x12a;

CREATE TABLE datos_desa.tb_ce_${sufijo}_x12a AS 
SELECT
id_carrera,
CASE WHEN (mes <=7) THEN (-1/6 + mes/6) WHEN (mes >7) THEN (5/12 - 5*mes/144) ELSE 0.5 END AS mes,
hora,
num_galgos,
premio_primero, premio_segundo, premio_otros, premio_total_carrera,
going_allowance_segundos,
fc_1, fc_2, fc_pounds, tc_1, tc_2, tc_3, tc_pounds
FROM datos_desa.tb_galgos_carreras_norm;

SELECT * FROM datos_desa.tb_ce_${sufijo}_x12a LIMIT 5;
SELECT count(*) as num_x12a FROM datos_desa.tb_ce_${sufijo}_x12a LIMIT 5;

set @min_hora=(select MIN(hora) FROM datos_desa.tb_ce_${sufijo}_x12a);
set @diff_hora=(select CASE WHEN MIN(hora)=0 THEN MAX(hora) ELSE MAX(hora)-MIN(hora) END FROM datos_desa.tb_ce_${sufijo}_x12a);
set @min_num_galgos=(select MIN(num_galgos) FROM datos_desa.tb_ce_${sufijo}_x12a);
set @diff_num_galgos=(select CASE WHEN MIN(num_galgos)=0 THEN MAX(num_galgos) ELSE MAX(num_galgos)-MIN(num_galgos) END FROM datos_desa.tb_ce_${sufijo}_x12a);
set @min_premio_primero=(select MIN(premio_primero) FROM datos_desa.tb_ce_${sufijo}_x12a);
set @diff_premio_primero=(select CASE WHEN MIN(premio_primero)=0 THEN MAX(premio_primero) ELSE MAX(premio_primero)-MIN(premio_primero) END FROM datos_desa.tb_ce_${sufijo}_x12a);
set @min_premio_segundo=(select MIN(premio_segundo) FROM datos_desa.tb_ce_${sufijo}_x12a);
set @diff_premio_segundo=(select CASE WHEN MIN(premio_segundo)=0 THEN MAX(premio_segundo) ELSE MAX(premio_segundo)-MIN(premio_segundo) END FROM datos_desa.tb_ce_${sufijo}_x12a);
set @min_premio_otros=(select MIN(premio_otros) FROM datos_desa.tb_ce_${sufijo}_x12a);
set @diff_premio_otros=(select CASE WHEN MIN(premio_otros)=0 THEN MAX(premio_otros) ELSE MAX(premio_otros)-MIN(premio_otros) END FROM datos_desa.tb_ce_${sufijo}_x12a);
set @min_premio_total_carrera=(select MIN(premio_total_carrera) FROM datos_desa.tb_ce_${sufijo}_x12a);
set @diff_premio_total_carrera=(select CASE WHEN MIN(premio_total_carrera)=0 THEN MAX(premio_total_carrera) ELSE MAX(premio_total_carrera)-MIN(premio_total_carrera) END FROM datos_desa.tb_ce_${sufijo}_x12a);
set @min_going_allowance_segundos=(select MIN(going_allowance_segundos) FROM datos_desa.tb_ce_${sufijo}_x12a);
set @diff_going_allowance_segundos=(select CASE WHEN MIN(going_allowance_segundos)=0 THEN MAX(going_allowance_segundos) ELSE MAX(going_allowance_segundos)-MIN(going_allowance_segundos) END FROM datos_desa.tb_ce_${sufijo}_x12a);
set @min_fc_1=(select MIN(fc_1) FROM datos_desa.tb_ce_${sufijo}_x12a);
set @diff_fc_1=(select CASE WHEN MIN(fc_1)=0 THEN MAX(fc_1) ELSE MAX(fc_1)-MIN(fc_1) END FROM datos_desa.tb_ce_${sufijo}_x12a);
set @min_fc_2=(select MIN(fc_2) FROM datos_desa.tb_ce_${sufijo}_x12a);
set @diff_fc_2=(select CASE WHEN MIN(fc_2)=0 THEN MAX(fc_2) ELSE MAX(fc_2)-MIN(fc_2) END FROM datos_desa.tb_ce_${sufijo}_x12a);
set @min_fc_pounds=(select MIN(fc_pounds) FROM datos_desa.tb_ce_${sufijo}_x12a);
set @diff_fc_pounds=(select CASE WHEN MIN(fc_pounds)=0 THEN MAX(fc_pounds) ELSE MAX(fc_pounds)-MIN(fc_pounds) END FROM datos_desa.tb_ce_${sufijo}_x12a);
set @min_tc_1=(select MIN(tc_1) FROM datos_desa.tb_ce_${sufijo}_x12a);
set @diff_tc_1=(select CASE WHEN MIN(tc_1)=0 THEN MAX(tc_1) ELSE MAX(tc_1)-MIN(tc_1) END FROM datos_desa.tb_ce_${sufijo}_x12a);
set @min_tc_2=(select MIN(tc_2) FROM datos_desa.tb_ce_${sufijo}_x12a);
set @diff_tc_2=(select CASE WHEN MIN(tc_2)=0 THEN MAX(tc_2) ELSE MAX(tc_2)-MIN(tc_2) END FROM datos_desa.tb_ce_${sufijo}_x12a);
set @min_tc_3=(select MIN(tc_3) FROM datos_desa.tb_ce_${sufijo}_x12a);
set @diff_tc_3=(select CASE WHEN MIN(tc_3)=0 THEN MAX(tc_3) ELSE MAX(tc_3)-MIN(tc_3) END FROM datos_desa.tb_ce_${sufijo}_x12a);
set @min_tc_pounds=(select MIN(tc_pounds) FROM datos_desa.tb_ce_${sufijo}_x12a);
set @diff_tc_pounds=(select CASE WHEN MIN(tc_pounds)=0 THEN MAX(tc_pounds) ELSE MAX(tc_pounds)-MIN(tc_pounds) END FROM datos_desa.tb_ce_${sufijo}_x12a);


DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x12b;

CREATE TABLE datos_desa.tb_ce_${sufijo}_x12b AS 
SELECT 
id_carrera,
mes AS mes_norm,
CASE WHEN (hora IS NULL OR @diff_hora=0) THEN NULL ELSE ((hora - @min_hora)/@diff_hora) END AS hora_norm,
CASE WHEN (num_galgos IS NULL OR @diff_num_galgos=0) THEN NULL ELSE ((num_galgos - @min_num_galgos)/@diff_num_galgos) END AS num_galgos_norm,
CASE WHEN (premio_primero IS NULL OR @diff_premio_primero=0) THEN NULL ELSE ((premio_primero - @min_premio_primero)/@diff_premio_primero) END AS premio_primero_norm,
CASE WHEN (premio_segundo IS NULL OR @diff_premio_segundo=0) THEN NULL ELSE ((premio_segundo - @min_premio_segundo)/@diff_premio_segundo) END AS premio_segundo_norm,
CASE WHEN (premio_otros IS NULL OR @diff_premio_otros=0) THEN NULL ELSE ((premio_otros - @min_premio_otros)/@diff_premio_otros) END AS premio_otros_norm,
CASE WHEN (premio_total_carrera IS NULL OR @diff_premio_total_carrera=0) THEN NULL ELSE ((premio_total_carrera - @min_premio_total_carrera)/@diff_premio_total_carrera) END AS premio_total_carrera_norm,
CASE WHEN (going_allowance_segundos IS NULL OR @diff_going_allowance_segundos=0) THEN NULL ELSE ((going_allowance_segundos - @min_going_allowance_segundos)/@diff_going_allowance_segundos) END AS going_allowance_segundos_norm,
CASE WHEN (fc_1 IS NULL OR @diff_fc_1=0) THEN NULL ELSE ((fc_1 - @min_fc_1)/@diff_fc_1) END AS fc_1_norm,
CASE WHEN (fc_2 IS NULL OR @diff_fc_2=0) THEN NULL ELSE ((fc_2 - @min_fc_2)/@diff_fc_2) END AS fc_2_norm,
CASE WHEN (fc_pounds IS NULL OR @diff_fc_pounds=0) THEN NULL ELSE ((fc_pounds - @min_fc_pounds)/@diff_fc_pounds) END AS fc_pounds_norm,
CASE WHEN (tc_1 IS NULL OR @diff_tc_1=0) THEN NULL ELSE ((tc_1 - @min_tc_1)/@diff_tc_1) END AS tc_1_norm,
CASE WHEN (tc_2 IS NULL OR @diff_tc_2=0) THEN NULL ELSE ((tc_2 - @min_tc_2)/@diff_tc_2) END AS tc_2_norm,
CASE WHEN (tc_3 IS NULL OR @diff_tc_3=0) THEN NULL ELSE ((tc_3 - @min_tc_3)/@diff_tc_3) END AS tc_3_norm,
CASE WHEN (tc_pounds IS NULL OR @diff_tc_pounds=0) THEN NULL ELSE ((tc_pounds - @min_tc_pounds)/@diff_tc_pounds) END AS tc_pounds_norm
FROM datos_desa.tb_ce_${sufijo}_x12a;

ALTER TABLE datos_desa.tb_ce_${sufijo}_x12b ADD INDEX tb_ce_${sufijo}_x12b_idx(id_carrera);
SELECT * FROM datos_desa.tb_ce_${sufijo}_x12b LIMIT 5;
SELECT count(*) as num_x12b FROM datos_desa.tb_ce_${sufijo}_x12b LIMIT 5;
EOF

#echo -e "\n$CONSULTA_X12" 2>&1 1>>${LOG_CE}
mysql --login-path=local --execute="$CONSULTA_X12" >>$LOG_CE
}

##########################################################################################
function calcularVariableX13 ()
{
sufijo="${1}"
echo -e "\n ---- X13: [(carrera, galgo) -> (scoring_remarks de los ultimos 10/20/50/TODOS los dias anteriores)]" 2>&1 1>>${LOG_CE}
echo -e " Media de SCORING_REMARKS considerando las carreras de los 10/20/50 dias anteriores" 2>&1 1>>${LOG_CE}
echo -e " Parametros: -->${1}" 2>&1 1>>${LOG_CE}


echo -e "cruzarGHyRemarksPuntos: GH LEFT JOIN remarks_puntos. Los puntos finales seran una media/mediana de la 'posición normalizada mirando solo remarks'" 2>&1 1>>${LOG_CE}

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

echo -e "\n\n\n$CONSULTA_GH_CRUCE_REMARKS_PUNTOS1" 2>&1 1>>${LOG_CE}
mysql --login-path=local --execute="$CONSULTA_GH_CRUCE_REMARKS_PUNTOS1" 2>&1 1>>${LOG_CE}


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

echo -e "\n\n\n\n$CONSULTA_GH_CRUCE_REMARKS_PUNTOS2" 2>&1 1>>${LOG_CE}
mysql --login-path=local --execute="$CONSULTA_GH_CRUCE_REMARKS_PUNTOS2" 2>&1 1>>${LOG_CE}


read -d '' CONSULTA_GH_CRUCE_REMARKS_PUNTOS3 <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_gh_y_remarkspuntos_norm3;

CREATE TABLE datos_desa.tb_gh_y_remarkspuntos_norm3 AS

SELECT 
T_todos.galgo_nombre, T_todos.id_carrera, T_todos.fecha, T_todos.remarks_puntos_historico,
T10D.remarks_puntos_historico_10d,
T20D.remarks_puntos_historico_20d,
T50D.remarks_puntos_historico_50d

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

echo -e "\n\n\n$CONSULTA_GH_CRUCE_REMARKS_PUNTOS3" 2>&1 1>>${LOG_CE}
mysql --login-path=local --execute="$CONSULTA_GH_CRUCE_REMARKS_PUNTOS3" 2>&1 1>>${LOG_CE}

############

read -d '' CONSULTA_X13 <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x13;

CREATE TABLE datos_desa.tb_ce_${sufijo}_x13 AS 
SELECT GHRPNM3.* FROM datos_desa.tb_gh_y_remarkspuntos_norm3 GHRPNM3;

ALTER TABLE datos_desa.tb_ce_${sufijo}_x13 ADD INDEX tb_ce_${sufijo}_x13_idx(galgo_nombre, id_carrera);
SELECT * FROM datos_desa.tb_ce_${sufijo}_x13 LIMIT 5;
SELECT count(*) AS num_x13 FROM datos_desa.tb_ce_${sufijo}_x13 LIMIT 5;
EOF

echo -e "\n\n\n\n$CONSULTA_X13" 2>&1 1>>${LOG_CE}
mysql --login-path=local --execute="$CONSULTA_X13" >>$LOG_CE
}

################ TABLAS de INDICES ####################################################################################
function generarTablasIndices ()
{
echo -e "\n""\n---- TABLAS DE INDICES -------- " 2>&1 1>>${LOG_CE}

echo -e "Tablas ORIGINALES:" 2>&1 1>>${LOG_CE}
echo -e "datos_desa.tb_galgos_carreras_norm --> id_carrera" 2>&1 1>>${LOG_CE}
echo -e "datos_desa.tb_galgos_posiciones_en_carreras_norm --> (id_carrera, galgo_nombre)" 2>&1 1>>${LOG_CE}
echo -e "datos_desa.tb_galgos_historico_norm --> (id_carrera, galgo_nombre)" 2>&1 1>>${LOG_CE}
echo -e "datos_desa.tb_galgos_agregados_norm --> galgo_nombre" 2>&1 1>>${LOG_CE}

echo -e " Tablas de columnas ELABORADAS (provienen de usar las originales, así que tienen las mismas claves):" 2>&1 1>>${LOG_CE}
echo -e "datos_desa.tb_ce_${sufijo}_x1b --> galgo_nombre" 2>&1 1>>${LOG_CE}
echo -e "datos_desa.tb_ce_${sufijo}_x2b --> (id_carrera, galgo_nombre)" 2>&1 1>>${LOG_CE}
echo -e "datos_desa.tb_ce_${sufijo}_x3b --> trap (se usa con carrera+galgo)" 2>&1 1>>${LOG_CE}
echo -e "datos_desa.datos_desa.tb_ce_${sufijo}_x4 --> (id_carrera, galgo_nombre)" 2>&1 1>>${LOG_CE}
echo -e "datos_desa.tb_ce_${sufijo}_x5 --> (id_carrera, galgo_nombre)" 2>&1 1>>${LOG_CE}
echo -e "datos_desa.tb_ce_${sufijo}_x6e --> (id_carrera, galgo_nombre)" 2>&1 1>>${LOG_CE}
echo -e "datos_desa.tb_ce_${sufijo}_x7d --> (id_carrera, galgo_nombre)" 2>&1 1>>${LOG_CE}
echo -e "datos_desa.tb_ce_${sufijo}_x8b --> track (se usa con carrera)" 2>&1 1>>${LOG_CE}
echo -e "datos_desa.tb_ce_${sufijo}_x9b --> entrenador (se usa con galgo)" 2>&1 1>>${LOG_CE}
echo -e "datos_desa.tb_ce_${sufijo}_x10b --> (id_carrera, galgo_nombre)" 2>&1 1>>${LOG_CE}
echo -e "datos_desa.tb_ce_${sufijo}_x11 --> galgo_nombre" 2>&1 1>>${LOG_CE}
echo -e "datos_desa.tb_ce_${sufijo}_x12b --> id_carrera" 2>&1 1>>${LOG_CE}
echo -e "datos_desa.tb_ce_${sufijo}_x13 --> (id_carrera, galgo_nombre)" 2>&1 1>>${LOG_CE}


echo -e "\n""\n-------- 3 Tablas auxiliares con todas las claves extraidas y haciendo DISTINCT (serán las tablas MAESTRAS de índices)-------" 2>&1 1>>${LOG_CE}

read -d '' CONSULTA_IDS <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_ids_carreras_${sufijo};
CREATE TABLE datos_desa.tb_ids_carreras_${sufijo} AS 
SELECT DISTINCT id_carrera 
FROM (
  SELECT DISTINCT id_carrera FROM datos_desa.tb_galgos_carreras_norm
  UNION DISTINCT
  SELECT DISTINCT id_carrera FROM datos_desa.tb_galgos_posiciones_en_carreras_norm
  UNION DISTINCT
  SELECT DISTINCT id_carrera FROM datos_desa.tb_galgos_historico_norm
) dentro
;
ALTER TABLE datos_desa.tb_ids_carreras_${sufijo} ADD INDEX tb_ids_carreras_${sufijo}_idx(id_carrera);
SELECT count(*) as num_ids_carreras FROM datos_desa.tb_ids_carreras_${sufijo} LIMIT 5;
SELECT * FROM datos_desa.tb_ids_carreras_${sufijo} LIMIT 5;


DROP TABLE IF EXISTS datos_desa.tb_ids_galgos_${sufijo};
CREATE TABLE datos_desa.tb_ids_galgos_${sufijo} AS 
SELECT DISTINCT galgo_nombre 
FROM (
  SELECT DISTINCT galgo_nombre FROM datos_desa.tb_galgos_posiciones_en_carreras_norm
  UNION DISTINCT
  SELECT DISTINCT galgo_nombre FROM datos_desa.tb_galgos_historico_norm
  UNION DISTINCT
  SELECT DISTINCT galgo_nombre FROM datos_desa.tb_galgos_agregados_norm
) dentro;
ALTER TABLE datos_desa.tb_ids_galgos_${sufijo} ADD INDEX tb_ids_galgos_${sufijo}_idx(galgo_nombre);
SELECT count(*) AS num_ids_galgos FROM datos_desa.tb_ids_galgos_${sufijo} LIMIT 5;
SELECT * FROM datos_desa.tb_ids_galgos_${sufijo} LIMIT 5;


DROP TABLE IF EXISTS datos_desa.tb_ids_carrerasgalgos_${sufijo};
CREATE TABLE datos_desa.tb_ids_carrerasgalgos_${sufijo} AS
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

ALTER TABLE datos_desa.tb_ids_carrerasgalgos_${sufijo} ADD INDEX tb_ids_carrerasgalgos_${sufijo}_idx(id_carrera,galgo_nombre);
SELECT count(*) as num_ids_cg FROM datos_desa.tb_ids_carrerasgalgos_${sufijo} LIMIT 5;
SELECT * FROM datos_desa.tb_ids_carrerasgalgos_${sufijo} LIMIT 5;
EOF


#echo -e "\n$CONSULTA_IDS" 2>&1 1>>${LOG_CE}
mysql --login-path=local --execute="$CONSULTA_IDS" 2>&1 1>>${LOG_CE}

echo -e "\n"" Comprobacion: las 3 tablas de IDs no deben tener duplicados" 2>&1 1>>${LOG_CE}
mysql --login-path=local --execute="SELECT id_carrera, count(*) as num_ids_carreras FROM datos_desa.tb_ids_carreras_${sufijo} GROUP BY id_carrera HAVING num_ids_carreras>=2 LIMIT 5;" 2>&1 1>>${LOG_CE}
mysql --login-path=local --execute="SELECT galgo_nombre, count(*) as num_ids_galgos FROM datos_desa.tb_ids_galgos_${sufijo} GROUP BY galgo_nombre HAVING num_ids_galgos>=2 LIMIT 5;" 2>&1 1>>${LOG_CE}
mysql --login-path=local --execute="SELECT cg, count(*) as num_ids_cg FROM datos_desa.tb_ids_carrerasgalgos_${sufijo} GROUP BY cg HAVING num_ids_cg>=2 LIMIT 5;" 2>&1 1>>${LOG_CE}

}


################ TABLAS PREPARADAS (con columnas elaboradas) ####################################################################################
### ATENCION: MySQL no soporta FULL OUTER JOIN, asi que tenemos 2 opciones:
# - Opcion 1: hacer LEFT OJ + RIGHT OJ, sin null por la izquierda
# - Opcion 2: crear tablas auxiliares de indices (carreras ó galgos ó carrera+galgo), hacer DISTINCT. Luego usar esas tablas haciendo solo LEFT JOINs.

function generarTablasElaboradas ()
{

echo -e "\n\n ---- TABLA ELABORADA 1: [ carrera -> columnas ]" 2>&1 1>>${LOG_CE}

read -d '' CONSULTA_ELAB1 <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_elaborada_carreras_${sufijo};

CREATE TABLE datos_desa.tb_elaborada_carreras_${sufijo} AS 
SELECT 
dentro.*, 
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
  CAST( IFNULL(B.tc_pounds_norm, C.tc_pounds_norm) AS DECIMAL(8,6) ) AS tc_pounds_norm

  FROM datos_desa.tb_ids_carreras_${sufijo} A
  LEFT OUTER JOIN datos_desa.tb_galgos_carreras_norm B ON (A.id_carrera=B.id_carrera)
  LEFT JOIN datos_desa.tb_ce_${sufijo}_x12b C ON (A.id_carrera=C.id_carrera)
) dentro

LEFT JOIN datos_desa.tb_ce_${sufijo}_x8b D ON (dentro.track=D.track)
;


ALTER TABLE datos_desa.tb_elaborada_carreras_${sufijo} ADD INDEX tb_elaborada_carreras_${sufijo}_idx(id_carrera);
SELECT * FROM datos_desa.tb_elaborada_carreras_${sufijo} ORDER BY id_carrera LIMIT 5;
SELECT count(*) as num_elab_carreras FROM datos_desa.tb_elaborada_carreras_${sufijo} LIMIT 5;
EOF

#echo -e "\n$CONSULTA_ELAB1" 2>&1 1>>${LOG_CE}
mysql --login-path=local -t --execute="$CONSULTA_ELAB1" >>$LOG_CE


echo -e "\n\n ---- TABLA ELABORADA 2: [ galgo -> columnas ]" 2>&1 1>>${LOG_CE}
read -d '' CONSULTA_ELAB2 <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_elaborada_galgos_${sufijo};

CREATE TABLE datos_desa.tb_elaborada_galgos_${sufijo} AS 
SELECT 
A.*,

CAST( C.vgcortas_max_norm AS DECIMAL(8,6) ) AS vgcortas_max_norm, 
CAST( C.vgmedias_max_norm AS DECIMAL(8,6) ) AS vgmedias_max_norm, 
CAST( C.vglargas_max_norm AS DECIMAL(8,6) ) AS vglargas_max_norm,

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

FROM datos_desa.tb_ids_galgos_${sufijo} A
LEFT JOIN datos_desa.tb_galgos_agregados_norm B ON (A.galgo_nombre=B.galgo_nombre)
LEFT JOIN datos_desa.tb_ce_${sufijo}_x1b C ON (A.galgo_nombre=C.galgo_nombre)
LEFT JOIN datos_desa.tb_ce_${sufijo}_x11 D ON (A.galgo_nombre=D.galgo_nombre)
;

ALTER TABLE datos_desa.tb_elaborada_galgos_${sufijo} ADD INDEX tb_elaborada_galgos_${sufijo}_idx(galgo_nombre);
SELECT * FROM datos_desa.tb_elaborada_galgos_${sufijo} ORDER BY galgo_nombre LIMIT 5;
SELECT count(*) as num_elab_galgos FROM datos_desa.tb_elaborada_galgos_${sufijo} LIMIT 5;
EOF

echo -e "\n$CONSULTA_ELAB2" 2>&1 1>>${LOG_CE}
mysql --login-path=local -t --execute="$CONSULTA_ELAB2" >>$LOG_CE


echo -e "\n\n ---- TABLA ELABORADA 3: [ carrera+galgo -> columnas ]" 2>&1 1>>${LOG_CE}
read -d '' CONSULTA_ELAB3 <<- EOF

-- SIMULAMOS FULL OUTER JOIN mediante LEFT y RIGHT-connullizda (alternativa porque MYSQL no soporta FULL)
DROP TABLE IF EXISTS datos_desa.tb_elaborada_carrerasgalgos_${sufijo}_fullouterjoin1;

CREATE TABLE datos_desa.tb_elaborada_carrerasgalgos_${sufijo}_fullouterjoin1 AS
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


DROP TABLE IF EXISTS datos_desa.tb_elaborada_carrerasgalgos_${sufijo}_aux1;

CREATE TABLE datos_desa.tb_elaborada_carrerasgalgos_${sufijo}_aux1 AS
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

  FROM datos_desa.tb_ids_carrerasgalgos_${sufijo} A
  LEFT JOIN datos_desa.tb_elaborada_carrerasgalgos_${sufijo}_fullouterjoin1 B ON (A.id_carrera=B.id_carrera AND A.galgo_nombre=B.galgo_nombre)
  LEFT JOIN datos_desa.tb_ce_${sufijo}_x2b D ON (A.id_carrera=D.id_carrera AND A.galgo_nombre=D.galgo_nombre)
;


ALTER TABLE datos_desa.tb_elaborada_carrerasgalgos_${sufijo}_aux1 ADD INDEX tb_elaborada_carrerasgalgos_${sufijo}_aux1_idx1(trap);
ALTER TABLE datos_desa.tb_elaborada_carrerasgalgos_${sufijo}_aux1 ADD INDEX tb_elaborada_carrerasgalgos_${sufijo}_aux1_idx2(id_carrera, galgo_nombre);
ALTER TABLE datos_desa.tb_elaborada_carrerasgalgos_${sufijo}_aux1 ADD INDEX tb_elaborada_carrerasgalgos_${sufijo}_aux1_idx3(id_carrera, galgo_nombre, clase);
ALTER TABLE datos_desa.tb_elaborada_carrerasgalgos_${sufijo}_aux1 ADD INDEX tb_elaborada_carrerasgalgos_${sufijo}_aux1_idx4(entrenador);

DROP TABLE IF EXISTS datos_desa.tb_elaborada_carrerasgalgos_${sufijo};

CREATE TABLE datos_desa.tb_elaborada_carrerasgalgos_${sufijo} AS 
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

FROM datos_desa.tb_elaborada_carrerasgalgos_${sufijo}_aux1 dentro
LEFT JOIN datos_desa.tb_ce_${sufijo}_x3b E ON (dentro.trap=E.trap)
LEFT JOIN datos_desa.tb_ce_${sufijo}_x4 F ON (dentro.id_carrera=F.id_carrera AND dentro.galgo_nombre=F.galgo_nombre)
LEFT JOIN datos_desa.tb_ce_${sufijo}_x5 G ON (dentro.id_carrera=G.id_carrera AND dentro.galgo_nombre=G.galgo_nombre)
LEFT JOIN datos_desa.tb_ce_${sufijo}_x6e H ON (dentro.id_carrera=H.id_carrera AND dentro.galgo_nombre=H.galgo_nombre AND dentro.clase=H.clase)
LEFT JOIN datos_desa.tb_ce_${sufijo}_x7d I ON (dentro.id_carrera=I.id_carrera AND dentro.galgo_nombre=I.galgo_nombre)
LEFT JOIN datos_desa.tb_ce_${sufijo}_x9b J ON (dentro.entrenador=J.entrenador)
LEFT JOIN datos_desa.tb_ce_${sufijo}_x10b K ON (dentro.id_carrera=K.id_carrera AND dentro.galgo_nombre=K.galgo_nombre)
LEFT JOIN datos_desa.tb_ce_${sufijo}_x13 L ON (dentro.id_carrera=L.id_carrera AND dentro.galgo_nombre=L.galgo_nombre)
;

ALTER TABLE datos_desa.tb_elaborada_carrerasgalgos_${sufijo} ADD INDEX tb_elaborada_carrerasgalgos_${sufijo}_idx(id_carrera,galgo_nombre);
SELECT * FROM datos_desa.tb_elaborada_carrerasgalgos_${sufijo} ORDER BY cg LIMIT 5;
SELECT count(*) as num_elab_cg FROM datos_desa.tb_elaborada_carrerasgalgos_${sufijo} LIMIT 5;
EOF


echo -e "\n$CONSULTA_ELAB3" 2>&1 1>>${LOG_CE}
mysql --login-path=local -t --execute="$CONSULTA_ELAB3" >>$LOG_CE


echo -e "\n\n Comprobacion: las 3 tablas de columnas ELABORADAS no deben tener duplicados (por clave)" 2>&1 1>>${LOG_CE}
mysql --login-path=local --execute="SELECT id_carrera, count(*) as num_ids_carreras FROM datos_desa.tb_elaborada_carreras_${sufijo} GROUP BY id_carrera HAVING num_ids_carreras>=2 LIMIT 5;" 2>&1 1>>${LOG_CE}
mysql --login-path=local --execute="SELECT galgo_nombre, count(*) as num_ids_galgos FROM datos_desa.tb_elaborada_galgos_${sufijo} GROUP BY galgo_nombre HAVING num_ids_galgos>=2 LIMIT 5;" 2>&1 1>>${LOG_CE}
mysql --login-path=local --execute="SELECT cg, count(*) as num_ids_cg FROM datos_desa.tb_elaborada_carrerasgalgos_${sufijo} GROUP BY cg HAVING num_ids_cg>=2 LIMIT 5;" 2>&1 1>>${LOG_CE}


echo -e "\n----------- | 031 | Tablas de COLUMNAS ELABORADAS --------------" 2>&1 1>>${LOG_CE}
echo -e "datos_desa.tb_elaborada_carreras_${sufijo}" 2>&1 1>>${LOG_CE}
echo -e "datos_desa.tb_elaborada_galgos_${sufijo}" 2>&1 1>>${LOG_CE}
echo -e "datos_desa.tb_elaborada_carrerasgalgos_${sufijo}" 2>&1 1>>${LOG_CE}
echo -e "----------------------------------------------------\n\n\n" 2>&1 1>>${LOG_CE}

}


################ BORRAR TABLAS INTERMEDIAS (para no tener tablas inmanejables al final) (no usar eso cuando debugueamos) #############################################
function borrarTablasInnecesarias ()
{
sufijo="${1}"

echo -e " Borrando tablas innecesarias..." 2>&1 1>>${LOG_CE}
read -d '' CONSULTA_DROP_TABLAS_INNECESARIAS <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x1a;
DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x1b;
DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x2a;
DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x2b;
DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x3a;
DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x3b;
DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x4;
DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x5;
DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x6a;
DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x6b;
DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x6c0;
DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x6c;
DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x6e_aux1;
DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x6e;
DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x7a;
DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x7b;
DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x7c;
DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x7d;
DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x8a;
DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x8b;
DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x9a;
DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x9b;
DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x10a;
DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x10b;
DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x11;
DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x12a;
DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x12b;
DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x13
EOF

#echo -e "\n$CONSULTA_DROP_TABLAS_INNECESARIAS" 2>&1 1>>${LOG_CE}
mysql --login-path=local -t --execute="$CONSULTA_DROP_TABLAS_INNECESARIAS" >>$LOG_CE

}


################################################ MAIN ###########################################################################################

if [ "$#" -ne 1 ]; then
    echo "Numero de parametros incorrecto!!!" 2>&1 1>>${LOG_CE}
fi

#sufijo="pre"
#sufijo="post"
sufijo="${1}"

echo -e " Generador de COLUMNAS ELABORADAS: INICIO" 2>&1 1>>${LOG_CE}
echo -e " Parametros: -->${1}" 2>&1 1>>${LOG_CE}

echo -e " Creando tabla de REMARKS-PUNTOS (util para variable 13)..." 2>&1 1>>${LOG_CE}
crearTablaRemarksPuntos

echo -e "\n\n---- Variables: X1, X2..." 2>&1 1>>${LOG_CE}
calcularVariableX1 "${sufijo}"
calcularVariableX2 "${sufijo}"
calcularVariableX3 "${sufijo}"
calcularVariableX4 "${sufijo}"
calcularVariableX5 "${sufijo}"
calcularVariableX6 "${sufijo}"
calcularVariableX7 "${sufijo}"
calcularVariableX8 "${sufijo}"
calcularVariableX9 "${sufijo}"
calcularVariableX10 "${sufijo}"
calcularVariableX11 "${sufijo}"
calcularVariableX12 "${sufijo}"
calcularVariableX13 "${sufijo}"

echo -e "\n\n ---- Tablas MAESTRAS de INDICES..." 2>&1 1>>${LOG_CE}
generarTablasIndices

echo -e "\n\n --- Tablas finales con COLUMNAS ELABORADAS (se usarán para crear datasets)..." 2>&1 1>>${LOG_CE}
generarTablasElaboradas


echo -e "\n\n | 031 | --- Analizando tablas (¡¡ mirar MUCHO los NULOS de CADA columna!!!! )...\n\n" 2>&1 1>>${LOG_CE}
analizarTabla "datos_desa" "tb_elaborada_carreras_${sufijo}" "${LOG_CE}"
analizarTabla "datos_desa" "tb_elaborada_galgos_${sufijo}" "${LOG_CE}"
analizarTabla "datos_desa" "tb_elaborada_carrerasgalgos_${sufijo}" "${LOG_CE}"


echo -e "\n\n --- Borrando tablas intermedias innecesarias..." 2>&1 1>>${LOG_CE}
#borrarTablasInnecesarias "${sufijo}"


echo -e " Generador de COLUMNAS ELABORADAS: FIN\n\n" 2>&1 1>>${LOG_CE}





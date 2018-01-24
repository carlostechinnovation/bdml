#!/bin/bash

source "/root/git/bdml/mod002parser/scripts/galgos/funciones.sh"

echo -e $(date +"%T")"Los galgos SEMILLAS deberian tener el SP (STARTING PRICE) si lo conocemos en el instante de la descarga" 2>&1 1>>${LOG_CE}


##########################################################################################
function calcularVariableX1 ()
{
filtro_galgos="${1}"
sufijo="${2}"
echo -e "\n"$(date +"%T")" ---- X1: [(galgo) -> velocidad_max_going]" 2>&1 1>>${LOG_CE}
echo -e $(date +"%T")"Parametros: -->${1}-->${2}" 2>&1 1>>${LOG_CE}

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

#echo -e $(date +"%T")"$CONSULTA_X1" 2>&1 1>>${LOG_CE}
mysql -u root --password=datos1986 --execute="$CONSULTA_X1" >>$LOG_CE
}

##########################################################################################
function calcularVariableX2 ()
{
filtro_galgos="${1}"
sufijo="${2}"
echo -e "\n"$(date +"%T")" ---- X2: [(carrera, galgo) ->experiencia]" 2>&1 1>>${LOG_CE}
echo -e $(date +"%T")"Parametros: -->${1}-->${2}" 2>&1 1>>${LOG_CE}

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
set @max_experiencia=(select MAX(experiencia) FROM datos_desa.tb_ce_${sufijo}_x2a);


DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x2b;

CREATE TABLE datos_desa.tb_ce_${sufijo}_x2b AS 
SELECT id_carrera, galgo_nombre, anio, mes, dia, 
(experiencia - @min_experiencia)/(@max_experiencia - @min_experiencia) AS experiencia
FROM datos_desa.tb_ce_${sufijo}_x2a;

ALTER TABLE datos_desa.tb_ce_${sufijo}_x2b ADD INDEX tb_ce_${sufijo}_x2b_idx(id_carrera, galgo_nombre);
SELECT * FROM datos_desa.tb_ce_${sufijo}_x2b LIMIT 5;
SELECT count(*) as num_x2b FROM datos_desa.tb_ce_${sufijo}_x2b LIMIT 5;
EOF

#echo -e $(date +"%T")"$CONSULTA_X2" 2>&1 1>>${LOG_CE}
mysql -u root --password=datos1986 --execute="$CONSULTA_X2" >>$LOG_CE

}

##########################################################################################
function calcularVariableX3 ()
{
filtro_galgos="${1}"
sufijo="${2}"
echo -e "\n"$(date +"%T")" ---- X3: [(carrera, galgo) -> (TRAP, trap_factor)]" 2>&1 1>>${LOG_CE}
echo -e $(date +"%T")"Parametros: -->${1}-->${2}" 2>&1 1>>${LOG_CE}

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
set @max_trap_puntos=(select MAX(trap_suma) FROM datos_desa.tb_ce_${sufijo}_x3a);


DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x3b;

CREATE TABLE datos_desa.tb_ce_${sufijo}_x3b AS 
SELECT trap, 
(trap_suma - @min_trap_puntos)/(@max_trap_puntos - @min_trap_puntos) AS trap_factor
FROM datos_desa.tb_ce_${sufijo}_x3a;

ALTER TABLE datos_desa.tb_ce_${sufijo}_x3b ADD INDEX tb_ce_${sufijo}_x3b_idx(trap);
SELECT * FROM datos_desa.tb_ce_${sufijo}_x3b LIMIT 5;
SELECT count(*) as num_x3b FROM datos_desa.tb_ce_${sufijo}_x3b LIMIT 5;
EOF

#echo -e $(date +"%T")"$CONSULTA_X3" 2>&1 1>>${LOG_CE}
mysql -u root --password=datos1986 --execute="$CONSULTA_X3" >>$LOG_CE

}

##########################################################################################
function calcularVariableX4 ()
{
filtro_galgos="${1}"
sufijo="${2}"
echo -e "\n"$(date +"%T")" ---- X4: [(carrera, galgo) -> (starting price)]" 2>&1 1>>${LOG_CE}
echo -e $(date +"%T")"Parametros: -->${1}-->${2}" 2>&1 1>>${LOG_CE}

read -d '' CONSULTA_X4 <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x4;
CREATE TABLE datos_desa.tb_ce_${sufijo}_x4 AS 
SELECT id_carrera, galgo_nombre, sp_norm 
FROM datos_desa.tb_galgos_historico_norm  GH;

ALTER TABLE datos_desa.tb_ce_${sufijo}_x4 ADD INDEX tb_ce_${sufijo}_x4_idx(id_carrera, galgo_nombre);
SELECT * FROM datos_desa.tb_ce_${sufijo}_x4 LIMIT 5;
SELECT count(*) as num_x4 FROM datos_desa.tb_ce_${sufijo}_x4 LIMIT 5;
EOF

#echo -e $(date +"%T")"$CONSULTA_X4" 2>&1 1>>${LOG_CE}
mysql -u root --password=datos1986 --execute="$CONSULTA_X4" >>$LOG_CE
}

##########################################################################################
function calcularVariableX5 ()
{
filtro_galgos="${1}"
sufijo="${2}"
echo -e "\n"$(date +"%T")" ---- X5: [(carrera, galgo) -> (clase)]" 2>&1 1>>${LOG_CE}
echo -e $(date +"%T")"Parametros: -->${1}-->${2}" 2>&1 1>>${LOG_CE}

mysql -u root --password=datos1986 --execute="DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x5;" >>$LOG_CE
mysql -u root --password=datos1986 --execute="CREATE TABLE datos_desa.tb_ce_${sufijo}_x5 AS SELECT id_carrera, galgo_nombre, clase FROM datos_desa.tb_galgos_historico_norm  GH;" >>$LOG_CE
mysql -u root --password=datos1986 --execute="ALTER TABLE datos_desa.tb_ce_${sufijo}_x5 ADD INDEX tb_ce_${sufijo}_x5_idx(id_carrera, galgo_nombre);" >>$LOG_CE
mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_ce_${sufijo}_x5 LIMIT 5;" >>$LOG_CE
mysql -u root --password=datos1986 --execute="SELECT count(*) as num_x5 FROM datos_desa.tb_ce_${sufijo}_x5 LIMIT 5;" >>$LOG_CE
}

##########################################################################################
function calcularVariableX6 ()
{
filtro_galgos="${1}"
sufijo="${2}"
echo -e "\n"$(date +"%T")" ---- X6 - POSICION media por experiencia en una clase. Un perro que corre en una carrera tiene X experiencia corriendo en esa clase. Asignamos la posición media que le correspondería tener a ese perro por tener esa experiencia X en esa clase. Agrupamos por rangos de experiencia (baja, media, alta) en función de unos umbrales calculados empiricamente." 2>&1 1>>${LOG_CE}

echo -e $(date +"%T")"X6: [(carrera, galgo, clase) -> (posicion_media según su experiencia en esa clase)]" 2>&1 1>>${LOG_CE}
echo -e $(date +"%T")"Parametros: -->${1}-->${2}" 2>&1 1>>${LOG_CE}

read -d '' CONSULTA_X6A <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x6a;

CREATE TABLE datos_desa.tb_ce_${sufijo}_x6a AS 
SELECT 
galgo_nombre, 
clase, 
COUNT(posicion) AS experiencia_en_clase, 
AVG(posicion) AS posicion_media_en_clase
FROM datos_desa.tb_galgos_historico_norm  
GROUP BY galgo_nombre,clase;

SELECT * FROM datos_desa.tb_ce_${sufijo}_x6a LIMIT 5;
SELECT count(*) as num_x6a FROM datos_desa.tb_ce_${sufijo}_x6a LIMIT 5;
EOF

#echo -e $(date +"%T")"$CONSULTA_X6A" 2>&1 1>>${LOG_CE}
mysql -u root --password=datos1986 --execute="$CONSULTA_X6A" >>$LOG_CE


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

SELECT * FROM datos_desa.tb_ce_${sufijo}_x6b LIMIT 5;
SELECT count(*) as num_x6b FROM datos_desa.tb_ce_${sufijo}_x6b LIMIT 5;

set @min_posicion_media_en_clase_por_experiencia=(select MIN(posicion_media_en_clase_por_experiencia) FROM datos_desa.tb_ce_${sufijo}_x6b);
set @max_posicion_media_en_clase_por_experiencia=(select MAX(posicion_media_en_clase_por_experiencia) FROM datos_desa.tb_ce_${sufijo}_x6b);
EOF

#echo -e $(date +"%T")"$CONSULTA_X6B" 2>&1 1>>${LOG_CE}
mysql -u root --password=datos1986 --execute="$CONSULTA_X6B" >>$LOG_CE


read -d '' CONSULTA_X6C <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x6c;

CREATE TABLE datos_desa.tb_ce_${sufijo}_x6c AS
SELECT galgo_nombre, id_carrera, count(*) AS experiencia_en_clase 
  FROM (
    SELECT galgo_nombre, clase, amd, amd2, id_carrera  
    FROM (
      SELECT GH.galgo_nombre, GH.id_carrera, GH.anio*10000+GH.mes*100+GH.dia AS amd, GH2.anio*10000+GH2.mes*100+GH2.dia AS amd2, GH.clase AS clase
      FROM datos_desa.tb_galgos_historico_norm GH 
      LEFT JOIN datos_desa.tb_galgos_historico_norm GH2 ON (GH.galgo_nombre=GH2.galgo_nombre AND GH.clase=GH2.clase)
    ) dentro
    WHERE dentro.amd >= dentro.amd2
  ) fuera
GROUP BY galgo_nombre, id_carrera;

SELECT * FROM datos_desa.tb_ce_${sufijo}_x6c LIMIT 5;
SELECT count(*) as num_x6c FROM datos_desa.tb_ce_${sufijo}_x6c LIMIT 5;

EOF

#echo -e $(date +"%T")"$CONSULTA_X6C" 2>&1 1>>${LOG_CE}
mysql -u root --password=datos1986 --execute="$CONSULTA_X6C" >>$LOG_CE


read -d '' CONSULTA_X6E <<- EOF

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


set @min_experiencia_en_clase=(select MIN(experiencia_en_clase) FROM datos_desa.tb_ce_${sufijo}_x6c);
set @max_experiencia_en_clase=(select MAX(experiencia_en_clase) FROM datos_desa.tb_ce_${sufijo}_x6c);

DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x6e;

CREATE TABLE datos_desa.tb_ce_${sufijo}_x6e AS 
SELECT
cruce1.id_carrera,
cruce1.galgo_nombre,
cruce1.clase,
(cruce1.experiencia_en_clase - @min_experiencia_en_clase)/(@max_experiencia_en_clase - @min_experiencia_en_clase) AS experiencia_en_clase,
cruce1.experiencia_cualitativo,
(X6B.posicion_media_en_clase_por_experiencia - @min_posicion_media_en_clase_por_experiencia)/(@max_posicion_media_en_clase_por_experiencia - @min_posicion_media_en_clase_por_experiencia) AS posicion_media_en_clase_por_experiencia,  
anio, mes, dia

FROM datos_desa.tb_ce_${sufijo}_x6e_aux1 cruce1
LEFT JOIN datos_desa.tb_ce_${sufijo}_x6b X6B ON (cruce1.clase=X6B.clase AND cruce1.experiencia_cualitativo=X6B.experiencia_cualitativo)
;

ALTER TABLE datos_desa.tb_ce_${sufijo}_x6e ADD INDEX tb_ce_${sufijo}_x6e_idx(id_carrera, galgo_nombre, clase);
SELECT * FROM datos_desa.tb_ce_${sufijo}_x6e LIMIT 5;
SELECT count(*) as num_x6e FROM datos_desa.tb_ce_${sufijo}_x6e LIMIT 5;
EOF

#echo -e $(date +"%T")"$CONSULTA_X6E" 2>&1 1>>${LOG_CE}
mysql -u root --password=datos1986 --execute="$CONSULTA_X6E" >>$LOG_CE

}

##########################################################################################
function calcularVariableX7 ()
{
filtro_galgos="${1}"
sufijo="${2}"
echo -e "\n"$(date +"%T")" ---- X7: peso del galgo en relacion al peso medio de los galgos que corren en esa distancia (centenas de metros). Toma valores NULL cuando no hemos descargado las filas de la tabla de posiciones en carrera (que es la que tiene el peso de cada galgo)." 2>&1 1>>${LOG_CE}

echo -e $(date +"%T")"X7: [(carrera, galgo) -> (diferencia respecto al peso medio en esa distancia_centenas)]" 2>&1 1>>${LOG_CE}
echo -e $(date +"%T")"Parametros: -->${1}-->${2}" 2>&1 1>>${LOG_CE}

read -d '' CONSULTA_X7C <<- EOF
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
set @max_dif_peso=(select MAX(dif_peso) FROM datos_desa.tb_ce_${sufijo}_x7c);

DROP TABLE datos_desa.tb_ce_${sufijo}_x7d;

CREATE TABLE datos_desa.tb_ce_${sufijo}_x7d AS 
SELECT id_carrera, galgo_nombre, distancia_centenas, distancia,
(dif_peso - @min_dif_peso)/(@max_dif_peso - @min_dif_peso) AS dif_peso
FROM datos_desa.tb_ce_${sufijo}_x7c;

ALTER TABLE datos_desa.tb_ce_${sufijo}_x7d ADD INDEX tb_ce_${sufijo}_x7d_idx(id_carrera, galgo_nombre);
SELECT * FROM datos_desa.tb_ce_${sufijo}_x7d LIMIT 5;
SELECT count(*) as num_x7d FROM datos_desa.tb_ce_${sufijo}_x7d LIMIT 5;
EOF

#echo -e $(date +"%T")"$CONSULTA_X7C" 2>&1 1>>${LOG_CE}
mysql -u root --password=datos1986 --execute="$CONSULTA_X7C" >>$LOG_CE
}

##########################################################################################
function calcularVariableX8 ()
{
filtro_galgos="${1}"
sufijo="${2}"
echo -e "\n"$(date +"%T")" ---- X8: [carrera -> (going_avg, going_std)]. \nIndica si el estadio tiene mucha correccion (going allowance), normalmente debido al viento, lluvia, etc." 2>&1 1>>${LOG_CE}
echo -e $(date +"%T")"Parametros: -->${1}-->${2}" 2>&1 1>>${LOG_CE}

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
set @max_vgs=(select MAX(venue_going_std) FROM datos_desa.tb_ce_${sufijo}_x8a);
set @min_vga=(select MIN(venue_going_avg) FROM datos_desa.tb_ce_${sufijo}_x8a);
set @max_vga=(select MAX(venue_going_avg) FROM datos_desa.tb_ce_${sufijo}_x8a);


DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x8b;

CREATE TABLE datos_desa.tb_ce_${sufijo}_x8b AS 
SELECT track,
(venue_going_std - @min_vgs)/(@max_vgs - @min_vgs) AS venue_going_std,
(venue_going_avg - @min_vga)/(@max_vga - @min_vga) AS venue_going_avg
 FROM datos_desa.tb_ce_${sufijo}_x8a
;

ALTER TABLE datos_desa.tb_ce_${sufijo}_x8b ADD INDEX tb_ce_${sufijo}_x8b_idx(track);
SELECT * FROM datos_desa.tb_ce_${sufijo}_x8b LIMIT 5;
SELECT count(*) as num_x8a FROM datos_desa.tb_ce_${sufijo}_x8b LIMIT 5;
EOF

#echo -e $(date +"%T")"$CONSULTA_X8" 2>&1 1>>${LOG_CE}
mysql -u root --password=datos1986 --execute="$CONSULTA_X8" >>$LOG_CE
}

##########################################################################################
function calcularVariableX9 ()
{
filtro_galgos="${1}"
sufijo="${2}"
echo -e "\n"$(date +"%T")" ---- X9: [entrenador -> puntos]. Calidad del ENTRENADOR" 2>&1 1>>${LOG_CE}
echo -e $(date +"%T")"Parametros: -->${1}-->${2}" 2>&1 1>>${LOG_CE}

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

#echo -e $(date +"%T")"$CONSULTA_X9" 2>&1 1>>${LOG_CE}
mysql -u root --password=datos1986 --execute="$CONSULTA_X9" >>$LOG_CE
}

##########################################################################################
function calcularVariableX10 ()
{
filtro_galgos="${1}"
sufijo="${2}"
echo -e "\n"$(date +"%T")" ---- X10: [(carrera, galgo) -> (edad_en_dias)]" 2>&1 1>>${LOG_CE}
echo -e $(date +"%T")"Parametros: -->${1}-->${2}" 2>&1 1>>${LOG_CE}

read -d '' CONSULTA_X10 <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x10a;

CREATE TABLE datos_desa.tb_ce_${sufijo}_x10a AS 
SELECT id_carrera, galgo_nombre, edad_en_dias
FROM datos_desa.tb_galgos_posiciones_en_carreras_norm;

SELECT * FROM datos_desa.tb_ce_${sufijo}_x10a LIMIT 5;
SELECT count(*) as num_x10a FROM datos_desa.tb_ce_${sufijo}_x10a LIMIT 5;

set @min_eed=(select MIN(edad_en_dias) FROM datos_desa.tb_ce_${sufijo}_x10a);
set @max_eed=(select MAX(edad_en_dias) FROM datos_desa.tb_ce_${sufijo}_x10a);


DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x10b;

CREATE TABLE datos_desa.tb_ce_${sufijo}_x10b AS 
SELECT id_carrera, galgo_nombre,
(edad_en_dias - @min_eed)/(@max_eed - @min_eed) AS eed_norm
FROM datos_desa.tb_ce_${sufijo}_x10a;

ALTER TABLE datos_desa.tb_ce_${sufijo}_x10b ADD INDEX tb_ce_${sufijo}_x10b_idx(id_carrera, galgo_nombre);
SELECT * FROM datos_desa.tb_ce_${sufijo}_x10b LIMIT 5;
SELECT count(*) as num_x10b FROM datos_desa.tb_ce_${sufijo}_x10b LIMIT 5;
EOF

#echo -e $(date +"%T")"$CONSULTA_X10" 2>&1 1>>${LOG_CE}
mysql -u root --password=datos1986 --execute="$CONSULTA_X10" >>$LOG_CE
}

##########################################################################################
function calcularVariableX11 ()
{
filtro_galgos="${1}"
sufijo="${2}"
echo -e "\n"$(date +"%T")" ---- X11: [(galgo) -> (agregados normalizados del galgo)]" 2>&1 1>>${LOG_CE}
echo -e $(date +"%T")"Parametros: -->${1}-->${2}" 2>&1 1>>${LOG_CE}

#vel_real_cortas_mediana | vel_real_cortas_max | vel_going_cortas_mediana | vel_going_cortas_max | 
#vel_real_longmedias_mediana | vel_real_longmedias_max | vel_going_longmedias_mediana | vel_going_longmedias_max | 
#vel_real_largas_mediana | vel_real_largas_max | vel_going_largas_mediana | vel_going_largas_max

read -d '' CONSULTA_X11 <<- EOF
set @min_vrc_med=(select MIN(vel_real_cortas_mediana) FROM datos_desa.tb_galgos_agregados_norm);
set @max_vrc_med=(select MAX(vel_real_cortas_mediana) FROM datos_desa.tb_galgos_agregados_norm);
set @min_vrc_max=(select MIN(vel_real_cortas_max) FROM datos_desa.tb_galgos_agregados_norm);
set @max_vrc_max=(select MAX(vel_real_cortas_max) FROM datos_desa.tb_galgos_agregados_norm);
set @min_vgc_med=(select MIN(vel_going_cortas_mediana) FROM datos_desa.tb_galgos_agregados_norm);
set @max_vgc_med=(select MAX(vel_going_cortas_mediana) FROM datos_desa.tb_galgos_agregados_norm);
set @min_vgc_max=(select MIN(vel_going_cortas_max) FROM datos_desa.tb_galgos_agregados_norm);
set @max_vgc_max=(select MAX(vel_going_cortas_max) FROM datos_desa.tb_galgos_agregados_norm);

set @min_vrlm_med=(select MIN(vel_real_longmedias_mediana) FROM datos_desa.tb_galgos_agregados_norm);
set @max_vrlm_med=(select MAX(vel_real_longmedias_mediana) FROM datos_desa.tb_galgos_agregados_norm);
set @min_vrlm_max=(select MIN(vel_real_longmedias_max) FROM datos_desa.tb_galgos_agregados_norm);
set @max_vrlm_max=(select MAX(vel_real_longmedias_max) FROM datos_desa.tb_galgos_agregados_norm);
set @min_vglm_med=(select MIN(vel_going_longmedias_mediana) FROM datos_desa.tb_galgos_agregados_norm);
set @max_vglm_med=(select MAX(vel_going_longmedias_mediana) FROM datos_desa.tb_galgos_agregados_norm);
set @min_vglm_max=(select MIN(vel_going_longmedias_max) FROM datos_desa.tb_galgos_agregados_norm);
set @max_vglm_max=(select MAX(vel_going_longmedias_max) FROM datos_desa.tb_galgos_agregados_norm);

set @min_vrl_med=(select MIN(vel_real_largas_mediana) FROM datos_desa.tb_galgos_agregados_norm);
set @max_vrl_med=(select MAX(vel_real_largas_mediana) FROM datos_desa.tb_galgos_agregados_norm);
set @min_vrl_max=(select MIN(vel_real_largas_max) FROM datos_desa.tb_galgos_agregados_norm);
set @max_vrl_max=(select MAX(vel_real_largas_max) FROM datos_desa.tb_galgos_agregados_norm);
set @min_vgl_med=(select MIN(vel_going_largas_mediana) FROM datos_desa.tb_galgos_agregados_norm);
set @max_vgl_med=(select MAX(vel_going_largas_mediana) FROM datos_desa.tb_galgos_agregados_norm);
set @min_vgl_max=(select MIN(vel_going_largas_max) FROM datos_desa.tb_galgos_agregados_norm);
set @max_vgl_max=(select MAX(vel_going_largas_max) FROM datos_desa.tb_galgos_agregados_norm);


DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x11;

CREATE TABLE datos_desa.tb_ce_${sufijo}_x11 AS 
SELECT galgo_nombre, 

vel_real_cortas_mediana,
(vel_real_cortas_mediana - @min_vrc_med)/(@max_vrc_med - @min_vrc_med) AS vel_real_cortas_mediana_norm,
vel_real_cortas_max,
(vel_real_cortas_max - @min_vrc_max)/(@max_vrc_max - @min_vrc_max) AS vel_real_cortas_max_norm,
vel_going_cortas_mediana,
(vel_going_cortas_mediana - @min_vgc_med)/(@max_vgc_med - @min_vgc_med) AS vel_going_cortas_mediana_norm,
vel_going_cortas_max,
(vel_going_cortas_max - @min_vgc_max)/(@max_vgc_max - @min_vgc_max) AS vel_going_cortas_max_norm,

vel_real_longmedias_mediana,
(vel_real_longmedias_mediana - @min_vrlm_med)/(@max_vrlm_med - @min_vrlm_med) AS vel_real_longmedias_mediana_norm,
vel_real_longmedias_max,
(vel_real_longmedias_max - @min_vrlm_max)/(@max_vrlm_max - @min_vrlm_max) AS vel_real_longmedias_max_norm,
vel_going_longmedias_mediana,
(vel_going_longmedias_mediana - @min_vglm_med)/(@max_vglm_med - @min_vglm_med) AS vel_going_longmedias_mediana_norm,
vel_going_longmedias_max,
(vel_going_longmedias_max - @min_vglm_max)/(@max_vglm_max - @min_vglm_max) AS vel_going_longmedias_max_norm,

vel_real_largas_mediana,
(vel_real_largas_mediana - @min_vrl_med)/(@max_vrl_med - @min_vrl_med) AS vel_real_largas_mediana_norm,
vel_real_largas_max,
(vel_real_largas_max - @min_vrl_max)/(@max_vrl_max - @min_vrl_max) AS vel_real_largas_max_norm,
vel_going_largas_mediana,
(vel_going_largas_mediana - @min_vgl_med)/(@max_vgl_med - @min_vgl_med) AS vel_going_largas_mediana_norm,
vel_going_largas_max,
(vel_going_largas_max - @min_vgl_max)/(@max_vgl_max - @min_vgl_max) AS vel_going_largas_max_norm

FROM datos_desa.tb_galgos_agregados_norm;

ALTER TABLE datos_desa.tb_ce_${sufijo}_x11 ADD INDEX tb_ce_${sufijo}_x11_idx(galgo_nombre);
SELECT * FROM datos_desa.tb_ce_${sufijo}_x11 LIMIT 5;
SELECT count(*) as num_x11 FROM datos_desa.tb_ce_${sufijo}_x11 LIMIT 5;
EOF

#echo -e $(date +"%T")"$CONSULTA_X11" 2>&1 1>>${LOG_CE}
mysql -u root --password=datos1986 --execute="$CONSULTA_X11" >>$LOG_CE
}

##########################################################################################
function calcularVariableX12 ()
{
filtro_galgos="${1}"
sufijo="${2}"
echo -e "\n"$(date +"%T")" ---- X12: [ carrera -> (propiedades normalizadas de la carrera)]" 2>&1 1>>${LOG_CE}
echo -e $(date +"%T")"Parametros: -->${1}-->${2}" 2>&1 1>>${LOG_CE}

echo -e $(date +"%T")"PENDIENTE Leer el track (pista) y sacar las caracteristicas de su ubicacion fisica (norte, sur, cerca del mar, altitud, numero de espectadores presenciales, tamaño de la pista...)" 2>&1 1>>${LOG_CE}

echo -e $(date +"%T")"PENDIENTE Leer la clase (tipo de competición) y crear categorias (boolean): tipo A, OR, S... --> SELECT DISTINCT clase FROM datos_desa.tb_galgos_carreras LIMIT 100;" 2>&1 1>>${LOG_CE}

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
set @max_hora=(select MAX(hora) FROM datos_desa.tb_ce_${sufijo}_x12a);
set @min_num_galgos=(select MIN(num_galgos) FROM datos_desa.tb_ce_${sufijo}_x12a);
set @max_num_galgos=(select MAX(num_galgos) FROM datos_desa.tb_ce_${sufijo}_x12a);
set @min_premio_primero=(select MIN(premio_primero) FROM datos_desa.tb_ce_${sufijo}_x12a);
set @max_premio_primero=(select MAX(premio_primero) FROM datos_desa.tb_ce_${sufijo}_x12a);
set @min_premio_segundo=(select MIN(premio_segundo) FROM datos_desa.tb_ce_${sufijo}_x12a);
set @max_premio_segundo=(select MAX(premio_segundo) FROM datos_desa.tb_ce_${sufijo}_x12a);
set @min_premio_otros=(select MIN(premio_otros) FROM datos_desa.tb_ce_${sufijo}_x12a);
set @max_premio_otros=(select MAX(premio_otros) FROM datos_desa.tb_ce_${sufijo}_x12a);
set @min_premio_total_carrera=(select MIN(premio_total_carrera) FROM datos_desa.tb_ce_${sufijo}_x12a);
set @max_premio_total_carrera=(select MAX(premio_total_carrera) FROM datos_desa.tb_ce_${sufijo}_x12a);
set @min_going_allowance_segundos=(select MIN(going_allowance_segundos) FROM datos_desa.tb_ce_${sufijo}_x12a);
set @max_going_allowance_segundos=(select MAX(going_allowance_segundos) FROM datos_desa.tb_ce_${sufijo}_x12a);
set @min_fc_1=(select MIN(fc_1) FROM datos_desa.tb_ce_${sufijo}_x12a);
set @max_fc_1=(select MAX(fc_1) FROM datos_desa.tb_ce_${sufijo}_x12a);
set @min_fc_2=(select MIN(fc_2) FROM datos_desa.tb_ce_${sufijo}_x12a);
set @max_fc_2=(select MAX(fc_2) FROM datos_desa.tb_ce_${sufijo}_x12a);
set @min_fc_pounds=(select MIN(fc_pounds) FROM datos_desa.tb_ce_${sufijo}_x12a);
set @max_fc_pounds=(select MAX(fc_pounds) FROM datos_desa.tb_ce_${sufijo}_x12a);
set @min_tc_1=(select MIN(tc_1) FROM datos_desa.tb_ce_${sufijo}_x12a);
set @max_tc_1=(select MAX(tc_1) FROM datos_desa.tb_ce_${sufijo}_x12a);
set @min_tc_2=(select MIN(tc_2) FROM datos_desa.tb_ce_${sufijo}_x12a);
set @max_tc_2=(select MAX(tc_2) FROM datos_desa.tb_ce_${sufijo}_x12a);
set @min_tc_3=(select MIN(tc_3) FROM datos_desa.tb_ce_${sufijo}_x12a);
set @max_tc_3=(select MAX(tc_3) FROM datos_desa.tb_ce_${sufijo}_x12a);
set @min_tc_pounds=(select MIN(tc_pounds) FROM datos_desa.tb_ce_${sufijo}_x12a);
set @max_tc_pounds=(select MAX(tc_pounds) FROM datos_desa.tb_ce_${sufijo}_x12a);


DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}_x12b;

CREATE TABLE datos_desa.tb_ce_${sufijo}_x12b AS 
SELECT 
id_carrera,
mes AS mes_norm,
(hora - @min_hora)/(@max_hora - @min_hora) AS hora_norm,
(num_galgos - @min_num_galgos)/(@max_num_galgos - @min_num_galgos) AS num_galgos_norm,
(premio_primero - @min_premio_primero)/(@max_premio_primero - @min_premio_primero) AS premio_primero_norm,
(premio_segundo - @min_premio_segundo)/(@max_premio_segundo - @min_premio_segundo) AS premio_segundo_norm,
(premio_otros - @min_premio_otros)/(@max_premio_otros - @min_premio_otros) AS premio_otros_norm,
(premio_total_carrera - @min_premio_total_carrera)/(@max_premio_total_carrera - @min_premio_total_carrera) AS premio_total_carrera_norm,
(going_allowance_segundos - @min_going_allowance_segundos)/(@max_going_allowance_segundos - @min_going_allowance_segundos) AS going_allowance_segundos_norm,
(fc_1 - @min_fc_1)/(@max_fc_1 - @min_fc_1) AS fc_1_norm,
(fc_2 - @min_fc_2)/(@max_fc_2 - @min_fc_2) AS fc_2_norm,
(fc_pounds - @min_fc_pounds)/(@max_fc_pounds - @min_fc_pounds) AS fc_pounds_norm,
(tc_1 - @min_tc_1)/(@max_tc_1 - @min_tc_1) AS tc_1_norm,
(tc_2 - @min_tc_2)/(@max_tc_2 - @min_tc_2) AS tc_2_norm,
(tc_3 - @min_tc_3)/(@max_tc_3 - @min_tc_3) AS tc_3_norm,
(tc_pounds - @min_tc_pounds)/(@max_tc_pounds - @min_tc_pounds) AS tc_pounds_norm
FROM datos_desa.tb_ce_${sufijo}_x12a;

ALTER TABLE datos_desa.tb_ce_${sufijo}_x12b ADD INDEX tb_ce_${sufijo}_x12b_idx(id_carrera);
SELECT * FROM datos_desa.tb_ce_${sufijo}_x12b LIMIT 5;
SELECT count(*) as num_x12b FROM datos_desa.tb_ce_${sufijo}_x12b LIMIT 5;
EOF

#echo -e $(date +"%T")"$CONSULTA_X12" 2>&1 1>>${LOG_CE}
mysql -u root --password=datos1986 --execute="$CONSULTA_X12" >>$LOG_CE
}


################ TABLAS de INDICES ####################################################################################
function generarTablasIndices ()
{
echo -e "\n"$(date +"%T")" \n---- TABLAS DE INDICES -------- " 2>&1 1>>${LOG_CE}

echo -e $(date +"%T")"Tablas ORIGINALES:" 2>&1 1>>${LOG_CE}
echo -e $(date +"%T")"datos_desa.tb_galgos_carreras_norm --> id_carrera" 2>&1 1>>${LOG_CE}
echo -e $(date +"%T")"datos_desa.tb_galgos_posiciones_en_carreras_norm --> (id_carrera, galgo_nombre)" 2>&1 1>>${LOG_CE}
echo -e $(date +"%T")"datos_desa.tb_galgos_historico_norm --> (id_carrera, galgo_nombre)" 2>&1 1>>${LOG_CE}
echo -e $(date +"%T")"datos_desa.tb_galgos_agregados_norm --> galgo_nombre" 2>&1 1>>${LOG_CE}

echo -e $(date +"%T")"Tablas de columnas ELABORADAS (provienen de usar las originales, así que tienen las mismas claves):" 2>&1 1>>${LOG_CE}
echo -e $(date +"%T")"datos_desa.tb_ce_${sufijo}_x1b --> galgo_nombre" 2>&1 1>>${LOG_CE}
echo -e $(date +"%T")"datos_desa.tb_ce_${sufijo}_x2b --> (id_carrera, galgo_nombre)" 2>&1 1>>${LOG_CE}
echo -e $(date +"%T")"datos_desa.tb_ce_${sufijo}_x3b --> trap (se usa con carrera+galgo)" 2>&1 1>>${LOG_CE}
echo -e $(date +"%T")"datos_desa.datos_desa.tb_ce_${sufijo}_x4 --> (id_carrera, galgo_nombre)" 2>&1 1>>${LOG_CE}
echo -e $(date +"%T")"datos_desa.tb_ce_${sufijo}_x5 --> (id_carrera, galgo_nombre)" 2>&1 1>>${LOG_CE}
echo -e $(date +"%T")"datos_desa.tb_ce_${sufijo}_x6e --> (id_carrera, galgo_nombre)" 2>&1 1>>${LOG_CE}
echo -e $(date +"%T")"datos_desa.tb_ce_${sufijo}_x7d --> (id_carrera, galgo_nombre)" 2>&1 1>>${LOG_CE}
echo -e $(date +"%T")"datos_desa.tb_ce_${sufijo}_x8b --> track (se usa con carrera)" 2>&1 1>>${LOG_CE}
echo -e $(date +"%T")"datos_desa.tb_ce_${sufijo}_x9b --> entrenador (se usa con galgo)" 2>&1 1>>${LOG_CE}
echo -e $(date +"%T")"datos_desa.tb_ce_${sufijo}_x10b --> (id_carrera, galgo_nombre)" 2>&1 1>>${LOG_CE}
echo -e $(date +"%T")"datos_desa.tb_ce_${sufijo}_x11 --> galgo_nombre" 2>&1 1>>${LOG_CE}
echo -e $(date +"%T")"datos_desa.tb_ce_${sufijo}_x12b --> id_carrera" 2>&1 1>>${LOG_CE}


echo -e "\n"$(date +"%T")" -------- 3 Tablas auxiliares con todas las claves extraidas y haciendo DISTINCT (serás las tablas MAESTRAS de índices)-------" 2>&1 1>>${LOG_CE}

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
SELECT cg, 
substring_index(cg,"|",1) AS id_carrera, 
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

#echo -e $(date +"%T")"$CONSULTA_IDS" 2>&1 1>>${LOG_CE}
mysql -u root --password=datos1986 --execute="$CONSULTA_IDS" 2>&1 1>>${LOG_CE}


echo -e "\n"$(date +"%T")" Comprobacion: las 3 tablas de IDs no deben tener duplicados" 2>&1 1>>${LOG_CE}
mysql -u root --password=datos1986 --execute="SELECT id_carrera, count(*) as num_ids_carreras FROM datos_desa.tb_ids_carreras_${sufijo} GROUP BY id_carrera HAVING num_ids_carreras>=2 LIMIT 5;" 2>&1 1>>${LOG_CE}
mysql -u root --password=datos1986 --execute="SELECT galgo_nombre, count(*) as num_ids_galgos FROM datos_desa.tb_ids_galgos_${sufijo} GROUP BY galgo_nombre HAVING num_ids_galgos>=2 LIMIT 5;" 2>&1 1>>${LOG_CE}
mysql -u root --password=datos1986 --execute="SELECT cg, count(*) as num_ids_cg FROM datos_desa.tb_ids_carrerasgalgos_${sufijo} GROUP BY cg HAVING num_ids_cg>=2 LIMIT 5;" 2>&1 1>>${LOG_CE}

}


################ TABLAS PREPARADAS (con columnas elaboradas) ####################################################################################
### ATENCION: MySQL no soporta FULL OUTER JOIN, asi que tenemos 2 opciones:
# - Opcion 1: hacer LEFT OJ + RIGHT OJ
# - Opcion 2: crear tablas auxiliares de indices (carreras ó galgos ó carrera+galgo), hacer DISTINCT. Luego usar esas tablas haciendo solo LEFT JOINs.


function generarTablasElaboradas ()
{

echo -e "\n"$(date +"%T")" \n---- TABLA ELABORADA 1: [ carrera -> columnas ]" 2>&1 1>>${LOG_CE}

read -d '' CONSULTA_ELAB1 <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_elaborada_carreras_${sufijo};

CREATE TABLE datos_desa.tb_elaborada_carreras_${sufijo} AS 
SELECT 
dentro.*, 
D.venue_going_std, D.venue_going_avg
FROM (
  SELECT 
  A.id_carrera,
  B.id_campeonato, B.track, B.clase, B.distancia_norm,
  C.num_galgos_norm,

  IFNULL(B.mes_norm, C.mes_norm) AS mes_norm,
  IFNULL(B.hora_norm, C.hora_norm) AS hora_norm,
  IFNULL(B.premio_primero_norm, C.premio_primero_norm) AS premio_primero_norm,
  IFNULL(B.premio_segundo_norm, C.premio_segundo_norm) AS premio_segundo_norm,
  IFNULL(B.premio_otros_norm, C.premio_otros_norm) AS premio_otros_norm,
  IFNULL(B.premio_total_carrera_norm, C.premio_total_carrera_norm) AS premio_total_carrera_norm,
  IFNULL(B.going_allowance_segundos_norm, C.going_allowance_segundos_norm) AS going_allowance_segundos_norm,
  IFNULL(B.fc_1_norm, C.fc_1_norm) AS fc_1_norm,
  IFNULL(B.fc_2_norm, C.fc_2_norm) AS fc_2_norm,
  IFNULL(B.fc_pounds_norm, C.fc_pounds_norm) AS fc_pounds_norm,
  IFNULL(B.tc_1_norm, C.tc_1_norm) AS tc_1_norm,
  IFNULL(B.tc_2_norm, C.tc_2_norm) AS tc_2_norm,
  IFNULL(B.tc_3_norm, C.tc_3_norm) AS tc_3_norm,
  IFNULL(B.tc_pounds_norm, C.tc_pounds_norm) AS tc_pounds_norm

  FROM datos_desa.tb_ids_carreras_${sufijo} A
  LEFT JOIN datos_desa.tb_galgos_carreras_norm B ON (A.id_carrera=B.id_carrera)
  LEFT JOIN datos_desa.tb_ce_${sufijo}_x12b C ON (A.id_carrera=C.id_carrera)
) dentro

LEFT JOIN datos_desa.tb_ce_${sufijo}_x8b D ON (dentro.track=D.track)
;

ALTER TABLE datos_desa.tb_elaborada_carreras_${sufijo} ADD INDEX tb_elaborada_carreras_${sufijo}_idx(id_carrera);
SELECT * FROM datos_desa.tb_elaborada_carreras_${sufijo} ORDER BY id_carrera LIMIT 5;
SELECT count(*) as num_elab_carreras FROM datos_desa.tb_elaborada_carreras_${sufijo} LIMIT 5;
EOF

#echo -e $(date +"%T")"$CONSULTA_ELAB1" 2>&1 1>>${LOG_CE}
mysql -u root --password=datos1986 -t --execute="$CONSULTA_ELAB1" >>$LOG_CE


echo -e "\n"$(date +"%T")" \n---- TABLA ELABORADA 2: [ galgo -> columnas ]" 2>&1 1>>${LOG_CE}
read -d '' CONSULTA_ELAB2 <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_elaborada_galgos_${sufijo};

CREATE TABLE datos_desa.tb_elaborada_galgos_${sufijo} AS 
SELECT 
A.*,

C.vgcortas_max_norm, C.vgmedias_max_norm, C.vglargas_max_norm,

D.vel_real_cortas_mediana_norm, D.vel_real_cortas_max_norm, D.vel_going_cortas_mediana_norm, D.vel_going_cortas_max_norm, D.vel_real_longmedias_mediana_norm, D.vel_real_longmedias_max_norm, D.vel_going_longmedias_mediana_norm, D.vel_going_longmedias_max_norm, D.vel_real_largas_mediana_norm, D.vel_real_largas_max_norm, D.vel_going_largas_mediana_norm, D.vel_going_largas_max_norm

FROM datos_desa.tb_ids_galgos_${sufijo} A

LEFT JOIN datos_desa.tb_galgos_agregados_norm B ON (A.galgo_nombre=B.galgo_nombre)
LEFT JOIN datos_desa.tb_ce_${sufijo}_x1b C ON (A.galgo_nombre=C.galgo_nombre)
LEFT JOIN datos_desa.tb_ce_${sufijo}_x11 D ON (A.galgo_nombre=D.galgo_nombre)
;

ALTER TABLE datos_desa.tb_elaborada_galgos_${sufijo} ADD INDEX tb_elaborada_galgos_${sufijo}_idx(galgo_nombre);
SELECT * FROM datos_desa.tb_elaborada_galgos_${sufijo} ORDER BY galgo_nombre LIMIT 5;
SELECT count(*) as num_elab_galgos FROM datos_desa.tb_elaborada_galgos_${sufijo} LIMIT 5;
EOF

#echo -e $(date +"%T")"$CONSULTA_ELAB2" 2>&1 1>>${LOG_CE}
mysql -u root --password=datos1986 -t --execute="$CONSULTA_ELAB2" >>$LOG_CE


echo -e "\n"$(date +"%T")" \n---- TABLA ELABORADA 3: [ carrera+galgo -> columnas ]" 2>&1 1>>${LOG_CE}
read -d '' CONSULTA_ELAB3 <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_elaborada_carrerasgalgos_${sufijo}_aux1;

CREATE TABLE datos_desa.tb_elaborada_carrerasgalgos_${sufijo}_aux1 AS
SELECT 
  A.*,
  B.time_sec_norm, B.time_distance_norm, B.peso_galgo_norm, B.galgo_padre, B.galgo_madre, B.comment, B.edad_en_dias_norm,
  C.distancia,  C.stmhcp, C.by_dato, C.galgo_primero_o_segundo, C.venue, C.remarks, C.win_time, C.going, C.clase, C.calculated_time, C.velocidad_real, C.velocidad_con_going, C.scoring_remarks,
  D.experiencia,
  IFNULL(B.posicion,C.posicion) AS posicion,
  IFNULL(B.sp_norm, C.sp_norm) AS sp_norm,
  IFNULL(B.id_campeonato, C.id_campeonato) AS id_campeonato,
  IFNULL(B.trap, C.trap) AS trap,
  IFNULL(B.trap_norm, C.trap_norm) AS trap_norm,
  IFNULL(C.anio, D.anio) AS anio,
  IFNULL(C.mes, D.mes) AS mes,
  IFNULL(C.dia, D.dia) AS dia,
  IFNULL(B.entrenador_nombre, C.entrenador) AS entrenador

  FROM datos_desa.tb_ids_carrerasgalgos_${sufijo} A
  LEFT JOIN datos_desa.tb_galgos_posiciones_en_carreras_norm B ON (A.id_carrera=B.id_carrera AND A.galgo_nombre=B.galgo_nombre)
  LEFT JOIN datos_desa.tb_galgos_historico_norm C ON (A.id_carrera=C.id_carrera AND A.galgo_nombre=C.galgo_nombre)
  LEFT JOIN datos_desa.tb_ce_${sufijo}_x2b D ON (A.id_carrera=D.id_carrera AND A.galgo_nombre=D.galgo_nombre)
;

ALTER TABLE datos_desa.tb_elaborada_carrerasgalgos_${sufijo}_aux1 ADD INDEX tb_elaborada_carrerasgalgos_${sufijo}_aux1_idx(id_carrera, galgo_nombre);


DROP TABLE IF EXISTS datos_desa.tb_elaborada_carrerasgalgos_${sufijo};

CREATE TABLE datos_desa.tb_elaborada_carrerasgalgos_${sufijo} AS 
SELECT
dentro.cg, dentro.id_carrera, dentro.galgo_nombre, dentro.time_sec_norm, dentro.time_distance_norm, dentro.peso_galgo_norm, dentro.galgo_padre, dentro.galgo_madre, dentro.comment, dentro.edad_en_dias_norm, dentro.stmhcp, dentro.by_dato, dentro.galgo_primero_o_segundo, dentro.venue, dentro.remarks, dentro.win_time, dentro.going, dentro.calculated_time, dentro.velocidad_real, dentro.velocidad_con_going, dentro.scoring_remarks, dentro.experiencia, dentro.posicion, dentro.id_campeonato,
E.trap_factor,
H.experiencia_cualitativo, H.experiencia_en_clase, H.posicion_media_en_clase_por_experiencia,
I.distancia_centenas, I.dif_peso,
J.entrenador_posicion_norm,
K.eed_norm,
dentro.trap_norm,
IFNULL(dentro.mes, H.mes) AS mes,
IFNULL(dentro.sp_norm,F.sp_norm) AS sp_norm,
IFNULL(dentro.clase, IFNULL(G.clase, H.clase) ) AS clase,
IFNULL(dentro.distancia, I.distancia) AS distancia,
IFNULL(dentro.entrenador, J.entrenador) AS entrenador

FROM datos_desa.tb_elaborada_carrerasgalgos_${sufijo}_aux1 dentro
LEFT JOIN datos_desa.tb_ce_${sufijo}_x3b E ON (dentro.trap=E.trap)
LEFT JOIN datos_desa.tb_ce_${sufijo}_x4 F ON (dentro.id_carrera=F.id_carrera AND dentro.galgo_nombre=F.galgo_nombre)
LEFT JOIN datos_desa.tb_ce_${sufijo}_x5 G ON (dentro.id_carrera=G.id_carrera AND dentro.galgo_nombre=G.galgo_nombre)
LEFT JOIN datos_desa.tb_ce_${sufijo}_x6e H ON (dentro.id_carrera=H.id_carrera AND dentro.galgo_nombre=H.galgo_nombre AND dentro.clase=H.clase)
LEFT JOIN datos_desa.tb_ce_${sufijo}_x7d I ON (dentro.id_carrera=I.id_carrera AND dentro.galgo_nombre=I.galgo_nombre)
LEFT JOIN datos_desa.tb_ce_${sufijo}_x9b J ON (dentro.entrenador=J.entrenador)
LEFT JOIN datos_desa.tb_ce_${sufijo}_x10b K ON (dentro.id_carrera=K.id_carrera AND dentro.galgo_nombre=K.galgo_nombre)
;

ALTER TABLE datos_desa.tb_elaborada_carrerasgalgos_${sufijo} ADD INDEX tb_elaborada_carrerasgalgos_${sufijo}_idx(id_carrera,galgo_nombre);
SELECT * FROM datos_desa.tb_elaborada_carrerasgalgos_${sufijo} ORDER BY cg LIMIT 5;
SELECT count(*) as num_elab_cg FROM datos_desa.tb_elaborada_carrerasgalgos_${sufijo} LIMIT 5;
EOF

#echo -e $(date +"%T")"$CONSULTA_ELAB3" 2>&1 1>>${LOG_CE}
mysql -u root --password=datos1986 -t --execute="$CONSULTA_ELAB3" >>$LOG_CE


echo -e "\n"$(date +"%T")" Comprobacion: las 3 tablas de columnas ELABORADAS no deben tener duplicados (por clave)" 2>&1 1>>${LOG_CE}
mysql -u root --password=datos1986 --execute="SELECT id_carrera, count(*) as num_ids_carreras FROM datos_desa.tb_elaborada_carreras_${sufijo} GROUP BY id_carrera HAVING num_ids_carreras>=2 LIMIT 5;" 2>&1 1>>${LOG_CE}
mysql -u root --password=datos1986 --execute="SELECT galgo_nombre, count(*) as num_ids_galgos FROM datos_desa.tb_elaborada_galgos_${sufijo} GROUP BY galgo_nombre HAVING num_ids_galgos>=2 LIMIT 5;" 2>&1 1>>${LOG_CE}
mysql -u root --password=datos1986 --execute="SELECT cg, count(*) as num_ids_cg FROM datos_desa.tb_elaborada_carrerasgalgos_${sufijo} GROUP BY cg HAVING num_ids_cg>=2 LIMIT 5;" 2>&1 1>>${LOG_CE}

}



################################################ MAIN ###########################################################################################

if [ "$#" -ne 2 ]; then
    echo "Numero de parametros incorrecto!!!" 2>&1 1>>${LOG_CE}
fi

#filtro_galgos=""
#filtro_galgos="WHERE galgo_nombre IN (${filtro_galgos_nombres})"
filtro_galgos="${1}"

#sufijo="pre"
#sufijo="post"
sufijo="${2}"


echo -e $(date +"%T")"Generador de COLUMNAS ELABORADAS: INICIO" 2>&1 1>>${LOG_CE}
echo -e $(date +"%T")"Parametros: -->${1}-->${2}" 2>&1 1>>${LOG_CE}

echo -e "\n"$(date +"%T")" ---- Variables: X1, X2..." 2>&1 1>>${LOG_CE}
calcularVariableX1 "${filtro_galgos}" "${sufijo}"
calcularVariableX2 "${filtro_galgos}" "${sufijo}"
calcularVariableX3 "${filtro_galgos}" "${sufijo}"
calcularVariableX4 "${filtro_galgos}" "${sufijo}"
calcularVariableX5 "${filtro_galgos}" "${sufijo}"
calcularVariableX6 "${filtro_galgos}" "${sufijo}"
calcularVariableX7 "${filtro_galgos}" "${sufijo}"
calcularVariableX8 "${filtro_galgos}" "${sufijo}"
calcularVariableX9 "${filtro_galgos}" "${sufijo}"
calcularVariableX10 "${filtro_galgos}" "${sufijo}"
calcularVariableX11 "${filtro_galgos}" "${sufijo}"
calcularVariableX12 "${filtro_galgos}" "${sufijo}"

echo -e "\n"$(date +"%T")" ---- Tablas MAESTRAS de INDICES..." 2>&1 1>>${LOG_CE}
generarTablasIndices

echo -e "\n"$(date +"%T")" ---- Tablas finales con COLUMNAS ELABORADAS (se usarán para crear datasets)..." 2>&1 1>>${LOG_CE}
generarTablasElaboradas

echo -e $(date +"%T")"Generador de COLUMNAS ELABORADAS: FIN\n\n" 2>&1 1>>${LOG_CE}






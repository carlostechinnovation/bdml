#!/bin/bash

function calcularVariableX1 ()
{
##########################################################################################
echo -e "\n---- X1: [(carrera, galgo) -> velocidad_max_going]" >&1
mysql -u root --password=datos1986 --execute="DROP TABLE IF EXISTS datos_desa.tb_pga_x1a\W;" >>$PATH_WARNINGS_PGA
mysql -u root --password=datos1986 --execute="CREATE TABLE datos_desa.tb_pga_x1a AS SELECT 1 AS distancia_tipo, MIN(vel_going_cortas_max) AS valor_min, MAX(vel_going_cortas_max) AS valor_max FROM datos_desa.tb_galgos_agregados UNION SELECT 2 AS distancia_tipo, MIN(vel_going_longmedias_max) AS valor_min, MAX(vel_going_longmedias_max) AS valor_max FROM datos_desa.tb_galgos_agregados UNION SELECT 3 AS distancia_tipo, MIN(vel_going_largas_max) AS valor_min, MAX(vel_going_largas_max) AS valor_max FROM datos_desa.tb_galgos_agregados\W;" >>$PATH_WARNINGS_PGA
mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_pga_x1a LIMIT 10\W;" >>$PATH_WARNINGS_PGA
mysql -u root --password=datos1986 --execute="SELECT count(*) as num_x1a FROM datos_desa.tb_pga_x1a LIMIT 10\W;" >>$PATH_WARNINGS_PGA

read -d '' CONSULTA_X1 <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_pga_x1b;

CREATE TABLE datos_desa.tb_pga_x1b AS SELECT galgo_nombre, 

(vel_going_cortas_max - (select valor_min FROM datos_desa.tb_pga_x1a WHERE distancia_tipo=1) ) / (select valor_max FROM datos_desa.tb_pga_x1a WHERE distancia_tipo=1) AS vgcortasm_norm, 

(vel_going_longmedias_max - (select valor_min FROM datos_desa.tb_pga_x1a WHERE distancia_tipo=2) ) / (select valor_max FROM datos_desa.tb_pga_x1a WHERE distancia_tipo=2) AS vgmediasm_norm, 

(vel_going_largas_max - (select valor_min FROM datos_desa.tb_pga_x1a WHERE distancia_tipo=3) ) / (select valor_max FROM datos_desa.tb_pga_x1a WHERE distancia_tipo=3) AS vglargasm_norm 

FROM datos_desa.tb_galgos_agregados;

SELECT * FROM datos_desa.tb_pga_x1b LIMIT 10;

SELECT count(*) as num_x1b FROM datos_desa.tb_pga_x1b LIMIT 10;
EOF

#echo -e "$CONSULTA_X1" 2>&1 >&1
mysql -u root --password=datos1986 --execute="$CONSULTA_X1" >>$PATH_WARNINGS_PGA
}

function calcularVariableX2 ()
{
##########################################################################################
echo -e "\n---- X2: [Galgo ->experiencia]" >&1
mysql -u root --password=datos1986 --execute="DROP TABLE IF EXISTS datos_desa.tb_pga_x2a\W;" >>$PATH_WARNINGS_PGA
mysql -u root --password=datos1986 --execute="CREATE TABLE datos_desa.tb_pga_x2a AS SELECT MIN(contador) AS experiencia_min, MAX(contador) AS experiencia_max FROM (SELECT galgo_nombre, count(*) as contador FROM datos_desa.tb_galgos_historico GROUP BY galgo_nombre) dentro \W;" >>$PATH_WARNINGS_PGA
mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_pga_x2a LIMIT 10\W;" >>$PATH_WARNINGS_PGA
mysql -u root --password=datos1986 --execute="SELECT count(*) as num_x2a FROM datos_desa.tb_pga_x2a LIMIT 10\W;" >>$PATH_WARNINGS_PGA

mysql -u root --password=datos1986 --execute="DROP TABLE IF EXISTS datos_desa.tb_pga_x2b\W;" >>$PATH_WARNINGS_PGA
mysql -u root --password=datos1986 --execute="CREATE TABLE datos_desa.tb_pga_x2b AS SELECT galgo_nombre, count(*) / (select experiencia_max FROM datos_desa.tb_pga_x2a) AS experiencia FROM datos_desa.tb_galgos_historico GROUP BY galgo_nombre\W;" >>$PATH_WARNINGS_PGA
mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_pga_x2b LIMIT 10\W;" >>$PATH_WARNINGS_PGA
mysql -u root --password=datos1986 --execute="SELECT count(*) as num_x2b FROM datos_desa.tb_pga_x2b LIMIT 10\W;" >>$PATH_WARNINGS_PGA

mysql -u root --password=datos1986 --execute="DROP TABLE IF EXISTS datos_desa.tb_pga_x2c\W;" >>$PATH_WARNINGS_PGA
mysql -u root --password=datos1986 --execute="CREATE TABLE datos_desa.tb_pga_x2c AS SELECT GH.galgo_nombre, B.experiencia FROM datos_desa.tb_galgos_historico GH LEFT JOIN datos_desa.tb_pga_x2b B ON (GH.galgo_nombre=B.galgo_nombre) \W;" >>$PATH_WARNINGS_PGA
mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_pga_x2c LIMIT 10\W;" >>$PATH_WARNINGS_PGA
mysql -u root --password=datos1986 --execute="SELECT count(*) as num_x2c FROM datos_desa.tb_pga_x2c LIMIT 10\W;" >>$PATH_WARNINGS_PGA
}

function calcularVariableX3 ()
{
##########################################################################################
echo -e "\n---- X3: [(carrera, galgo) -> Trap]" >&1
mysql -u root --password=datos1986 --execute="DROP TABLE IF EXISTS datos_desa.tb_pga_x3a\W;" >>$PATH_WARNINGS_PGA
mysql -u root --password=datos1986 --execute="CREATE TABLE datos_desa.tb_pga_x3a AS SELECT dentro.trap, SUM(dentro.contador) AS trap_suma FROM (select trap,posicion,count(*) as contador FROM datos_desa.tb_galgos_historico GROUP BY trap,posicion ORDER BY trap ASC, posicion ASC) dentro WHERE posicion IN (1,2) GROUP BY dentro.trap LIMIT 100\W;" >>$PATH_WARNINGS_PGA
mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_pga_x3a LIMIT 10\W;" >>$PATH_WARNINGS_PGA
mysql -u root --password=datos1986 --execute="SELECT count(*) as num_x3a FROM datos_desa.tb_pga_x3a LIMIT 10\W;" >>$PATH_WARNINGS_PGA

mysql -u root --password=datos1986 --execute="DROP TABLE IF EXISTS datos_desa.tb_pga_x3b\W;" >>$PATH_WARNINGS_PGA
mysql -u root --password=datos1986 --execute="CREATE TABLE datos_desa.tb_pga_x3b AS SELECT trap, trap_suma / (SELECT max(trap_suma) FROM datos_desa.tb_pga_x3a) AS trap_factor FROM datos_desa.tb_pga_x3a\W;" >>$PATH_WARNINGS_PGA
mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_pga_x3b LIMIT 10\W;" >>$PATH_WARNINGS_PGA
mysql -u root --password=datos1986 --execute="SELECT count(*) as num_x3b FROM datos_desa.tb_pga_x3b LIMIT 10\W;" >>$PATH_WARNINGS_PGA

}

function calcularVariableX4 ()
{
##########################################################################################
echo -e "\n---- X4: apuestas (starting price, odds)" >&1
mysql -u root --password=datos1986 --execute="DROP TABLE IF EXISTS datos_desa.tb_pga_x4\W;" >>$PATH_WARNINGS_PGA
mysql -u root --password=datos1986 --execute="CREATE TABLE datos_desa.tb_pga_x4 AS SELECT id_carrera, galgo_nombre, sp FROM datos_desa.tb_galgos_historico GH\W;" >>$PATH_WARNINGS_PGA
mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_pga_x4 LIMIT 10\W;" >>$PATH_WARNINGS_PGA
mysql -u root --password=datos1986 --execute="SELECT count(*) as num_x4 FROM datos_desa.tb_pga_x4 LIMIT 10\W;" >>$PATH_WARNINGS_PGA
}

function calcularVariableX5 ()
{
##########################################################################################
echo -e "\n---- X5: clase (grade)" >&1
mysql -u root --password=datos1986 --execute="DROP TABLE IF EXISTS datos_desa.tb_pga_x5\W;" >>$PATH_WARNINGS_PGA
mysql -u root --password=datos1986 --execute="CREATE TABLE datos_desa.tb_pga_x5 AS SELECT id_carrera, galgo_nombre, clase FROM datos_desa.tb_galgos_historico GH\W;" >>$PATH_WARNINGS_PGA
mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_pga_x5 LIMIT 10\W;" >>$PATH_WARNINGS_PGA
mysql -u root --password=datos1986 --execute="SELECT count(*) as num_x5 FROM datos_desa.tb_pga_x5 LIMIT 10\W;" >>$PATH_WARNINGS_PGA
}

function calcularVariableX6 ()
{
##########################################################################################
echo -e "\n---- X6: POSICION media por experiencia en una clase" >&1
mysql -u root --password=datos1986 --execute="DROP TABLE IF EXISTS datos_desa.tb_pga_x6a\W;" >>$PATH_WARNINGS_PGA
mysql -u root --password=datos1986 --execute="CREATE TABLE datos_desa.tb_pga_x6a AS SELECT galgo_nombre, clase, COUNT(posicion) AS experiencia_en_clase, AVG(posicion) AS posicion_media_en_clase FROM datos_desa.tb_galgos_historico GROUP BY galgo_nombre,clase\W;" >>$PATH_WARNINGS_PGA
mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_pga_x6a LIMIT 5\W;" >>$PATH_WARNINGS_PGA
mysql -u root --password=datos1986 --execute="SELECT count(*) as num_x6a FROM datos_desa.tb_pga_x6a LIMIT 10\W;" >>$PATH_WARNINGS_PGA

mysql -u root --password=datos1986 --execute="DROP TABLE IF EXISTS datos_desa.tb_pga_x6b\W;" >>$PATH_WARNINGS_PGA
mysql -u root --password=datos1986 --execute="CREATE TABLE datos_desa.tb_pga_x6b AS SELECT clase, CASE WHEN experiencia_en_clase>=13 THEN 'alta' WHEN (experiencia_en_clase>=5 AND experiencia_en_clase<13) THEN 'media' ELSE 'baja' END AS experiencia_cualitativo, AVG(posicion_media_en_clase) AS posicion_media_en_clase_por_experiencia FROM datos_desa.tb_pga_x6a GROUP BY clase, experiencia_cualitativo ORDER BY clase ASC, experiencia_cualitativo ASC\W;" >>$PATH_WARNINGS_PGA
mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_pga_x6b LIMIT 30\W;" >>$PATH_WARNINGS_PGA
mysql -u root --password=datos1986 --execute="SELECT count(*) as num_x6b FROM datos_desa.tb_pga_x6b LIMIT 10\W;" >>$PATH_WARNINGS_PGA

read -d '' CONSULTA_X6C <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_pga_x6c;

CREATE TABLE datos_desa.tb_pga_x6c AS 
SELECT galgo_nombre, clase, id_carrera, experiencia_en_clase, 
CASE WHEN experiencia_en_clase>=13 THEN 'alta' WHEN (experiencia_en_clase>=5 AND experiencia_en_clase<13) THEN 'media' ELSE 'baja' END AS experiencia_cualitativo
FROM(
  SELECT galgo_nombre, clase, id_carrera, count(*) AS experiencia_en_clase 
  FROM (
    SELECT galgo_nombre,clase, amd, amd2, id_carrera  
    FROM (
      SELECT GH.galgo_nombre, GH.id_carrera, GH.anio*10000+GH.mes*100+GH.dia AS amd, GH2.anio*10000+GH2.mes*100+GH2.dia AS amd2, GH.clase AS clase
      FROM datos_desa.tb_galgos_historico GH 
      LEFT JOIN datos_desa.tb_galgos_historico GH2 ON (GH.galgo_nombre=GH2.galgo_nombre AND GH.clase=GH2.clase)
    ) dentro
    WHERE dentro.amd >= dentro.amd2
  ) fuera
  GROUP BY galgo_nombre, clase, id_carrera
)fuera2
;

SELECT * FROM datos_desa.tb_pga_x6c LIMIT 30;
SELECT count(*) as num_x6c FROM datos_desa.tb_pga_x6c LIMIT 10;
EOF
#echo -e "$CONSULTA_X6C" 2>&1 >&1
mysql -u root --password=datos1986 --execute="$CONSULTA_X6C" >>$PATH_WARNINGS_PGA

read -d '' CONSULTA_X6D <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_pga_x6d;

CREATE TABLE datos_desa.tb_pga_x6d AS 
SELECT anio, mes, dia, cruce1.id_carrera, cruce1.galgo_nombre, cruce1.clase,  cruce1.experiencia_en_clase, cruce1.experiencia_cualitativo,
X6B.posicion_media_en_clase_por_experiencia
FROM(
  SELECT GH.anio, GH.mes, GH.dia, GH.id_carrera, GH.galgo_nombre, GH.clase,  
  X6C.experiencia_en_clase , X6C.experiencia_cualitativo
  FROM datos_desa.tb_galgos_historico GH 
  LEFT JOIN datos_desa.tb_pga_x6c X6C ON (GH.id_carrera=X6C.id_carrera AND GH.galgo_nombre=X6C.galgo_nombre)
) cruce1

LEFT JOIN datos_desa.tb_pga_x6b X6B ON (cruce1.clase=X6B.clase AND cruce1.experiencia_cualitativo=X6B.experiencia_cualitativo)
;

SELECT * FROM datos_desa.tb_pga_x6d LIMIT 30;
SELECT count(*) as num_x6d FROM datos_desa.tb_pga_x6d LIMIT 10;
EOF
#echo -e "$CONSULTA_X6D" 2>&1 >&1
mysql -u root --password=datos1986 --execute="$CONSULTA_X6D" >>$PATH_WARNINGS_PGA
}

function calcularVariableX7 ()
{
##########################################################################################
echo -e "\n---- X7: peso del galgo" >&1
mysql -u root --password=datos1986 --execute="DROP TABLE IF EXISTS datos_desa.tb_pga_x7a\W;" >>$PATH_WARNINGS_PGA
mysql -u root --password=datos1986 --execute="CREATE TABLE datos_desa.tb_pga_x7a AS select PO.id_carrera, PO.posicion, PO.peso_galgo, GH.distancia, (GH.distancia/100 - GH.distancia%100/100) AS distancia_centenas FROM datos_desa.tb_galgos_posiciones_en_carreras PO LEFT JOIN (select id_carrera, MAX(distancia) AS distancia FROM datos_desa.tb_galgos_historico GROUP BY id_carrera) GH ON PO.id_carrera=GH.id_carrera WHERE PO.posicion IN (1,2) ORDER BY PO.id_carrera ASC, PO.posicion ASC\W;" >>$PATH_WARNINGS_PGA
mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_pga_x7a LIMIT 10\W;" >>$PATH_WARNINGS_PGA
mysql -u root --password=datos1986 --execute="SELECT count(*) as num_x7a FROM datos_desa.tb_pga_x7a LIMIT 10\W;" >>$PATH_WARNINGS_PGA


mysql -u root --password=datos1986 --execute="DROP TABLE IF EXISTS datos_desa.tb_pga_x7b\W;" >>$PATH_WARNINGS_PGA
mysql -u root --password=datos1986 --execute="CREATE TABLE datos_desa.tb_pga_x7b AS SELECT distancia_centenas, AVG(peso_galgo) AS peso_medio, COUNT(*) FROM datos_desa.tb_pga_x7a GROUP BY distancia_centenas ORDER BY distancia_centenas ASC\W;" >>$PATH_WARNINGS_PGA
mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_pga_x7b LIMIT 10\W;" >>$PATH_WARNINGS_PGA
mysql -u root --password=datos1986 --execute="SELECT count(*) as num_x7b FROM datos_desa.tb_pga_x7b LIMIT 10\W;" >>$PATH_WARNINGS_PGA

read -d '' CONSULTA_X7C <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_pga_x7c;

CREATE TABLE datos_desa.tb_pga_x7c AS 
SELECT galgo_nombre, id_carrera, dentro.distancia_centenas, dentro.distancia, ABS(dentro.peso_galgo - X7B.peso_medio) AS dif_peso  
FROM
(
  select GH.galgo_nombre, GH.id_carrera, (GH.distancia/100 - GH.distancia%100/100) AS distancia_centenas, GH.distancia, PO.peso_galgo 
  FROM datos_desa.tb_galgos_historico GH
  LEFT JOIN (SELECT galgo_nombre, MAX(peso_galgo) AS peso_galgo FROM datos_desa.tb_galgos_posiciones_en_carreras GROUP BY galgo_nombre) PO
  ON (GH.galgo_nombre=PO.galgo_nombre)
) dentro
LEFT JOIN datos_desa.tb_pga_x7b X7B 
ON (dentro.distancia_centenas=X7B.distancia_centenas);

SELECT * FROM datos_desa.tb_pga_x7c LIMIT 10;
SELECT count(*) as num_x7c FROM datos_desa.tb_pga_x7c LIMIT 10;
EOF
#echo -e "$CONSULTA_X7C" 2>&1 >&1
mysql -u root --password=datos1986 --execute="$CONSULTA_X7C" >>$PATH_WARNINGS_PGA
}

function calcularVariableX8 ()
{
##########################################################################################
echo -e "\n---- X8: estadio con mucho going" >&1
read -d '' CONSULTA_X8A <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_pga_x8a;

CREATE TABLE datos_desa.tb_pga_x8a AS 
SELECT track, STD(going_abs) AS venue_going_std, AVG(going_abs) AS venue_going_avg 
FROM (select track, ABS(going_allowance_segundos) AS going_abs FROM datos_desa.tb_galgos_carreras) dentro 
GROUP BY dentro.track
;
SELECT * FROM datos_desa.tb_pga_x8a LIMIT 10;
SELECT count(*) as num_x8a FROM datos_desa.tb_pga_x8a LIMIT 10;
EOF
#echo -e "$CONSULTA_X8A" 2>&1 >&1
mysql -u root --password=datos1986 --execute="$CONSULTA_X8A" >>$PATH_WARNINGS_PGA
}

function calcularVariableX9 ()
{
##########################################################################################
echo -e "\n---- X9: Calidad del ENTRENADOR" >&1
mysql -u root --password=datos1986 --execute="DROP TABLE IF EXISTS datos_desa.tb_pga_x9a\W;" >>$PATH_WARNINGS_PGA
mysql -u root --password=datos1986 --execute="CREATE TABLE datos_desa.tb_pga_x9a AS SELECT entrenador, AVG(posicion) AS posicion_avg, STD(posicion) AS posicion_std FROM datos_desa.tb_galgos_historico GROUP BY entrenador\W;" >>$PATH_WARNINGS_PGA
mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_pga_x9a LIMIT 10\W;" >>$PATH_WARNINGS_PGA
mysql -u root --password=datos1986 --execute="SELECT count(*) as num_x9a FROM datos_desa.tb_pga_x9a LIMIT 10\W;" >>$PATH_WARNINGS_PGA

mysql -u root --password=datos1986 --execute="DROP TABLE IF EXISTS datos_desa.tb_pga_x9b\W;" >>$PATH_WARNINGS_PGA
mysql -u root --password=datos1986 --execute="CREATE TABLE datos_desa.tb_pga_x9b AS SELECT entrenador, (6-posicion_avg)/5 AS entrenador_posicion_norm FROM datos_desa.tb_pga_x9a\W;" >>$PATH_WARNINGS_PGA
mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_pga_x9b LIMIT 10\W;" >>$PATH_WARNINGS_PGA
mysql -u root --password=datos1986 --execute="SELECT count(*) as num_x9b FROM datos_desa.tb_pga_x9b LIMIT 10\W;" >>$PATH_WARNINGS_PGA
}

############################################
############################################

function calcularFinalX1 () 
{
read -d '' CONSULTA_FINAL <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_pga_final_01;


CREATE TABLE datos_desa.tb_pga_final_01 AS 
SELECT ACUM.galgo_nombre, ACUM.id_carrera, ACUM.trap, ACUM.venue, ACUM.entrenador, ACUM.posicion,
ACUM.distancia,
CASE WHEN ACUM.distancia<400 THEN 1 WHEN (ACUM.distancia>=400 AND ACUM.distancia<600) THEN 2 WHEN (ACUM.distancia>=600) THEN 3 ELSE NULL END AS distancia_tipo,
X1B.vgcortasm_norm, X1B.vgmediasm_norm, X1B.vglargasm_norm 
FROM datos_desa.tb_galgos_historico ACUM
LEFT JOIN datos_desa.tb_pga_x1b X1B ON (ACUM.galgo_nombre=X1B.galgo_nombre);


SELECT * FROM datos_desa.tb_pga_final_01 LIMIT 10;

SELECT count(*) as num_final_01 FROM datos_desa.tb_pga_final_01 LIMIT 10;
EOF
echo -e "$CONSULTA_FINAL" 2>&1 >&1
mysql -u root --password=datos1986 --execute="$CONSULTA_FINAL" >>$PATH_WARNINGS_PGA
}

################
function calcularFinalX2 () 
{
read -d '' CONSULTA_FINAL <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_pga_final_02;

CREATE TABLE datos_desa.tb_pga_final_02 AS 
SELECT ACUM.*, X2B.experiencia 
FROM datos_desa.tb_pga_final_01 ACUM
LEFT JOIN datos_desa.tb_pga_x2b X2B ON (ACUM.galgo_nombre=X2B.galgo_nombre);

SELECT * FROM datos_desa.tb_pga_final_02 LIMIT 10;

SELECT count(*) as num_final_02 FROM datos_desa.tb_pga_final_02 LIMIT 10;
EOF
echo -e "$CONSULTA_FINAL" 2>&1 >&1
mysql -u root --password=datos1986 --execute="$CONSULTA_FINAL" >>$PATH_WARNINGS_PGA
}

################
function calcularFinalX3 () 
{
read -d '' CONSULTA_FINAL <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_pga_final_03;

CREATE TABLE datos_desa.tb_pga_final_03 AS 
SELECT ACUM.*, X3B.trap_factor FROM datos_desa.tb_pga_final_02 ACUM
LEFT JOIN datos_desa.tb_pga_x3b X3B ON (ACUM.trap=X3B.trap);

SELECT * FROM datos_desa.tb_pga_final_03 LIMIT 10;

SELECT count(*) as num_final_03 FROM datos_desa.tb_pga_final_03 LIMIT 10;
EOF
echo -e "$CONSULTA_FINAL" 2>&1 >&1
mysql -u root --password=datos1986 --execute="$CONSULTA_FINAL" >>$PATH_WARNINGS_PGA
}

################
function calcularFinalX4 () 
{
read -d '' CONSULTA_FINAL <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_pga_final_04;

CREATE TABLE datos_desa.tb_pga_final_04 AS 
SELECT ACUM.*, 0 AS x4_temp FROM datos_desa.tb_pga_final_03 ACUM;

SELECT * FROM datos_desa.tb_pga_final_04 LIMIT 10;

SELECT count(*) as num_final_04 FROM datos_desa.tb_pga_final_04 LIMIT 10;
EOF
echo -e "$CONSULTA_FINAL" 2>&1 >&1
mysql -u root --password=datos1986 --execute="$CONSULTA_FINAL" >>$PATH_WARNINGS_PGA
}

################
function calcularFinalX5 () 
{
read -d '' CONSULTA_FINAL <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_pga_final_05;

CREATE TABLE datos_desa.tb_pga_final_05 AS 
SELECT ACUM.*, 0 AS x5_temp FROM datos_desa.tb_pga_final_04 ACUM;

SELECT * FROM datos_desa.tb_pga_final_05 LIMIT 10;

SELECT count(*) as num_final_05 FROM datos_desa.tb_pga_final_05 LIMIT 10;
EOF
echo -e "$CONSULTA_FINAL" 2>&1 >&1
mysql -u root --password=datos1986 --execute="$CONSULTA_FINAL" >>$PATH_WARNINGS_PGA
}

################
function calcularFinalX6 () 
{
read -d '' CONSULTA_FINAL <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_pga_final_06;

CREATE TABLE datos_desa.tb_pga_final_06 AS 
SELECT ACUM.*, X6D.experiencia_en_clase, X6D.experiencia_cualitativo, X6D.posicion_media_en_clase_por_experiencia FROM datos_desa.tb_pga_final_05 ACUM
LEFT JOIN datos_desa.tb_pga_x6d X6D ON (ACUM.id_carrera=X6D.id_carrera AND ACUM.galgo_nombre=X6D.galgo_nombre);

SELECT * FROM datos_desa.tb_pga_final_06 LIMIT 10;

SELECT count(*) as num_final_06 FROM datos_desa.tb_pga_final_06 LIMIT 10;
EOF
echo -e "$CONSULTA_FINAL" 2>&1 >&1
mysql -u root --password=datos1986 --execute="$CONSULTA_FINAL" >>$PATH_WARNINGS_PGA
}

################
function calcularFinalX7 () 
{
read -d '' CONSULTA_FINAL <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_pga_final_07;

CREATE TABLE datos_desa.tb_pga_final_07 AS 
SELECT ACUM.*, X7C.distancia_centenas, X7C.dif_peso/15 FROM datos_desa.tb_pga_final_06 ACUM
LEFT JOIN datos_desa.tb_pga_x7c X7C ON (ACUM.id_carrera=X7C.id_carrera AND ACUM.galgo_nombre=X7C.galgo_nombre);

SELECT * FROM datos_desa.tb_pga_final_07 LIMIT 10;

SELECT count(*) as num_final_07 FROM datos_desa.tb_pga_final_07 LIMIT 10;
EOF
echo -e "$CONSULTA_FINAL" 2>&1 >&1
mysql -u root --password=datos1986 --execute="$CONSULTA_FINAL" >>$PATH_WARNINGS_PGA
}

################
function calcularFinalX8 () 
{
read -d '' CONSULTA_FINAL <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_pga_final_08;

CREATE TABLE datos_desa.tb_pga_final_08 AS 
SELECT ACUM.*, X8A.venue_going_std, X8A.venue_going_avg FROM datos_desa.tb_pga_final_07 ACUM
LEFT JOIN datos_desa.tb_pga_x8a X8A ON (ACUM.venue=X8A.track);

SELECT * FROM datos_desa.tb_pga_final_08 LIMIT 10;

SELECT count(*) as num_final_08 FROM datos_desa.tb_pga_final_08 LIMIT 10;
EOF
echo -e "$CONSULTA_FINAL" 2>&1 >&1
mysql -u root --password=datos1986 --execute="$CONSULTA_FINAL" >>$PATH_WARNINGS_PGA
}

################
function calcularFinalX9 () 
{
read -d '' CONSULTA_FINAL <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_pga_final_09;

CREATE TABLE datos_desa.tb_pga_final_09 AS 
SELECT ACUM.*, X9B.entrenador_posicion_norm FROM datos_desa.tb_pga_final_08 ACUM
LEFT JOIN datos_desa.tb_pga_x9b X9B ON (ACUM.entrenador=X9B.entrenador);

SELECT * FROM datos_desa.tb_pga_final_09 LIMIT 10;

SELECT count(*) as num_final_09 FROM datos_desa.tb_pga_final_09 LIMIT 10;
EOF
echo -e "$CONSULTA_FINAL" 2>&1 >&1
mysql -u root --password=datos1986 --execute="$CONSULTA_FINAL" >>$PATH_WARNINGS_PGA
}


#####################################################################################

function predecirPasado ()
{
echo -e "\n---- PREDICCION: sobre el pasado (->Saco score) " >&1


read -d '' CONSULTA_PESOS <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_pga_prediccion_pre;

CREATE TABLE datos_desa.tb_pga_prediccion_pre AS 
SELECT 
galgo_nombre,
id_carrera,
trap,
venue,
entrenador,
vgcortasm_norm,
vgmediasm_norm,
vglargasm_norm,
experiencia,
trap_factor,
x4_temp, 
x5_temp,
experiencia_en_clase,
experiencia_cualitativo,
posicion_media_en_clase_por_experiencia,
(6-posicion_media_en_clase_por_experiencia)/5 AS posicion_media_en_clase_por_experiencia_norm,
distancia,
distancia_centenas,
CASE WHEN distancia<400 THEN 1 WHEN (distancia>=400 AND distancia<600) THEN 2 WHEN (distancia>=600) THEN 3 ELSE NULL END AS distancia_tipo,
dif_peso,
venue_going_std,
venue_going_avg,
entrenador_posicion_norm,

'PENDIENTE' as puntos_prediccion,
posicion AS posicion_real

FROM datos_desa.tb_pga_final_09 PGA_FINAL;

SELECT * FROM datos_desa.tb_pga_prediccion_pre LIMIT 10;

SELECT count(*) as num_filas_con_pesos FROM datos_desa.tb_pga_prediccion_pre LIMIT 10;
EOF
echo -e "$CONSULTA_PESOS" 2>&1 >&1
mysql -u root --password=datos1986 --execute="$CONSULTA_PESOS" >>$PATH_WARNINGS_PGA


###
echo -e "\n---- SCORE " >&1
# Ejecuta sobre el 100% de los datos (no habíamos usado train+test, sino medias/medianas, etc.)
# Objetivo: cuánto porcentaje acertamos si usamos este sistema sencillo (ajustando los pesos óptimos)
# Iterar con los PESOS para maximizar el score --> Mejor hacerlo en Python con una Regresión logística o lineal...


#Comparar prediccion (puntos) con la posicion real que sucedio. Meterlo en la tabla tb.

read -d '' CONSULTA_SCORE <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_pga_score_a_pre;

CREATE TABLE datos_desa.tb_pga_score_a_pre AS 
SELECT galgo_nombre, id_carrera, trap, venue, entrenador, 
posicion_real,
CASE WHEN posicion_real<=2 THEN 1 ELSE 0 END AS posicion_1o2_real,
CASE WHEN distancia_tipo=1 THEN (vgcortasm_norm) WHEN distancia_tipo=2 THEN (vgmediasm_norm) WHEN distancia_tipo=3 THEN (vglargasm_norm) ELSE NULL END AS x1,
experiencia AS x2,
trap_factor AS x3,
x4_temp AS x4,
x5_temp AS x5,
posicion_media_en_clase_por_experiencia_norm AS x6,
dif_peso AS x7,
venue_going_avg AS x8,
entrenador_posicion_norm AS x9
FROM datos_desa.tb_pga_prediccion_pre

WHERE posicion_real<=4
;

SELECT * FROM datos_desa.tb_pga_score_a_pre LIMIT 10;
SELECT count(*) FROM datos_desa.tb_pga_score_a_pre LIMIT 1;


DROP TABLE IF EXISTS datos_desa.tb_pga_score_b_pre;

CREATE TABLE datos_desa.tb_pga_score_b_pre AS 
SELECT 
MIN(x1) AS x1_min, MAX(x1) AS x1_max,
MIN(x2) AS x2_min, MAX(x2) AS x2_max,
MIN(x3) AS x3_min, MAX(x3) AS x3_max,
MIN(x4) AS x4_min, MAX(x4) AS x4_max,
MIN(x5) AS x5_min, MAX(x5) AS x5_max,
MIN(x6) AS x6_min, MAX(x6) AS x6_max,
MIN(x7) AS x7_min, MAX(x7) AS x7_max,
MIN(x8) AS x8_min, MAX(x8) AS x8_max,
MIN(x9) AS x9_min, MAX(x9) AS x9_max
FROM datos_desa.tb_pga_score_a_pre;

SELECT * FROM datos_desa.tb_pga_score_b_pre LIMIT 10;
SELECT count(*) FROM datos_desa.tb_pga_score_b_pre LIMIT 1;


DROP TABLE IF EXISTS datos_desa.tb_pga_score_FEATURES_pre;
CREATE TABLE datos_desa.tb_pga_score_FEATURES_pre AS SELECT x1, x2, x3, x4, x5, x6, x7/15, x8, x9 
FROM datos_desa.tb_pga_score_a_pre;
SELECT * FROM datos_desa.tb_pga_score_FEATURES_pre LIMIT 10;
SELECT count(*) FROM datos_desa.tb_pga_score_FEATURES_pre LIMIT 1;

DROP TABLE IF EXISTS datos_desa.tb_pga_score_TARGET_pre;
CREATE TABLE datos_desa.tb_pga_score_TARGET_pre AS SELECT posicion_1o2_real FROM datos_desa.tb_pga_score_a_pre;
SELECT * FROM datos_desa.tb_pga_score_TARGET_pre LIMIT 10;
SELECT count(*) FROM datos_desa.tb_pga_score_TARGET_pre LIMIT 1;

EOF
echo -e "$CONSULTA_SCORE" 2>&1 >&1
mysql -u root --password=datos1986 --execute="$CONSULTA_SCORE" >>$PATH_WARNINGS_PGA



##
echo -e "Modelo predictivo CLASIFICADOR..." 2>&1 >&1
INFORME_PGA="/home/carloslinux/Desktop/INFORMES/galgos_MOD004_pga.out"
echo -e "Informe del modelo predictivo: ${INFORME_PGA}" 2>&1 >&1
PATH_MODELO_GANADOR='/home/carloslinux/Desktop/GIT_REPO_PYTHON_POC_ML/python_poc_ml/galgos/galgos_pga_MEJOR_MODELO.pkl'
rm -f $PATH_MODELO_GANADOR
python3 '/home/carloslinux/Desktop/GIT_REPO_PYTHON_POC_ML/python_poc_ml/galgos/galgos_pga.py' > "${INFORME_PGA}"
cat "${INFORME_PGA}" | grep 'PGA-Gana modelo'  >&1


}


########## MAIN #########################
echo -e "Modulo 003PGA (Dada una carrera, Predictor simple por Pesos del Galgo Analizado)" >&1

PATH_WARNINGS_PGA="/home/carloslinux/Desktop/DATOS_LIMPIO/galgos/warnings_mod003pga.txt"

echo -e "Tablas de ENTRADA: HISTORICO (y otras auxiliares: agregados...)" >&1

echo -e "SALIDA: SCORE (calculado sobre 100% filas del historico), habiendo optimizado los pesos" >&1
echo -e "\nWARNINGS: $PATH_WARNINGS_PGA" >&1

rm -f "$PATH_WARNINGS_PGA"


echo -e "\n---- Variables de CADA galgo: X1, X2..." >&1
calcularVariableX1
calcularVariableX2
calcularVariableX3
calcularVariableX4
calcularVariableX5
calcularVariableX6
calcularVariableX7
calcularVariableX8
calcularVariableX9

echo -e "\n---- Tabla FINAL con las variables de CADA galgo: usando pesos --> f(x1,x2...)=w1*x1 + w2*x2 + w3*x3+..." >&1
calcularFinalX1
calcularFinalX2
calcularFinalX3
calcularFinalX4
calcularFinalX5
calcularFinalX6
calcularFinalX7
calcularFinalX8
calcularFinalX9


#PLAN B (si MySQL se atasca): MEDIANTE FICHERO DE SENTENCIAS SQL 
#mysql -u root --password=datos1986 --show-warnings datos_desa < "./galgos_MOD003PGA_queries.txt.tmp" > "./galgos_MOD003PGA_queries_output"


echo -e "\n---- Ejecutando el predictor para predecir el pasado y poder sacar el SCORE (porque conocemos el resultado real)..." >&1
predecirPasado

echo -e "Modulo 003PGA - FIN\n\n" >&1




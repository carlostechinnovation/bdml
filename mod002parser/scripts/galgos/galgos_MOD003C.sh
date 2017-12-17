#!/bin/bash

echo -e "Modulo 003C - PGA (Dada una carrera, Predictor simple por Pesos del Galgo Analizado)" >&1

echo -e "ENTRADAS: HISTORICO (y otras auxiliares: agregados...)" >&1
echo -e "SALIDA: SCORE (calculado sobre 100% filas del historico), habiendo optimizado los pesos" >&1


########### Variables de CADA galgo ########

#X1: [(carrera, galgo) -> velocidad_max_going]
mysql -u root --password=datos1986 --execute="DROP TABLE datos_desa.tb_pga_x1a\W;" >&1
mysql -u root --password=datos1986 --execute="CREATE TABLE datos_desa.tb_pga_x1a AS SELECT 1 AS distancia_tipo, MIN(vel_going_cortas_max) AS valor_min, MAX(vel_going_cortas_max) AS valor_max FROM datos_desa.tb_galgos_agregados UNION SELECT 2 AS distancia_tipo, MIN(vel_going_longmedias_max) AS valor_min, MAX(vel_going_longmedias_max) AS valor_max FROM datos_desa.tb_galgos_agregados UNION SELECT 3 AS distancia_tipo, MIN(vel_going_largas_max) AS valor_min, MAX(vel_going_largas_max) AS valor_max FROM datos_desa.tb_galgos_agregados\W;" >&1
mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_pga_x1a LIMIT 10\W;" >&1
mysql -u root --password=datos1986 --execute="SELECT count(*) as num_x1a FROM datos_desa.tb_pga_x1a LIMIT 10\W;" >&1

read -d '' CONSULTA_X1 <<- EOF
DROP TABLE datos_desa.tb_pga_x1b;

CREATE TABLE datos_desa.tb_pga_x1b AS SELECT galgo_nombre, 

(vel_going_cortas_max - (select valor_min FROM datos_desa.tb_pga_x1a WHERE distancia_tipo=1) ) / (select valor_max FROM datos_desa.tb_pga_x1a WHERE distancia_tipo=1) AS vgcortasm_norm, 

(vel_going_longmedias_max - (select valor_min FROM datos_desa.tb_pga_x1a WHERE distancia_tipo=2) ) / (select valor_max FROM datos_desa.tb_pga_x1a WHERE distancia_tipo=2) AS vgmediasm_norm, 

(vel_going_largas_max - (select valor_min FROM datos_desa.tb_pga_x1a WHERE distancia_tipo=3) ) / (select valor_max FROM datos_desa.tb_pga_x1a WHERE distancia_tipo=3) AS vglargasm_norm 

FROM datos_desa.tb_galgos_agregados;

SELECT * FROM datos_desa.tb_pga_x1b LIMIT 10;

SELECT count(*) as num_x1b FROM datos_desa.tb_pga_x1b LIMIT 10;
EOF

echo -e "$CONSULTA_X1" 2>&1 >&1
mysql -u root --password=datos1986 --execute="$CONSULTA_X1" >&1


#X2: [Galgo ->experiencia]
mysql -u root --password=datos1986 --execute="DROP TABLE datos_desa.tb_pga_x2a\W;" >&1
mysql -u root --password=datos1986 --execute="CREATE TABLE datos_desa.tb_pga_x2a AS SELECT MIN(contador) AS experiencia_min, MAX(contador) AS experiencia_max FROM (SELECT galgo_nombre, count(*) as contador FROM datos_desa.tb_galgos_historico GROUP BY galgo_nombre) dentro \W;" >&1
mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_pga_x2a LIMIT 10\W;" >&1
mysql -u root --password=datos1986 --execute="SELECT count(*) as num_x2a FROM datos_desa.tb_pga_x2a LIMIT 10\W;" >&1

mysql -u root --password=datos1986 --execute="DROP TABLE datos_desa.tb_pga_x2b\W;" >&1
mysql -u root --password=datos1986 --execute="CREATE TABLE datos_desa.tb_pga_x2b AS SELECT galgo_nombre, count(*) / (select experiencia_max FROM datos_desa.tb_pga_x2a) as experiencia FROM datos_desa.tb_galgos_historico GROUP BY galgo_nombre\W;" >&1
mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_pga_x2b LIMIT 10\W;" >&1
mysql -u root --password=datos1986 --execute="SELECT count(*) as num_x2b FROM datos_desa.tb_pga_x2b LIMIT 10\W;" >&1


#X3: [(carrera, galgo) -> Trap]
mysql -u root --password=datos1986 --execute="DROP TABLE datos_desa.tb_pga_x3a\W;" >&1
mysql -u root --password=datos1986 --execute="CREATE TABLE datos_desa.tb_pga_x3a AS SELECT dentro.trap, SUM(dentro.contador) AS trap_suma FROM (select trap,posicion,count(*) as contador FROM datos_desa.tb_galgos_historico GROUP BY trap,posicion ORDER BY trap ASC, posicion ASC) dentro WHERE posicion IN (1,2) GROUP BY dentro.trap LIMIT 100\W;" >&1
mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_pga_x3a LIMIT 10\W;" >&1
mysql -u root --password=datos1986 --execute="SELECT count(*) as num_x3a FROM datos_desa.tb_pga_x3a LIMIT 10\W;" >&1

mysql -u root --password=datos1986 --execute="DROP TABLE datos_desa.tb_pga_x3b\W;" >&1
mysql -u root --password=datos1986 --execute="CREATE TABLE datos_desa.tb_pga_x3b AS SELECT trap, trap_suma / (SELECT max(trap_suma) FROM datos_desa.tb_pga_x3a) AS trap_factor FROM datos_desa.tb_pga_x3a\W;" >&1
mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_pga_x3b LIMIT 10\W;" >&1
mysql -u root --password=datos1986 --execute="SELECT count(*) as num_x3b FROM datos_desa.tb_pga_x3b LIMIT 10\W;" >&1

mysql -u root --password=datos1986 --execute="DROP TABLE datos_desa.tb_pga_x3c\W;" >&1
mysql -u root --password=datos1986 --execute="CREATE TABLE datos_desa.tb_pga_x3c AS SELECT id_carrera, galgo_nombre, GH.trap, trap_factor FROM datos_desa.tb_galgos_historico GH LEFT JOIN datos_desa.tb_pga_x3b B ON GH.trap=B.trap\W;" >&1
mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_pga_x3c ORDER BY id_carrera ASC, trap ASC LIMIT 10\W;" >&1
mysql -u root --password=datos1986 --execute="SELECT count(*) as num_x3c FROM datos_desa.tb_pga_x3c LIMIT 10\W;" >&1


#X4: apuestas (starting price, odds)
mysql -u root --password=datos1986 --execute="DROP TABLE datos_desa.tb_pga_x4\W;" >&1
mysql -u root --password=datos1986 --execute="CREATE TABLE datos_desa.tb_pga_x4 AS SELECT id_carrera, galgo_nombre, sp FROM datos_desa.tb_galgos_historico GH\W;" >&1
mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_pga_x4 LIMIT 10\W;" >&1
mysql -u root --password=datos1986 --execute="SELECT count(*) as num_x4 FROM datos_desa.tb_pga_x4 LIMIT 10\W;" >&1


#X5: clase (grade)
mysql -u root --password=datos1986 --execute="DROP TABLE datos_desa.tb_pga_x5\W;" >&1
mysql -u root --password=datos1986 --execute="CREATE TABLE datos_desa.tb_pga_x5 AS SELECT id_carrera, galgo_nombre, clase FROM datos_desa.tb_galgos_historico GH\W;" >&1
mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_pga_x5 LIMIT 10\W;" >&1
mysql -u root --password=datos1986 --execute="SELECT count(*) as num_x5 FROM datos_desa.tb_pga_x5 LIMIT 10\W;" >&1


#X6: POSICION media por experiencia en una clase
mysql -u root --password=datos1986 --execute="DROP TABLE datos_desa.tb_pga_x6a\W;" >&1
mysql -u root --password=datos1986 --execute="CREATE TABLE datos_desa.tb_pga_x6a AS SELECT galgo_nombre, clase, COUNT(posicion) AS experiencia_en_clase, AVG(posicion) AS posicion_media_en_clase FROM datos_desa.tb_galgos_historico GROUP BY galgo_nombre,clase\W;" >&1
mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_pga_x6a LIMIT 5\W;" >&1
mysql -u root --password=datos1986 --execute="SELECT count(*) as num_x6a FROM datos_desa.tb_pga_x6a LIMIT 10\W;" >&1

mysql -u root --password=datos1986 --execute="DROP TABLE datos_desa.tb_pga_x6b\W;" >&1
mysql -u root --password=datos1986 --execute="CREATE TABLE datos_desa.tb_pga_x6b AS SELECT clase, CASE WHEN experiencia_en_clase>=13 THEN 'alta' WHEN (experiencia_en_clase>=5 AND experiencia_en_clase<13) THEN 'media' ELSE 'baja' END AS experiencia_cualitativo, AVG(posicion_media_en_clase) AS posicion_media_en_clase_por_experiencia FROM datos_desa.tb_pga_x6a GROUP BY clase, experiencia_cualitativo ORDER BY clase ASC, experiencia_cualitativo ASC\W;" >&1
mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_pga_x6b LIMIT 30\W;" >&1
mysql -u root --password=datos1986 --execute="SELECT count(*) as num_x6b FROM datos_desa.tb_pga_x6b LIMIT 10\W;" >&1

read -d '' CONSULTA_X6C <<- EOF
DROP TABLE datos_desa.tb_pga_x6c;

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
echo -e "$CONSULTA_X6C" 2>&1 >&1

read -d '' CONSULTA_X6D <<- EOF
DROP TABLE datos_desa.tb_pga_x6d;

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
echo -e "$CONSULTA_X6D" 2>&1 >&1



#X7: peso del galgo
mysql -u root --password=datos1986 --execute="DROP TABLE datos_desa.tb_pga_x7a\W;" >&1
mysql -u root --password=datos1986 --execute="CREATE TABLE datos_desa.tb_pga_x7a AS select PO.id_carrera, PO.posicion, PO.peso_galgo, GH.distancia, (GH.distancia/100 - GH.distancia%100/100) AS distancia_centenas FROM datos_desa.tb_galgos_posiciones_en_carreras PO LEFT JOIN (select id_carrera, MAX(distancia) AS distancia FROM datos_desa.tb_galgos_historico GROUP BY id_carrera) GH ON PO.id_carrera=GH.id_carrera WHERE PO.posicion IN (1,2) ORDER BY PO.id_carrera ASC, PO.posicion ASC\W;" >&1
mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_pga_x7a LIMIT 10\W;" >&1
mysql -u root --password=datos1986 --execute="SELECT count(*) as num_x7a FROM datos_desa.tb_pga_x7a LIMIT 10\W;" >&1


mysql -u root --password=datos1986 --execute="DROP TABLE datos_desa.tb_pga_x7b\W;" >&1
mysql -u root --password=datos1986 --execute="CREATE TABLE datos_desa.tb_pga_x7b AS SELECT distancia_centenas, AVG(peso_galgo) AS peso_medio, COUNT(*) FROM datos_desa.tb_pga_x7a GROUP BY distancia_centenas ORDER BY distancia_centenas ASC;\W;" >&1
mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_pga_x7b LIMIT 10\W;" >&1
mysql -u root --password=datos1986 --execute="SELECT count(*) as num_x7b FROM datos_desa.tb_pga_x7b LIMIT 10\W;" >&1

read -d '' CONSULTA_X7C <<- EOF
DROP TABLE datos_desa.tb_pga_x7c;

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
echo -e "$CONSULTA_X7C" 2>&1 >&1


#X8: estadio con mucho going
read -d '' CONSULTA_X8A <<- EOF
DROP TABLE datos_desa.tb_pga_x8a;

CREATE TABLE datos_desa.tb_pga_x8a AS 
SELECT id_carrera, venue, going_std, going_avg
FROM datos_desa.tb_galgos_historico GH 
LEFT JOIN ( 
  SELECT track, STD(going_abs) AS going_std, AVG(going_abs) AS going_avg 
  FROM (select track, ABS(going_allowance_segundos) AS going_abs FROM datos_desa.tb_galgos_carreras) dentro 
  GROUP BY dentro.track
) fuera
ON GH.venue=fuera.track;

SELECT * FROM datos_desa.tb_pga_x8a LIMIT 10;
SELECT count(*) as num_x8a FROM datos_desa.tb_pga_x8a LIMIT 10;
EOF
echo -e "$CONSULTA_X8A" 2>&1 >&1



#####################################################################################
######### PREDICCION: sobre el pasado (->Saco score) 
#####################################################################################


############## PESOS ########
w1=1.0;
w2=1.0;
w3=1.0;
w4=0.0;
w5=0.0;
w6=1.0;
w7=1.0;

echo -e "PESOS: ${w1}|${w2}|${w3}|${w4}|${w5}|${w6}|${w7}" >&1

###############################################################
#Tabla FINAL con las variables de CADA galgo: usando pesos --> f(x1,x2...)=w1*x1 + w2*x2 + w3*x3+...
###############################################################3

#mysql -u root --password=datos1986 --execute="\W;" >&1
#mysql -u root --password=datos1986 --execute="CREATE TABLE datos_desa.tb_pga_final AS SELECT DISTINCT galgo_nombre from tb_galgos_posiciones_en_carreras\W;" >&1
#mysql -u root --password=datos1986 --execute="\W;" >&1



########## SCORE sobre el 100% de los datos (no habíamos usado train+test, sino medias/medianas, etc.) ######
######## Objetivo: cuánto porcentaje acertamos si usamos este sistema (ajustando los pesos óptimos)
#Iterar con los pesos para maximizar el score --> Mejor hacerlo en Python con una Regresión logística o lineal...




echo -e "Modulo 003C - FIN\n\n" >&1



#!/bin/bash

#filtro_galgos=""
#filtro_galgos="WHERE PO1.galgo_nombre IN (${filtro_galgos_nombres})"
filtro_galgos="${1}"


#sufijo="_pre"
#sufijo="_post"
sufijo="${2}"

PATH_LOG="/home/carloslinux/Desktop/LOGS/galgos_generador_datasets${sufijo}.log"
echo -e "Log del generador de datasets: "$PATH_LOG

rm -f $PATH_LOG

echo -e "Generador de datasets: INICIO" 2>&1 1>>$PATH_LOG
################################################
########### Datasets del galgos_i001 ###########
################################################


#################### TABLA con los IDs de: carrera, galgo analizado, galgo competidor, target
read -d '' CONSULTA1 <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_galgos_001${sufijo};

CREATE TABLE datos_desa.tb_galgos_001${sufijo} AS

SELECT
PO1.id_carrera,
PO1.galgo_nombre AS galgo_analizado,
PO1.posicion AS posicion_analizado,
PO2.galgo_nombre AS galgo_competidor,
PO2.posicion AS posicion_competidor,
PO2.edad_en_dias AS competidor_edad,
PO2.peso_galgo AS competidor_peso

FROM datos_desa.tb_galgos_posiciones_en_carreras PO1

LEFT JOIN datos_desa.tb_galgos_posiciones_en_carreras PO2
ON (PO1.id_Carrera=PO2.id_carrera AND PO1.galgo_nombre <> PO2.galgo_nombre)

${filtro_galgos}

ORDER BY PO1.id_carrera DESC, PO1.posicion ASC, PO2.posicion
;

SELECT * FROM datos_desa.tb_galgos_001${sufijo} LIMIT 10;
EOF

echo -e "$CONSULTA1" 2>&1 1>>$PATH_LOG
mysql -u root --password=datos1986 --execute="$CONSULTA1" 2>&1 1>>$PATH_LOG
echo -e "\n----------------------------------------------------\n" 2>&1 1>>$PATH_LOG

#################### 
read -d '' CONSULTA2 <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_galgos_002${sufijo};

CREATE TABLE datos_desa.tb_galgos_002${sufijo} AS

SELECT 

fuera.id_carrera,
galgo_competidor,
MAX(vel_real_cortas_mediana) AS vel_real_cortas_mediana,
MAX(vel_real_cortas_max) AS vel_real_cortas_max,
MAX(vel_going_cortas_mediana) AS vel_going_cortas_mediana,
MAX(vel_going_cortas_max) AS vel_going_cortas_max,
MAX(vel_real_longmedias_mediana) AS vel_real_longmedias_mediana,
MAX(vel_real_longmedias_max) AS vel_real_longmedias_max,
MAX(vel_going_longmedias_mediana) AS vel_going_longmedias_mediana,
MAX(vel_going_longmedias_max) AS vel_going_longmedias_max,
MAX(vel_real_largas_mediana) AS vel_real_largas_mediana,
MAX(vel_real_largas_max) AS vel_real_largas_max,
MAX(vel_going_largas_mediana) AS vel_going_largas_mediana,
MAX(vel_going_largas_max) AS vel_going_largas_max,
MAX(competidor_edad) AS competidor_edad,
MAX(competidor_peso) AS competidor_peso,

CA.distancia

FROM (

  SELECT
  A1.id_carrera,
  CASE WHEN (A1.posicion_analizado IN (1,2) AND A1.posicion_competidor=3) THEN true WHEN (A1.posicion_analizado>=3 AND A1.posicion_competidor=2) THEN true ELSE false END AS competidor_es_segundo_segun_posicion,
  A1.galgo_analizado,  A1.posicion_analizado,
  A1.galgo_competidor,  A1.posicion_competidor,  A1.competidor_edad, A1.competidor_peso,
  GA2.*

  FROM datos_desa.tb_galgos_001${sufijo} A1

  LEFT JOIN datos_desa.tb_galgos_agregados GA2
  ON A1.galgo_competidor=GA2.galgo_nombre

  ORDER BY id_carrera, galgo_competidor DESC

) fuera

LEFT JOIN datos_desa.tb_galgos_carreras CA
ON fuera.id_carrera=CA.id_carrera

GROUP BY id_carrera, galgo_competidor
;


SELECT * FROM datos_desa.tb_galgos_002${sufijo} LIMIT 10;
EOF

echo -e "$CONSULTA2" 2>&1 1>>$PATH_LOG
mysql -u root --password=datos1986 --execute="$CONSULTA2" 2>&1 1>>$PATH_LOG
echo -e "\n----------------------------------------------------\n" 2>&1 1>>$PATH_LOG

#################### En cada carrera, ordeno los galgos segun su PUNTOS-PGA (SEGUN DISTANCIA DE ESA CARRERA), extrayendo los que deberían quedar segundos.
read -d '' CONSULTA3 <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_galgos_002_ordenadoporcriteriocompuesto${sufijo};


CREATE TABLE datos_desa.tb_galgos_002_ordenadoporcriteriocompuesto${sufijo} AS 
SELECT 
*,

CASE
  WHEN (distancia <400) THEN 1
  WHEN (distancia >= 400 AND distancia <600) THEN 2
  WHEN (distancia >600) THEN 3
  ELSE NULL
END AS distancia_tipo,

CASE
  WHEN (distancia <400) THEN vel_going_cortas_max
  WHEN (distancia >= 400 AND distancia <600) THEN vel_going_longmedias_max
  WHEN (distancia >600) THEN vel_going_largas_max
  ELSE NULL
END AS vel_going_comparar_max

FROM datos_desa.tb_galgos_002${sufijo} OPVMD
ORDER BY OPVMD.id_carrera, vel_going_comparar_max DESC
;


SELECT * FROM datos_desa.tb_galgos_002_ordenadoporcriteriocompuesto${sufijo} LIMIT 10;
EOF

echo -e "$CONSULTA3" 2>&1 1>>$PATH_LOG
mysql -u root --password=datos1986 --execute="$CONSULTA3" 2>&1 1>>$PATH_LOG
echo -e "\n----------------------------------------------------\n" 2>&1 1>>$PATH_LOG


####################
read -d '' CONSULTA4 <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_galgos_003${sufijo};

CREATE TABLE datos_desa.tb_galgos_003${sufijo} AS 
SELECT
P1.*,
( CASE id_carrera 
  WHEN @curCarreraId 
  THEN @curRow := @curRow + 1 
  ELSE @curRow := 1 AND @curCarreraId := id_carrera 
  END
)  AS rank
FROM datos_desa.tb_galgos_002_ordenadoporcriteriocompuesto${sufijo} P1, 
(SELECT @curRow := 0, @curCarreraId := '') r
ORDER BY  id_carrera ASC, vel_going_comparar_max DESC
;

SELECT * FROM datos_desa.tb_galgos_003${sufijo} LIMIT 10;

EOF

echo -e "$CONSULTA4" 2>&1 1>>$PATH_LOG
mysql -u root --password=datos1986 --execute="$CONSULTA4" 2>&1 1>>$PATH_LOG
echo -e "\n----------------------------------------------------\n" 2>&1 1>>$PATH_LOG


#################### TABLA que anhade info a cada galgo (analizado y competidor) (todavia en 5 filas). Selecciona los datos agregados del GALGO CON EL QUE REALMENTE COMPITE (segundo o tercero, en velocidad historica PARA LA DISTANCIA DE ESA CARRERA)
read -d '' CONSULTA5<<- EOF

DROP TABLE IF EXISTS datos_desa.tb_galgos_004${sufijo};

CREATE TABLE datos_desa.tb_galgos_004${sufijo} AS

SELECT * FROM (

SELECT 
cruce2.*, 
P2.rank as segundo_segun_vel_going_comparar_max
FROM (

 SELECT *
 FROM (

  SELECT
  A1.id_carrera,
  CASE WHEN (A1.posicion_analizado IN (1,2) AND A1.posicion_competidor=3) THEN true WHEN (A1.posicion_analizado>=3 AND A1.posicion_competidor=2) THEN true ELSE false END AS competidor_es_segundo_segun_posicion,
  
  A1.galgo_analizado,
  A1.posicion_analizado,
  GA1.vel_real_cortas_mediana AS analizado_vel_real_cortas_mediana,
  GA1.vel_real_cortas_max AS analizado_vel_real_cortas_max,
  GA1.vel_going_cortas_mediana AS analizado_vel_going_cortas_mediana,
  GA1.vel_going_cortas_max AS analizado_vel_going_cortas_max,
  GA1.vel_real_longmedias_mediana AS analizado_vel_real_longmedias_mediana,
  GA1.vel_real_longmedias_max AS analizado_vel_real_longmedias_max,
  GA1.vel_going_longmedias_mediana AS analizado_vel_going_longmedias_mediana,
  GA1.vel_going_longmedias_max AS analizado_vel_going_longmedias_max,
  GA1.vel_real_largas_mediana AS analizado_vel_real_largas_mediana,
  GA1.vel_real_largas_max AS analizado_vel_real_largas_max,
  GA1.vel_going_largas_mediana AS analizado_vel_going_largas_mediana,
  GA1.vel_going_largas_max AS analizado_vel_going_largas_max,

  A1.galgo_competidor,
  A1.posicion_competidor,
  A1.competidor_edad,
  A1.competidor_peso,
  GA2.vel_real_cortas_mediana AS competidor_vel_real_cortas_mediana,
  GA2.vel_real_cortas_max AS competidor_vel_real_cortas_max,
  GA2.vel_going_cortas_mediana AS competidor_vel_going_cortas_mediana,
  GA2.vel_going_cortas_max AS competidor_vel_going_cortas_max,
  GA2.vel_real_longmedias_mediana AS competidor_vel_real_longmedias_mediana,
  GA2.vel_real_longmedias_max AS competidor_vel_real_longmedias_max,
  GA2.vel_going_longmedias_mediana AS competidor_vel_going_longmedias_mediana,
  GA2.vel_going_longmedias_max AS competidor_vel_going_longmedias_max,
  GA2.vel_real_largas_mediana AS competidor_vel_real_largas_mediana,
  GA2.vel_real_largas_max AS competidor_vel_real_largas_max,
  GA2.vel_going_largas_mediana AS competidor_vel_going_largas_mediana,
  GA2.vel_going_largas_max AS competidor_vel_going_largas_max

  FROM datos_desa.tb_galgos_001${sufijo} A1

  LEFT JOIN datos_desa.tb_galgos_agregados GA1
  ON A1.galgo_analizado=GA1.galgo_nombre

  LEFT JOIN datos_desa.tb_galgos_agregados GA2
  ON A1.galgo_competidor=GA2.galgo_nombre

  WHERE A1.posicion_analizado<=4


 ) cruce1
 ORDER BY id_carrera, posicion_analizado

)cruce2

LEFT JOIN datos_desa.tb_galgos_003${sufijo} P2
ON (cruce2.id_carrera=P2.id_carrera AND cruce2.galgo_competidor=P2.galgo_competidor)

ORDER BY cruce2.id_carrera ASC, cruce2.posicion_analizado ASC

) cruce3

WHERE cruce3.segundo_segun_vel_going_comparar_max=true

;

SELECT * FROM datos_desa.tb_galgos_004${sufijo} LIMIT 10;

EOF

echo -e "$CONSULTA5" 2>&1 1>>$PATH_LOG
mysql -u root --password=datos1986 --execute="$CONSULTA5" 2>&1 1>>$PATH_LOG
echo -e "\n----------------------------------------------------\n" 2>&1 1>>$PATH_LOG


#################### Tabla que anhade los datos de la CARRERA y el TARGET (filtro por mes de frio o calor) ###########
read -d '' CONSULTA6 <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_galgos_005${sufijo};

CREATE TABLE datos_desa.tb_galgos_005${sufijo} AS

SELECT
A3.*,

CA.track,
CA.clase,
anio,
mes,
dia,
hora,
minuto,

CA.distancia,

CASE
  WHEN (distancia <400) THEN 1
  WHEN (distancia >= 400 AND distancia <600) THEN 2
  WHEN (distancia >600) THEN 3
  ELSE NULL
END AS cod_d,

CA.num_galgos,
CA.premio_primero,
CA.premio_segundo,
CA.premio_otros,
CA.premio_total_carrera,

(0.5+CA.going_allowance_segundos/2.8) AS going_allowance_segundos,
CASE WHEN (CA.going_allowance_segundos <= -0.40) THEN 1 ELSE 0 END AS going_muy_en_contra,
CASE WHEN (CA.going_allowance_segundos >= 0.40) THEN 1 ELSE 0 END AS going_muy_a_favor,

CA.fc_1,
CA.fc_2,
CA.fc_pounds,
CA.tc_1,
CA.tc_2,
CA.tc_3,
CA.tc_pounds,

PO.edad_en_dias AS analizado_edad,
PO.peso_galgo AS analizado_peso,
PO.sp AS analizado_sp,
PO.trap AS analizado_trap,

CASE 
  WHEN PO.posicion IN (1,2) THEN 1
  WHEN PO.posicion >=3 THEN 0
  ELSE NULL
END as target

FROM datos_desa.tb_galgos_004${sufijo} A3

LEFT JOIN datos_desa.tb_galgos_carreras CA
ON A3.id_carrera=CA.id_carrera

LEFT JOIN datos_desa.tb_galgos_posiciones_en_carreras PO
ON (A3.id_carrera=PO.id_carrera AND A3.galgo_analizado=PO.galgo_nombre)

ORDER BY anio DESC,mes DESC,dia DESC, A3.id_carrera, A3.posicion_analizado
;

SELECT * FROM datos_desa.tb_galgos_005${sufijo} LIMIT 10;
EOF

echo -e "$CONSULTA6" 2>&1 1>>$PATH_LOG
mysql -u root --password=datos1986 --execute="$CONSULTA6" 2>&1 1>>$PATH_LOG
echo -e "\n----------------------------------------------------\n" 2>&1 1>>$PATH_LOG


#################### DATASET Final (para quitar o poner campos) ##########
read -d '' CONSULTA7 <<- EOF

DROP TABLE IF EXISTS datos_desa.tb_galgos_data${sufijo};


CREATE TABLE datos_desa.tb_galgos_data${sufijo} AS 
SELECT

(-9/15 +hora/15) AS hora,

CASE WHEN (mes <=7) THEN (-1/6 + mes/6) WHEN (mes >7) THEN (5/12 - 5*mes/144) ELSE 0.5 END AS mes,

num_galgos/12 AS num_galgos,
(analizado_trap/num_galgos) AS analizado_trap_normalizado,
(20 + competidor_peso - analizado_peso)/40 AS diferencia_pesos,
((5*365) + competidor_edad - analizado_edad)/(10*365) AS diferencia_edades,
going_muy_en_contra,
going_muy_a_favor,

CASE WHEN cod_d=1 THEN (analizado_vel_real_cortas_mediana-13)/18 WHEN cod_d=2 THEN (analizado_vel_real_longmedias_mediana-13)/18 WHEN cod_d=3 THEN (analizado_vel_real_largas_mediana-13)/18 ELSE NULL END AS analizado_vel_real_mediana,
CASE WHEN cod_d=1 THEN (analizado_vel_real_cortas_max-13)/18 WHEN cod_d=2 THEN (analizado_vel_real_longmedias_max-13)/18 WHEN cod_d=3 THEN (analizado_vel_real_largas_max-13)/18 ELSE NULL END AS analizado_vel_real_max,
CASE WHEN cod_d=1 THEN (analizado_vel_going_cortas_mediana-13)/18 WHEN cod_d=2 THEN (analizado_vel_going_longmedias_mediana-13)/18 WHEN cod_d=3 THEN (analizado_vel_going_largas_mediana-13)/18 ELSE NULL END AS analizado_vel_going_mediana,
CASE WHEN cod_d=1 THEN (analizado_vel_going_cortas_max-13)/18 WHEN cod_d=2 THEN (analizado_vel_going_longmedias_max-13)/18 WHEN cod_d=3 THEN (analizado_vel_going_largas_max-13)/18 ELSE NULL END AS analizado_vel_going_max,

CASE WHEN cod_d=1 THEN (competidor_vel_real_cortas_mediana-13)/18 WHEN cod_d=2 THEN (competidor_vel_real_longmedias_mediana-13)/18 WHEN cod_d=3 THEN (competidor_vel_real_largas_mediana-13)/18 ELSE NULL END AS competidor_vel_real_mediana,
CASE WHEN cod_d=1 THEN (competidor_vel_real_cortas_max-13)/18 WHEN cod_d=2 THEN (competidor_vel_real_longmedias_max-13)/18 WHEN cod_d=3 THEN (competidor_vel_real_largas_max-13)/18 ELSE NULL END AS competidor_vel_real_max,
CASE WHEN cod_d=1 THEN (competidor_vel_going_cortas_mediana-13)/18 WHEN cod_d=2 THEN (competidor_vel_going_longmedias_mediana-13)/18 WHEN cod_d=3 THEN (competidor_vel_going_largas_mediana-13)/18 ELSE NULL END AS competidor_vel_going_mediana,
CASE WHEN cod_d=1 THEN (competidor_vel_going_cortas_max-13)/18 WHEN cod_d=2 THEN (competidor_vel_going_longmedias_max-13)/18 WHEN cod_d=3 THEN (competidor_vel_going_largas_max-13)/18 ELSE NULL END AS competidor_vel_going_max

FROM datos_desa.tb_galgos_005${sufijo};

SELECT * FROM datos_desa.tb_galgos_data${sufijo} LIMIT 10;
SELECT COUNT(*) as num_filas FROM datos_desa.tb_galgos_data${sufijo} LIMIT 1;
EOF


echo -e "$CONSULTA7" 2>&1 1>>$PATH_LOG
mysql -u root --password=datos1986 --execute="$CONSULTA7" 2>&1 1>>$PATH_LOG
echo -e "\n----------------------------------------------------\n" 2>&1 1>>$PATH_LOG


echo -e "Generador de datasets: FIN\n\n" 2>&1 1>>$PATH_LOG



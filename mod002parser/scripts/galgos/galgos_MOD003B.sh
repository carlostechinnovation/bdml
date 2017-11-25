#!/bin/bash

echo -e "Modulo 003B - Generador de datasets"


################################################
########### Datasets del galgos_i001 ###########
################################################

#################### TABLA con los IDs de: carrera, galgo analizado, galgo competidor, target
mysql -u root --password=datos1986 --execute="DROP TABLE IF EXISTS datos_desa.tb_galgos_i001_aux1;"

read -d '' CONSULTA1 <<- EOF
CREATE TABLE datos_desa.tb_galgos_i001_aux1 AS

SELECT
PO1.id_carrera,
PO1.galgo_nombre AS galgo_analizado,
PO1.posicion AS posicion_analizado,
PO2.galgo_nombre AS galgo_competidor,
PO2.posicion AS posicion_competidor,
PO2.edad_en_dias AS competidor_edad

FROM datos_desa.tb_galgos_posiciones_en_carreras PO1

LEFT JOIN datos_desa.tb_galgos_posiciones_en_carreras PO2
ON (PO1.id_Carrera=PO2.id_carrera AND PO1.galgo_nombre <> PO2.galgo_nombre)

ORDER BY PO1.id_carrera DESC, PO1.posicion ASC, PO2.posicion
;
EOF

echo -e "$CONSULTA1"
mysql -u root --password=datos1986 --execute="$CONSULTA1"
mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_galgos_i001_aux1 LIMIT 10\W;" >&1

#################### En cada carrera, ordeno los galgos segun su velocidad_media_con_going_reciente, extrayendo los que deberían quedar segundos
read -d '' CONSULTA2previa <<- EOF
DROP TABLE datos_desa.tb_prueba1;
CREATE TABLE datos_desa.tb_prueba1 AS

SELECT 

id_carrera,
galgo_competidor,
MAX(velocidad_con_going_media_reciente) AS velocidad_con_going_media_reciente,
MAX(competidor_edad) AS competidor_edad

FROM (

  SELECT
  A1.id_carrera,
  CASE WHEN (A1.posicion_analizado IN (1,2) AND A1.posicion_competidor=3) THEN true WHEN (A1.posicion_analizado>=3 AND A1.posicion_competidor=2) THEN true ELSE false END AS segundo_segun_posicion,
  A1.galgo_analizado,  A1.posicion_analizado,
  A1.galgo_competidor,  A1.posicion_competidor,  A1.competidor_edad,
  GA2.*

  FROM datos_desa.tb_galgos_i001_aux1 A1

  LEFT JOIN datos_desa.tb_galgos_agregados GA2
  ON A1.galgo_competidor=GA2.galgo_nombre

  ORDER BY id_carrera, velocidad_con_going_media_reciente DESC

) fuera

GROUP BY id_carrera, galgo_competidor
ORDER BY id_carrera, velocidad_con_going_media_reciente DESC
;


DROP TABLE datos_desa.tb_prueba2;
CREATE TABLE datos_desa.tb_prueba2 AS 
SELECT
P1.*,
( CASE id_carrera 
  WHEN @curCarreraId 
  THEN @curRow := @curRow + 1 
  ELSE @curRow := 1 AND @curCarreraId := id_carrera 
  END
)  AS rank
FROM datos_desa.tb_prueba1 P1, 
(SELECT @curRow := 0, @curCarreraId := '') r
ORDER BY  id_carrera ASC, velocidad_con_going_media_reciente DESC
;


DROP TABLE datos_desa.tb_prueba3;
CREATE TABLE datos_desa.tb_prueba3 AS 
SELECT * FROM datos_desa.tb_prueba2
WHERE rank=2;

EOF

echo -e "$CONSULTA2previa"
mysql -u root --password=datos1986 --execute="$CONSULTA2previa"
mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_prueba1 LIMIT 10\W;" >&1
mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_prueba2 LIMIT 10\W;" >&1
mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_prueba3 LIMIT 10\W;" >&1





#################### TABLA que anhade info a cada galgo (analizado y competidor) (todavia en 5 filas). Selecciona los datos agregados del GALGO CON EL QUE REALMENTE COMPITE (segundo o tercero, en velocidad historica)
mysql -u root --password=datos1986 --execute="DROP TABLE IF EXISTS datos_desa.tb_galgos_i001_aux2;"

read -d '' CONSULTA2 <<- EOF
CREATE TABLE datos_desa.tb_galgos_i001_aux2 AS

SELECT * FROM (

SELECT 
cruce2.*, 
P2.rank as segundo_segun_vel_con_going_media_reciente
FROM (

 SELECT *
 FROM (

  SELECT
  A1.id_carrera,
  CASE WHEN (A1.posicion_analizado IN (1,2) AND A1.posicion_competidor=3) THEN true WHEN (A1.posicion_analizado>=3 AND A1.posicion_competidor=2) THEN true ELSE false END AS segundo_segun_posicion,
  
  A1.galgo_analizado,
  A1.posicion_analizado, 
  GA1.velocidad_real_media_reciente AS analizado_velocidad_real_media_reciente, GA1.velocidad_con_going_media_reciente AS analizado_velocidad_con_going_media_reciente,


  A1.galgo_competidor,
  A1.posicion_competidor,
  A1.competidor_edad,
  GA2.velocidad_real_media_reciente AS competidor_velocidad_real_media_reciente, GA2.velocidad_con_going_media_reciente AS competidor_velocidad_con_going_media_reciente

  FROM datos_desa.tb_galgos_i001_aux1 A1

  LEFT JOIN datos_desa.tb_galgos_agregados GA1
  ON A1.galgo_analizado=GA1.galgo_nombre

  LEFT JOIN datos_desa.tb_galgos_agregados GA2
  ON A1.galgo_competidor=GA2.galgo_nombre

 ) cruce1
 ORDER BY id_carrera, posicion_analizado

)cruce2

LEFT JOIN datos_desa.tb_prueba2 P2
ON (cruce2.id_carrera=P2.id_carrera AND cruce2.galgo_competidor=P2.galgo_competidor)

ORDER BY cruce2.id_carrera ASC, cruce2.posicion_analizado ASC

) cruce3
WHERE cruce3.segundo_segun_vel_con_going_media_reciente=true

;

EOF

echo -e "$CONSULTA2"
mysql -u root --password=datos1986 --execute="$CONSULTA2"
mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_galgos_i001_aux2 LIMIT 10\W;" >&1



#################### Tabla que anhade los datos de la CARRERA y el TARGET (filtro por mes de frio o calor) ###########
mysql -u root --password=datos1986 --execute="DROP TABLE IF EXISTS datos_desa.tb_galgos_i001_aux4;"

read -d '' CONSULTA4 <<- EOF
CREATE TABLE datos_desa.tb_galgos_i001_aux4 AS

SELECT
A3.*,

CA.track,
CA.clase,
CASE WHEN (CA.mes <=2 OR CA.mes >=12) THEN 1 WHEN ((CA.mes >=3 AND CA.mes <=4) OR (CA.mes >=10 AND CA.mes <=11)) THEN 0.5 ELSE 0 END AS mes,
CA.hora,
CA.distancia,
CA.num_galgos,
CA.premio_primero,
CA.premio_segundo,
CA.premio_otros,
CA.premio_total_carrera,
CA.going_allowance_segundos,
CA.fc_1,
CA.fc_2,
CA.fc_pounds,
CA.tc_1,
CA.tc_2,
CA.tc_3,
CA.tc_pounds,

PO.edad_en_dias AS analizado_edad,
PO.sp,

CASE 
  WHEN PO.posicion IN (1,2) THEN 1
  WHEN PO.posicion >=3 THEN 0
  ELSE NULL
END as target

FROM datos_desa.tb_galgos_i001_aux2 A3

LEFT JOIN datos_desa.tb_galgos_carreras CA
ON A3.id_carrera=CA.id_carrera

LEFT JOIN datos_desa.tb_galgos_posiciones_en_carreras PO
ON (A3.id_carrera=PO.id_carrera AND A3.galgo_analizado=PO.galgo_nombre)

ORDER BY anio DESC,mes DESC,dia DESC, A3.id_carrera, A3.posicion_analizado
;
EOF

echo -e "$CONSULTA4"
mysql -u root --password=datos1986 --execute="$CONSULTA4"
mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_galgos_i001_aux4 LIMIT 10\W;" >&1



#################### DATASET Final (para quitar o poner campos) ##########

read -d '' CONSULTA5 <<- EOF

DROP TABLE IF EXISTS datos_desa.tb_galgos_dataset_data_i001;

DROP TABLE IF EXISTS datos_desa.tb_galgos_dataset_target_i001;

CREATE TABLE datos_desa.tb_galgos_dataset_data_i001 AS 
SELECT
mes,
hora,
num_galgos,
sp,
(competidor_edad-analizado_edad) AS diferencia_edades,
analizado_velocidad_con_going_media_reciente,
competidor_velocidad_con_going_media_reciente

FROM datos_desa.tb_galgos_i001_aux4;


CREATE TABLE datos_desa.tb_galgos_dataset_target_i001 AS SELECT target FROM datos_desa.tb_galgos_i001_aux4\W;

EOF

echo -e "$CONSULTA5"
mysql -u root --password=datos1986 --execute="$CONSULTA5"
echo -e "Dataset - DATA: " >&1
mysql -u root --password=datos1986 --execute="SELECT COUNT(*) as num_filas FROM datos_desa.tb_galgos_dataset_data_i001 LIMIT 1\W;" >&1

echo -e "Dataset - TARGET: " >&1
mysql -u root --password=datos1986 --execute="SELECT COUNT(*) as num_filas FROM datos_desa.tb_galgos_dataset_target_i001 LIMIT 1\W;" >&1



######################################################
echo -e "Dataset - Vemos 8 filas de ejemplo: " >&1
mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_galgos_dataset_data_i001 LIMIT 10\W;" -N >&1





echo -e "Modulo 003B - FIN\n\n\n\n"



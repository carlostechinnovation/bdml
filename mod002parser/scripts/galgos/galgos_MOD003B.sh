#!/bin/bash

echo -e "Modulo 003B - Generador de datasets"


################################################
########### Datasets del galgos_i001 ###########
################################################

#################### TABLA con los IDs de: carrera, galgo analizado, galgo competidor, target
mysql -u root --password=datos1986 --execute="DROP TABLE datos_desa.tb_galgos_i001_aux1;"

read -d '' CONSULTA1 <<- EOF
CREATE TABLE datos_desa.tb_galgos_i001_aux1 AS

SELECT
PO1.id_carrera,
PO1.galgo_nombre AS galgo_analizado,
PO2.galgo_nombre AS galgo_competidor

FROM datos_desa.tb_galgos_posiciones_en_carreras PO1

LEFT JOIN datos_desa.tb_galgos_posiciones_en_carreras PO2
ON (PO1.id_Carrera=PO2.id_carrera AND PO1.galgo_nombre <> PO2.galgo_nombre)

ORDER BY PO1.id_carrera DESC, PO1.galgo_nombre ASC, PO1.posicion ASC
;
EOF

echo -e "$CONSULTA1"
mysql -u root --password=datos1986 --execute="$CONSULTA1"
#mysql -u root --password=datos1986 --execute="SELECT COUNT(*) as num_filas FROM datos_desa.tb_galgos_i001_aux1 LIMIT 1\W;" >&1

#################### TABLA que anhade info a cada galgo (analizado y competidor) (todavia en 5 filas)
mysql -u root --password=datos1986 --execute="DROP TABLE datos_desa.tb_galgos_i001_aux2;"

read -d '' CONSULTA2 <<- EOF
CREATE TABLE datos_desa.tb_galgos_i001_aux2 AS

SELECT
A1.id_carrera,
A1.galgo_analizado,

A1.galgo_competidor,
GA2.*

FROM datos_desa.tb_galgos_i001_aux1 A1

LEFT JOIN datos_desa.tb_galgos_agregados GA2
ON A1.galgo_competidor=GA2.galgo_nombre

;
EOF

echo -e "$CONSULTA2"
mysql -u root --password=datos1986 --execute="$CONSULTA2"
#mysql -u root --password=datos1986 --execute="SELECT COUNT(*) as num_filas FROM datos_desa.tb_galgos_i001_aux2 LIMIT 1\W;" >&1

#################### TABLA que agrupa los 5 galgos competidores del galgo analizado (a una sola fila, del galgo analizado)
mysql -u root --password=datos1986 --execute="DROP TABLE datos_desa.tb_galgos_i001_aux3;"

read -d '' CONSULTA3 <<- EOF
CREATE TABLE datos_desa.tb_galgos_i001_aux3 AS

SELECT 
agrupado.*,

GA1.velocidad_real_media_reciente AS analizado_vel_real,
GA1.velocidad_con_going_media_reciente AS analizado_vel_going

FROM
(
  SELECT
  A2.id_carrera,
  A2.galgo_analizado,

ROUND(MAX(velocidad_real_media_reciente),4) AS max_competidores_vel_real, 
ROUND(MIN(velocidad_real_media_reciente),4) AS min_competidores_vel_real, 
ROUND(AVG(velocidad_real_media_reciente),4) AS avg_competidores_vel_real, 
ROUND(STD(velocidad_real_media_reciente),4) AS std_competidores_vel_real,

ROUND(MAX(velocidad_con_going_media_reciente),4) AS max_competidores_vel_going, 
ROUND(MIN(velocidad_con_going_media_reciente),4) AS min_competidores_vel_going, 
ROUND(AVG(velocidad_con_going_media_reciente),4) AS avg_competidores_vel_going, 
ROUND(STD(velocidad_con_going_media_reciente),4) AS std_competidores_vel_going

  FROM datos_desa.tb_galgos_i001_aux2 A2
  GROUP BY A2.id_carrera, A2.galgo_analizado

) agrupado

LEFT JOIN datos_desa.tb_galgos_agregados GA1
ON agrupado.galgo_analizado=GA1.galgo_nombre

ORDER BY agrupado.id_carrera, agrupado.galgo_analizado
;
EOF

echo -e "$CONSULTA3"
mysql -u root --password=datos1986 --execute="$CONSULTA3"
#mysql -u root --password=datos1986 --execute="SELECT COUNT(*) as num_filas FROM datos_desa.tb_galgos_i001_aux3 LIMIT 1\W;" >&1

#################### Tabla que anhade los datos de la CARRERA y el TARGET (filtro por mes de frio o calor) ###########
mysql -u root --password=datos1986 --execute="DROP TABLE datos_desa.tb_galgos_i001_aux4;"

read -d '' CONSULTA4 <<- EOF
CREATE TABLE datos_desa.tb_galgos_i001_aux4 AS

SELECT
A3.*,

CA.track,
CA.clase,
CASE WHEN (CA.mes <=4 OR CA.mes >=10) THEN 1 ELSE 0 END AS mes,
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

CASE 
  WHEN PO.posicion IN (1,2) THEN 1
  WHEN PO.posicion >=3 THEN 0
  ELSE NULL
END as target

FROM datos_desa.tb_galgos_i001_aux3 A3

LEFT JOIN datos_desa.tb_galgos_carreras CA
ON A3.id_carrera=CA.id_carrera

LEFT JOIN datos_desa.tb_galgos_posiciones_en_carreras PO
ON (A3.id_carrera=PO.id_carrera AND A3.galgo_analizado=PO.galgo_nombre)

ORDER BY anio DESC,mes DESC,dia DESC, A3.id_carrera, A3.galgo_analizado
;
EOF

echo -e "$CONSULTA4"
mysql -u root --password=datos1986 --execute="$CONSULTA4"
#mysql -u root --password=datos1986 --execute="SELECT COUNT(*) as num_filas FROM datos_desa.tb_galgos_i001_aux4 LIMIT 1\W;" >&1

#################### DATASET Final (para quitar o poner campos) ##########
mysql -u root --password=datos1986 --execute="DROP TABLE datos_desa.tb_galgos_dataset_data_i001;"
mysql -u root --password=datos1986 --execute="DROP TABLE datos_desa.tb_galgos_dataset_target_i001;"

read -d '' CONSULTA5 <<- EOF
CREATE TABLE datos_desa.tb_galgos_dataset_data_i001 AS SELECT

mes,
hora,
distancia,
num_galgos,
premio_primero,
premio_segundo,
premio_otros,
premio_total_carrera,
going_allowance_segundos,

analizado_vel_real, 
analizado_vel_going,

max_competidores_vel_real,
min_competidores_vel_real,
avg_competidores_vel_real,
std_competidores_vel_real,
max_competidores_vel_going,
min_competidores_vel_going,
avg_competidores_vel_going,
std_competidores_vel_going

FROM datos_desa.tb_galgos_i001_aux4;
EOF

echo -e "$CONSULTA5"
mysql -u root --password=datos1986 --execute="$CONSULTA5"
echo -e "Dataset - DATA: " >&1
mysql -u root --password=datos1986 --execute="SELECT COUNT(*) as num_filas FROM datos_desa.tb_galgos_dataset_data_i001 LIMIT 1\W;" >&1

mysql -u root --password=datos1986 --execute="CREATE TABLE datos_desa.tb_galgos_dataset_target_i001 AS SELECT target FROM datos_desa.tb_galgos_i001_aux4\W;"
echo -e "Dataset - TARGET: " >&1
mysql -u root --password=datos1986 --execute="SELECT COUNT(*) as num_filas FROM datos_desa.tb_galgos_dataset_target_i001 LIMIT 1\W;" >&1

######################################################
echo -e "Dataset - Vemos 8 filas de ejemplo: " >&1
mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_galgos_dataset_data_i001 LIMIT 8\W;" -N >&1





echo -e "Modulo 003B - FIN\n\n\n\n"



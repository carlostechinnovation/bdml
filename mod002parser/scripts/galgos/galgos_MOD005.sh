#!/bin/bash

echo -e "Modulo 005 - Prediccion"

PATH_CONTADOR_GALGOS="./contador_galgos"


#--------------------------------------------

filtro_galgos_nombres=""

input="./galgos_iniciales.txt"
while IFS= read -r linea
do
echo $linea
  filtro_galgos_nombres=${filtro_galgos_nombres}"'"
  filtro_galgos_nombres="${filtro_galgos_nombres}${linea}',"
done < "$input"

#Limpiamos ultima coma, que sobra
filtro_galgos_nombres=${filtro_galgos_nombres::-1}

echo -e "Filtro=${filtro_galgos_nombres}"
#--------------------------------------------



echo -e "Entradas- features: cada FILA es un GALGO EN UNA CARRERA FUTURA"
read -d '' CONSULTA_COMPETIDORES <<- EOF

DROP TABLE IF EXISTS datos_desa.tb_galgos_apuesta;
CREATE TABLE datos_desa.tb_galgos_apuesta AS SELECT * FROM datos_desa.tb_galgos_agregados GA WHERE GA.galgo_nombre IN (${filtro_galgos_nombres}) ;

DROP TABLE IF EXISTS datos_desa.tb_galgos_apuesta_aux1;
CREATE TABLE datos_desa.tb_galgos_apuesta_aux1 AS SELECT * FROM datos_desa.tb_galgos_i001_aux1 WHERE galgo_analizado IN (${filtro_galgos_nombres});

DROP TABLE IF EXISTS datos_desa.tb_galgos_apuesta_aux2;
CREATE TABLE datos_desa.tb_galgos_apuesta_aux2 AS SELECT A1.id_carrera, A1.galgo_analizado, A1.galgo_competidor, GA2.*
FROM datos_desa.tb_galgos_apuesta_aux1 A1
LEFT JOIN datos_desa.tb_galgos_agregados GA2 ON A1.galgo_competidor=GA2.galgo_nombre;


DROP TABLE IF EXISTS datos_desa.tb_galgos_apuesta_aux3;
CREATE TABLE datos_desa.tb_galgos_apuesta_aux3 AS
SELECT agrupado.*,
GA1.velocidad_real_media_reciente AS analizado_vel_real,
GA1.velocidad_con_going_media_reciente AS analizado_vel_going

FROM
(
  SELECT  A2.id_carrera,  A2.galgo_analizado,

ROUND(MAX(velocidad_real_media_reciente),4) AS max_competidores_vel_real, 
ROUND(MIN(velocidad_real_media_reciente),4) AS min_competidores_vel_real, 
ROUND(AVG(velocidad_real_media_reciente),4) AS avg_competidores_vel_real, 
ROUND(STD(velocidad_real_media_reciente),4) AS std_competidores_vel_real,

ROUND(MAX(velocidad_con_going_media_reciente),4) AS max_competidores_vel_going, 
ROUND(MIN(velocidad_con_going_media_reciente),4) AS min_competidores_vel_going, 
ROUND(AVG(velocidad_con_going_media_reciente),4) AS avg_competidores_vel_going, 
ROUND(STD(velocidad_con_going_media_reciente),4) AS std_competidores_vel_going

  FROM datos_desa.tb_galgos_apuesta_aux2 A2
  GROUP BY A2.id_carrera, A2.galgo_analizado

) agrupado

LEFT JOIN datos_desa.tb_galgos_agregados GA1
ON agrupado.galgo_analizado=GA1.galgo_nombre

ORDER BY agrupado.galgo_analizado
;



DROP TABLE IF EXISTS datos_desa.tb_galgos_apuesta_aux4;

CREATE TABLE datos_desa.tb_galgos_apuesta_aux4 AS

select
id_carrera,galgo_analizado,anio,mes,dia,
max_competidores_vel_real,min_competidores_vel_real,avg_competidores_vel_real,std_competidores_vel_real,
max_competidores_vel_going,min_competidores_vel_going,avg_competidores_vel_going, std_competidores_vel_going,
analizado_vel_real,analizado_vel_going,
track,clase,hora,distancia,num_galgos,
premio_primero,premio_segundo,premio_otros,premio_total_carrera

FROM
(
SELECT
A3.*,

CA.track,CA.clase,CA.anio,CA.mes,CA.dia,CA.hora,CA.distancia,CA.num_galgos,
CA.premio_primero,CA.premio_segundo,CA.premio_otros,CA.premio_total_carrera,CA.going_allowance_segundos,CA.fc_1,CA.fc_2,CA.fc_pounds,CA.tc_1,CA.tc_2,CA.tc_3,
CA.tc_pounds

FROM datos_desa.tb_galgos_apuesta_aux3 A3

LEFT JOIN datos_desa.tb_galgos_carreras CA
ON A3.id_carrera=CA.id_carrera

LEFT JOIN datos_desa.tb_galgos_posiciones_en_carreras PO
ON (A3.id_carrera=PO.id_carrera AND A3.galgo_analizado=PO.galgo_nombre)

ORDER BY A3.galgo_analizado ASC , anio DESC,mes DESC,dia DESC, A3.id_carrera
) varias_carreras_relevantes_por_perro

;


select count(*) FROM datos_desa.tb_galgos_apuesta_aux4;


DROP TABLE IF EXISTS datos_desa.tb_galgos_dataset_prediccion_features_i001;
CREATE TABLE datos_desa.tb_galgos_dataset_prediccion_features_i001 AS SELECT

CASE WHEN (month(CURDATE()) <=4 OR month(CURDATE()) >=10) THEN 1 ELSE 0 END AS mes,

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

FROM datos_desa.tb_galgos_apuesta_aux4;




EOF

echo -e "$CONSULTA_COMPETIDORES"
mysql -u root --password=datos1986 --execute="$CONSULTA_COMPETIDORES" >&1


echo -e "Dataset - Comprobacion de que deberia haber SOLO 6 galgos con sus features..." >&1
mysql -u root --password=datos1986 --execute="SELECT COUNT(*) as num_filas FROM datos_desa.tb_galgos_dataset_prediccion_features_i001 LIMIT 1\W;" -N > $PATH_CONTADOR_GALGOS

numero_galgos=$(cat ${PATH_CONTADOR_GALGOS})

if [ ${numero_galgos} -eq 6 ]
then
  
  mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_galgos_dataset_prediccion_features_i001 LIMIT 10\W;" >&1

  echo -e "Prediciendo los targets..."
  python3 '/home/carloslinux/Desktop/GIT_REPO_PYTHON_POC_ML/python_poc_ml/galgos/galgos_i001_predictor.py'


  echo -e "Dataset - TARGETs predichos: " >&1
  mysql -u root --password=datos1986 --execute="DROP TABLE IF EXISTS datos_desa.tb_galgos_dataset_prediccion_target_i001;"
  mysql -u root --password=datos1986 --execute="CREATE TABLE datos_desa.tb_galgos_dataset_prediccion_target_i001 (target INT);"
  mysql -u root --password=datos1986 --execute="LOAD DATA LOCAL INFILE '/home/carloslinux/Desktop/DATOS_LIMPIO/galgos/i001_targets.txt' INTO TABLE datos_desa.tb_galgos_dataset_prediccion_target_i001 FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n' IGNORE 0 LINES\W;"
  sleep 4s

  echo -e "Mostrando los galgos con sus targets..."
  mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_galgos_apuesta LIMIT 10\W;" >&1
  mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_galgos_dataset_prediccion_target_i001;" >&1

else
  echo -e "No tenemos datos de los 6 galgos!!! Solo conocemos datos de ${numero_galgos} galgos!!"
fi


echo -e "FIN"





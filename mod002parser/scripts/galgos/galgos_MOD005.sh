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
CREATE TABLE datos_desa.tb_galgos_apuesta_aux2 AS
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

  FROM datos_desa.tb_galgos_apuesta_aux1 A1

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



DROP TABLE IF EXISTS datos_desa.tb_galgos_apuesta_aux4;

CREATE TABLE datos_desa.tb_galgos_apuesta_aux4 AS

SELECT
A3.*,

CA.track,
CA.clase,
CASE WHEN (CA.mes <=3 OR CA.mes >=12) THEN 0 WHEN ((CA.mes >=4 AND CA.mes <=5) OR (CA.mes >=10 AND CA.mes <=11)) THEN 0.5 ELSE 1 END AS mes,
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

FROM datos_desa.tb_galgos_apuesta_aux2 A3

LEFT JOIN datos_desa.tb_galgos_carreras CA
ON A3.id_carrera=CA.id_carrera

LEFT JOIN datos_desa.tb_galgos_posiciones_en_carreras PO
ON (A3.id_carrera=PO.id_carrera AND A3.galgo_analizado=PO.galgo_nombre)

ORDER BY anio DESC,mes DESC,dia DESC, A3.id_carrera, A3.posicion_analizado
;


select count(*) FROM datos_desa.tb_galgos_apuesta_aux4;


DROP TABLE IF EXISTS datos_desa.tb_galgos_dataset_prediccion_features_i001;
CREATE TABLE datos_desa.tb_galgos_dataset_prediccion_features_i001 AS SELECT

CASE WHEN (month(CURDATE()) <=4 OR month(CURDATE()) >=10) THEN 1 ELSE 0 END AS mes,
hora,
num_galgos,
sp,
(competidor_edad-analizado_edad) AS diferencia_edades,
analizado_velocidad_con_going_media_reciente,
competidor_velocidad_con_going_media_reciente

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





#!/bin/bash

read -d '' CONSULTA_SEMILLAS_FILAS_ARTIFICIALES <<- EOF

set @min_id_carreras_artificiales=(select MIN(id_carrera_artificial) FROM datos_desa.tb_carrerasgalgos_semillasfuturas_d);
set @max_id_carreras_artificiales=(select MAX(id_carrera_artificial) FROM datos_desa.tb_carrerasgalgos_semillasfuturas_d);

DELETE FROM datos_desa.tb_galgos_carreras 
WHERE ( id_carrera >= @min_id_carreras_artificiales AND id_carrera <= @max_id_carreras_artificiales);












select dia, 
CAST(SUBSTRING( CAST(dia AS CHAR(8)), 1,4) AS SMALLINT(6)) AS anio, 
CAST( SUBSTRING( CAST(dia AS CHAR(8)), 5,2) AS SMALLINT(6)) AS mes, 
CAST( SUBSTRING( CAST(dia AS CHAR(8)), 7,2) AS SMALLINT(6)) AS dia 
FROM datos_desa.tb_carrerasgalgos_semillasfuturas_d LIMIT 3;




INSERT INTO datos_desa.tb_galgos_carreras
SELECT 
@max_id_carreras_artificiales AS id_carrera, 
NULL AS id_campeonato, 
estadio AS track, 
NULL AS clase, 
anio, 
mes, 
dia, 
hora, 
minuto, 
NULL AS distancia, 
num_galgos,
NULL AS premio_primero, NULL AS premio_segundo, NULL AS premio_otros, NULL AS premio_total_carrera, NULL AS going_allowance_segundos, NULL AS fc_1, NULL AS fc_2, NULL AS fc_pounds, NULL AS tc_1, NULL AS tc_2, NULL AS tc_3, NULL AS tc_pounds

FROM datos_desa.tb_carrerasgalgos_semillasfuturas_d
;

SELECT count(*) FROM datos_desa.tb_galgos_carreras 
WHERE ( id_carrera >= @min_id_carreras_artificiales AND id_carrera <= @max_id_carreras_artificiales);



select * FROM datos_desa.tb_carrerasgalgos_semillasfuturas_d LIMIT 3;
+------------------+-------------------------------------+----------+------+---------+------------------+------+-----------------------+
| DHE              | id                                  | dia      | hora | estadio | galgo_nombre     | trap | id_carrera_artificial |
+------------------+-------------------------------------+----------+------+---------+------------------+------+-----------------------+
| 201801181827Hove | Hove#20180118#1827#Ballinclare Solo | 20180118 | 1827 | Hove    | Ballinclare Solo |    4 |                     1 |
| 201801181827Hove | Hove#20180118#1827#Candolim Folly   | 20180118 | 1827 | Hove    | Candolim Folly   |    2 |                     1 |
| 201801181827Hove | Hove#20180118#1827#Jumeirah Maximus | 20180118 | 1827 | Hove    | Jumeirah Maximus |    1 |                     1 |
+------------------+-------------------------------------+----------+------+---------+------------------+------+-----------------------+





 |
+------------+---------------+----------+-------+------+------+------+------+--------+-----------+------------+----------------+----------------+--------------+----------------------
|    2049717 |        155188 | Crayford | A7    | 2017 |   12 |   22 |   18 |     33 |       380 |          6 |            140 |             60 |           55 |                  420 |                     0.10 |    1 |    2 |     33.30 |    1 |    2 |    5 |     91.60 |



SELECT * FROM datos_desa.tb_galgos_carreras  LIMIT 1;



SELECT * FROM datos_desa.tb_galgos_posiciones_en_carreras  LIMIT 1;

SELECT * FROM datos_desa.tb_galgos_historico  LIMIT 1;


EOF

#echo -e "$CONSULTA_SEMILLAS_FILAS_ARTIFICIALES" 2>&1 >&1
mysql -u root --password=datos1986 --execute="$CONSULTA_SEMILLAS_FILAS_ARTIFICIALES" >>$LOG_CE

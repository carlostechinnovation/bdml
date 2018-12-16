#!/bin/bash

source "/home/carloslinux/git/bdml/mod002parser/scripts/galgos/funciones.sh"

#Borrar log
rm -f "${LOG_099}"

######################## PARAMETROS ############
if [ "$#" -ne 3 ]; then
    echo " Numero de parametros incorrecto!!!" 2>&1 1>>${LOG_099}
fi

INFORME_COMANDOS_INPUT="${1}"
TAG="${2}"
ID_EJECUCION="${3}"

echo -e "---------- 099 - Parametros entrada -------" 2>&1 1>>${LOG_099}
echo -e "INFORME_COMANDOS_INPUT = ${INFORME_COMANDOS_INPUT}" 2>&1 1>>${LOG_099}
echo -e "TAG = ${TAG}" 2>&1 1>>${LOG_099}
echo -e "ID_EJECUCION = ${ID_EJECUCION}" 2>&1 1>>${LOG_099}
echo -e "------------------------------------" 2>&1 1>>${LOG_099}


echo -e $(date +"%T")" | 099 | Posteriori - Extractor de resultados reales | INICIO" >>$LOG_070
echo -e "MOD099 --> LOG = ${LOG_099}"

#Directorio de salida (informes y datasets)
PATH_DIR_OUT="${PATH_EXTERNAL_DATA}${ID_EJECUCION}/"
mkdir ${PATH_DIR_OUT}

#Paths informes
PATH_IBP="${INFORME_BRUTO_POSTERIORI}"
PATH_ILP="${INFORME_LIMPIO_POSTERIORI}_${ID_EJECUCION}_${TAG}.txt"
PATH_IRP="${INFORME_RENTABILIDAD_POSTERIORI}_${ID_EJECUCION}_${TAG}.txt"


echo -e "\nOutput (HTML bruto leido): ${PATH_IBP}" 2>&1 1>>${LOG_099}
echo -e "Borrando fichero bruto output..." 2>&1 1>>${LOG_099}
rm -f "${ID_EJECUCION}_${TAG}_${PATH_IBP}"


########## EJECUTANDO COMANDOS (calculados previamente en el script 050) #################
echo -e "Input (comandos): "$INFORME_COMANDOS_INPUT 2>&1 1>>${LOG_099}
$INFORME_COMANDOS_INPUT  #Ejecuta el fichero con todos los comandos!!!!!!


########## BUCLE Limpieza #################
echo -e "Limpieza POSTERIORI..." 2>&1 1>>${LOG_099}

rm -f "${PATH_ILP}"
echo -e "|Date|Distancia|TP|STmHcp|Fin|By|WinnerOr2nd|Venue|Remarks|WinTime|Going|SP|Class|CalcTm|Race|Meeting" >>${LOG_099}

sed 's/\t//g' ${PATH_IBP} | sed 's/center//g' | sed 's/resultsRace.aspx?id=//g' | sed 's/<\/td>//g' | sed 's/<\/a>//g' | sed 's/align=\"\"//g' | sed 's/ title=\"Race\"//g' | sed 's/a title=\"Meeting\" href=\"//g' | sed 's/<td/|/g' | sed 's/<//g' | sed 's/>//g' | sed 's/a href=\"//g' | sed 's/\"Race//g' | sed 's/resultsMeeting\.aspx//g' | sed 's/\"Meeting//g' | sed 's/\?id=//g' | sed 's/&nbsp;//g' 2>&1 1>>"${PATH_ILP}"

echo -e "\n\nOutput (HTML limpio leido): ${PATH_ILP}" 2>&1 1>>${LOG_099}


######### Tabla sobre esos datos REALES ######
read -d '' CONSULTA_TABLA_LIMPIA_POSTERIORI <<- EOF

DROP TABLE IF EXISTS datos_desa.tb_galgos_fut_real;

CREATE TABLE IF NOT EXISTS datos_desa.tb_galgos_fut_real (
real_vacio varchar(5), 
real_fecha varchar(10), 
real_distancia INT, 
real_trap SMALLINT, 
real_stmhcp varchar(10), 
real_posicion SMALLINT, 
real_by_espacio varchar(10), 
real_winneror2nd varchar(30), 
real_venue varchar(30), 
real_remarks varchar(30), 
real_wintime decimal(6,4), 
real_going varchar(10), 
real_sp varchar(10), 
real_class varchar(5), 
real_calc_time varchar(10), 
real_id_carrera BIGINT, 
real_id_campeonato BIGINT);
EOF

echo -e "\n$CONSULTA_TABLA_LIMPIA_POSTERIORI" 2>&1 1>>${LOG_099}
mysql -t --execute="$CONSULTA_TABLA_LIMPIA_POSTERIORI"  2>&1 1>>${LOG_099}

consultar "TRUNCATE TABLE datos_desa.tb_galgos_fut_real\W;" "${LOG_099}"
consultar "LOAD DATA LOCAL INFILE '${PATH_ILP}' INTO TABLE datos_desa.tb_galgos_fut_real FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n' IGNORE 0 LINES\W;" "${LOG_099}"

mysql -t --execute="SELECT * FROM datos_desa.tb_galgos_fut_real LIMIT 5;"  2>&1 1>>${LOG_099}
mysql -t --execute="SELECT count(*) AS num_fut_real FROM datos_desa.tb_galgos_fut_real;"  2>&1 1>>${LOG_099}


###################################################################################################
##Tablas enriquecidas con los features que conociamos a priori y el target predicho a priori
#Cuando quería predecir las carreras futuras, no conocía el id_carrera, asi que me inventé 1,2,3...
#Ahora en el resultado real sí veo el id_carrera.
#identifico las carreras simplemente porque vienen en el orden que puse en el dataset (ordenado por id_carrera inventado). 

echo -e "\nDebo comprobar que tengo exactamente el mismo número de filas en fut_predicha y en fut_real" 2>&1 1>>${LOG_099}


##########################
if [ "$TAG" == "BUCLE" ]
then
    SELECCIONAR_TAG=''
else
    SELECCIONAR_TAG="WHERE A.subgrupo='${TAG}'"
fi
##########################

read -d '' CONSULTA_PASADO_Y_FUTURO <<- EOF

DROP TABLE IF EXISTS datos_desa.tb_galgos_fut_predicha;

CREATE TABLE IF NOT EXISTS datos_desa.tb_galgos_fut_predicha 
AS 
SELECT id_carrera AS id_carrera, MAX(target_predicho) as target_predicho_1st 
FROM (
    SELECT id_carrera, target_predicho FROM datos_desa.tb_fut_1st_final_riesgo A ${SELECCIONAR_TAG}
    GROUP BY id_carrera, target_predicho ORDER BY id_carrera ASC, target_predicho DESC
) t 
GROUP BY id_carrera ORDER BY id_carrera ASC;

SELECT count(*) AS num_fut_predicha FROM datos_desa.tb_galgos_fut_predicha LIMIT 1;


DROP TABLE IF EXISTS datos_desa.tb_galgos_fut_predicha2;

CREATE TABLE IF NOT EXISTS datos_desa.tb_galgos_fut_predicha2 
AS 
SELECT A.* 
FROM datos_desa.tb_fut_1st_final_riesgo A
INNER JOIN datos_desa.tb_galgos_fut_predicha B
ON (A.id_carrera=B.id_carrera AND A.target_predicho=B.target_predicho_1st) 
${SELECCIONAR_TAG};

SELECT count(*) AS num_fut_predicha2 FROM datos_desa.tb_galgos_fut_predicha2 LIMIT 1;
SELECT count(*) AS num_fut_real FROM datos_desa.tb_galgos_fut_real LIMIT 1;



-- Combinacion por columna (cbind)

DROP TABLE IF EXISTS datos_desa.tb_galgos_fut_combinada;

CREATE TABLE IF NOT EXISTS datos_desa.tb_galgos_fut_combinada 
AS 

SELECT a.*,b.*
FROM
( SELECT @row1 := @row1 + 1 AS numero1, A1.*
  FROM   datos_desa.tb_galgos_fut_predicha2 A1, (SELECT @row1 := 0) r
) a
INNER JOIN
( SELECT @row2 := @row2 + 1 AS numero2, B1.*
  FROM   datos_desa.tb_galgos_fut_real B1, (SELECT @row2 := 0) r
) b 
ON a.numero1 = b.numero2;

SELECT count(*) AS num_fut_combinada FROM datos_desa.tb_galgos_fut_combinada;
SELECT * FROM datos_desa.tb_galgos_fut_combinada LIMIT 5;
EOF

echo -e "\n$CONSULTA_PASADO_Y_FUTURO" 2>&1 1>>${LOG_099}
mysql -t --execute="$CONSULTA_PASADO_Y_FUTURO"  2>&1 1>>${LOG_099}



################################## Extraccion a dataset para analisis ###########
echo -e "Datasets futuro (predicho y real)" >> "${LOG_099}"
exportarTablaAFichero "datos_desa" "tb_galgos_fut_combinada" "${PATH_MYSQL_PRIV_SECURE}099_ds_futuro_frfp.txt" "${LOG_099}" "${PATH_DIR_OUT}099_ds_futuro_frfp.txt"


############ Extracción en un ACUMULADO de futuros, para analizar muchas ejecuciones ya hechas #########


echo -e "\nInserto los datos futuros conocidos en la tabla de futuros acumulados. Asi podré estudiar esa tabla tras muchas ejecuciones..." 2>&1 1>>${LOG_099}

read -d '' CONSULTA_ACUMULAR_FUT_COMBINADA <<- EOF

CREATE TABLE IF NOT EXISTS datos_desa.tb_galgos_fut_combinada_acum (
  id_ejecucion varchar(14) NOT NULL,
  subgrupo_ganador varchar(50) NOT NULL,
  numero1 double NOT NULL,
  id_carrera bigint(21) unsigned DEFAULT NULL,
  galgo_rowid double DEFAULT NULL,
  target_predicho decimal(10,8) DEFAULT NULL,
  posicion_predicha double DEFAULT NULL,
  galgo_nombre varchar(51) DEFAULT NULL,
  fortaleza decimal(14,8) DEFAULT NULL,
  numero2 double DEFAULT NULL,
  real_vacio varchar(5) DEFAULT NULL,
  real_fecha varchar(10) DEFAULT NULL,
  real_distancia int(11) DEFAULT NULL,
  real_trap smallint(6) DEFAULT NULL,
  real_stmhcp varchar(10) DEFAULT NULL,
  real_posicion smallint(6) DEFAULT NULL,
  real_by_espacio varchar(10) DEFAULT NULL,
  real_winneror2nd varchar(30) DEFAULT NULL,
  real_venue varchar(30) DEFAULT NULL,
  real_remarks varchar(30) DEFAULT NULL,
  real_wintime decimal(6,4) DEFAULT NULL,
  real_going varchar(10) DEFAULT NULL,
  real_sp varchar(10) DEFAULT NULL,
  real_class varchar(5) DEFAULT NULL,
  real_calc_time varchar(10) DEFAULT NULL,
  real_id_carrera bigint(20) DEFAULT NULL,
  real_id_campeonato bigint(20) DEFAULT NULL,
  PRIMARY KEY(id_ejecucion,subgrupo_ganador,numero1)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DELETE FROM datos_desa.tb_galgos_fut_combinada_acum WHERE id_ejecucion='${ID_EJECUCION}' AND subgrupo_ganador='${TAG}';

INSERT INTO datos_desa.tb_galgos_fut_combinada_acum
  SELECT 
  '${ID_EJECUCION}' AS id_ejecucion, '${TAG}' AS subgrupo_ganador,
  numero1, id_carrera, rowid, target_predicho, posicion_predicha, galgo_nombre, fortaleza, numero2, real_vacio, real_fecha, real_distancia, real_trap, real_stmhcp, real_posicion, real_by_espacio, real_winneror2nd, real_venue, real_remarks, real_wintime, real_going, real_sp, real_class, real_calc_time, real_id_carrera, real_id_campeonato
  FROM datos_desa.tb_galgos_fut_combinada
  
  WHERE con_historico_desconocido = 0;

EOF

echo -e "\n$CONSULTA_ACUMULAR_FUT_COMBINADA" 2>&1 1>>${LOG_099}
mysql -t --execute="$CONSULTA_ACUMULAR_FUT_COMBINADA"  2>&1 1>>${LOG_099}


################### Rentabilidad a posteriori (tras 2 días) #######

echo -e "\n----------------------------------------------------\n\n\n\n" 2>&1 1>>${LOG_099}
echo -e "Rentabilidad a posteriori (tras 2 días)..." 2>&1 1>>${LOG_099}

rm -f "${PATH_IRP}"


FILE_TEMP_PRED="./temp_MOD099_num_predicciones_posteriori"
rm -f ${FILE_TEMP_PRED}
mysql -N --execute="SELECT count(*) AS contador FROM datos_desa.tb_galgos_fut_combinada_acum WHERE subgrupo_ganador='${TAG}' AND id_ejecucion='${ID_EJECUCION}';" > ${FILE_TEMP_PRED}
numero_predicciones_posteriori=$(cat ${FILE_TEMP_PRED})
echo -e "\nDato intermedio --> numero_predicciones_posteriori =${numero_predicciones_posteriori}" 2>&1 1>>${LOG_099}


FILE_TEMP="./temp_MOD099_rentabilidad_posteriori"
rm -f ${FILE_TEMP}
mysql -N --execute="SELECT ROUND( 100.0 * SUM(ganado)/SUM(gastado) , 2) AS rentabilidad FROM ( SELECT numero1, fortaleza, 1 AS gastado, CASE WHEN real_posicion=1 THEN cast(numerador AS decimal(2,0)) / cast(denominador AS decimal(2,0)) ELSE 0 END AS ganado FROM ( SELECT numero1, fortaleza, real_posicion, real_sp, substring_index(real_sp,'/',1) as numerador, substring_index(real_sp,'/',-1) as denominador FROM datos_desa.tb_galgos_fut_combinada_acum WHERE subgrupo_ganador='${TAG}' AND id_ejecucion='${ID_EJECUCION}' ) d ) fuera;" > ${FILE_TEMP}
rentabilidad_posteriori=$( cat ${FILE_TEMP})
echo -e "\nDato intermedio --> rentabilidad_posteriori =${rentabilidad_posteriori} euros (por cada 100 euros)" 2>&1 1>>${LOG_099}


FILE_TEMP="./temp_MOD099_num_aciertos_posteriori"
mysql -N --execute="SELECT count(*) FROM datos_desa.tb_galgos_fut_combinada_acum WHERE real_posicion=1 AND subgrupo_ganador='${TAG}' AND id_ejecucion='${ID_EJECUCION}'" > ${FILE_TEMP}
numero_aciertos_posteriori=$( cat ${FILE_TEMP})
echo -e "\nDato intermedio --> numero_aciertos_posteriori =${numero_aciertos_posteriori}" 2>&1 1>>${LOG_099}


COBERTURA_posteriori=$(echo "scale=2; $numero_aciertos_posteriori / $numero_predicciones_posteriori" | bc -l)
echo -e "\nDato intermedio --> COBERTURA_posteriori =${COBERTURA_posteriori}" 2>&1 1>>${LOG_099}

####SALIDA
echo -e "FUTURO_POSTERIORI --> Analisis del TAG=${TAG}  id_ejecucion=${ID_EJECUCION}" 2>&1 1>>${PATH_IRP}
#MENSAJE="cobertura=$numero_aciertos_posteriori/$numero_predicciones_posteriori=${COBERTURA_posteriori}  rentabilidad (si >100%)=${rentabilidad_posteriori}"
#echo -e "$MENSAJE" 2>&1 1>>${PATH_IRP}
echo -e "\nObservar las tablas de este informe y calcular RENTABILIDAD POSTERIORI a mano (mirar las carreras futuras con acierto=1 y que esten dentro de los grupo_sp rentables)" 2>&1 1>>${PATH_IRP}

echo -e "La distancia de la carrera futura la habiamos estimado mirando la MEDIANA de la distancia de la carrera más reciente de cada uno de los 6 galgos que corren..." 2>&1 1>>${PATH_IRP}

echo -e "\nAtencion, dentro del subgrupo, solo debo mirar el grupo_sp rentable:" 2>&1 1>>${PATH_IRP}
mysql -t  --execute="SELECT A.*, B.* FROM datos_desa.tb_rentabilidades_solo_ganadores A LEFT JOIN datos_desa.tb_grupos_sp B ON (A.grupo_sp=B.grupo_sp) LIMIT 100;" 2>&1 1>>${PATH_IRP}


read -d '' CONSULTA_PREDICHO_Y_REAL <<- EOF
select dentro1.*
 from (

SELECT 
cast(substring_index(A.real_sp,'/',1) AS decimal(2,0)) / cast(substring_index(A.real_sp,'/',-1) AS decimal(2,0)) AS real_sp_numero,

CASE WHEN (A.posicion_predicha=A.real_posicion) THEN 1 ELSE 0 END AS acierto, 
abs(A.real_distancia-B.distancia) AS distancia_diff,
100*(abs(A.real_distancia-B.distancia))/B.distancia AS distancia_diff_pct,
A.real_distancia AS dis_post,
B.distancia AS dis_pre,
CASE WHEN (B.distancia <= ${POST_099_UMBRAL_CORTAS_MEDIAS} ) THEN 1 ELSE 0 END AS b_corta,
CASE WHEN (B.distancia > ${POST_099_UMBRAL_CORTAS_MEDIAS} AND  B.distancia <= ${POST_099_UMBRAL_MEDIAS_LARGAS} ) THEN 1 ELSE 0 END AS b_media,
CASE WHEN (B.distancia > ${POST_099_UMBRAL_MEDIAS_LARGAS} ) THEN 1 ELSE 0 END AS b_larga,
A.*
FROM datos_desa.tb_galgos_fut_combinada_acum A 

LEFT JOIN  datos_desa.tb_elaborada_carreras B
ON (A.id_carrera=B.id_carrera)

WHERE subgrupo_ganador='${TAG}' AND id_ejecucion='${ID_EJECUCION}' AND A.real_posicion > 0
ORDER BY real_sp_numero ASC
) as dentro1

INNER JOIN ( 
  SELECT C.subgrupo, D.* FROM datos_desa.tb_rentabilidades_solo_ganadores C
  LEFT JOIN datos_desa.tb_grupos_sp D
  ON (C.grupo_sp=D.grupo_sp)
) AS dentro2
ON (dentro1.subgrupo_ganador=dentro2.subgrupo AND dentro1.real_sp_numero >=dentro2.sp_min AND dentro1.real_sp_numero <=dentro2.sp_max)

WHERE dentro1.distancia_diff_pct < ${VAR_distancia_diff_pct};

EOF




##########################
if [ "$TAG" == "BUCLE" ]
then
    echo -e "\nPara BUCLE, no puedo pintar facilmente la tabla de aciertos, pero los datos globales ( ¡¡ Sin mirar SP real!! ) usando bucle serian:" 2>&1 1>>${PATH_IRP}
    echo -e "\nnumero_predicciones_posteriori =${numero_predicciones_posteriori}" 2>&1 1>>${PATH_IRP}
    echo -e "\nnumero_aciertos_posteriori =${numero_aciertos_posteriori}" 2>&1 1>>${PATH_IRP}
    echo -e "\nrentabilidad_posteriori =${rentabilidad_posteriori} euros (por cada 100 euros)" 2>&1 1>>${PATH_IRP}
    echo -e "\nCOBERTURA_posteriori =${COBERTURA_posteriori}" 2>&1 1>>${PATH_IRP}

else
    echo -e "\nA priori pensabamos que era una distancia, pero a posteriori era otra distancia real!!! (Quitamos casos con mucha distancia_diff > ${VAR_distancia_diff_pct} % ) !!\n" 2>&1 1>>${PATH_IRP}
    echo -e "\nTabla completa (PREDICHO y REAL):\n" 2>&1 1>>${PATH_IRP}
    echo -e "\n$CONSULTA_PREDICHO_Y_REAL" 2>&1 1>>${LOG_099}
    mysql -t --execute="$CONSULTA_PREDICHO_Y_REAL"  2>&1 1>>${PATH_IRP}
fi
##########################

################################# INFORMES (POSTERIORI) ###############################################
echo -e "\n----------------------------------------------------\n\n\n\n" 2>&1 1>>${LOG_099}
echo -e "Informes (posteriori) en: ${PATH_DIR_OUT}" >> "${LOG_099}"

#Limpiar por si acaso relanzo varias veces a posteriori sobre el mismo ID_EJECUCION
rm -rf "${PATH_DIR_OUT}posteriori*"

cp "$LOG_070" "${PATH_DIR_OUT}posteriori_${TAG}_tic.txt" #Informe TIC. En su ultima linea aparece el COMANDO que debo lanzar a POSTERIORI
cp "${PATH_ILP}" "${PATH_DIR_OUT}posteriori_${TAG}_limpio.txt"
cp "${PATH_IRP}" "${PATH_DIR_OUT}posteriori_${TAG}_rentabilidad.txt"


##################### Permisos ########################################################################
chmod -R 777 "${PATH_DIR_OUT}"
#####################################################################################################

echo -e "\n-------------------- FIN --------------------------------\n\n\n\n" 2>&1 1>>${LOG_099}
echo -e $(date +"%T")" | 099 | Posteriori - Extractor de resultados reales | FIN" >>$LOG_070







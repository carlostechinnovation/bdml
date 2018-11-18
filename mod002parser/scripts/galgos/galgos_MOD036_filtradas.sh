#!/bin/bash

source "/home/carloslinux/git/bdml/mod002parser/scripts/galgos/funciones.sh"


################ TABLAS FILTRADAS (a partir de tablas TRANSFORMADAS) ####################################################################################
function generarTablasFiltradas ()
{

echo -e "\n"$(date +"%T")" ---- TABLAS FILTRADAS ---" 2>&1 1>>${LOG_DS}

filtro_carreras="${1}"
filtro_galgos="${2}"
filtro_cg="${3}"
sufijo="${4}"

read -d '' CONSULTA_FILTRADAS <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_filtrada_carreras_${sufijo};

CREATE TABLE datos_desa.tb_filtrada_carreras_${sufijo} AS 
SELECT 
cast(id_carrera AS DECIMAL(20,0)) AS id_carrera_ix,
cast(id_campeonato AS DECIMAL(20,0)) AS id_campeonato_ix, 
A.* 
FROM datos_desa.tb_trans_carreras A ${filtro_carreras};

ALTER TABLE datos_desa.tb_filtrada_carreras_${sufijo} ADD INDEX tb_filtrada_carreras_${sufijo}_idx(id_carrera_ix);
SELECT * FROM datos_desa.tb_filtrada_carreras_${sufijo} ORDER BY id_carrera_ix LIMIT 5;
SELECT count(*) as num_filtrada_carreras FROM datos_desa.tb_filtrada_carreras_${sufijo} LIMIT 5;


DROP TABLE IF EXISTS datos_desa.tb_filtrada_galgos_${sufijo};

CREATE TABLE datos_desa.tb_filtrada_galgos_${sufijo} AS 
SELECT 
SUBSTRING(galgo_nombre, 1, 30) AS galgo_nombre_ix, 
B.* 
FROM datos_desa.tb_trans_galgos B ${filtro_galgos};

ALTER TABLE datos_desa.tb_filtrada_galgos_${sufijo} ADD INDEX tb_filtrada_galgos_${sufijo}_idx(galgo_nombre_ix);
SELECT * FROM datos_desa.tb_filtrada_galgos_${sufijo} ORDER BY galgo_nombre_ix LIMIT 5;
SELECT count(*) as num_filtrada_galgos FROM datos_desa.tb_filtrada_galgos_${sufijo} LIMIT 5;


DROP TABLE IF EXISTS datos_desa.tb_filtrada_carrerasgalgos_${sufijo};

CREATE TABLE datos_desa.tb_filtrada_carrerasgalgos_${sufijo} AS 
SELECT 
cast(id_carrera AS DECIMAL(20,0)) AS id_carrera_ix,
SUBSTRING(galgo_nombre, 1, 30) AS galgo_nombre_ix,
C.*
 FROM datos_desa.tb_trans_carrerasgalgos C ${filtro_cg};

ALTER TABLE datos_desa.tb_filtrada_carrerasgalgos_${sufijo} ADD INDEX tb_filtrada_carrerasgalgos_${sufijo}_idx1(id_carrera_ix);
ALTER TABLE datos_desa.tb_filtrada_carrerasgalgos_${sufijo} ADD INDEX tb_filtrada_carrerasgalgos_${sufijo}_idx2(galgo_nombre_ix);
SELECT * FROM datos_desa.tb_filtrada_carrerasgalgos_${sufijo} ORDER BY cg LIMIT 5;
SELECT count(*) as num_filtrada_carrerasgalgos FROM datos_desa.tb_filtrada_carrerasgalgos_${sufijo} LIMIT 5;
EOF

echo -e "$CONSULTA_FILTRADAS" 2>&1 1>>${LOG_DS}
mysql -t --execute="$CONSULTA_FILTRADAS" >>$LOG_DS


echo -e "\n---------------- | 036 | Tablas FILTRADAS --------------" 2>&1 1>>${LOG_DS}
echo -e "datos_desa.tb_filtrada_carreras_${sufijo}" 2>&1 1>>${LOG_DS}
echo -e "datos_desa.tb_filtrada_galgos_${sufijo}" 2>&1 1>>${LOG_DS}
echo -e "datos_desa.tb_filtrada_carrerasgalgos_${sufijo}" 2>&1 1>>${LOG_DS}
echo -e "----------------------------------------------------\n\n\n" 2>&1 1>>${LOG_DS}

analizarTabla "datos_desa" "tb_filtrada_carreras_${sufijo}" "${LOG_DS}"
analizarTabla "datos_desa" "tb_filtrada_galgos_${sufijo}" "${LOG_DS}"
analizarTabla "datos_desa" "tb_filtrada_carrerasgalgos_${sufijo}" "${LOG_DS}"
}



################################################ MAIN ###########################################################################################

if [ "$#" -ne 4 ]; then
    echo " Numero de parametros incorrecto!!!" 2>&1 1>>${LOG_DS}
fi

filtro_carreras="${1}"
filtro_galgos="${2}"
filtro_cg="${3}"
sufijo="${4}"


echo -e $(date +"%T")" | 036 | Filtradas (subgrupo: $sufijo) | INICIO" >>$LOG_070

echo -e $(date +"%T")" 036_Filtradas-Parametros: -->${1}-->${2}-->${3}-->${4}" 2>&1 1>>${LOG_DS}

generarTablasFiltradas "$filtro_carreras" "$filtro_galgos" "$filtro_cg" "$sufijo"

echo -e $(date +"%T")" | 036 | Filtradas (subgrupos) | FIN" >>$LOG_070






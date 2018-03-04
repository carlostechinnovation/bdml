#!/bin/bash

source "/root/git/bdml/mod002parser/scripts/galgos/funciones.sh"


################ TABLAS FILTRADAS (a partir de tablas elaboradas) ####################################################################################
function generarTablasFiltradas ()
{

echo -e "\n"$(date +"%T")" \n---- TABLAS FILTRADAS ---" 2>&1 1>>${LOG_DS}

filtro_carreras="${1}"
filtro_galgos="${2}"
filtro_cg="${3}"
sufijo="${4}"

read -d '' CONSULTA_FILTRADAS <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_filtrada_carreras_${sufijo};

CREATE TABLE datos_desa.tb_filtrada_carreras_${sufijo} AS 
SELECT * FROM datos_desa.tb_elaborada_carreras_pre ${filtro_carreras};

ALTER TABLE datos_desa.tb_filtrada_carreras_${sufijo} ADD INDEX tb_filtrada_carreras_${sufijo}_idx(id_carrera);
SELECT * FROM datos_desa.tb_filtrada_carreras_${sufijo} ORDER BY id_carrera LIMIT 5;
SELECT count(*) as num_filtrada_carreras FROM datos_desa.tb_filtrada_carreras_${sufijo} LIMIT 5;


DROP TABLE IF EXISTS datos_desa.tb_filtrada_galgos_${sufijo};

CREATE TABLE datos_desa.tb_filtrada_galgos_${sufijo} AS 
SELECT * FROM datos_desa.tb_elaborada_galgos_pre ${filtro_galgos};

ALTER TABLE datos_desa.tb_filtrada_galgos_${sufijo} ADD INDEX tb_filtrada_galgos_${sufijo}_idx(galgo_nombre);
SELECT * FROM datos_desa.tb_filtrada_galgos_${sufijo} ORDER BY galgo_nombre LIMIT 5;
SELECT count(*) as num_filtrada_galgos FROM datos_desa.tb_filtrada_galgos_${sufijo} LIMIT 5;


DROP TABLE IF EXISTS datos_desa.tb_filtrada_carrerasgalgos_${sufijo};

CREATE TABLE datos_desa.tb_filtrada_carrerasgalgos_${sufijo} AS 
SELECT * FROM datos_desa.tb_elaborada_carrerasgalgos_pre ${filtro_cg};

ALTER TABLE datos_desa.tb_filtrada_carrerasgalgos_${sufijo} ADD INDEX tb_filtrada_carrerasgalgos_${sufijo}_idx(id_carrera);
SELECT * FROM datos_desa.tb_filtrada_carrerasgalgos_${sufijo} ORDER BY cg LIMIT 5;
SELECT count(*) as num_filtrada_carrerasgalgos FROM datos_desa.tb_filtrada_carrerasgalgos_${sufijo} LIMIT 5;
EOF

#echo -e $(date +"%T")"$CONSULTA_FILTRADAS" 2>&1 1>>${LOG_DS}
mysql -u root --password=datos1986 -t --execute="$CONSULTA_FILTRADAS" >>$LOG_DS


echo -e "*** TABLAS FILTRADAS ***" 2>&1 1>>${LOG_DS}
echo -e "datos_desa.tb_filtrada_carreras_${sufijo}" 2>&1 1>>${LOG_DS}
echo -e "datos_desa.tb_filtrada_galgos_${sufijo}" 2>&1 1>>${LOG_DS}
echo -e "datos_desa.tb_filtrada_carrerasgalgos_${sufijo}" 2>&1 1>>${LOG_DS}
}



################################################ MAIN ###########################################################################################

if [ "$#" -ne 4 ]; then
    echo " Numero de parametros incorrecto!!!" 2>&1 1>>${LOG_DS}
fi

filtro_carreras="${1}"
filtro_galgos="${2}"
filtro_cg="${3}"
sufijo="${4}"


echo -e $(date +"%T")" Generador de Tablas FILTRADAS (ya elaboradas): INICIO" 2>&1 1>>${LOG_DS}
echo -e $(date +"%T")" Parametros: -->${1}-->${2}-->${3}-->${4}" 2>&1 1>>${LOG_DS}

generarTablasFiltradas "$filtro_carreras" "$filtro_galgos" "$filtro_cg" "$sufijo"

echo -e $(date +"%T")" Generador de FILTRADAS: FIN\n\n" 2>&1 1>>${LOG_DS}






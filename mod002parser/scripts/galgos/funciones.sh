#!/bin/bash

LOG_DESCARGA_BRUTO="/home/carloslinux/Desktop/LOGS/galgos_001A_descarga_bruto.log"
DOC_ANALISIS_PREVIO="/home/carloslinux/Desktop/INFORMES/analisis_previo.txt"
LOG_ESTADISTICA_BRUTO="/home/carloslinux/Desktop/LOGS/galgos_003A_stats_bruto.log"
LOG_CE_y_DS="/home/carloslinux/Desktop/LOGS/galgos_003B_ce_y_ds.log"
LOG_CE="/home/carloslinux/Desktop/LOGS/galgos_003B_columnas_elaboradas.log"
LOG_DS="/home/carloslinux/Desktop/LOGS/galgos_003B_datasets.log"


function consultar(){
  sentencia_sql=${1}
  path_log_sql=${2}
  opciones=${3}
  mysql -u root --password=datos1986 ${opciones} --execute="${sentencia_sql}" 2>&1 1>>${path_log_sql}
}

function consultar_sobreescribirsalida(){
  sentencia_sql=${1}
  path_output_file=${2}
  opciones=${3}
  mysql -u root --password=datos1986 ${opciones} --execute="${sentencia_sql}" >"$path_output_file"
  sleep 4s
}

function mostrar_tabla(){
  descripcion=${1}
  schema_tabla=${2}
  path_output_file=${3}
  echo -e "\n${descripcion} (${schema_tabla}): " 2>&1 1>>${path_output_file}
  consultar "SHOW CREATE TABLE ${schema_tabla}\W;" "${path_output_file}" "-tNs"
  consultar "SELECT COUNT(*) as num_filas FROM ${schema_tabla} LIMIT 1\W;" "${path_output_file}"  "-t"
  consultar "SELECT * FROM ${schema_tabla} LIMIT 1\W;" "${path_output_file}" "-t"
}





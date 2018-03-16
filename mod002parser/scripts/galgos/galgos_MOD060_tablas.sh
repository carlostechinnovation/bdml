#!/bin/bash

source "/root/git/bdml/mod002parser/scripts/galgos/funciones.sh"

echo -e $(date +"%T")" | 060 | Analisis de tablas | INICIO" >>$LOG_070

echo -e "MOD060_tablas --> LOG = "${LOG_060_TABLAS}

#Limpieza inicial
rm -Rf "$LOG_060_TABLAS"


mysql -u root --password=datos1986 -t --execute="SELECT concat(table_schema,'.',table_name) AS tabla, cardinality AS num_filas FROM INFORMATION_SCHEMA.STATISTICS WHERE table_schema = 'datos_desa' ORDER BY table_name;" 2>&1 1>>$LOG_060_TABLAS

mysql -u root --password=datos1986 -t --execute="SELECT concat(table_schema,'.',table_name) AS tabla, table_rows, data_length FROM INFORMATION_SCHEMA.PARTITIONS   WHERE table_schema = 'datos_desa' ORDER BY table_name;" 2>&1 1>>$LOG_060_TABLAS 2>&1 1>>$LOG_060_TABLAS


echo -e $(date +"%T")" | 060 | Analisis de tablas | FIN" >>$LOG_070




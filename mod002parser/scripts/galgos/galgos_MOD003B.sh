#!/bin/bash

echo -e "Modulo 003B - Generador de datasets" >&1


echo -e "Entradas- features: cada FILA es un GALGO EN UNA CARRERA FUTURA" >&1
"/home/carloslinux/Desktop/CODIGOS/workspace_java/bdml/mod002parser/scripts/galgos/galgos_generador_datasets.sh" "" "_gagst_pre"




echo -e "Dataset - TARGET: " >&1
mysql -u root --password=datos1986 --execute="DROP TABLE IF EXISTS datos_desa.tb_galgos_target_gagst_pre\W;" >&1
mysql -u root --password=datos1986 --execute="CREATE TABLE datos_desa.tb_galgos_target_gagst_pre AS SELECT target FROM datos_desa.tb_galgos_005_gagst_pre\W;" >&1
mysql -u root --password=datos1986 --execute="SELECT COUNT(*) as num_filas FROM datos_desa.tb_galgos_target_gagst_pre LIMIT 1\W;" >&1





echo -e "Modulo 003B - FIN\n\n" >&1



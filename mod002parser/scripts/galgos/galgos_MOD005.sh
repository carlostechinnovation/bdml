#!/bin/bash

echo -e "Modulo 005 - Prediccion"

PATH_CONTADOR_GALGOS="./contador_galgos"

PATH_INFORME_FINAL="/home/carloslinux/Desktop/INFORMES/galgos_prediccion.txt"


echo -e "Entradas- features: cada FILA es un GALGO EN UNA CARRERA FUTURA" >&1
"/home/carloslinux/Desktop/CODIGOS/workspace_java/bdml/mod002parser/scripts/galgos/galgos_generador_datasets.sh" "WHERE PO1.galgo_nombre IN (SELECT MAX(galgo_nombre) AS galgo_nombre FROM datos_desa.tb_galgos_carreragalgo GROUP BY galgo_nombre)" "_post"

echo -e "MACHINE LEARNING - Prediciendo los targets..."
python3 '/home/carloslinux/Desktop/GIT_REPO_PYTHON_POC_ML/python_poc_ml/galgos/galgos_i001_predictor.py'


echo -e "RESULTADO - TARGETs predichos: " >&1
mysql -u root --password=datos1986 --execute="DROP TABLE IF EXISTS datos_desa.tb_galgos_target_post;"
mysql -u root --password=datos1986 --execute="CREATE TABLE datos_desa.tb_galgos_target_post (target INT);"
mysql -u root --password=datos1986 --execute="LOAD DATA LOCAL INFILE '/home/carloslinux/Desktop/DATOS_LIMPIO/galgos/target_post.txt' INTO TABLE datos_desa.tb_galgos_target_post FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n' IGNORE 0 LINES\W;"
sleep 4s

echo -e "Mostrando los galgos con sus targets..."


mysql -u root --password=datos1986 --execute="SET @rank1=0; DROP TABLE IF EXISTS datos_desa.tb_galgos_data_final; CREATE TABLE datos_desa.tb_galgos_data_final AS SELECT @rank1:=@rank1+1 AS rank, 
id, dia, hora, estadio, galgo_nombre FROM datos_desa.tb_galgos_carreragalgo\W;" >&1
mysql -u root --password=datos1986 --execute="SET @rank2=0;  DROP TABLE IF EXISTS datos_desa.tb_galgos_target_final; CREATE TABLE datos_desa.tb_galgos_target_final AS SELECT @rank2:=@rank2+1 AS rank, target AS PREDICCION FROM datos_desa.tb_galgos_target_post;" >&1

mysql -u root --password=datos1986 -t --execute="SELECT dia, hora, estadio, galgo_nombre, PREDICCION FROM datos_desa.tb_galgos_data_final A LEFT JOIN datos_desa.tb_galgos_target_final B ON (A.rank=B.rank) ORDER BY dia DESC, hora DESC, estadio DESC, galgo_nombre DESC;" >${PATH_INFORME_FINAL}


echo -e "Resultado guardado en: $PATH_INFORME_FINAL" >&1

echo -e "Primeras filas del resultado: " >&1
head -n 10 $PATH_INFORME_FINAL >&1


#***********************************
# MAILS
#***********************************
cat "$PATH_INFORME_FINAL" | mail -s "GALGOS - Prediccion carreras futuras Sportium" carlosandresgarcia1986@gmail.com,fcacereslau@hotmail.com,luisandresgarcia@gmail.com




echo -e "FIN"





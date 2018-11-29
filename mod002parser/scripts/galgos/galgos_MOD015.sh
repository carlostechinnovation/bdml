#!/bin/bash

source "/home/carloslinux/git/bdml/mod002parser/scripts/galgos/funciones.sh"
 
#Borrar log
rm -f "${LOG_015}"

echo -e $(date +"%T")" | 015 | Transformacion de columnas | INICIO" >>$LOG_070
echo -e "MOD015 --> LOG = "${LOG_015}

##########################################
echo -e $(date +"%T")" TRANSFORMACIONES NUMERICAS *************************" 2>&1 1>>${LOG_015}
echo -e $(date +"%T")" - NORMALIZACION (scale) a rango [0,1]" 2>&1 1>>${LOG_015}
echo -e $(date +"%T")" - STANDARDIZE (z-score) a gausianna[media=0, std=1] --> Util en Regr. Log., LDA... pero las features deben ser gaussianas!!! (transformarlas con LOG u otra funcion y comprobar su normalidad pintando un QQ-plot)" 2>&1 1>>${LOG_015}
echo -e $(date +"%T")" - NORMALIZACION de filas para que los pesos de cada fila sumen 1 --> Util en KNN, NeuralNet..." 2>&1 1>>${LOG_015}
echo -e $(date +"%T")" ****************************************************" 2>&1 1>>${LOG_015}
##########################################
echo -e $(date +"%T")" SHAPIRO-WILK (test de normalidad): " 2>&1 1>>${LOG_015}
echo -e $(date +"%T")" - Si p-value es mayor que alpha (0.05) entonces no se puede rechazar la hipotesis nula (la muestra viene de una distribucion NORMAL)" 2>&1 1>>${LOG_015}
echo -e $(date +"%T")" - Si p-value es menor que alpha (0.05) entonces rechazamos la hipotesis nula: SEGURO que la muestra NO viene de una distribucion NORMAL." 2>&1 1>>${LOG_015}
##########################################

#Borrar tablas preexistentes
mysql -t --execute="DROP TABLE IF EXISTS datos_desa.tb_trans_galgos;" 2>&1 1>>${LOG_015}
mysql -t --execute="DROP TABLE IF EXISTS datos_desa.tb_trans_carreras;" 2>&1 1>>${LOG_015}
mysql -t --execute="DROP TABLE IF EXISTS datos_desa.tb_trans_carrerasgalgos;" 2>&1 1>>${LOG_015}

#Borrar graficos previos
rm -Rf '/home/carloslinux/Desktop/LOGS/015_graficos/'
mkdir '/home/carloslinux/Desktop/LOGS/015_graficos/'

echo -e "MOD015 - Transformando con R..." 2>&1 1>>${LOG_015}
Rscript "${PATH_RSTUDIO_WSKP}galgos_015.R" "10000000" 2>&1 1>>"${LOG_015}"
echo -e "MOD015 - Transformando con R - FIN" 2>&1 1>>${LOG_015}
<<<<<<< HEAD

=======
>>>>>>> branch 'master' of https://github.com/carlostechinnovation/bdml

############################## OPTIMIZACION #######################################################################
echo -e "-------------- OPTIMIZACION --------------" >> "${LOG_016_STATS}"
mysql -t --execute="ALTER TABLE datos_desa.tb_trans_galgos ADD INDEX trans_galgos_idx1(galgo_nombre(255));" 2>&1 1>>${LOG_015}
mysql -t --execute="ALTER TABLE datos_desa.tb_trans_galgos ADD INDEX trans_galgos_idx2(vel_going_largas_max(255));" 2>&1 1>>${LOG_015}

mysql -t --execute="ALTER TABLE datos_desa.tb_trans_carreras ADD INDEX trans_carreras_idx1(id_carrera);" 2>&1 1>>${LOG_015}
mysql -t --execute="ALTER TABLE datos_desa.tb_trans_carreras ADD INDEX trans_carreras_idx2(distancia(255));" 2>&1 1>>${LOG_015}

mysql -t --execute="ALTER TABLE datos_desa.tb_trans_carrerasgalgos ADD INDEX trans_cg_idx1(id_carrera);" 2>&1 1>>${LOG_015}
mysql -t --execute="ALTER TABLE datos_desa.tb_trans_carrerasgalgos ADD INDEX trans_cg_idx2(galgo_nombre(255));" 2>&1 1>>${LOG_015}
mysql -t --execute="ALTER TABLE datos_desa.tb_trans_carrerasgalgos ADD INDEX trans_cg_idx3(id_carrera, galgo_nombre(255));" 2>&1 1>>${LOG_015}
########################################################################

echo -e $(date +"%T")" | 015 | Transformacion de columnas | FIN" >>$LOG_070




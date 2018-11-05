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



echo -e "MOD015 - Transformando con R..." 2>&1 1>>${LOG_015}
Rscript "${PATH_RSTUDIO_WSKP}galgos_015.R" 2>&1 1>>"${LOG_015}"


echo -e "-------------- TABLAS con columnas TRANSFORMADAS --------------" >> "${LOG_015}"
analizarTabla "datos_desa" "tb_trans_carreras" "${LOG_015}"
analizarTabla "datos_desa" "tb_trans_galgos" "${LOG_015}"
analizarTabla "datos_desa" "tb_trans_carrerasgalgos" "${LOG_015}"



echo -e $(date +"%T")" | 015 | Transformacion de columnas | FIN" >>$LOG_070








#!/bin/bash
 
source "/home/carloslinux/git/bdml/mod002parser/scripts/galgos/funciones.sh"
source "/home/carloslinux/git/bdml/mod002parser/scripts/galgos/galgos_MOD013_001_nuevas_cols.sh"
source "/home/carloslinux/git/bdml/mod002parser/scripts/galgos/galgos_MOD013_002_tablas_cols_elab.sh"


echo -e $(date +"%T")" | 013 | Columnas elaboradas | INICIO" >>$LOG_070

#### Limpiar LOG ###
rm -f ${LOG_013}

echo -e "MOD013 --> LOG = "${LOG_013}
echo -e "Los galgos SEMILLAS deberian tener el SP (STARTING PRICE) si lo conocemos en el instante de la descarga" 2>&1 1>>${LOG_013}

################################################ MAIN ###########################################################################################

if [ "$#" -ne 0 ]; then
    echo "Parametros de entrada: incorrecto!!!" 2>&1 1>>${LOG_013}
fi

echo -e " Generador de COLUMNAS ELABORADAS: INICIO" 2>&1 1>>${LOG_013}
echo -e " Parametros: -->${1}" 2>&1 1>>${LOG_013}

echo -e " Creando tabla de REMARKS-PUNTOS (util para variable 13)..." 2>&1 1>>${LOG_013}
crearTablaRemarksPuntos

echo -e "\n\n---- Variables: X1, X2..." 2>&1 1>>${LOG_013}
calcularVariableX1
calcularVariableX2
calcularVariableX3
calcularVariableX4
calcularVariableX5
calcularVariableX6
calcularVariableX7
calcularVariableX8
calcularVariableX9
calcularVariableX10
calcularVariableX11
calcularVariableX12
calcularVariableX13

echo -e "\n\n ---- Tablas MAESTRAS de INDICES..." 2>&1 1>>${LOG_013}
generarTablasIndices

echo -e "\n\n --- Tablas finales con COLUMNAS ELABORADAS (se usarán para crear datasets)..." 2>&1 1>>${LOG_013}
generarTablasElaboradas

####################################################################
echo -e "\n\n | 013 | --- Analizando tablas intermedias (¡¡ mirar MUCHO los NULOS de CADA columna!!!! )...\n\n" 2>&1 1>>${LOG_013}

analizarTabla "datos_desa" "tb_ce_x1a" "${LOG_013}"
analizarTabla "datos_desa" "tb_ce_x1b" "${LOG_013}"
analizarTabla "datos_desa" "tb_ce_x2a" "${LOG_013}"
analizarTabla "datos_desa" "tb_ce_x2b" "${LOG_013}"
analizarTabla "datos_desa" "tb_ce_x3a" "${LOG_013}"
analizarTabla "datos_desa" "tb_ce_x3b" "${LOG_013}"
analizarTabla "datos_desa" "tb_ce_x4" "${LOG_013}"
analizarTabla "datos_desa" "tb_ce_x5" "${LOG_013}"
analizarTabla "datos_desa" "tb_ce_x6e" "${LOG_013}"
analizarTabla "datos_desa" "tb_ce_x7a" "${LOG_013}"
analizarTabla "datos_desa" "tb_ce_x7b" "${LOG_013}"
analizarTabla "datos_desa" "tb_ce_x7c" "${LOG_013}"
analizarTabla "datos_desa" "tb_ce_x7d" "${LOG_013}"
analizarTabla "datos_desa" "tb_ce_x8a" "${LOG_013}"
analizarTabla "datos_desa" "tb_ce_x8b" "${LOG_013}"
analizarTabla "datos_desa" "tb_ce_x9a" "${LOG_013}"
analizarTabla "datos_desa" "tb_ce_x9b" "${LOG_013}"
analizarTabla "datos_desa" "tb_ce_x10a" "${LOG_013}"
analizarTabla "datos_desa" "tb_ce_x10b" "${LOG_013}"
analizarTabla "datos_desa" "tb_ce_x11" "${LOG_013}"
analizarTabla "datos_desa" "tb_ce_x12a" "${LOG_013}"
analizarTabla "datos_desa" "tb_ce_x12b" "${LOG_013}"
analizarTabla "datos_desa" "tb_gh_y_remarkspuntos_LIM3" "${LOG_013}"
analizarTabla "datos_desa" "tb_ce_x13" "${LOG_013}"

####################################################################

#echo -e "\n\n --- Borrando tablas intermedias innecesarias..." 2>&1 1>>${LOG_013}
#borrarTablasInnecesarias

####################################################################
echo -e "\n\n | 013 | --- Analizando tablas finales ELABORADAS (¡¡ mirar MUCHO los NULOS de CADA columna!!!! )...\n\n" 2>&1 1>>${LOG_013}

analizarTabla "datos_desa" "tb_elaborada_carreras" "${LOG_013}"
analizarTabla "datos_desa" "tb_elaborada_galgos" "${LOG_013}"
analizarTabla "datos_desa" "tb_elaborada_carrerasgalgos" "${LOG_013}"

echo -e $(date +"%T")" | 013 | Columnas elaboradas | FIN" >>$LOG_070




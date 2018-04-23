#!/bin/bash

source "/home/carloslinux/git/bdml/mod002parser/scripts/galgos/funciones.sh"

#Borrar log
rm -f "${LOG_019_EXPORT}"

echo -e $(date +"%T")" | 019 | Export de 010-012 | INICIO" >>$LOG_070
echo -e "MOD019 --> LOG = "${LOG_019_EXPORT}

#Limpiar informe
rm -f "${LOG_019_EXPORT}"

########## SUBCARPETAS #################
mkdir $EXTERNAL_010_BRUTO
mkdir $EXTERNAL_012_LIMNOR


############### EXPORTACION A CARPETA EXTERNA #####################

echo -e "Semillas" >> "${LOG_019_EXPORT}"
exportarTablaAFichero "datos_desa" "tb_cg_semillas_sportium" "${PATH_MYSQL_PRIV_SECURE}000_semillas.txt" "${LOG_019_EXPORT}" "${EXTERNAL_010_BRUTO}000_semillas.txt"

##010
echo -e "TABLAS BRUTAS (pasadas + futuras)" >> "${LOG_019_EXPORT}"
exportarTablaAFichero "datos_desa" "tb_galgos_carreras" "${PATH_MYSQL_PRIV_SECURE}010_carreras.txt" "${LOG_019_EXPORT}" "${EXTERNAL_010_BRUTO}010_carreras.txt"
exportarTablaAFichero "datos_desa" "tb_galgos_posiciones_en_carreras" "${PATH_MYSQL_PRIV_SECURE}010_galgos_en_carreras.txt" "${LOG_019_EXPORT}" "${EXTERNAL_010_BRUTO}010_galgos_en_carreras.txt"
exportarTablaAFichero "datos_desa" "tb_galgos_historico" "${PATH_MYSQL_PRIV_SECURE}010_historico.txt" "${LOG_019_EXPORT}" "${EXTERNAL_010_BRUTO}010_historico.txt"
exportarTablaAFichero "datos_desa" "tb_galgos_agregados" "${PATH_MYSQL_PRIV_SECURE}010_agregados.txt" "${LOG_019_EXPORT}" "${EXTERNAL_010_BRUTO}010_agregados.txt"



##012
echo -e "TABLAS LIMNOR (pasadas + futuras)" >> "${LOG_019_EXPORT}"
exportarTablaAFichero "datos_desa" "tb_galgos_carreras_norm" "${PATH_MYSQL_PRIV_SECURE}010_carreras_norm.txt" "${LOG_019_EXPORT}" "${EXTERNAL_012_LIMNOR}010_carreras_norm.txt"
exportarTablaAFichero "datos_desa" "tb_galgos_posiciones_en_carreras_norm" "${PATH_MYSQL_PRIV_SECURE}010_galgos_en_carreras_norm.txt" "${LOG_019_EXPORT}" "${EXTERNAL_012_LIMNOR}010_galgos_en_carreras_norm.txt"
exportarTablaAFichero "datos_desa" "tb_galgos_historico_norm" "${PATH_MYSQL_PRIV_SECURE}010_historico_norm.txt" "${LOG_019_EXPORT}" "${EXTERNAL_012_LIMNOR}010_historico_norm.txt"
exportarTablaAFichero "datos_desa" "tb_galgos_agregados_norm" "${PATH_MYSQL_PRIV_SECURE}010_agregados_norm.txt" "${LOG_019_EXPORT}" "${EXTERNAL_012_LIMNOR}010_agregados_norm.txt"


#####################################################################################################

echo -e $(date +"%T")" | 019 | Export de 010-012 | FIN" >>$LOG_070




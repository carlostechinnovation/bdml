#!/bin/bash

source "/root/git/bdml/mod002parser/scripts/galgos/funciones.sh"

echo -e $(date +"%T")" | 010.param | ANALISIS DE PARAMETROS para Descarga datos brutos | INICIO" >>$LOG_070

FILE_TEMP="${PATH_LOGS}temp_010_analisis_params"

##########################
rm -f ${INFORME_CONFIG_010}


###############################################
function ejecutar(){
  
  #CONFIG="MAX_NUM_CARRERAS_SEMILLA|MAX_PROFUNDIDAD_PROCESADA|GALGOS_UMBRAL_DIAS_CARRERAS_ANTERIORES|MAX_NUM_CARRERAS_PROCESADAS"
  CONFIG="${1}"

  rm -f $FILE_TEMP

  echo -e "\n**************************************************************************" >>$INFORME_CONFIG_010
  echo -e $(date +"%T")"#INICIO#${CONFIG}" >>$INFORME_CONFIG_010
  ${PATH_SCRIPTS}'galgos_MOD010.sh' "${CONFIG}" >>$FILE_TEMP #Sportium

  echo -e "\n--------------" >>$INFORME_CONFIG_010
  cat "${LOG_DESCARGA_BRUTO}" | grep 'ANALITICA_GLOBAL' >>$INFORME_CONFIG_010
  echo -e "\n--------------" >>$INFORME_CONFIG_010

  analizarTabla "datos_desa" "tb_galgos_carreras" "${INFORME_CONFIG_010}"
  analizarTabla "datos_desa" "tb_galgos_posiciones_en_carreras" "${INFORME_CONFIG_010}"
  analizarTabla "datos_desa" "tb_galgos_historico" "${INFORME_CONFIG_010}"
  analizarTabla "datos_desa" "tb_galgos_agregados" "${INFORME_CONFIG_010}"
}


##########################################

#CONFIG="MAX_NUM_CARRERAS_SEMILLA|MAX_PROFUNDIDAD_PROCESADA|GALGOS_UMBRAL_DIAS_CARRERAS_ANTERIORES|MAX_NUM_CARRERAS_PROCESADAS"

ejecutar "3&1&14&30"




##########################################

echo -e $(date +"%T")" | 010.param | ANALISIS DE PARAMETROS para Descarga datos brutos | FIN" >>$LOG_070




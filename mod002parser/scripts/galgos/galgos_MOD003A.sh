#!/bin/bash

source "/root/git/bdml/mod002parser/scripts/galgos/funciones.sh"

#Borrar log
rm -f "${DOC_ANALISIS_PREVIO}"

echo -e $(date +"%T")"Modulo 003A - Estadística básica de las features de ENTRADA..." 2>&1 1>>${LOG_ESTADISTICA_BRUTO}
echo -e $(date +"%T")"Informe: ${DOC_ANALISIS_PREVIO}" 2>&1 1>>${LOG_ESTADISTICA_BRUTO}

#Limpiar informe
rm -f "${DOC_ANALISIS_PREVIO}"

echo -e $(date +"%T")"----- Analisis de REMARKS-----" >> "${DOC_ANALISIS_PREVIO}"
echo -e $(date +"%T")"RanOn:" >> "${DOC_ANALISIS_PREVIO}"
mysql -u root --password=datos1986 -t --execute="select posicion, count(*) as contador from datos_desa.tb_galgos_historico WHERE remarks LIKE '%RanOn%' GROUP BY posicion ORDER BY posicion ASC LIMIT 10;\W;" >> "${DOC_ANALISIS_PREVIO}"
echo -e $(date +"%T")"Led:" >> "${DOC_ANALISIS_PREVIO}"
mysql -u root --password=datos1986 -t --execute="select posicion, count(*) as contador from datos_desa.tb_galgos_historico WHERE remarks LIKE '%Led%' GROUP BY posicion ORDER BY posicion ASC LIMIT 10;\W;" >> "${DOC_ANALISIS_PREVIO}"
echo -e $(date +"%T")"AlwaysLed:" >> "${DOC_ANALISIS_PREVIO}"
mysql -u root --password=datos1986 -t --execute="select posicion, count(*) as contador from datos_desa.tb_galgos_historico WHERE remarks LIKE '%AlwaysLed%' GROUP BY posicion ORDER BY posicion ASC LIMIT 10;\W;" >> "${DOC_ANALISIS_PREVIO}"




echo -e $(date +"%T")"Modulo 003A - FIN" 2>&1 1>>${LOG_ESTADISTICA_BRUTO}



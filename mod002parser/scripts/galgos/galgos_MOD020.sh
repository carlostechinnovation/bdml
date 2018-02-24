#!/bin/bash

source "/root/git/bdml/mod002parser/scripts/galgos/funciones.sh"

#Borrar log
rm -f "${LOG_ESTADISTICA_BRUTO}"
rm -f "${DOC_ANALISIS_PREVIO}"


echo -e $(date +"%T")" Modulo 020 - Estadística básica de las features de ENTRADA..." 2>&1 1>>${LOG_ESTADISTICA_BRUTO}
echo -e $(date +"%T")" Informe: ${DOC_ANALISIS_PREVIO}" 2>&1 1>>${LOG_ESTADISTICA_BRUTO}

#Limpiar informe
rm -f "${DOC_ANALISIS_PREVIO}"


echo -e "\n----- Analisis de GALGOS y CARRERAS -----" >> "${DOC_ANALISIS_PREVIO}"

echo -e "Numero de galgos:" >> "${DOC_ANALISIS_PREVIO}"
mysql -u root --password=datos1986 -t --execute="SELECT count(*) FROM datos_desa.tb_elaborada_galgos_pre;" >> "${DOC_ANALISIS_PREVIO}"
echo -e "Numero de carreras:" >> "${DOC_ANALISIS_PREVIO}"
mysql -u root --password=datos1986 -t --execute="SELECT count(*) FROM datos_desa.tb_elaborada_carreras_pre;" >> "${DOC_ANALISIS_PREVIO}"
echo -e "Numero de galgos en carreras:" >> "${DOC_ANALISIS_PREVIO}"
mysql -u root --password=datos1986 -t --execute="SELECT count(*) FROM datos_desa.tb_elaborada_carrerasgalgos_pre;" >> "${DOC_ANALISIS_PREVIO}"

echo -e "\nNumero MEDIO de GALGOS que corren en una CARRERA:" >> "${DOC_ANALISIS_PREVIO}"
mysql -u root --password=datos1986 -t --execute="SELECT count(DISTINCT id_carrera)/count(DISTINCT galgo_nombre) FROM datos_desa.tb_elaborada_carrerasgalgos_pre;" >> "${DOC_ANALISIS_PREVIO}"
echo -e "Numero MEDIO de CARRERAS conocidas por galgo (ajustado en Constantes: semanas hacia atrás):" >> "${DOC_ANALISIS_PREVIO}"
mysql -u root --password=datos1986 -t --execute="SELECT AVG(num_carreras_por_galgo) AS avg_num_carreras_por_galgo FROM ( SELECT galgo_nombre, count(*) AS num_carreras_por_galgo FROM datos_desa.tb_elaborada_carrerasgalgos_pre GROUP BY galgo_nombre ) dentro; " >> "${DOC_ANALISIS_PREVIO}"



echo -e "\n----- Analisis de REMARKS-----" >> "${DOC_ANALISIS_PREVIO}"

echo -e "RanOn:" >> "${DOC_ANALISIS_PREVIO}"
mysql -u root --password=datos1986 -t --execute="SELECT posicion, count(*) as contador FROM datos_desa.tb_galgos_historico WHERE remarks LIKE '%RanOn%' GROUP BY posicion ORDER BY posicion ASC LIMIT 10;" >> "${DOC_ANALISIS_PREVIO}"

echo -e "Led:" >> "${DOC_ANALISIS_PREVIO}"
mysql -u root --password=datos1986 -t --execute="SELECT posicion, count(*) as contador FROM datos_desa.tb_galgos_historico WHERE remarks LIKE '%Led%' GROUP BY posicion ORDER BY posicion ASC LIMIT 10;" >> "${DOC_ANALISIS_PREVIO}"

echo -e "AlwaysLed:" >> "${DOC_ANALISIS_PREVIO}"
mysql -u root --password=datos1986 -t --execute="SELECT posicion, count(*) as contador FROM datos_desa.tb_galgos_historico WHERE remarks LIKE '%AlwaysLed%' GROUP BY posicion ORDER BY posicion ASC LIMIT 10;" >> "${DOC_ANALISIS_PREVIO}"






echo -e $(date +"%T")" Modulo 020 - FIN" 2>&1 1>>${LOG_ESTADISTICA_BRUTO}



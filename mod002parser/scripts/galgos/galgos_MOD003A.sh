#!/bin/bash

echo -e "Modulo 003A - Estadistica basica de las features" >&1



DOC_ANALISIS_PREVIO="/home/carloslinux/Desktop/INFORMES/analisis_previo.txt"
rm -f "${DOC_ANALISIS_PREVIO}"


echo -e "----- Analisis de REMARKS-----" >> "${DOC_ANALISIS_PREVIO}"
echo -e "RanOn:" >> "${DOC_ANALISIS_PREVIO}"
mysql -u root --password=datos1986 -t --execute="select posicion, count(*) as contador from datos_desa.tb_galgos_historico WHERE remarks LIKE '%RanOn%' GROUP BY posicion ORDER BY posicion ASC LIMIT 10;\W;" >> "${DOC_ANALISIS_PREVIO}"
echo -e "Led:" >> "${DOC_ANALISIS_PREVIO}"
mysql -u root --password=datos1986 -t --execute="select posicion, count(*) as contador from datos_desa.tb_galgos_historico WHERE remarks LIKE '%Led%' GROUP BY posicion ORDER BY posicion ASC LIMIT 10;\W;" >> "${DOC_ANALISIS_PREVIO}"
echo -e "AlwaysLed:" >> "${DOC_ANALISIS_PREVIO}"
mysql -u root --password=datos1986 -t --execute="select posicion, count(*) as contador from datos_desa.tb_galgos_historico WHERE remarks LIKE '%AlwaysLed%' GROUP BY posicion ORDER BY posicion ASC LIMIT 10;\W;" >> "${DOC_ANALISIS_PREVIO}"




echo -e "Modulo 003A - FIN" >&1



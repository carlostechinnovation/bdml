#!/bin/bash

source "/root/git/bdml/mod002parser/scripts/galgos/funciones.sh"

#Borrar log
rm -f "${LOG_ESTADISTICA_BRUTO}"
rm -f "${DOC_ANALISIS_PREVIO}"


echo -e $(date +"%T")" Modulo 020 - Estadística básica de los datos BRUTOS de ENTRADA..." 2>&1 1>>${LOG_ESTADISTICA_BRUTO}

echo -e "MOD020 --> LOG = "${LOG_ESTADISTICA_BRUTO}
echo -e "MOD020-INFORME = "${DOC_ANALISIS_PREVIO} 2>&1 1>>${LOG_ESTADISTICA_BRUTO}


#Limpiar informe
rm -f "${DOC_ANALISIS_PREVIO}"

echo -e "-------------- CG Semillas FUTURAS SPORTIUM --------------" >> "${DOC_ANALISIS_PREVIO}"
echo -e "tb_cg_semillas_sportium:" >> "${DOC_ANALISIS_PREVIO}"
mysql -u root --password=datos1986 -tN --execute="SELECT count(*) FROM datos_desa.tb_cg_semillas_sportium;" >> "${DOC_ANALISIS_PREVIO}"

echo -e "-------------- TABLAS SIN NORMALIZAR --------------" >> "${DOC_ANALISIS_PREVIO}"
echo -e "tb_galgos_carreras:" >> "${DOC_ANALISIS_PREVIO}"
mysql -u root --password=datos1986 -tN --execute="SELECT count(*) FROM datos_desa.tb_galgos_carreras;" >> "${DOC_ANALISIS_PREVIO}"
echo -e "tb_galgos_posiciones_en_carreras:" >> "${DOC_ANALISIS_PREVIO}"
mysql -u root --password=datos1986 -tN --execute="SELECT count(*) FROM datos_desa.tb_galgos_posiciones_en_carreras;" >> "${DOC_ANALISIS_PREVIO}"
echo -e "tb_galgos_historico:" >> "${DOC_ANALISIS_PREVIO}"
mysql -u root --password=datos1986 -tN --execute="SELECT count(*) FROM datos_desa.tb_galgos_historico;" >> "${DOC_ANALISIS_PREVIO}"
echo -e "tb_galgos_agregados:" >> "${DOC_ANALISIS_PREVIO}"
mysql -u root --password=datos1986 -tN --execute="SELECT count(*) FROM datos_desa.tb_galgos_agregados;" >> "${DOC_ANALISIS_PREVIO}"

echo -e "-------------- TABLAS NORMALIZADAS --------------" >> "${DOC_ANALISIS_PREVIO}"
echo -e "tb_galgos_carreras_norm:" >> "${DOC_ANALISIS_PREVIO}"
mysql -u root --password=datos1986 -tN --execute="SELECT count(*) FROM datos_desa.tb_galgos_carreras_norm;" >> "${DOC_ANALISIS_PREVIO}"
echo -e "tb_galgos_posiciones_en_carreras_norm:" >> "${DOC_ANALISIS_PREVIO}"
mysql -u root --password=datos1986 -tN --execute="SELECT count(*) FROM datos_desa.tb_galgos_posiciones_en_carreras_norm;" >> "${DOC_ANALISIS_PREVIO}"
echo -e "tb_galgos_historico_norm:" >> "${DOC_ANALISIS_PREVIO}"
mysql -u root --password=datos1986 -tN --execute="SELECT count(*) FROM datos_desa.tb_galgos_historico_norm;" >> "${DOC_ANALISIS_PREVIO}"
echo -e "tb_galgos_agregados_norm:" >> "${DOC_ANALISIS_PREVIO}"
mysql -u root --password=datos1986 -tN --execute="SELECT count(*) FROM datos_desa.tb_galgos_agregados_norm;" >> "${DOC_ANALISIS_PREVIO}"

echo -e "-------------- TABLAS NORMALIZADAS: datos ARTIFICIALES sobre carreras FUTURAS --------------" >> "${DOC_ANALISIS_PREVIO}"
echo -e "tb_galgos_carreras_norm --> Deben aparecer 6 galgos por carrera futura:" >> "${DOC_ANALISIS_PREVIO}"
mysql -u root --password=datos1986 -tN --execute="SELECT * FROM datos_desa.tb_galgos_carreras_norm WHERE id_carrera<=50 ORDER BY id_carrera LIMIT 12;" >> "${DOC_ANALISIS_PREVIO}"
echo -e "tb_galgos_posiciones_en_carreras_norm --> Deberia haber 6 filas por cada carrera futura (pero no más):" >> "${DOC_ANALISIS_PREVIO}"
mysql -u root --password=datos1986 -tN --execute="SELECT id_carrera, count(*) AS contador FROM datos_desa.tb_galgos_posiciones_en_carreras_norm WHERE id_carrera<=50 GROUP BY id_carrera HAVING contador>6 ORDER BY id_carrera LIMIT 10;" >> "${DOC_ANALISIS_PREVIO}"
echo -e "tb_galgos_historico_norm --> Deben aparecer los historicos (artificiales) de una carrera futura:" >> "${DOC_ANALISIS_PREVIO}"
mysql -u root --password=datos1986 -tN --execute="SELECT * FROM datos_desa.tb_galgos_historico_norm WHERE id_carrera<=50 ORDER BY id_carrera LIMIT 10;" >> "${DOC_ANALISIS_PREVIO}"
echo -e "tb_galgos_agregados_norm --> No deberia haber ningun galgo_agregado duplicado:" >> "${DOC_ANALISIS_PREVIO}"
mysql -u root --password=datos1986 -tN --execute="SELECT galgo_nombre, count(*) AS contador FROM datos_desa.tb_galgos_agregados_norm GROUP BY galgo_nombre HAVING contador>=2 LIMIT 10;" >> "${DOC_ANALISIS_PREVIO}"


echo -e "\n----- Analisis de CARRERAS -----" >> "${DOC_ANALISIS_PREVIO}"

echo -e "Numero de carreras segun el dia:" >> "${DOC_ANALISIS_PREVIO}"
mysql -u root --password=datos1986 -t --execute="SELECT SUM(dow_d) AS sum_d, SUM(dow_l) AS sum_l, SUM(dow_m) AS sum_m, SUM(dow_x) AS sum_x, SUM(dow_j) AS sum_j, SUM(dow_v) AS sum_v, SUM(dow_s) AS sum_s, SUM(dow_finde) AS sum_finde, SUM(dow_laborable) AS sum_laborable FROM datos_desa.tb_galgos_carreras_norm;" >> "${DOC_ANALISIS_PREVIO}"


echo -e "\n----- Analisis de GALGOS y CARRERAS -----" >> "${DOC_ANALISIS_PREVIO}"

echo -e "\nNumero MEDIO de GALGOS que corren en una CARRERA:" >> "${DOC_ANALISIS_PREVIO}"
mysql -u root --password=datos1986 -tN --execute="SELECT count(DISTINCT id_carrera)/count(DISTINCT galgo_nombre) FROM datos_desa.tb_galgos_historico_norm;" >> "${DOC_ANALISIS_PREVIO}"
echo -e "Numero MEDIO de CARRERAS conocidas por galgo (ajustado en Constantes: semanas hacia atrás):" >> "${DOC_ANALISIS_PREVIO}"
mysql -u root --password=datos1986 -tN --execute="SELECT AVG(num_carreras_por_galgo) AS avg_num_carreras_por_galgo FROM ( SELECT galgo_nombre, count(*) AS num_carreras_por_galgo FROM datos_desa.tb_galgos_historico_norm GROUP BY galgo_nombre ) dentro; " >> "${DOC_ANALISIS_PREVIO}"
echo -e "\nGalgos con mas de un entrenador conocido:" >> "${DOC_ANALISIS_PREVIO}"
mysql -u root --password=datos1986 -tN --execute="SELECT galgo_nombre, count(DISTINCT entrenador) AS num_entrenadores FROM datos_desa.tb_galgos_historico_norm GROUP BY galgo_nombre HAVING num_entrenadores>=2;" >> "${DOC_ANALISIS_PREVIO}"


echo -e "\n----- Analisis de REMARKS -----" >> "${DOC_ANALISIS_PREVIO}"

echo -e "Crd:" >> "${DOC_ANALISIS_PREVIO}"
mysql -u root --password=datos1986 -t --execute="SELECT posicion, count(*) as contador FROM datos_desa.tb_galgos_historico WHERE remarks LIKE '%Crd%' GROUP BY posicion ORDER BY posicion ASC LIMIT 10;" >> "${DOC_ANALISIS_PREVIO}"

echo -e "Wide:" >> "${DOC_ANALISIS_PREVIO}"
mysql -u root --password=datos1986 -t --execute="SELECT posicion, count(*) as contador FROM datos_desa.tb_galgos_historico WHERE remarks LIKE '%Wide%' GROUP BY posicion ORDER BY posicion ASC LIMIT 10;" >> "${DOC_ANALISIS_PREVIO}"

echo -e "RanOn:" >> "${DOC_ANALISIS_PREVIO}"
mysql -u root --password=datos1986 -t --execute="SELECT posicion, count(*) as contador FROM datos_desa.tb_galgos_historico WHERE remarks LIKE '%RanOn%' GROUP BY posicion ORDER BY posicion ASC LIMIT 10;" >> "${DOC_ANALISIS_PREVIO}"

echo -e "Led:" >> "${DOC_ANALISIS_PREVIO}"
mysql -u root --password=datos1986 -t --execute="SELECT posicion, count(*) as contador FROM datos_desa.tb_galgos_historico WHERE remarks LIKE '%Led%' GROUP BY posicion ORDER BY posicion ASC LIMIT 10;" >> "${DOC_ANALISIS_PREVIO}"

echo -e "AlwaysLed:" >> "${DOC_ANALISIS_PREVIO}"
mysql -u root --password=datos1986 -t --execute="SELECT posicion, count(*) as contador FROM datos_desa.tb_galgos_historico WHERE remarks LIKE '%AlwaysLed%' GROUP BY posicion ORDER BY posicion ASC LIMIT 10;" >> "${DOC_ANALISIS_PREVIO}"



echo -e $(date +"%T")" Modulo 020 - FIN" 2>&1 1>>${LOG_ESTADISTICA_BRUTO}



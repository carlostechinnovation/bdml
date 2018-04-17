#!/bin/bash

source "/home/carloslinux/git/bdml/mod002parser/scripts/galgos/funciones.sh"

#Borrar log
rm -f "${LOG_020_ESTADISTICA}"

echo -e $(date +"%T")" | 020 | Estadistica basica | INICIO" >>$LOG_070
echo -e "MOD020 --> LOG = "${LOG_020_ESTADISTICA}

#Limpiar informe
rm -f "${LOG_020_ESTADISTICA}"

######################################################################################################
echo -e "-------------- CG Semillas FUTURAS SPORTIUM --------------" >> "${LOG_020_ESTADISTICA}"
echo -e "tb_cg_semillas_sportium:" >> "${LOG_020_ESTADISTICA}"
mysql-tN --execute="SELECT count(*) FROM datos_desa.tb_cg_semillas_sportium;" >> "${LOG_020_ESTADISTICA}"

######################################################################################################
echo -e "-------------- TABLAS BRUTAS (pasadas + futuras) --------------" >> "${LOG_020_ESTADISTICA}"
echo -e "tb_galgos_carreras:" >> "${LOG_020_ESTADISTICA}"
mysql-tN --execute="SELECT count(*) FROM datos_desa.tb_galgos_carreras;" >> "${LOG_020_ESTADISTICA}"
echo -e "tb_galgos_posiciones_en_carreras:" >> "${LOG_020_ESTADISTICA}"
mysql-tN --execute="SELECT count(*) FROM datos_desa.tb_galgos_posiciones_en_carreras;" >> "${LOG_020_ESTADISTICA}"
echo -e "tb_galgos_historico:" >> "${LOG_020_ESTADISTICA}"
mysql-tN --execute="SELECT count(*) FROM datos_desa.tb_galgos_historico;" >> "${LOG_020_ESTADISTICA}"
echo -e "tb_galgos_agregados:" >> "${LOG_020_ESTADISTICA}"
mysql-tN --execute="SELECT count(*) FROM datos_desa.tb_galgos_agregados;" >> "${LOG_020_ESTADISTICA}"

analizarTabla "datos_desa" "tb_galgos_carreras" "${LOG_020_ESTADISTICA}"
analizarTabla "datos_desa" "tb_galgos_posiciones_en_carreras" "${LOG_020_ESTADISTICA}"
analizarTabla "datos_desa" "tb_galgos_historico" "${LOG_020_ESTADISTICA}"
analizarTabla "datos_desa" "tb_galgos_agregados" "${LOG_020_ESTADISTICA}"

######################################################################################################
echo -e "-------------- TABLAS LIMPIAS (pasadas + futuras) --------------" >> "${LOG_020_ESTADISTICA}"
echo -e "tb_galgos_carreras:" >> "${LOG_020_ESTADISTICA}"
mysql-tN --execute="SELECT count(*) FROM datos_desa.tb_galgos_carreras_LIM;" >> "${LOG_020_ESTADISTICA}"
echo -e "tb_galgos_posiciones_en_carreras:" >> "${LOG_020_ESTADISTICA}"
mysql-tN --execute="SELECT count(*) FROM datos_desa.tb_galgos_posiciones_en_carreras_LIM;" >> "${LOG_020_ESTADISTICA}"
echo -e "tb_galgos_historico:" >> "${LOG_020_ESTADISTICA}"
mysql-tN --execute="SELECT count(*) FROM datos_desa.tb_galgos_historico_LIM;" >> "${LOG_020_ESTADISTICA}"
echo -e "tb_galgos_agregados:" >> "${LOG_020_ESTADISTICA}"
mysql-tN --execute="SELECT count(*) FROM datos_desa.tb_galgos_agregados_LIM;" >> "${LOG_020_ESTADISTICA}"

analizarTabla "datos_desa" "tb_galgos_carreras_LIM" "${LOG_020_ESTADISTICA}"
analizarTabla "datos_desa" "tb_galgos_posiciones_en_carreras_LIM" "${LOG_020_ESTADISTICA}"
analizarTabla "datos_desa" "tb_galgos_historico_LIM" "${LOG_020_ESTADISTICA}"
analizarTabla "datos_desa" "tb_galgos_agregados_LIM" "${LOG_020_ESTADISTICA}"

######################################################################################################
echo -e "-------------- TABLAS LIMPIAS Y NORMALIZADAS (pasadas + futuras) --------------" >> "${LOG_020_ESTADISTICA}"
echo -e "tb_galgos_carreras_norm:" >> "${LOG_020_ESTADISTICA}"
mysql-tN --execute="SELECT count(*) FROM datos_desa.tb_galgos_carreras_norm;" >> "${LOG_020_ESTADISTICA}"
echo -e "tb_galgos_posiciones_en_carreras_norm:" >> "${LOG_020_ESTADISTICA}"
mysql-tN --execute="SELECT count(*) FROM datos_desa.tb_galgos_posiciones_en_carreras_norm;" >> "${LOG_020_ESTADISTICA}"
echo -e "tb_galgos_historico_norm:" >> "${LOG_020_ESTADISTICA}"
mysql-tN --execute="SELECT count(*) FROM datos_desa.tb_galgos_historico_norm;" >> "${LOG_020_ESTADISTICA}"
echo -e "tb_galgos_agregados_norm:" >> "${LOG_020_ESTADISTICA}"
mysql-tN --execute="SELECT count(*) FROM datos_desa.tb_galgos_agregados_norm;" >> "${LOG_020_ESTADISTICA}"

analizarTabla "datos_desa" "tb_galgos_carreras_norm" "${LOG_020_ESTADISTICA}"
analizarTabla "datos_desa" "tb_galgos_posiciones_en_carreras_norm" "${LOG_020_ESTADISTICA}"
analizarTabla "datos_desa" "tb_galgos_historico_norm" "${LOG_020_ESTADISTICA}"
analizarTabla "datos_desa" "tb_galgos_agregados_norm" "${LOG_020_ESTADISTICA}"

######################################################################################################

echo -e "\n\n\n\n-------------- TABLAS NORMALIZADAS: datos ARTIFICIALES sobre carreras FUTURAS --------------" >> "${LOG_020_ESTADISTICA}"
echo -e "\n\ntb_galgos_carreras_norm --> Carreras futuras con id artificial:" >> "${LOG_020_ESTADISTICA}"
mysql-t --execute="SELECT * FROM datos_desa.tb_galgos_carreras_norm WHERE id_carrera<=50 ORDER BY id_carrera LIMIT 12;" >> "${LOG_020_ESTADISTICA}"

echo -e "\n\ntb_galgos_posiciones_en_carreras_norm --> Deberia haber 6 filas por cada carrera futura (pero no más). Esta consulta debe devolver 0 resultados:" >> "${LOG_020_ESTADISTICA}"
mysql-t --execute="SELECT id_carrera, count(*) AS contador FROM datos_desa.tb_galgos_posiciones_en_carreras_norm WHERE id_carrera<=50 GROUP BY id_carrera HAVING contador>6 ORDER BY id_carrera LIMIT 10;" >> "${LOG_020_ESTADISTICA}"

echo -e "\n\ntb_galgos_historico_norm --> Deben aparecer los historicos (artificiales) de una carrera futura:" >> "${LOG_020_ESTADISTICA}"
mysql-t --execute="SELECT * FROM datos_desa.tb_galgos_historico_norm WHERE id_carrera<=50 ORDER BY id_carrera LIMIT 10;" >> "${LOG_020_ESTADISTICA}"

echo -e "\n\ntb_galgos_agregados_norm --> No deberia haber ningun galgo_agregado duplicado. Esta consulta debe devolver 0 resultados:" >> "${LOG_020_ESTADISTICA}"
mysql-t --execute="SELECT galgo_nombre, count(*) AS contador FROM datos_desa.tb_galgos_agregados_norm GROUP BY galgo_nombre HAVING contador>=2 LIMIT 10;" >> "${LOG_020_ESTADISTICA}"


echo -e "\n\n----- Analisis de CARRERAS -----" >> "${LOG_020_ESTADISTICA}"

echo -e "\nNumero de carreras segun el dia:" >> "${LOG_020_ESTADISTICA}"
mysql-t --execute="SELECT SUM(dow_d) AS sum_d, SUM(dow_l) AS sum_l, SUM(dow_m) AS sum_m, SUM(dow_x) AS sum_x, SUM(dow_j) AS sum_j, SUM(dow_v) AS sum_v, SUM(dow_s) AS sum_s, SUM(dow_finde) AS sum_finde, SUM(dow_laborable) AS sum_laborable FROM datos_desa.tb_galgos_carreras_norm;" >> "${LOG_020_ESTADISTICA}"


echo -e "\n\n----- Analisis de GALGOS y CARRERAS -----" >> "${LOG_020_ESTADISTICA}"

echo -e "\nNumero MEDIO de GALGOS que corren en una CARRERA:" >> "${LOG_020_ESTADISTICA}"
mysql-tN --execute="SELECT count(DISTINCT id_carrera)/count(DISTINCT galgo_nombre) FROM datos_desa.tb_galgos_historico_norm;" >> "${LOG_020_ESTADISTICA}"
echo -e "\nNumero MEDIO de CARRERAS conocidas por galgo (ajustado en Constantes: semanas hacia atrás):" >> "${LOG_020_ESTADISTICA}"
mysql-tN --execute="SELECT AVG(num_carreras_por_galgo) AS avg_num_carreras_por_galgo FROM ( SELECT galgo_nombre, count(*) AS num_carreras_por_galgo FROM datos_desa.tb_galgos_historico_norm GROUP BY galgo_nombre ) dentro; " >> "${LOG_020_ESTADISTICA}"
echo -e "\nGalgos con mas de un entrenador conocido:" >> "${LOG_020_ESTADISTICA}"
mysql-tN --execute="SELECT galgo_nombre, count(DISTINCT entrenador) AS num_entrenadores FROM datos_desa.tb_galgos_historico_norm GROUP BY galgo_nombre HAVING num_entrenadores >= 2;" >> "${LOG_020_ESTADISTICA}"


####################################################################################################
echo -e "\n\n----------------- Analisis de REMARKS ---------------" >> "${LOG_020_ESTADISTICA}"

echo -e "Crd:" >> "${LOG_020_ESTADISTICA}"
mysql-t --execute="SELECT posicion, count(*) as contador FROM datos_desa.tb_galgos_historico WHERE remarks LIKE '%Crd%' GROUP BY posicion ORDER BY posicion ASC LIMIT 10;" >> "${LOG_020_ESTADISTICA}"

echo -e "Wide:" >> "${LOG_020_ESTADISTICA}"
mysql-t --execute="SELECT posicion, count(*) as contador FROM datos_desa.tb_galgos_historico WHERE remarks LIKE '%Wide%' GROUP BY posicion ORDER BY posicion ASC LIMIT 10;" >> "${LOG_020_ESTADISTICA}"

echo -e "RanOn:" >> "${LOG_020_ESTADISTICA}"
mysql-t --execute="SELECT posicion, count(*) as contador FROM datos_desa.tb_galgos_historico WHERE remarks LIKE '%RanOn%' GROUP BY posicion ORDER BY posicion ASC LIMIT 10;" >> "${LOG_020_ESTADISTICA}"

echo -e "Led:" >> "${LOG_020_ESTADISTICA}"
mysql-t --execute="SELECT posicion, count(*) as contador FROM datos_desa.tb_galgos_historico WHERE remarks LIKE '%Led%' GROUP BY posicion ORDER BY posicion ASC LIMIT 10;" >> "${LOG_020_ESTADISTICA}"

echo -e "AlwaysLed:" >> "${LOG_020_ESTADISTICA}"
mysql-t --execute="SELECT posicion, count(*) as contador FROM datos_desa.tb_galgos_historico WHERE remarks LIKE '%AlwaysLed%' GROUP BY posicion ORDER BY posicion ASC LIMIT 10;" >> "${LOG_020_ESTADISTICA}"

echo -e "Rls:" >> "${LOG_020_ESTADISTICA}"
mysql-t --execute="SELECT posicion, count(*) as contador FROM datos_desa.tb_galgos_historico WHERE remarks LIKE '%Rls%' GROUP BY posicion ORDER BY posicion ASC LIMIT 10;" >> "${LOG_020_ESTADISTICA}"

echo -e "Baulked:" >> "${LOG_020_ESTADISTICA}"
mysql-t --execute="SELECT posicion, count(*) as contador FROM datos_desa.tb_galgos_historico WHERE remarks LIKE '%Baulked%' GROUP BY posicion ORDER BY posicion ASC LIMIT 10;" >> "${LOG_020_ESTADISTICA}"

echo -e "Blk:" >> "${LOG_020_ESTADISTICA}"
mysql-t --execute="SELECT posicion, count(*) as contador FROM datos_desa.tb_galgos_historico WHERE remarks LIKE '%Blk%' GROUP BY posicion ORDER BY posicion ASC LIMIT 10;" >> "${LOG_020_ESTADISTICA}"

echo -e "ClearRun:" >> "${LOG_020_ESTADISTICA}"
mysql-t --execute="SELECT posicion, count(*) as contador FROM datos_desa.tb_galgos_historico WHERE remarks LIKE '%ClearRun%' GROUP BY posicion ORDER BY posicion ASC LIMIT 10;" >> "${LOG_020_ESTADISTICA}"

echo -e "Mid:" >> "${LOG_020_ESTADISTICA}"
mysql-t --execute="SELECT posicion, count(*) as contador FROM datos_desa.tb_galgos_historico WHERE remarks LIKE '%Mid%' GROUP BY posicion ORDER BY posicion ASC LIMIT 10;" >> "${LOG_020_ESTADISTICA}"

echo -e "SAw:" >> "${LOG_020_ESTADISTICA}"
mysql-t --execute="SELECT posicion, count(*) as contador FROM datos_desa.tb_galgos_historico WHERE remarks LIKE '%SAw%' GROUP BY posicion ORDER BY posicion ASC LIMIT 10;" >> "${LOG_020_ESTADISTICA}"

echo -e "Bmp:" >> "${LOG_020_ESTADISTICA}"
mysql-t --execute="SELECT posicion, count(*) as contador FROM datos_desa.tb_galgos_historico WHERE remarks LIKE '%Bmp%' GROUP BY posicion ORDER BY posicion ASC LIMIT 10;" >> "${LOG_020_ESTADISTICA}"

echo -e "\n------------------------------------------------------\n" >> "${LOG_020_ESTADISTICA}"

#####################################################################################################

echo -e $(date +"%T")" | 020 | Estadistica basica | FIN" >>$LOG_070




#!/bin/bash

echo -e "Modulo 005 - Informes y resultados finales"

PATH_INFORMES="/home/carloslinux/Desktop/INFORMES/"


#######################################################################################################################
################# Informe MOD005_001 ######
PATH_INFORME_001=${PATH_INFORMES}"Informe_001.txt"

echo "Informe 001" > $PATH_INFORME_001
echo "Empresas que más crecieron (>8% BRUTO) en ciertos periodos de CRISIS o BONANZA" >> $PATH_INFORME_001


#A.Limpieza
mysql -e "DROP TABLE IF EXISTS datos_desa.tb_mod005_001_a\W;"
mysql -e "DROP TABLE IF EXISTS datos_desa.tb_mod005_001_b\W;"


#B.Marcamos sólo los inicios y finales de periodos.
read -r -d '' CONSULTA <<- EOM
CREATE TABLE datos_desa.tb_mod005_001_a AS

SELECT ticker, date, close, marca 
FROM (

  SELECT ticker, date, (open+gap_close_open) as close, PE1.marca
  FROM datos_desa.tb_yf01 YF1 
  LEFT JOIN (select 'inicio' as marca, fecha_inicio FROM datos_desa.tb_periodos) PE1
  ON (YF1.date=PE1.fecha_inicio)

  UNION ALL

  SELECT ticker, date, (open+gap_close_open) as close, PE2.marca
  FROM datos_desa.tb_yf01 YF2
  LEFT JOIN (select 'fin' as marca, fecha_fin FROM datos_desa.tb_periodos) PE2
  ON (YF2.date=PE2.fecha_fin)
) juntos

WHERE marca IS NOT NULL;
EOM

echo -e $CONSULTA
mysql -e "${CONSULTA}"
sleep 2s

#C. Para cada periodo, guardamos la lista de valores ordenados por la diferencia DESC
read -r -d '' CONSULTA <<- EOM
CREATE TABLE datos_desa.tb_mod005_001_b AS

select cruce1.descripcion, cruce1.id_periodo, cruce1.ticker, cruce1.flag_subida, cruce1.precio_inicio, PRECIOS2.precio_fin,
CASE WHEN (precio_inicio=0) THEN 0 ELSE 100.0*(precio_fin - precio_inicio)/precio_inicio END as diferencia_porcentaje

FROM (
  SELECT PE.id_periodo,ticker, date, fecha_inicio, precio_inicio, fecha_fin, flag_subida, descripcion
  FROM datos_desa.tb_periodos PE
  LEFT JOIN (SELECT ticker, date, close AS precio_inicio FROM datos_desa.tb_mod005_001_a WHERE marca='inicio') PRECIOS1
  ON (PE.fecha_inicio=PRECIOS1.date)
) cruce1

LEFT JOIN (SELECT ticker, date, close AS precio_fin FROM datos_desa.tb_mod005_001_a WHERE marca='fin') PRECIOS2
ON (cruce1.fecha_fin=PRECIOS2.date AND cruce1.ticker=PRECIOS2.ticker)

ORDER BY id_periodo ASC, diferencia_porcentaje DESC\W;
EOM

echo -e $CONSULTA
mysql -e "${CONSULTA}"
sleep 2s

#D. Informe FINAL
mysql -t --execute="SELECT descripcion, id_periodo, ticker, CASE WHEN flag_subida=1 THEN 'alcista' ELSE 'bajista' END as tendencia_ibex, precio_inicio, precio_fin, diferencia_porcentaje FROM datos_desa.tb_mod005_001_b WHERE diferencia_porcentaje > 8 ORDER BY id_periodo DESC, diferencia_porcentaje DESC\W;" >> ${PATH_INFORME_001}


#######################################################################################################################
################# Análisis MOD005_002:  ######
PATH_INFORME_002=${PATH_INFORMES}"Informe_002.txt"

echo "Informe 002" > $PATH_INFORME_002
echo "En ciertos periodos cortos de CAIDAS más fuertes del IBEX (es decir, caídas de las grandes), ¿qué empresas subieron mas de un 3% BRUTO?" >> $PATH_INFORME_002


#A.Limpieza
mysql -e "DROP TABLE IF EXISTS datos_desa.tb_mod005_002_a\W;"
mysql -e "DROP TABLE IF EXISTS datos_desa.tb_mod005_002_b\W;"


#B.Marcamos sólo los inicios y finales de periodos.
read -r -d '' CONSULTA <<- EOM
CREATE TABLE datos_desa.tb_mod005_002_a AS

SELECT ticker, date, close, marca
FROM (

  SELECT ticker, date, (open+gap_close_open) as close, PE1.marca
  FROM datos_desa.tb_yf01 YF1 
  LEFT JOIN (select 'inicio' as marca, fecha_inicio FROM datos_desa.tb_periodos_fuertes_caidas_ibex) PE1
  ON (YF1.date=PE1.fecha_inicio)

  UNION ALL

  SELECT ticker, date, (open+gap_close_open) as close, PE2.marca
  FROM datos_desa.tb_yf01 YF2
  LEFT JOIN (select 'fin' as marca, fecha_fin FROM datos_desa.tb_periodos_fuertes_caidas_ibex) PE2
  ON (YF2.date=PE2.fecha_fin)
) juntos

WHERE marca IS NOT NULL\W;
EOM

echo -e $CONSULTA
mysql -e "${CONSULTA}"
sleep 2s

#C. Para cada periodo, guardamos la lista de valores ordenados por la diferencia DESC
read -r -d '' CONSULTA <<- EOM
CREATE TABLE datos_desa.tb_mod005_002_b AS

SELECT 
cruce1.id_periodo, cruce1.ticker, cruce1.precio_inicio, PRECIOS2.precio_fin,
CASE WHEN (precio_inicio=0) THEN 0 ELSE 100.0*(precio_fin - precio_inicio)/precio_inicio END as diferencia_porcentaje

FROM (
  SELECT PE.id_periodo,ticker, date, fecha_inicio, precio_inicio, fecha_fin
  FROM datos_desa.tb_periodos_fuertes_caidas_ibex PE
  LEFT JOIN (SELECT ticker, date, close AS precio_inicio FROM datos_desa.tb_mod005_002_a WHERE marca='inicio') PRECIOS1
  ON (PE.fecha_inicio=PRECIOS1.date)
) cruce1

LEFT JOIN (SELECT ticker, date, close AS precio_fin FROM datos_desa.tb_mod005_002_a WHERE marca='fin') PRECIOS2
ON (cruce1.fecha_fin=PRECIOS2.date AND cruce1.ticker=PRECIOS2.ticker)

ORDER BY id_periodo ASC, diferencia_porcentaje DESC\W;
EOM

echo -e $CONSULTA
mysql -e "${CONSULTA}"
sleep 2s

#D. Informe FINAL
mysql -t --execute="SELECT id_periodo, ticker, precio_inicio, precio_fin, diferencia_porcentaje FROM datos_desa.tb_mod005_002_b WHERE diferencia_porcentaje > 3 ORDER BY id_periodo DESC, diferencia_porcentaje DESC\W;" >> ${PATH_INFORME_002}



#######################################################################################################################
################# Análisis MOD005_003: Modelo predictivo SVC

#python3 '/home/carloslinux/Desktop/WORKSPACES/wksp_pycharm/python_poc_ml/informe_003/informe_003.py'






#***************************************************
# MAILS
#***********************************
cat "$PATH_INFORME_001" | mail -s "BOLSA Informe 001" carlosandresgarcia1986@gmail.com,fcacereslau@hotmail.com,luisandresgarcia@gmail.com
cat "$PATH_INFORME_002" | mail -s "BOLSA Informe 002" carlosandresgarcia1986@gmail.com,fcacereslau@hotmail.com,luisandresgarcia@gmail.com









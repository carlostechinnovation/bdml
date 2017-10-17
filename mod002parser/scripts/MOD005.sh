#!/bin/bash

echo -e "Modulo 005 - Informes y resultados finales"

PATH_INFORMES="/home/carloslinux/Desktop/INFORMES/"


#######################################################################################################################
################# Análisis MOD005_001: Las empresas empresas que más crecieron en los periodos de CRISIS o BONANZA ######
#A.Limpieza
mysql -u root --password=datos1986 --execute="DROP TABLE datos_desa.tb_mod005_001_a;"
mysql -u root --password=datos1986 --execute="DROP TABLE datos_desa.tb_mod005_001_b;"


#B.Marcamos sólo los inicios y finales de periodos.
read -r -d '' CONSULTA <<- EOM
CREATE TABLE datos_desa.tb_mod005_001_a AS

SELECT * 
FROM (

  SELECT ticker, date, close, PE1.marca
  FROM datos_desa.tb_yf01 YF1 
  LEFT JOIN (select 'inicio' as marca, fecha_inicio FROM datos_desa.tb_periodos) PE1
  ON (YF1.date=PE1.fecha_inicio)

  UNION ALL

  SELECT ticker, date, close, PE2.marca
  FROM datos_desa.tb_yf01 YF2
  LEFT JOIN (select 'fin' as marca, fecha_fin FROM datos_desa.tb_periodos) PE2
  ON (YF2.date=PE2.fecha_fin)
) juntos

WHERE marca IS NOT NULL;
EOM

mysql -u root --password=datos1986 --execute=${CONSULTA}


#C. Para cada periodo, guardamos la lista de valores ordenados por la diferencia DESC
read -r -d '' CONSULTA <<- EOM
CREATE TABLE datos_desa.tb_mod005_001_b AS

select 
cruce1.id_periodo, cruce1.ticker, cruce1.flag_subida, cruce1.desc, cruce1.precio_inicio, PRECIOS2.precio_fin,
CASE WHEN (precio_inicio=0) THEN 0 ELSE 100.0*(precio_fin - precio_inicio)/precio_inicio END as diferencia_porcentaje

FROM (
  SELECT PE.id_periodo,ticker, date, fecha_inicio, precio_inicio, fecha_fin, flag_subida, desc
  FROM datos_desa.tb_periodos PE
  LEFT JOIN (SELECT ticker, date, close AS precio_inicio FROM datos_desa.tb_mod005_001_a WHERE marca='inicio') PRECIOS1
  ON (PE.fecha_inicio=PRECIOS1.date)
) cruce1

LEFT JOIN (SELECT ticker, date, close AS precio_fin FROM datos_desa.tb_mod005_001_a WHERE marca='fin') PRECIOS2
ON (cruce1.fecha_fin=PRECIOS2.date AND cruce1.ticker=PRECIOS2.ticker)

ORDER BY id_periodo ASC, diferencia_porcentaje DESC;
EOM

mysql -u root --password=datos1986 --execute=${CONSULTA}


#D. Informe FINAL
mysql -u root --password=datos1986 -t --execute="SELECT id_periodo, ticker, CASE WHEN flag_subida=1 THEN 'alcista' ELSE 'bajista' END as tendencia_ibex, d, precio_inicio, precio_fin, diferencia_porcentaje FROM datos_desa.tb_mod005_001_b WHERE diferencia_porcentaje > 10;" > ${PATH_INFORMES}"001_mc_empresas_mas_crecientes_en_periodos_de_crisis_o_bonanza.txt"


#######################################################################################################################
################# Análisis MOD005_002:  ######






#######################################################################################################################
################# Análisis MOD005_003: En los periodos  (3-5 semanas) de caidas mas fuertes del ibex  (es decir, caidas de las grandes),  ¿qué empresas subieron?
































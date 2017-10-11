#!/bin/bash


PATH_OUTPUT="/home/carloslinux/Desktop/DATOS_BRUTO/mod003_poc.out"

curl 'https://finance.google.com/finance/getprices?q=GRF&x=BME&i=604800&p=40Y&f=d,c,v,k,o,h,l&df=cpct&auto=1&ts=1507570345714' > ${PATH_OUTPUT}


#################### GOOGLE FINANCE ######
mysql -u root --password=datos1986 --execute="SELECT distinct ticker FROM datos_desa.tb_gf01 WHERE ticker NOT LIKE '%.%' ORDER BY ticker;" > empresas_bme.out


########### Periodos de crisis y de bonanza (identificados por mi mirando el IBEX) ####
mysql -u root --password=datos1986 --execute="DROP TABLE datos_desa.tb_periodos;"

mysql -u root --password=datos1986 --execute="CREATE TABLE datos_desa.tb_periodos (id_periodo varchar(20), fecha_inicio INT, fecha_fin INT, flag_subida BOOLEAN, d varchar(30));"

mysql -u root --password=datos1986 --execute="INSERT INTO datos_desa.tb_periodos (id_periodo,fecha_inicio,fecha_fin,flag_subida,d) VALUES ('20060901-20070601',20060901,20070601,1,'burbuja_inmo_0607');"
mysql -u root --password=datos1986 --execute="INSERT INTO datos_desa.tb_periodos (id_periodo,fecha_inicio,fecha_fin,flag_subida,d) VALUES ('20080602-20090202',20080602,20090202,0,'crisis_financiera_0809');"
mysql -u root --password=datos1986 --execute="INSERT INTO datos_desa.tb_periodos (id_periodo,fecha_inicio,fecha_fin,flag_subida,d) VALUES ('20110201-20120502',20110201,20120502,0,'crisis_deuda_publica_1112');"
mysql -u root --password=datos1986 --execute="INSERT INTO datos_desa.tb_periodos (id_periodo,fecha_inicio,fecha_fin,flag_subida,d) VALUES ('20130603-20150202',20130603,20150202,1,'bonanza_1315');"
mysql -u root --password=datos1986 --execute="INSERT INTO datos_desa.tb_periodos (id_periodo,fecha_inicio,fecha_fin,flag_subida,d) VALUES ('20150803-20160201',20150803,20160201,0,'crisis_15');"
mysql -u root --password=datos1986 --execute="INSERT INTO datos_desa.tb_periodos (id_periodo,fecha_inicio,fecha_fin,flag_subida,d) VALUES ('20160701-20170502',20160701,20170502,1,'bonanza_1617');"
mysql -u root --password=datos1986 --execute="INSERT INTO datos_desa.tb_periodos (id_periodo,fecha_inicio,fecha_fin,flag_subida,d) VALUES ('20170601-20171004',20170601,20171004,0,'crisis_17');"

mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_periodos LIMIT 100;"


################# Análisis MOD003_001: Las 10 empresas empresas que más crecieron en los periodos de CRISIS ######
#A.Limpieza
DROP TABLE datos_desa.tb_mod003_001_a;
DROP TABLE datos_desa.tb_mod003_001_b;

#B.Marcamos sólo los inicios y finales de periodos.

CREATE TABLE datos_desa.tb_mod003_001_a AS

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

#C. Para cada periodo, guardamos la lista de valores ordenados por la diferencia DESC
CREATE TABLE datos_desa.tb_mod003_001_b AS

select 
cruce1.id_periodo, cruce1.ticker, cruce1.flag_subida, cruce1.d, cruce1.fecha_inicio, cruce1.precio_inicio, cruce1.fecha_fin, PRECIOS2.precio_fin,
CASE WHEN (precio_inicio=0) THEN 0 ELSE 100.0*(precio_fin - precio_inicio)/precio_inicio END as diferencia_porcentaje

FROM (
  SELECT PE.id_periodo,ticker, date, fecha_inicio, precio_inicio, fecha_fin, flag_subida, d
  FROM datos_desa.tb_periodos PE
  LEFT JOIN (SELECT ticker, date, close AS precio_inicio FROM datos_desa.tb_mod003_001_a WHERE marca='inicio') PRECIOS1
  ON (PE.fecha_inicio=PRECIOS1.date)
) cruce1

LEFT JOIN (SELECT ticker, date, close AS precio_fin FROM datos_desa.tb_mod003_001_a WHERE marca='fin') PRECIOS2
ON (cruce1.fecha_fin=PRECIOS2.date AND cruce1.ticker=PRECIOS2.ticker)

ORDER BY id_periodo ASC, diferencia_porcentaje DESC;

#D. Informe FINAL
mysql -u root --password=datos1986 -t --execute="SELECT * FROM datos_desa.tb_mod003_001_b WHERE diferencia_porcentaje > 10;" > periodos_incremento_precios.txt

#################################################################################






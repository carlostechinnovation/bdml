#!/bin/bash

set -x

echo -e "Modulo 002A - Parsear datos"

PATH_DIR_IN="/home/carloslinux/Desktop/DATOS_BRUTO/bolsa/"
PATH_DIR_OUT="/home/carloslinux/Desktop/DATOS_LIMPIO/bolsa/"
PATH_JAR="/root/git/bdml/mod002parser/target/mod002parser-jar-with-dependencies.jar"
PATH_SCRIPTS="/root/git/bdml/mod002parser/scripts/bolsa/"

TAG_BOE="BOE"
TAG_GF="GOOGLEFINANCE"
TAG_BM="BOLSAMADRID"
TAG_INE="INE"
TAG_DM="DATOSMACRO"


FILE_SENTENCIAS_CREATE_TABLE=${PATH_DIR_OUT}"sentencias_create_table"



######## PARAMETROS: DIA ##################################
if [ $# -eq 0 ]
  then
    echo "ERROR Parametro de entrada vacio. Debes indicar el dia (BOE) que quieres procesar!"
    exit -1
fi

TAG_DIA_DESCARGA=${1}
dia_semana=${TAG_DIA_DESCARGA:0:1}
anio=${TAG_DIA_DESCARGA:1:4}
mes=${TAG_DIA_DESCARGA:5:2}
dia=${TAG_DIA_DESCARGA:7:2}
echo 'ID de ejecucion parseado = $anio/$mes/$dia'



########## CREATE TABLES #############
echo -e "Crear tablas SQL (IF NOT EXISTS)"
rm $FILE_SENTENCIAS_CREATE_TABLE
java -jar ${PATH_JAR} "02" "$FILE_SENTENCIAS_CREATE_TABLE"
SENTENCIAS_CREATE_TABLE=$(cat ${FILE_SENTENCIAS_CREATE_TABLE})
echo -e ${SENTENCIAS_CREATE_TABLE}
mysql -u root --password=datos1986 --execute="$SENTENCIAS_CREATE_TABLE" >&1


######## PREPROCESAR DATOS DE UN DIA ##############
echo -e "Procesar un dia (borro posibles cargas previas de ese dia y las cargo)"
java -jar ${PATH_JAR} "03" ${DIA}


for GFindice in {1..6}
do
   mysql -u root --password=datos1986 --execute="DELETE FROM datos_desa.tb_gf0${GFindice} WHERE tag_dia=${dia}; LOAD DATA LOCAL INFILE '/home/carloslinux/Desktop/DATOS_LIMPIO/bolsa/${dia}_GOOGLEFINANCE_0${GFindice}_OUT' INTO TABLE datos_desa.tb_gf0${GFindice} FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n' IGNORE 1 LINES\W;" >&1
done


for BMindice in {1..6}
do
   mysql -u root --password=datos1986 --execute="DELETE FROM datos_desa.tb_bm0${BMindice} WHERE tag_dia=${dia}; LOAD DATA LOCAL INFILE '/home/carloslinux/Desktop/DATOS_LIMPIO/bolsa/${dia}_BOLSAMADRID_0${BMindice}_OUT' INTO TABLE datos_desa.tb_bm0${BMindice} FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n' IGNORE 1 LINES\W;" >&1
done


mysql -u root --password=datos1986 --execute="DELETE FROM datos_desa.tb_ine WHERE tag_dia=${dia}; LOAD DATA LOCAL INFILE '/home/carloslinux/Desktop/DATOS_LIMPIO/bolsa/${dia}_INE_01_OUT' INTO TABLE datos_desa.tb_ine FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n' IGNORE 1 LINES\W;" >&1

for DMindice in 0{1..9} {10..15}
do
   mysql -u root --password=datos1986 --execute="DELETE FROM datos_desa.tb_dm${DMindice} WHERE tag_dia=${dia}; LOAD DATA LOCAL INFILE '/home/carloslinux/Desktop/DATOS_LIMPIO/bolsa/${dia}_DATOSMACRO_${DMFindice}_OUT' INTO TABLE datos_desa.tb_dm${DMindice} FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n' IGNORE 1 LINES\W;" >&1
done



###### YAHOO FINANCE (Solo ejecuto los lunes, porque realmente son datos historicos) (se podria ejecutar cada dia...) #########

#${PATH_SCRIPTS}MOD002A_YF.sh "2005"
#${PATH_SCRIPTS}MOD002A_YF.sh "2006"
#${PATH_SCRIPTS}MOD002A_YF.sh "2007"
#${PATH_SCRIPTS}MOD002A_YF.sh "2008"
#${PATH_SCRIPTS}MOD002A_YF.sh "2009"
#${PATH_SCRIPTS}MOD002A_YF.sh "2010"
#${PATH_SCRIPTS}MOD002A_YF.sh "2011"
#${PATH_SCRIPTS}MOD002A_YF.sh "2012"
#${PATH_SCRIPTS}MOD002A_YF.sh "2013"
#${PATH_SCRIPTS}MOD002A_YF.sh "2014"
#${PATH_SCRIPTS}MOD002A_YF.sh "2015"
#${PATH_SCRIPTS}MOD002A_YF.sh "2016"


#Una vez a la semana
if [ ${dia_semana} = "L" ]
then
    ${PATH_SCRIPTS}MOD002A_YF.sh "${anio}"
fi


##############################################################
############### TABLAS AUXILIARES UTILES #####################
##############################################################


########### Periodos de crisis y de bonanza (identificados por mi mirando el IBEX) ####
mysql -u root --password=datos1986 --execute="DROP TABLE IF EXISTS datos_desa.tb_stg_periodos;"
mysql -u root --password=datos1986 --execute="CREATE TABLE datos_desa.tb_stg_periodos (id_periodo varchar(20), fecha_inicio INT, fecha_fin INT, flag_subida BOOLEAN, descripcion varchar(30));"
mysql -u root --password=datos1986 --execute="INSERT INTO datos_desa.tb_stg_periodos (id_periodo,fecha_inicio,fecha_fin,flag_subida,descripcion) VALUES ('20060901-20070601', 20060901, 20070601, 1,'burbuja_inmo_0607');"
mysql -u root --password=datos1986 --execute="INSERT INTO datos_desa.tb_stg_periodos (id_periodo,fecha_inicio,fecha_fin,flag_subida,descripcion) VALUES ('20080602-20090202',20080602, 20090202, 0,'crisis_financiera_0809');"
mysql -u root --password=datos1986 --execute="INSERT INTO datos_desa.tb_stg_periodos (id_periodo,fecha_inicio,fecha_fin,flag_subida,descripcion) VALUES ('20110201-20120502',20110201, 20120502, 0,'crisis_deuda_publica_1112');"
mysql -u root --password=datos1986 --execute="INSERT INTO datos_desa.tb_stg_periodos (id_periodo,fecha_inicio,fecha_fin,flag_subida,descripcion) VALUES ('20130603-20150202', 20130603, 20150202, 1, 'bonanza_1315');"
mysql -u root --password=datos1986 --execute="INSERT INTO datos_desa.tb_stg_periodos (id_periodo,fecha_inicio,fecha_fin,flag_subida,descripcion) VALUES ('20150803-20160201', 20150803, 20160201, 0, 'crisis_15');"
mysql -u root --password=datos1986 --execute="INSERT INTO datos_desa.tb_stg_periodos (id_periodo,fecha_inicio,fecha_fin,flag_subida,descripcion) VALUES ('20160701-20170502', 20160701, 20170502, 1, 'bonanza_1617');"
mysql -u root --password=datos1986 --execute="INSERT INTO datos_desa.tb_stg_periodos (id_periodo,fecha_inicio,fecha_fin,flag_subida,descripcion) VALUES ('20170601-20171004', 20170601, 20171004, 0, 'crisis_17');"
mysql -u root --password=datos1986 --execute="DROP TABLE IF EXISTS datos_desa.tb_periodos;"
mysql -u root --password=datos1986 --execute="CREATE TABLE datos_desa.tb_periodos AS SELECT SP.id_periodo, SP.fecha_inicio, SP.fecha_fin, SP.flag_subida, SP.descripcion, DATEDIFF(SP.fecha_fin,SP.fecha_inicio) AS dias_dif FROM datos_desa.tb_stg_periodos SP LIMIT 20;"

########### Periodos cortos de FUERTES caidas en el IBEX ####
mysql -u root --password=datos1986 --execute="DROP TABLE IF EXISTS datos_desa.tb_stg_periodos_fuertes_caidas_ibex;"
mysql -u root --password=datos1986 --execute="CREATE TABLE datos_desa.tb_stg_periodos_fuertes_caidas_ibex (id_periodo varchar(20), fecha_inicio INT, fecha_fin INT);"
mysql -u root --password=datos1986 --execute="INSERT INTO datos_desa.tb_stg_periodos_fuertes_caidas_ibex (id_periodo,fecha_inicio,fecha_fin) VALUES ('20080515-20080615',20080515,20080615);"
mysql -u root --password=datos1986 --execute="INSERT INTO datos_desa.tb_stg_periodos_fuertes_caidas_ibex (id_periodo,fecha_inicio,fecha_fin) VALUES ('20081001-20081030',20081001,20081030);"
mysql -u root --password=datos1986 --execute="INSERT INTO datos_desa.tb_stg_periodos_fuertes_caidas_ibex (id_periodo,fecha_inicio,fecha_fin) VALUES ('20100415-20100515',20100415,20100515);"
mysql -u root --password=datos1986 --execute="INSERT INTO datos_desa.tb_stg_periodos_fuertes_caidas_ibex (id_periodo,fecha_inicio,fecha_fin) VALUES ('20110715-20110830',20110715,20110830);"
mysql -u root --password=datos1986 --execute="INSERT INTO datos_desa.tb_stg_periodos_fuertes_caidas_ibex (id_periodo,fecha_inicio,fecha_fin) VALUES ('20120401-20120530',20120401,20120530);"
mysql -u root --password=datos1986 --execute="INSERT INTO datos_desa.tb_stg_periodos_fuertes_caidas_ibex (id_periodo,fecha_inicio,fecha_fin) VALUES ('20150801-20150930',20150801,20150930);"
mysql -u root --password=datos1986 --execute="INSERT INTO datos_desa.tb_stg_periodos_fuertes_caidas_ibex (id_periodo,fecha_inicio,fecha_fin) VALUES ('20151215-20160209',20151215,20160209);"
mysql -u root --password=datos1986 --execute="INSERT INTO datos_desa.tb_stg_periodos_fuertes_caidas_ibex (id_periodo,fecha_inicio,fecha_fin) VALUES ('20170715-20170901',20170715,20170901);"
mysql -u root --password=datos1986 --execute="DROP TABLE IF EXISTS datos_desa.tb_periodos_fuertes_caidas_ibex;"
mysql -u root --password=datos1986 --execute="CREATE TABLE datos_desa.tb_periodos_fuertes_caidas_ibex AS SELECT SP.id_periodo, SP.fecha_inicio, SP.fecha_fin, DATEDIFF(SP.fecha_fin,SP.fecha_inicio) AS dias_dif FROM datos_desa.tb_stg_periodos_fuertes_caidas_ibex SP LIMIT 20;"


#################### Empresas de Google Finance #########
mysql -u root --password=datos1986 --execute="SELECT distinct ticker FROM datos_desa.tb_gf01 WHERE ticker NOT LIKE '%.%' ORDER BY ticker;" > empresas_bme.out

#################### Empresas de Yahoo Finance #########
mysql -u root --password=datos1986 --execute="SELECT CONCAT(tabla.ticker,'.MC') FROM ( SELECT distinct ticker FROM datos_desa.tb_gf01 WHERE ticker NOT LIKE '%.%' ORDER BY ticker ) tabla;" > "/root/git/bdml/mod002parser/scripts/bolsa/empresas_yahoo_finance.in"



echo  -e "Modulo 002A - FIN"





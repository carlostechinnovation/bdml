#!/bin/bash

read -r -d '' CONSULTA <<- EOM
  This is line 1.
    This is line 2.
    Line 3.
EOM


echo $CONSULTA


########### BASE DE DATOS: básico ######
#sudo service mysql status
#sudo service mysql start
#sudo service mysql stop

#mysql -u root --password=datos1986 --execute="CREATE DATABASE datos_desa;"
#mysql -u root --password=datos1986 --execute="CREATE DATABASE datos_pro;"


############ EJEMPLO: Load fichero CSV completo #####
#mysql -u root --password=datos1986 --execute="CREATE TABLE datos_desa.tb_gf01_borrar ( amd int, accion varchar(255), valor FLOAT(7,2));" >&1
#mysql -u root --password=datos1986 --execute="LOAD DATA LOCAL INFILE '/home/carloslinux/Desktop/DATOS_LIMPIO/test.csv' INTO TABLE datos_desa.tb_gf01_borrar FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n' IGNORE 1 LINES;" >&1
#mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_gf01_borrar LIMIT 10;" >&1
#mysql -u root --password=datos1986 --execute="DROP TABLE datos_desa.tb_gf01_borrar;" >&1
###########################


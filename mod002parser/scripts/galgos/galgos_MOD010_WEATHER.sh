#!/bin/bash

source "/home/carloslinux/git/bdml/mod002parser/scripts/galgos/funciones.sh"

#Borrar log
rm -f ${LOG_010_WEATHER}


echo -e $(date +"%T")" | 010_WEATHER | Tiempo | INICIO" >>$LOG_070
echo -e "MOD010_WEATHER --> LOG = "${LOG_010_WEATHER}

###########################################################################
echo -e $(date +"%T")" Creando tabla de ESTADIOS..." 2>&1 1>>${LOG_010_WEATHER}

read -d '' CONSULTA_TABLA_ESTADIOS <<- EOF
select DISTINCT(track) AS estadios_extraidos FROM datos_desa.tb_galgos_carreras ORDER BY track ASC LIMIT 5;
select count(DISTINCT track) AS num_estadios_extraidos from datos_desa.tb_galgos_carreras LIMIT 5;

DROP TABLE IF EXISTS datos_desa.tb_galgos_estadios;

CREATE TABLE IF NOT EXISTS datos_desa.tb_galgos_estadios (track varchar(40) NOT NULL, accuweather_url varchar(200) DEFAULT NULL, PRIMARY KEY (track)) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- En la URL, la FECHA tiene el formato m/d/aaaa (ej: 9/1/2018)

INSERT INTO datos_desa.tb_galgos_estadios (track, accuweather_url) VALUES ('Belle Vue', 'https://www.accuweather.com/en/gb/manchester/m15-6/january-weather/329260?monyr=FECHA&view=table');
INSERT INTO datos_desa.tb_galgos_estadios (track, accuweather_url) VALUES ('Brighton', 'https://www.accuweather.com/en/gb/brighton-and-hove/bn2-1/september-weather/2520246?monyr=FECHA&view=table');
INSERT INTO datos_desa.tb_galgos_estadios (track, accuweather_url) VALUES ('Central Park', 'https://www.accuweather.com/en/gb/sittingbourne/me10-4/september-weather/323733?monyr=FECHA&view=table');
INSERT INTO datos_desa.tb_galgos_estadios (track, accuweather_url) VALUES ('Crayford', 'https://www.accuweather.com/en/gb/bexley/da16-1/september-weather/323573?monyr=FECHA&view=table');
INSERT INTO datos_desa.tb_galgos_estadios (track, accuweather_url) VALUES ('Doncaster', 'https://www.accuweather.com/en/gb/stainforth/dn7-5/september-weather/709170?monyr=FECHA&view=table');
INSERT INTO datos_desa.tb_galgos_estadios (track, accuweather_url) VALUES ('Harlow', 'https://www.accuweather.com/en/gb/harlow/cm20-1/september-weather/328076?monyr=FECHA&view=table');
INSERT INTO datos_desa.tb_galgos_estadios (track, accuweather_url) VALUES ('Henlow', 'https://www.accuweather.com/en/gb/stondon/sg16-6/september-weather/2524991?monyr=FECHA&view=table');
INSERT INTO datos_desa.tb_galgos_estadios (track, accuweather_url) VALUES ('Hove', 'https://www.accuweather.com/en/gb/brighton-and-hove/bn2-1/september-weather/2520246?monyr=FECHA&view=table');
INSERT INTO datos_desa.tb_galgos_estadios (track, accuweather_url) VALUES ('Kinsley', 'https://www.accuweather.com/en/gb/kinsley/wf9-5/september-weather/2522693?monyr=FECHA&view=table');
INSERT INTO datos_desa.tb_galgos_estadios (track, accuweather_url) VALUES ('Monmore', 'https://www.accuweather.com/en/gb/wolverhampton/wv1-4/september-weather/326975?monyr=FECHA&view=table');
INSERT INTO datos_desa.tb_galgos_estadios (track, accuweather_url) VALUES ('Monmore Green', 'https://www.accuweather.com/en/gb/wolverhampton/wv1-4/september-weather/326975?monyr=FECHA&view=table');
INSERT INTO datos_desa.tb_galgos_estadios (track, accuweather_url) VALUES ('Newcastle', 'https://www.accuweather.com/en/gb/newcastle-upon-tyne/ne2-4/september-weather/329683?monyr=FECHA&view=table');
INSERT INTO datos_desa.tb_galgos_estadios (track, accuweather_url) VALUES ('Nottingham', 'https://www.accuweather.com/en/gb/nottingham/ng1-7/september-weather/330088?monyr=FECHA&view=table');
INSERT INTO datos_desa.tb_galgos_estadios (track, accuweather_url) VALUES ('Pelaw Grange', 'https://www.accuweather.com/en/gb/durham/dh1-1/september-weather/323093?monyr=FECHA&view=table');
INSERT INTO datos_desa.tb_galgos_estadios (track, accuweather_url) VALUES ('Perry Barr', 'https://www.accuweather.com/en/gb/perry-barr/b42-2/september-weather/321760?monyr=FECHA&view=table');
INSERT INTO datos_desa.tb_galgos_estadios (track, accuweather_url) VALUES ('Peterborough', 'https://www.accuweather.com/en/gb/peterborough/pe1-2/september-weather/330350?monyr=FECHA&view=table');
INSERT INTO datos_desa.tb_galgos_estadios (track, accuweather_url) VALUES ('Poole', 'https://www.accuweather.com/en/gb/poole/bh15-1/september-weather/330357?monyr=FECHA&view=table');
INSERT INTO datos_desa.tb_galgos_estadios (track, accuweather_url) VALUES ('Romford', 'https://www.accuweather.com/en/gb/romford/rm1-4/september-weather/328302?monyr=FECHA&view=table');
INSERT INTO datos_desa.tb_galgos_estadios (track, accuweather_url) VALUES ('Shawfield', 'https://www.accuweather.com/en/gb/rutherglen/g42-0/september-weather/323171?monyr=FECHA&view=table');
INSERT INTO datos_desa.tb_galgos_estadios (track, accuweather_url) VALUES ('Sheffield', 'https://www.accuweather.com/en/gb/sheffield/s1-2/september-weather/326914?monyr=FECHA&view=table');
INSERT INTO datos_desa.tb_galgos_estadios (track, accuweather_url) VALUES ('Sunderland', 'https://www.accuweather.com/en/gb/sunderland/sr1-3/september-weather/708899?monyr=FECHA&view=table');
INSERT INTO datos_desa.tb_galgos_estadios (track, accuweather_url) VALUES ('Swindon', 'https://www.accuweather.com/en/gb/blunsdon-st-andrew/sn25-2/september-weather/716621?monyr=FECHA&view=table');
INSERT INTO datos_desa.tb_galgos_estadios (track, accuweather_url) VALUES ('Towcester', 'https://www.accuweather.com/en/gb/towcester/nn12-6/september-weather/330016?monyr=FECHA&view=table');
INSERT INTO datos_desa.tb_galgos_estadios (track, accuweather_url) VALUES ('Yarmouth', 'https://www.accuweather.com/en/gb/west-caister/nr30-5/september-weather/2525823?monyr=FECHA&view=table');
INSERT INTO datos_desa.tb_galgos_estadios (track, accuweather_url) VALUES ('Youghal', 'https://www.accuweather.com/en/ie/youghal/207631/september-weather/207631?monyr=FECHA&view=table');

select count(*) AS num_estadios_predefinidos from datos_desa.tb_galgos_estadios LIMIT 10;
EOF

echo -e "\n$CONSULTA_TABLA_ESTADIOS" 2>&1 1>>${LOG_010_WEATHER}
mysql -t --execute="$CONSULTA_TABLA_ESTADIOS"  2>&1 1>>${LOG_010_WEATHER}
echo -e "\nComprobar que todos los estadios extraidos (de las carreras pasadas y futuras) estan dentro de los predefinidos..." 2>&1 1>>${LOG_010_WEATHER}

###########################################################################
echo -e $(date +"%T")" Creando tabla de WEATHER_FECHAS..." 2>&1 1>>${LOG_010_WEATHER}

read -d '' CONSULTA_TABLA_WEATHER_FECHAS <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_weather_fechas;

CREATE TABLE IF NOT EXISTS datos_desa.tb_weather_fechas (
anio INT NOT NULL, 
mes INT NOT NULL, 
fecha varchar(40) NOT NULL, 
PRIMARY KEY (anio, mes)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- En la URL, la FECHA tiene el formato m/d/aaaa (ej: 9/1/2018)

-- INSERT INTO datos_desa.tb_weather_fechas (anio,mes,fecha) VALUES (2018, 1, '1/1/2018');
-- INSERT INTO datos_desa.tb_weather_fechas (anio,mes,fecha) VALUES (2018, 2, '2/1/2018');
-- INSERT INTO datos_desa.tb_weather_fechas (anio,mes,fecha) VALUES (2018, 3, '3/1/2018');
-- INSERT INTO datos_desa.tb_weather_fechas (anio,mes,fecha) VALUES (2018, 4, '4/1/2018');
-- INSERT INTO datos_desa.tb_weather_fechas (anio,mes,fecha) VALUES (2018, 5, '5/1/2018');
-- INSERT INTO datos_desa.tb_weather_fechas (anio,mes,fecha) VALUES (2018, 6, '6/1/2018');
-- INSERT INTO datos_desa.tb_weather_fechas (anio,mes,fecha) VALUES (2018, 7, '7/1/2018');
-- INSERT INTO datos_desa.tb_weather_fechas (anio,mes,fecha) VALUES (2018, 8, '8/1/2018');
-- INSERT INTO datos_desa.tb_weather_fechas (anio,mes,fecha) VALUES (2018, 9, '9/1/2018');
INSERT INTO datos_desa.tb_weather_fechas (anio,mes,fecha) VALUES (2018, 10, '10/1/2018');
INSERT INTO datos_desa.tb_weather_fechas (anio,mes,fecha) VALUES (2018, 11, '11/1/2018');
INSERT INTO datos_desa.tb_weather_fechas (anio,mes,fecha) VALUES (2018, 12, '12/1/2018');
INSERT INTO datos_desa.tb_weather_fechas (anio,mes,fecha) VALUES (2019, 1, '1/1/2019');
INSERT INTO datos_desa.tb_weather_fechas (anio,mes,fecha) VALUES (2019, 2, '2/1/2019');
-- INSERT INTO datos_desa.tb_weather_fechas (anio,mes,fecha) VALUES (2019, 3, '3/1/2019');
-- INSERT INTO datos_desa.tb_weather_fechas (anio,mes,fecha) VALUES (2019, 4, '4/1/2019');
-- INSERT INTO datos_desa.tb_weather_fechas (anio,mes,fecha) VALUES (2019, 5, '5/1/2019');
-- INSERT INTO datos_desa.tb_weather_fechas (anio,mes,fecha) VALUES (2019, 6, '6/1/2019');
-- INSERT INTO datos_desa.tb_weather_fechas (anio,mes,fecha) VALUES (2019, 7, '7/1/2019');
-- INSERT INTO datos_desa.tb_weather_fechas (anio,mes,fecha) VALUES (2019, 8, '8/1/2019');
-- INSERT INTO datos_desa.tb_weather_fechas (anio,mes,fecha) VALUES (2019, 9, '9/1/2019');
-- INSERT INTO datos_desa.tb_weather_fechas (anio,mes,fecha) VALUES (2019, 10, '10/1/2019');
-- INSERT INTO datos_desa.tb_weather_fechas (anio,mes,fecha) VALUES (2019, 11, '11/1/2019');
-- INSERT INTO datos_desa.tb_weather_fechas (anio,mes,fecha) VALUES (2019, 12, '12/1/2019');

SELECT * FROM datos_desa.tb_weather_fechas LIMIT 5;
EOF

echo -e "\n$CONSULTA_TABLA_WEATHER_FECHAS" 2>&1 1>>${LOG_010_WEATHER}
mysql -t --execute="$CONSULTA_TABLA_WEATHER_FECHAS"  2>&1 1>>${LOG_010_WEATHER}


###########################################################################
echo -e $(date +"%T")" Creando tabla de WEATHER_ESTADIOS_FECHAS (WEAM)..." 2>&1 1>>${LOG_010_WEATHER}
echo -e $(date +"%T")" Insertando en WEATHER_ESTADIOS_FECHAS (WEAM) las combinaciones que todavia no hayan sido descargadas..." 2>&1 1>>${LOG_010_WEATHER}

read -d '' CONSULTA_TABLA_WEATHER_ESTADIOS_FECHAS <<- EOF

-- Weather Estadios anio mes
-- Solo la creamos una vez en la historia. Iremos metiendo solo aquella info que nueva, pero mantenemos la ya conocida.
-- DROP TABLE IF EXISTS datos_desa.tb_galgos_weam;

CREATE TABLE IF NOT EXISTS datos_desa.tb_galgos_weam (
estadio varchar(40) NOT NULL,
anio INT NOT NULL, 
mes INT NOT NULL, 
url_descarga_fecha varchar(1000) NOT NULL,
descargado BOOLEAN,
PRIMARY KEY (estadio,anio,mes)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


INSERT INTO datos_desa.tb_galgos_weam (estadio,anio,mes,url_descarga_fecha,descargado) 

SELECT D.* FROM (

SELECT estadio, anio, mes, 
REPLACE(url_descarga, 'FECHA', fecha) AS url_descarga_fecha,
false AS descargado

FROM(

SELECT 
track AS estadio,

concat('wget --header=\\"User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_0) AppleWebKit/600.1.17 (KHTML, like Gecko) Version/8.0 Safari/600.1.17\\" ', ' -c -O \"${PATH_BRUTO_WEATHER}', anio,'_',mes, '_', track, '.html\" -o \"${PATH_LOGS}temp_weather_estadios.log\" ', accuweather_url) AS url_descarga,

B.anio, B.mes, B.fecha

FROM datos_desa.tb_galgos_estadios
RIGHT OUTER JOIN (SELECT  B_dentro.* FROM datos_desa.tb_weather_fechas B_dentro) B
ON (1=1)
) AS C
) AS D

ON DUPLICATE KEY UPDATE 
estadio=D.estadio,
anio=D.anio,
mes=D.mes,
url_descarga_fecha=D.url_descarga_fecha,
descargado=D.descargado;
;

select descargado, count(*) AS num_weam FROM datos_desa.tb_galgos_weam GROUP BY descargado;

EOF

echo -e "\n$CONSULTA_TABLA_WEATHER_ESTADIOS_FECHAS" 2>&1 1>>${LOG_010_WEATHER}
mysql -t --execute="$CONSULTA_TABLA_WEATHER_ESTADIOS_FECHAS"  2>&1 1>>${LOG_010_WEATHER}

###########################################################################
echo -e $(date +"%T")" Creando fichero de COMANDOS para DESCARGAR datos BRUTOS de WEATHER_ESTADIOS_FECHAS (WEAM)..." 2>&1 1>>${LOG_010_WEATHER}

rm -f ${SH_010_WEATHER_COMANDOS} 2>&1 1>>${LOG_010_WEATHER}

read -d '' CONSULTA_COMANDOS_DESCARGAS_WEAM <<- EOF
select concat('sleep 1s; ', url_descarga_fecha) AS espera_y_comando FROM datos_desa.tb_galgos_weam WHERE descargado=0;
EOF
echo -e "\n$CONSULTA_COMANDOS_DESCARGAS_WEAM" 2>&1 1>>${LOG_010_WEATHER}
mysql -Ns --execute="$CONSULTA_COMANDOS_DESCARGAS_WEAM" 2>&1 1>>${SH_010_WEATHER_COMANDOS}

chmod 777 ${SH_010_WEATHER_COMANDOS}

echo -e "\nComandos para descargar los WEATHER pendientes en: ${SH_010_WEATHER_COMANDOS}" 2>&1 1>>${LOG_010_WEATHER}

###########################################################################
echo -e $(date +"%T")" Crear directorio de datos BRUTOS para WEAM (por si no existe)..." 2>&1 1>>${LOG_010_WEATHER}
rm -f "${PATH_BRUTO_WEATHER}*" #Borrar posibles ficheros preexistentes
mkdir "${PATH_BRUTO_WEATHER}" 2>&1 1>>${LOG_010_WEATHER}


###########################################################################
echo -e $(date +"%T")" Ejecutando comandos de descarga de datos BRUTOS..." 2>&1 1>>${LOG_010_WEATHER}
${SH_010_WEATHER_COMANDOS} 2>&1 1>>${LOG_010_WEATHER}

############# Parsear el contenido y meterlo en una tabla: estadio, anio, mes, dia, datos-meteorologicos #######
echo -e $(date +"%T")" Parseando datos BRUTOS y metiendolos en la tabla WEAM con datos meteorológicos..." 2>&1 1>>${LOG_010_WEATHER}

echo -e $(date +"%T")" Generando fichero de SENTENCIAS SQL (varios INSERT INTO): ${FILE_WEATHER_LIMPIO_INSERT_INTO}" 2>&1 1>>${LOG_010_WEATHER}
#Entrada: folder (contiene las paginas web en bruto)
#Salida: fichero con sentencias INSERT INTO, separadas por ';' para ejecutarlas secuencialmente
rm -f ${FILE_WEATHER_LIMPIO_INSERT_INTO}
echo -e ";" > ${FILE_WEATHER_LIMPIO_INSERT_INTO} #Crear fichero vacio
java -jar ${PATH_JAR} "GALGOS_02_WEATHER" "${PATH_BRUTO_WEATHER}" "${FILE_WEATHER_LIMPIO_INSERT_INTO}" 2>&1 1>>${LOG_010_WEATHER}


read -d '' CONSULTA_TABLA_WEATHER_ESTADIOS_AMD <<- EOF

-- Weather Estadios anio mes dia
-- Solo la creamos una vez en la historia. Iremos metiendo solo aquella info que nueva, pero mantenemos la ya conocida.
-- DROP TABLE IF EXISTS datos_desa.tb_galgos_weamd;

CREATE TABLE IF NOT EXISTS datos_desa.tb_galgos_weamd (
estadio varchar(40) NOT NULL,
anio INT NOT NULL, 
mes INT NOT NULL,
dia INT NOT NULL,
pasada BOOLEAN,
tempMin INT,
tempMax INT,
histAvgMin INT,
histAvgMax INT,
texto varchar(80),
rain BOOLEAN,
wind BOOLEAN,
cloud BOOLEAN,
sun BOOLEAN,
snow BOOLEAN,
PRIMARY KEY (estadio,anio,mes,dia)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
EOF

echo -e "\n$CONSULTA_TABLA_WEATHER_ESTADIOS_AMD" 2>&1 1>>${LOG_010_WEATHER}
mysql -t --execute="$CONSULTA_TABLA_WEATHER_ESTADIOS_AMD"  2>&1 1>>${LOG_010_WEATHER}


echo -e "\nEjecutando sentencias SQL (insertan la info meteorologica de los dias + pone 'descargado=true' en los meses completos para evitar descargar lo ya conocido) ..." 2>&1 1>>${LOG_010_WEATHER}

while IFS="" read -r linea || [ -n "${linea}" ]
do
  consultar "${linea}" "${LOG_010_WEATHER}" "-tN"
done < "${FILE_WEATHER_LIMPIO_INSERT_INTO}"


echo -e "\nContenido de la tabla WEAMD (weather estadio anio-mes-dia):" 2>&1 1>>${LOG_010_WEATHER}
mysql -t --execute="SELECT anio, mes, pasada, count(*) AS num_weamd FROM datos_desa.tb_galgos_weamd GROUP BY anio ASC, mes ASC, pasada ASC;"  2>&1 1>>${LOG_010_WEATHER}


##########################################
echo -e $(date +"%T")" | 010_WEATHER | Tiempo | FIN" >>$LOG_070




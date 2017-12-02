#!/bin/bash

#mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_galgos_carreras\W;" > "./tb_galgos_carreras.csv"
#mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_galgos_posiciones_en_carreras\W;" > "./tb_galgos_posiciones_en_carreras.csv"
#mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_galgos_historico\W;" > "./tb_galgos_historico.csv"
#mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_galgos_agregados\W;" > "./tb_galgos_agregados.csv"



PATH_CARPETA="/home/carloslinux/Desktop/DATOS_BRUTO/galgos/"
PATH_SCRIPTS="/home/carloslinux/Desktop/CODIGOS/workspace_java/bdml/mod002parser/scripts/galgos/"
PATH_JAR="/home/carloslinux/Desktop/CODIGOS/workspace_java/bdml/mod002parser/target/mod002parser-jar-with-dependencies.jar"


java -jar ${PATH_JAR} "07" "${PATH_CARPETA}galgos_iniciales"








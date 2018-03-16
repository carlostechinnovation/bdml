#!/bin/bash

source "/root/git/bdml/mod002parser/scripts/galgos/funciones.sh"

#Script principal COORDINADOR de todas las tareas. Lo que no quiera ejecutar, lo comento.


#limpiar logs
rm -f "/home/carloslinux/Desktop/LOGS/log4j-application.log"
rm -f $LOG_MASTER
rm -f $LOG_070


##########################################
echo -e $(date +"%T")" | MASTER | Coordinador | INICIO" >>$LOG_070
echo -e "Tiempo de 5 segundos para que abras los logs (tailf)..."
#sleep 5s

echo -e "-------- "$(date +"%T")" ---------- GALGOS - Cadena de procesos ------------" >>$LOG_MASTER
echo -e "Ruta script="${PATH_SCRIPTS}
echo -e "Ruta log (coordinador)="${LOG_MASTER}

echo -e $(date +"%T")" Descarga de datos BRUTOS (planificado con CRON)" >>$LOG_MASTER
rm -f "$FLAG_BB_DESCARGADO_OK" #fichero FLAG que indica que el proceso hijo ha terminado (el padre lo mirará cuando le haga falta en el módulo predictivo de carreras FUTURAS).
#${PATH_SCRIPTS}'galgos_MOD010_paralelo_BB.sh'  >>$LOG_MASTER ## FUTURAS - BETBRIGHT (ASYNC?? Poner & en tal caso) ##
${PATH_SCRIPTS}'galgos_MOD010.sh'  >>$LOG_MASTER #Sportium


echo -e $(date +"%T")" Limpieza y normalizacion de tablas brutas (Sportium y Betbright)" >>$LOG_MASTER
${PATH_SCRIPTS}'galgos_MOD011.sh' >>$LOG_MASTER
${PATH_SCRIPTS}'galgos_MOD012.sh' >>$LOG_MASTER

echo -e $(date +"%T")" Analisis de datos BRUTOS: ESTADISTICA BASICA" >>$LOG_MASTER
${PATH_SCRIPTS}'galgos_MOD020.sh' >>$LOG_MASTER

echo -e $(date +"%T")" Generador de COLUMNAS ELABORADAS" >>$LOG_MASTER
${PATH_SCRIPTS}'galgos_MOD030.sh' >>$LOG_MASTER


echo -e $(date +"%T")" **** Análisis de SUBGRUPOS y GRUPOS_SP ****" >>$LOG_MASTER
resetTablaRentabilidades #Reseteando tabla de rentabilidades
echo -e $(date +"%T")" Para cada SUBGRUPO, calculamos FILTRADAS + DATASETS + INTELIGENCIA ARTIFICIAL..." >>$LOG_MASTER
analizarScoreSobreSubgrupos "$LOG_MASTER"
echo -e $(date +"%T")" Informe de rentabilidades (usar para poner DINERO solo en los grupos_sp indicados): ${INFORME_RENTABILIDADES}" >>$LOG_MASTER
CASOS_SUFICIENTES="400"
consultar_sobreescribirsalida "SELECT * FROM datos_desa.tb_rentabilidades WHERE rentabilidad_porciento > 10 AND casos > $CASOS_SUFICIENTES ORDER BY rentabilidad_porciento DESC LIMIT 10;" "${INFORME_RENTABILIDADES}" ""
SUBGRUPO_GANADOR=$( mysql -u root --password=datos1986  --execute="SELECT subgrupo FROM datos_desa.tb_rentabilidades WHERE rentabilidad_porciento > 10 AND casos > 100 ORDER BY rentabilidad_porciento DESC LIMIT 10;" )
echo -e $(date +"%T")" Subgrupo con más rentabilidad (y con suficientes casos: CASOS > $CASOS_SUFICIENTES ) = ${SUBGRUPO_GANADOR}" >>$LOG_MASTER


#Debug (Borrar)
#SUBGRUPO_GANADOR="TOTAL"


echo -e $(date +"%T")" Para el SUBGRUPO GANADOR, calculamos FILTRADAS + DATASETS + INTELIGENCIA ARTIFICIAL (el modelo estará preparado sólo para el SUBGRUPO GANADOR)..." >>$LOG_MASTER
${PATH_SCRIPTS}'galgos_MOD035.sh' "" "" "" "$SUBGRUPO_GANADOR" >>$LOG_MASTER #llama a 036 y 037
${PATH_SCRIPTS}'galgos_MOD040.sh' "$SUBGRUPO_GANADOR" >>$LOG_MASTER

echo -e $(date +"%T")" PREDICCION SOBRE EL FUTURO (resultados) sobre dataset FUTURO de sólo el subgrupo ganador" >>$LOG_MASTER
${PATH_SCRIPTS}'galgos_MOD050.sh' "$SUBGRUPO_GANADOR" >>$LOG_MASTER

echo -e $(date +"%T")" Análisis posterior" >>$LOG_MASTER
${PATH_SCRIPTS}'galgos_MOD060_caso_endtoend.sh' >>$LOG_MASTER
${PATH_SCRIPTS}'galgos_MOD060_tablas.sh' >>$LOG_MASTER

echo -e $(date +"%T")" Análisis TIC de la ejecucion" >>$LOG_MASTER
${PATH_SCRIPTS}'galgos_MOD070.sh' >>$LOG_MASTER

#echo -e $(date +"%T")" Limpieza final (tablas pasadas, pero no las futuras)" >>$LOG_MASTER
#limpieza

##########################################
echo -e $(date +"%T")" | MASTER | Coordinador | FIN" >>$LOG_070



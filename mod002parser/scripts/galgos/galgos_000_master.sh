#!/bin/bash

source "/home/carloslinux/git/bdml/mod002parser/scripts/galgos/funciones.sh"

#Script principal COORDINADOR de todas las tareas. Lo que no quiera ejecutar, lo comento.

#limpiar logs
rm -f "/home/carloslinux/Desktop/LOGS/log4j-application.log"
rm -f $LOG_MASTER
rm -f $LOG_070


############################################################################################
echo -e $(date +"%T")" | MASTER | Coordinador | INICIO" >>$LOG_070

echo -e "-------- "$(date +"%T")" ---------- GALGOS - Cadena de procesos ------------" >>$LOG_MASTER
echo -e "Ruta script="${PATH_SCRIPTS}
echo -e "Ruta log (coordinador)="${LOG_MASTER}


#echo -e $(date +"%T")" ANALISIS de CONFIG para Descarga de datos BRUTOS (puntualmente, no siempre)" >>$LOG_MASTER
#${PATH_SCRIPTS}'galgos_MOD010_ANALISIS_PARAMS.sh'  >>$LOG_MASTER #Sportium-CONFIG


#echo -e $(date +"%T")" Descarga de datos BRUTOS (planificado con CRON)" >>$LOG_MASTER
#rm -f "$FLAG_BB_DESCARGADO_OK" #fichero FLAG que indica que el proceso hijo ha terminado (el padre lo mirará cuando le haga falta en el módulo predictivo de carreras FUTURAS).
#${PATH_SCRIPTS}'galgos_MOD010_paralelo_BB.sh'  >>$LOG_MASTER ## FUTURAS - BETBRIGHT (ASYNC?? Poner & en tal caso) ##
#${PATH_SCRIPTS}'galgos_MOD010.sh' "" >>$LOG_MASTER #Sportium

#echo -e $(date +"%T")" Insertando filas artificiales FUTURAS en datos BRUTOS" >>$LOG_MASTER
#${PATH_SCRIPTS}'galgos_MOD010_FUT.sh'  >>$LOG_MASTER

#echo -e $(date +"%T")" Limpieza y normalizacion de tablas brutas (Sportium y Betbright)" >>$LOG_MASTER
#${PATH_SCRIPTS}'galgos_MOD011.sh' >>$LOG_MASTER
#${PATH_SCRIPTS}'galgos_MOD012.sh' >>$LOG_MASTER

echo -e $(date +"%T")" Exportacion externa de tablas brutas" >>$LOG_MASTER
${PATH_SCRIPTS}'galgos_MOD019.sh' >>$LOG_MASTER


echo -e $(date +"%T")" Analisis de datos BRUTOS: ESTADISTICA BASICA" >>$LOG_MASTER
${PATH_SCRIPTS}'galgos_MOD020.sh' >>$LOG_MASTER

echo -e $(date +"%T")" Generador de COLUMNAS ELABORADAS" >>$LOG_MASTER
${PATH_SCRIPTS}'galgos_MOD030.sh' >>$LOG_MASTER

echo -e $(date +"%T")" ANALISIS de cada SUBGRUPO y sus GRUPOS_SP ************************" >>$LOG_MASTER
analisisRentabilidadesPorSubgrupos >>$LOG_MASTER
SUBGRUPO_GANADOR_LINEAS=$(cat "$SUBGRUPO_GANADOR_FILE" | wc -l)
if [ "$SUBGRUPO_GANADOR_LINEAS" -ne "1" ]
  then
    echo "ERROR AL CALCULAR SUBGRUPO_GANADOR. Revisar fichero ( $SUBGRUPO_GANADOR_FILE ). Salimos con error controlado." >>$LOG_MASTER
    echo -e $(date +"%T")" | MASTER | Coordinador (ERROR: filas de SUBGRUPO_GANADOR_FILE) | FIN" >>$LOG_070
    exit -1
fi

#SUBGRUPO_GANADOR="TOTAL" #####DEBUG
SUBGRUPO_GANADOR=$(cat $SUBGRUPO_GANADOR_FILE)

if [ -z $SUBGRUPO_GANADOR ]
  then
    echo "No hay NINGUN subgrupo con SUFICIENTES casos y rentabilidad. Salimos con error controlado." >>$LOG_MASTER
    echo -e $(date +"%T")" | MASTER | Coordinador (ERROR controlador: NINGUN SUBGRUPO) | FIN" >>$LOG_070
    exit -1
fi
if [[ $SUBGRUPO_GANADOR = *"mysql"* ]]; then
  echo "HAY ALGO RARO. Saliendo...\nLa cadena es:\n"$SUBGRUPO_GANADOR >>$LOG_MASTER
  echo -e $(date +"%T")" | MASTER | Coordinador (ERROR controlador: datos raros) | FIN" >>$LOG_070
  exit -1
fi

echo -e "\n\n -------- SUBGRUPO_GANADOR=$SUBGRUPO_GANADOR ------------\n\n" >>$LOG_MASTER
echo -e "\n\n -------- SUBGRUPO_GANADOR=$SUBGRUPO_GANADOR ------------\n\n" >>$LOG_070


echo -e $(date +"%T")" Para el SUBGRUPO GANADOR, reentrenamos el modelo con un gran DS-TTV, con TODO el PASADO conocido (IMPORTANTE: el MODELO estará preparado sólo para el SUBGRUPO GANADOR)..." >>$LOG_MASTER
${PATH_SCRIPTS}'galgos_MOD038_ds_pasados.sh' "$SUBGRUPO_GANADOR" >>$LOG_MASTER
${PATH_SCRIPTS}'galgos_MOD045.sh' "$SUBGRUPO_GANADOR" >>$LOG_MASTER

echo -e $(date +"%T")" PREDICCION SOBRE EL FUTURO (resultados) sobre dataset FUTURO de sólo el subgrupo ganador" >>$LOG_MASTER
${PATH_SCRIPTS}'galgos_MOD050.sh' "$SUBGRUPO_GANADOR" >>$LOG_MASTER

echo -e $(date +"%T")" Análisis posterior" >>$LOG_MASTER
${PATH_SCRIPTS}'galgos_MOD060_caso_endtoend.sh' "$SUBGRUPO_GANADOR" "" >>$LOG_MASTER
${PATH_SCRIPTS}'galgos_MOD060_caso_endtoend.sh' "$SUBGRUPO_GANADOR" "FUTURA" >>$LOG_MASTER
${PATH_SCRIPTS}'galgos_MOD060_tablas.sh' >>$LOG_MASTER
${PATH_SCRIPTS}'galgos_MOD061.sh' "$SUBGRUPO_GANADOR" >>$LOG_MASTER #Exportacion a ficheros EXTERNAL


echo -e $(date +"%T")"Informe TIC: "$LOG_070 >>$LOG_MASTER

#echo -e $(date +"%T")" Guardando datos PRODUCTIVOS: semillas, tablas brutas, tablas economicas, informes..." >>$LOG_MASTER
#${PATH_SCRIPTS}'galgos_MOD080.sh' >>$LOG_MASTER


#echo -e $(date +"%T")" Limpieza MASIVA final (tablas pasadas, pero no las futuras)" >>$LOG_MASTER
#limpieza

echo -e $(date +"%T")" POSTERIORI: ejecutar el script 099 indicando el nombre del informe con comandos." >>$LOG_MASTER
echo -e ${PATH_SCRIPTS}'galgos_MOD099.sh' "$INFORME_PREDICCIONES_COMANDOS" "$SUBGRUPO_GANADOR" >>$LOG_MASTER #EXTRAE resultado REAL a un fichero EXTERNAL y calcula rentabilidad (score real)

echo -e $(date +"%T")" | MASTER | Coordinador | FIN" >>$LOG_070



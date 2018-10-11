#!/bin/bash

source "/home/carloslinux/git/bdml/mod002parser/scripts/galgos/funciones.sh"

#Script principal COORDINADOR de todas las tareas. Lo que no quiera ejecutar, lo comento.

ID_EJECUCION=$( date '+%Y%m%d%H%M%S' )
echo -e "ID_EJECUCION = "${ID_EJECUCION}


#limpiar logs
rm -f "/home/carloslinux/Desktop/LOGS/log4j-application.log"
rm -f $LOG_MASTER
rm -f $LOG_070


############################################################################################

echo -e $(date +"%T")" | MASTER | Coordinador | INICIO" >>$LOG_070

echo -e "-------- "$(date +"%T")" ---------- GALGOS - Cadena de procesos ------------" >>$LOG_MASTER
echo -e "Ruta script="${PATH_SCRIPTS}
echo -e "Ruta log (coordinador)="${LOG_MASTER}

crearTablaTiposSp #tabla estatica


##########echo -e $(date +"%T")" ANALISIS de CONFIG para Descarga de datos BRUTOS (puntualmente, no siempre)" >>$LOG_MASTER
##########${PATH_SCRIPTS}'galgos_MOD010_ANALISIS_PARAMS.sh'  >>$LOG_MASTER #Sportium-CONFIG

echo -e $(date +"%T")" Descarga de datos BRUTOS (planificado con CRON)" >>$LOG_MASTER
###########rm -f "$FLAG_BB_DESCARGADO_OK" #fichero FLAG que indica que el proceso hijo ha terminado (el padre lo mirará cuando le haga falta en el módulo predictivo de carreras FUTURAS).
###########${PATH_SCRIPTS}'galgos_MOD010_paralelo_BB.sh'  >>$LOG_MASTER ## FUTURAS - BETBRIGHT (ASYNC?? Poner & en tal caso) ##

#${PATH_SCRIPTS}'galgos_MOD010.sh' "" >>$LOG_MASTER  #Sportium (semillas futuras) + GBGB (historicos)
#echo -e $(date +"%T")" Insertando filas artificiales FUTURAS en datos BRUTOS" >>$LOG_MASTER
#${PATH_SCRIPTS}'galgos_MOD010_FUT.sh'  >>$LOG_MASTER
${PATH_SCRIPTS}'galgos_MOD010_WEATHER.sh'  >>$LOG_MASTER # WHEATHER de pasado y futuro (para enriquecer despues)

echo -e $(date +"%T")" Limpieza y normalizacion de tablas brutas (Sportium y Betbright)" >>$LOG_MASTER
${PATH_SCRIPTS}'galgos_MOD011.sh' >>$LOG_MASTER
${PATH_SCRIPTS}'galgos_MOD012.sh' >>$LOG_MASTER

echo -e $(date +"%T")" Exportacion externa de tablas brutas" >>$LOG_MASTER
${PATH_SCRIPTS}'galgos_MOD019.sh' >>$LOG_MASTER

echo -e $(date +"%T")" Analisis de datos BRUTOS: ESTADISTICA BASICA" >>$LOG_MASTER
${PATH_SCRIPTS}'galgos_MOD020.sh' >>$LOG_MASTER


echo -e "Borrando tablas LIMPIAS para ahorrar espacio..." >> "${LOG_MASTER}"
mysql -tN --execute="DROP TABLE IF EXISTS datos_desa.tb_galgos_carreras_LIM;" 2>&1 1>>"${LOG_MASTER}"
mysql -tN --execute="DROP TABLE IF EXISTS datos_desa.tb_galgos_posiciones_en_carreras_LIM;" 2>&1 1>>"${LOG_MASTER}"
mysql -tN --execute="DROP TABLE IF EXISTS datos_desa.tb_galgos_historico_LIM;" 2>&1 1>>"${LOG_MASTER}"
mysql -tN --execute="DROP TABLE IF EXISTS datos_desa.tb_galgos_agregados_LIM;" 2>&1 1>>"${LOG_MASTER}"


echo -e $(date +"%T")" Generador de COLUMNAS ELABORADAS" >>$LOG_MASTER
${PATH_SCRIPTS}'galgos_MOD030.sh' >>$LOG_MASTER


################## Bucle para obtener SUBGRUPO GANADOR (y SUBGRUPOS GANADORES secundarios) ############################################################

echo -e "\n"$(date +"%T")" ANALISIS de cada SUBGRUPO y sus GRUPOS_SP ************************\n" >>$LOG_MASTER

analisisRentabilidadesPorSubgrupos >>$LOG_MASTER

SUBGRUPO_GANADOR_LINEAS=$(cat "$SUBGRUPO_GANADOR_FILE" | wc -l)
if [ "$SUBGRUPO_GANADOR_LINEAS" -ne "1" ]
  then
    echo "ERROR AL CALCULAR SUBGRUPO_GANADOR. Revisar fichero ( $SUBGRUPO_GANADOR_FILE ). Salimos con error controlado." >>$LOG_MASTER
    echo -e $(date +"%T")" | MASTER | Coordinador (ERROR: filas de SUBGRUPO_GANADOR_FILE) | FIN" >>$LOG_070
    exit -1
fi

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


################## SUBGRUPO GANADOR: entrenar modelo grande y predecir futuro. Informes. ####################################################################

echo -e "\n\n\n"$(date +"%T")" Para el SUBGRUPO GANADOR, reentrenamos el modelo con un gran DS-TTV, con TODO el PASADO conocido (IMPORTANTE: el MODELO estará preparado sólo para el SUBGRUPO GANADOR)...\n" >>$LOG_MASTER

${PATH_SCRIPTS}'galgos_MOD038_ds_pasados.sh' "$SUBGRUPO_GANADOR" "S" >>$LOG_MASTER
${PATH_SCRIPTS}'galgos_MOD045.sh' "$SUBGRUPO_GANADOR" "S" >>$LOG_MASTER

echo -e $(date +"%T")" PREDICCION SOBRE EL FUTURO (resultados) sobre dataset FUTURO de sólo el subgrupo ganador" >>$LOG_MASTER
mysql -t --execute="DROP TABLE IF EXISTS datos_desa.tb_fut_1st_final_riesgo;"  2>&1 1>>$LOG_050 #Capa 050
${PATH_SCRIPTS}'galgos_MOD050.sh' "$SUBGRUPO_GANADOR" "S" "" >>$LOG_MASTER

echo -e "\n"$(date +"%T")" POSTERIORI: tras 2 días, debes ejecutar el script 099 indicando el nombre del informe con comandos." >>$LOG_MASTER
COMANDO_099="${PATH_SCRIPTS}galgos_MOD099.sh $INFORME_PREDICCIONES_COMANDOS $SUBGRUPO_GANADOR $ID_EJECUCION"
echo -e "\n\n"${COMANDO_099}"\n\n" >>$LOG_MASTER
echo -e "\n\n"${COMANDO_099}"\n\n" >>$LOG_070
#${COMANDO_099} >>$LOG_MASTER # (solo se puede hacer si son datos de hace unos dias) EXTRAE resultado REAL a un fichero EXTERNAL y calcula rentabilidad (score real)

echo -e $(date +"%T")" Análisis posterior" >>$LOG_MASTER
${PATH_SCRIPTS}'galgos_MOD060_caso_endtoend.sh' "$SUBGRUPO_GANADOR" "" >>$LOG_MASTER
${PATH_SCRIPTS}'galgos_MOD060_caso_endtoend.sh' "$SUBGRUPO_GANADOR" "FUTURA" >>$LOG_MASTER
${PATH_SCRIPTS}'galgos_MOD060_tablas.sh' >>$LOG_MASTER
${PATH_SCRIPTS}'galgos_MOD061.sh' "$SUBGRUPO_GANADOR" "$ID_EJECUCION" >>$LOG_MASTER #Exportacion a ficheros EXTERNAL

echo -e $(date +"%T")"Informe TIC: "$LOG_070 >>$LOG_MASTER

echo -e $(date +"%T")" Guardando datos PRODUCTIVOS: semillas, tablas brutas, tablas economicas, informes..." >>$LOG_MASTER
${PATH_SCRIPTS}'galgos_MOD080.sh' "$ID_EJECUCION" "S" >>$LOG_MASTER


################## SUBGRUPOS GANADORES: para cada uno, entrenar modelo grande y predecir futuro. Informes CONJUNTOS. ####################################################################
echo -e "\n\n\n****************************************************************************************************************************" >>$LOG_MASTER
echo -e "****************************************************************************************************************************\n\n" >>$LOG_MASTER
echo -e "\n\n\n"$(date +"%T")" **************** Para CADA uno de los SUGRUPOS GANADORES, repetimos el bucle, escribiendo a otros informes aparte..." >>$LOG_MASTER

echo -e "\n\n -------- SUBGRUPOS_GANADORES_FILE=$SUBGRUPOS_GANADORES_FILE ------------\n\n" >>$LOG_MASTER
echo -e "\n\n -------- SUBGRUPOS_GANADORES_FILE=$SUBGRUPOS_GANADORES_FILE ------------\n\n" >>$LOG_070

rm -f "$INFORME_BUCLE_PREDICCIONES" #Capa 050
rm -f "$INFORME_BUCLE_PREDICCIONES_CON_PERDEDORES" #Capa 050
rm -f "$INFORME_BUCLE_PREDICCIONES_COMANDOS" #Capa 050
mysql -t --execute="DROP TABLE IF EXISTS datos_desa.tb_fut_1st_final_riesgo;"  2>&1 1>>$LOG_050 #Capa 050


while IFS="" read -r SUB_GAN_AUX || [ -n "${SUB_GAN_AUX}" ]
do
    echo -e "*******************SUB_GAN_AUX=${SUB_GAN_AUX}*******************" >>$LOG_MASTER
    SUB_GAN=$( echo "${SUB_GAN_AUX}" | cut -d'|' -f1 )
    echo -e "*******************SUB_GAN=${SUB_GAN}*******************" >>$LOG_MASTER
  
    ${PATH_SCRIPTS}'galgos_MOD038_ds_pasados.sh' "$SUB_GAN" "N" >>$LOG_MASTER
    ${PATH_SCRIPTS}'galgos_MOD045.sh' "$SUB_GAN" "N" >>$LOG_MASTER

    echo -e $(date +"%T")" PREDICCION SOBRE EL FUTURO (resultados) sobre dataset FUTURO de sólo el SUB_GAN = ${SUB_GAN}" >>$LOG_MASTER
    ${PATH_SCRIPTS}'galgos_MOD050.sh' "$SUB_GAN" "N" "${SUB_GAN_AUX}" >>$LOG_MASTER

    echo -e "\n"$(date +"%T")" POSTERIORI: tras 2 días, debes ejecutar el script 099 indicando el nombre del informe con comandos." >>$LOG_MASTER
    COMANDO_099="${PATH_SCRIPTS}galgos_MOD099.sh $INFORME_BUCLE_PREDICCIONES_COMANDOS 'BUCLE' $ID_EJECUCION"
    echo -e "\n"${COMANDO_099}"\n" >>$LOG_MASTER
    echo -e "\n"${COMANDO_099}"\n" >>$LOG_070
    #######${COMANDO_099} >>$LOG_MASTER # (solo se puede hacer si son datos de hace unos dias) EXTRAE resultado REAL a un fichero EXTERNAL y calcula rentabilidad (score real)

    echo -e $(date +"%T")" Guardando datos PRODUCTIVOS: semillas, tablas brutas, tablas economicas, informes..." >>$LOG_MASTER
    ${PATH_SCRIPTS}'galgos_MOD080.sh' "$ID_EJECUCION" "N" >>$LOG_MASTER


done < ${SUBGRUPOS_GANADORES_FILE}

echo -e "\n\n ************************** FIN DE BUCLE de subgrupos ganadores **********************************\n\n" >>$LOG_MASTER


##################################################################################################################
#Informe ML-040-045-050  ----> El orden del INFORME sera: 040, 045(ganador)+045's(bucle), 050(ganador)+050's(bucle)
rm -f "${INFORME_ML_040_045_050}"
echo -e "\n\n####################### 040 ###################################\n\n" >>"${INFORME_ML_040_045_050}"
cat "${LOG_ML}" | grep "${DELIMITADOR_R_OUT}" |awk -F"${DELIMITADOR_R_OUT}" '{print $2}'  2>&1 1>>"${INFORME_ML_040_045_050}"
echo -e "\n\n####################### 045 ###################################\n\n" >>"${INFORME_ML_040_045_050}"
cat "${LOG_045}" | grep "${DELIMITADOR_R_OUT}" |awk -F"${DELIMITADOR_R_OUT}" '{print $2}'  2>&1 1>>"${INFORME_ML_040_045_050}"
echo -e "\n\n####################### 050 ###################################\n\n" >>"${INFORME_ML_040_045_050}"
cat "${LOG_050}" | grep "${DELIMITADOR_R_OUT}" |awk -F"${DELIMITADOR_R_OUT}" '{print $2}'  2>&1 1>>"${INFORME_ML_040_045_050}"


#echo -e $(date +"%T")" Limpieza MASIVA final de las tablas que NO son el subgrupo ganador (tablas pasadas, pero no las futuras)" >>$LOG_MASTER
#limpieza "$SUBGRUPO_GANADOR"
rm -f ${PATH_LOGS}temp*

##################################################################################################################

echo -e $(date +"%T")" | MASTER | Coordinador | FIN" >>$LOG_070
echo -e $(date +"%T")" | MASTER | Coordinador | FIN" >>$LOG_MASTER



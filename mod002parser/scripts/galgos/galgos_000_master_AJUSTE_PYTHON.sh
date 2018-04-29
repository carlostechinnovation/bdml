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



echo -e $(date +"%T")" ANALISIS de cada SUBGRUPO y sus GRUPOS_SP ************************" >>$LOG_MASTER
#analisisRentabilidadesPorSubgruposBORRAR >>$LOG_MASTER
SUBGRUPO_GANADOR_LINEAS=$(cat "$SUBGRUPO_GANADOR_FILE" | wc -l)
if [ "$SUBGRUPO_GANADOR_LINEAS" -ne "1" ]
  then
    echo "ERROR AL CALCULAR SUBGRUPO_GANADOR. Revisar fichero ( $SUBGRUPO_GANADOR_FILE ). Salimos con error controlado." >>$LOG_MASTER
    echo -e $(date +"%T")" | MASTER | Coordinador (ERROR: filas de SUBGRUPO_GANADOR_FILE) | FIN" >>$LOG_070
    exit -1
fi




echo -e "\n"$(date +"%T")" POSTERIORI: tras 2 días, ejecutar el script 099 indicando el nombre del informe con comandos." >>$LOG_MASTER
${PATH_SCRIPTS}'galgos_MOD099.sh' "$INFORME_PREDICCIONES_COMANDOS" "$SUBGRUPO_GANADOR" >>$LOG_MASTER #EXTRAE resultado REAL a un fichero EXTERNAL y calcula rentabilidad (score real)


TAG="$SUBGRUPO_GANADOR"




#------------- RENTABILIDAD POSTERIORI (tras 2 dias)----------------------------------------

FILE_TEMP_PRED="./temp_MOD099_num_predicciones_posteriori"
rm -f ${FILE_TEMP_PRED}
mysql -N --execute="SELECT count(*) AS contador FROM datos_desa.tb_galgos_fut_combinada;" > ${FILE_TEMP_PRED}
numero_predicciones_posteriori=$(cat ${FILE_TEMP_PRED})


FILE_TEMP="./temp_MOD099_rentabilidad_posteriori"
rm -f ${FILE_TEMP}
mysql -N --execute="SELECT ROUND( 100.0 * SUM(ganado)/SUM(gastado) , 2) AS rentabilidad FROM ( SELECT 1 AS gastado, CASE WHEN real_posicion=1 THEN cast(numerador AS decimal(2,0)) / cast(denominador AS decimal(2,0)) ELSE 0 END AS ganado FROM ( SELECT numero1, real_posicion, real_sp, substring_index(real_sp,'/',1) as numerador, substring_index(real_sp,'/',-1) as denominador FROM datos_desa.tb_galgos_fut_combinada ) d ) fuera;" > ${FILE_TEMP}
rentabilidad_posteriori=$( cat ${FILE_TEMP})


FILE_TEMP="./temp_MOD099_num_aciertos_posteriori"
mysql -N --execute="SELECT count(*) FROM datos_desa.tb_galgos_fut_combinada WHERE real_posicion=1" > ${FILE_TEMP}
numero_aciertos_posteriori=$( cat ${FILE_TEMP})


COBERTURA_posteriori=$(echo "scale=2; $numero_aciertos_posteriori / $numero_predicciones_posteriori" | bc -l)

####SALIDA

MENSAJE="FUTURO_POSTERIORI --> TAG=${TAG}  cobertura=${COBERTURA_posteriori}  rentabilidad=${rentabilidad_posteriori}"

echo -e "\n\n\n\n" 2>&1 1>>${LOG_099}
echo -e "$MENSAJE" 2>&1 1>>${LOG_099}
echo -e "\n\n\n\n" 2>&1 1>>${LOG_099}

#-----------------------------------------------------


echo -e $(date +"%T")" | MASTER | Coordinador | FIN" >>$LOG_070



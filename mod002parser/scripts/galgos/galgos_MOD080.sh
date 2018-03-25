#!/bin/bash

source "/root/git/bdml/mod002parser/scripts/galgos/funciones.sh"

######################## PARAMETROS ############
if [ "$#" -ne 1 ]; then
    echo " Numero de parametros incorrecto!!!" 2>&1 1>>${LOG_080}
fi

TAG="${1}"

#### Limpiar LOG ###
rm -f $LOG_080

echo -e $(date +"%T")" | 080 | Guardar info PRODUCTIVA | INICIO" >>$LOG_070
echo -e "MOD080 --> LOG = "${LOG_080}

####################################################

ID_EJECUCION=$(date +%Y%m%d%H%M%S)
echo -e "Generando el IDENTIFICADOR UNICO de esta ejecucion..." >>$LOG_080
echo -e "ID_EJECUCION="$ID_EJECUCION >>$LOG_080
echo -e "ID_EJECUCION="$ID_EJECUCION

PREFIJO="PRO_"$ID_EJECUCION"_"

echo -e "Guardando SEMILLAS con ID_EJECUCION..." >>$LOG_080
mysql --login-path=local --execute="CREATE TABLE datos_desa.${PREFIJO}tb_cg_semillas_sportium AS SELECT * FROM datos_desa.tb_cg_semillas_sportium;" 2>&1 1>>${LOG_080}

#pendiente (Semillas Betbright)


echo -e "Guardando TABLAS BRUTAS con ID_EJECUCION..." >>$LOG_080
mysql --login-path=local --execute="CREATE TABLE datos_desa.${PREFIJO}tb_galgos_carreras AS SELECT * FROM datos_desa.tb_galgos_carreras;" 2>&1 1>>${LOG_080}
mysql --login-path=local --execute="CREATE TABLE datos_desa.${PREFIJO}tb_galgos_posiciones_en_carreras AS SELECT * FROM datos_desa.tb_galgos_posiciones_en_carreras;" 2>&1 1>>${LOG_080}
mysql --login-path=local --execute="CREATE TABLE datos_desa.${PREFIJO}tb_galgos_historico AS SELECT * FROM datos_desa.tb_galgos_historico;" 2>&1 1>>${LOG_080}
mysql --login-path=local --execute="CREATE TABLE datos_desa.${PREFIJO}tb_galgos_agregados AS SELECT * FROM datos_desa.tb_galgos_agregados;" 2>&1 1>>${LOG_080}


echo -e "Guardando TABLAS ECONOMICAS con ID_EJECUCION..." >>$LOG_080
mysql --login-path=local --execute="CREATE TABLE datos_desa.${PREFIJO}datos_desa.tb_rentabilidades AS SELECT * FROM datos_desa.datos_desa.tb_rentabilidades;" 2>&1 1>>${LOG_080}


echo -e "Guardando INFORMES con ID_EJECUCION..." >>$LOG_080
cp 'INFORME_CONFIG_010.txt' '${PATH_INFORMES}${PREFIJO}INFORME_CONFIG_010.txt'
cp 'INFORME_PREDICCIONES.txt' '${PATH_INFORMES}${PREFIJO}INFORME_PREDICCIONES.txt'
cp 'INFORME_RENTABILIDADES.txt' '${PATH_INFORMES}${PREFIJO}INFORME_RENTABILIDADES.txt'
cp 'INFORME_TIC.txt' '${PATH_INFORMES}${PREFIJO}INFORME_TIC.txt'



##################################################
echo -e $(date +"%T")" | 080 | Guardar info PRODUCTIVA | FIN" >>$LOG_080
echo -e $(date +"%T")" | 080 | Guardar info PRODUCTIVA | FIN" >>$LOG_070





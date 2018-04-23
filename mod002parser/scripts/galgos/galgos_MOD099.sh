#!/bin/bash

source "/home/carloslinux/git/bdml/mod002parser/scripts/galgos/funciones.sh"

#Borrar log
rm -f "${LOG_099}"


####### PARAMETROS ###
INFORME_COMANDOS_INPUT="${1}"


echo -e $(date +"%T")" | 099 | Posteriori - Extractor de resultados reales | INICIO" >>$LOG_070
echo -e "MOD099 --> LOG = "${LOG_099}

#Limpiar informe
rm -f "${LOG_099}"
rm -f "${INFORME_BRUTO_POSTERIORI}"
rm -f "${INFORME_LIMPIO_POSTERIORI}"


########## EJECUTANDO COMANDOS #################
echo -e "Input (comandos): "$INFORME_COMANDOS_INPUT 2>&1 1>>${LOG_099}
$INFORME_COMANDOS_INPUT
echo -e "\nOutput (HTML bruto leido): "$INFORME_BRUTO_POSTERIORI 2>&1 1>>${LOG_099}


########## BUCLE Limpieza #################
echo -e "Limpieza POSTERIORI..." 2>&1 1>>${LOG_099}

echo -e "|Date|Distancia|TP|STmHcp|Fin|By|WinnerOr2nd|Venue|Remarks|WinTime|Going|SP|Class|CalcTm|Race|Meeting" >>$INFORME_LIMPIO_POSTERIORI

sed 's/\t//g' ${INFORME_BRUTO_POSTERIORI} | sed 's/center//g' | sed 's/resultsRace.aspx?id=//g' | sed 's/<\/td>//g' | sed 's/<\/a>//g' | sed 's/align=\"\"//g' | sed 's/ title=\"Race\"//g' | sed 's/a title=\"Meeting\" href=\"//g' | sed 's/<td/|/g' | sed 's/<//g' | sed 's/>//g' | sed 's/a href=\"//g' | sed 's/\"Race//g' | sed 's/resultsMeeting\.aspx//g' | sed 's/\"Meeting//g' | sed 's/\?id=//g' | sed 's/&nbsp;//g' 2>&1 1>>${INFORME_LIMPIO_POSTERIORI}

echo -e "\n\nOutput (HTML limpio leido): "$INFORME_LIMPIO_POSTERIORI 2>&1 1>>${LOG_099}


#####################################################################################################

echo -e $(date +"%T")" | 099 | Posteriori - Extractor de resultados reales | FIN" >>$LOG_070




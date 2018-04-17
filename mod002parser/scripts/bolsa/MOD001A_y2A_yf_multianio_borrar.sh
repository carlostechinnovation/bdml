#!/bin/bash

PATH_LOG="/home/carloslinux/Desktop/LOGS/descarga_bruto.log"
PATH_SCRIPTS="/home/carloslinux/git/bdml/mod002parser/scripts/bolsa/"

echo "Modulo 001A - Obtener datos en BRUTO" 2>&1 1>>${PATH_LOG}

PATH_CARPETA="/home/carloslinux/Desktop/DATOS_BRUTO/bolsa/"
PATH_JAR="/home/carloslinux/git/bdml/mod002parser/target/mod002parser-jar-with-dependencies.jar"




########### SHELL que invoca a NODE.js ###############################
TAG_YAHOO_FINANCE="YF"


#Historico anual hasta hoy. En caso de reejecucion, se sobreescriben los ficheros brutos de ese anio.
${PATH_SCRIPTS}'MOD001A_yahoo_finance.sh' 2005
${PATH_SCRIPTS}'MOD001A_yahoo_finance.sh' 2006
${PATH_SCRIPTS}'MOD001A_yahoo_finance.sh' 2007
${PATH_SCRIPTS}'MOD001A_yahoo_finance.sh' 2008
${PATH_SCRIPTS}'MOD001A_yahoo_finance.sh' 2009
${PATH_SCRIPTS}'MOD001A_yahoo_finance.sh' 2010
${PATH_SCRIPTS}'MOD001A_yahoo_finance.sh' 2011
${PATH_SCRIPTS}'MOD001A_yahoo_finance.sh' 2012
${PATH_SCRIPTS}'MOD001A_yahoo_finance.sh' 2013
${PATH_SCRIPTS}'MOD001A_yahoo_finance.sh' 2014
${PATH_SCRIPTS}'MOD001A_yahoo_finance.sh' 2015
${PATH_SCRIPTS}'MOD001A_yahoo_finance.sh' 2016
${PATH_SCRIPTS}'MOD001A_yahoo_finance.sh' 2017




echo -e "Modulo 002A - Parsear datos"

PATH_DIR_IN="/home/carloslinux/Desktop/DATOS_BRUTO/bolsa/"
PATH_DIR_OUT="/home/carloslinux/Desktop/DATOS_LIMPIO/bolsa/"
PATH_JAR="/home/carloslinux/git/bdml/mod002parser/target/mod002parser-jar-with-dependencies.jar"
PATH_SCRIPTS="/home/carloslinux/git/bdml/mod002parser/scripts/bolsa/"


###### YAHOO FINANCE (Solo ejecuto los lunes, porque realmente son datos historicos) (se podria ejecutar cada dia...) #########

${PATH_SCRIPTS}MOD002A_YF.sh "2005"
${PATH_SCRIPTS}MOD002A_YF.sh "2006"
${PATH_SCRIPTS}MOD002A_YF.sh "2007"
${PATH_SCRIPTS}MOD002A_YF.sh "2008"
${PATH_SCRIPTS}MOD002A_YF.sh "2009"
${PATH_SCRIPTS}MOD002A_YF.sh "2010"
${PATH_SCRIPTS}MOD002A_YF.sh "2011"
${PATH_SCRIPTS}MOD002A_YF.sh "2012"
${PATH_SCRIPTS}MOD002A_YF.sh "2013"
${PATH_SCRIPTS}MOD002A_YF.sh "2014"
${PATH_SCRIPTS}MOD002A_YF.sh "2015"
${PATH_SCRIPTS}MOD002A_YF.sh "2016"
${PATH_SCRIPTS}MOD002A_YF.sh "2017"







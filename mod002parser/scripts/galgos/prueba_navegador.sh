#!/bin/bash




echo -e "Buscamos el proceso del navegador web abierto..."
ps -aux | grep '/usr/bin/google-chrome --incognito' | awk '{print $2}'  > "./navegador_temp"
head -n 1 "./navegador_temp" > "./navegador_id_temp"
num_proceso_navegador=$(cat "./navegador_id_temp")
kill -9 ${num_proceso_navegador}
echo -e "Proceso navegador WEB matado."






#!/bin/bash

filtro_galgos_nombres=""

input="./galgos_iniciales.txt"
while IFS= read -r linea
do
echo $linea
  filtro_galgos_nombres=${filtro_galgos_nombres}"'"
  filtro_galgos_nombres="${filtro_galgos_nombres}${linea}',"
done < "$input"

#Limpiamos ultima coma, que sobra
filtro_galgos_nombres=${filtro_galgos_nombres::-1}

echo -e "Leido=${filtro_galgos_nombres}"



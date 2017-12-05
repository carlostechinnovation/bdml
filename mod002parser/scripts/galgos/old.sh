

#--------------------------------------------

filtro_galgos_nombres=""

input="/home/carloslinux/Desktop/DATOS_LIMPIO/galgos/galgos_iniciales.txt"
while IFS= read -r linea
do
echo $linea
  filtro_galgos_nombres=${filtro_galgos_nombres}"'"
  filtro_galgos_nombres="${filtro_galgos_nombres}${linea}',"
done < "$input"

#Limpiamos ultima coma, que sobra
filtro_galgos_nombres=${filtro_galgos_nombres::-1}

echo -e "Filtro=${filtro_galgos_nombres}"
#--------------------------------------------





SELECT
PO1.id_carrera,
PO1.galgo_nombre AS galgo_analizado,
PO1.posicion AS posicion_analizado,
PO2.galgo_nombre AS galgo_competidor,
PO2.posicion AS posicion_competidor,
PO2.edad_en_dias AS competidor_edad,
PO2.peso_galgo AS competidor_peso

FROM datos_desa.tb_galgos_posiciones_en_carreras PO1

LEFT JOIN datos_desa.tb_galgos_posiciones_en_carreras PO2
ON (PO1.id_Carrera=PO2.id_carrera AND PO1.galgo_nombre <> PO2.galgo_nombre)

WHERE PO1.galgo_nombre IN (SELECT MAX(galgo_nombre) AS galgo_nombre FROM datos_desa.tb_galgos_carreragalgo GROUP BY galgo_nombre)

ORDER BY PO1.id_carrera DESC, PO1.posicion ASC, PO2.posicion
;






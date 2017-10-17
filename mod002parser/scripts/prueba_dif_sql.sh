#!/bin/bash


TAG_DIA_DESCARGA="M20171017182501"

echo "a="${TAG_DIA_DESCARGA}
dia_semana=${TAG_DIA_DESCARGA:0:1}
echo "dia_semana="${dia_semana}

if [ ${dia_semana} = "M" ]
then
    echo "entra"
fi








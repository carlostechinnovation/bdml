#!/bin/bash

cadena='L20171016182501'

echo 'anio='${cadena:1:4}
echo 'mes='${cadena:5:2}
echo 'dia='${cadena:7:2}

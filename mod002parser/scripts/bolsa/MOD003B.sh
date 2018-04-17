#!/bin/bash

echo -e "Modulo 003B - Generador de datasets"


#############################################################################
########### Datasets del i003 ###########
#############################################################################
#Tabla de tickers distintos
mysql -e "DROP TABLE IF EXISTS datos_desa.tb_i003_tickers;"
mysql -e "CREATE TABLE datos_desa.tb_i003_tickers AS SELECT DISTINCT ticker FROM datos_desa.tb_yf01 ORDER BY ticker ASC;"

# Array (en bash) de tickers distintos
array_tickers=()
while read -r output_line; do
    array_tickers += ("$output_line")
done < <(mysql -u user -ppass -hhost DB -e "query")


#Consulta compleja


read -d '' CONSULTA <<- EOF
INSERT INTO datos_desa.tb_i003_dataset
AS

SELECT rank1_fin, rank2_fin, date_concat, oc_concat, 'PENDIENTE' AS closet3_menos_opent1 FROM (

SELECT 
rank1_fin, --ID periodo1
-1 AS rank2_fin,
GROUP_CONCAT(date ORDER BY date) as date_concat,
GROUP_CONCAT(open, gap_close_open) AS oc_concat --Por fuera, sumaremos: open_t1 + gap_close_open_t2 + gap_close_open_t3

FROM (
  select 
  1 + (rank1-(c1%3))/3 AS rank1_fin,
  cast(date as char) as date,
  open,
  gap_close_open
  FROM datos_desa.tb_i003_temp1 -- Contiene solo datos de UN ticker
  ORDER BY rank1 ASC, date ASC
) tabla1
GROUP BY rank1_fin
ORDER BY rank1_fin ASC


UNION ALL

SELECT 
-1 AS rank1_fin,
rank2_fin, --ID periodo2
GROUP_CONCAT(date ORDER BY date) as date_concat,
GROUP_CONCAT(open, gap_close_open) AS oc_concat --Por fuera, sumaremos: open_t1 + gap_close_open_t2 + gap_close_open_t3

FROM (
  select
  1 + (rank2-(rank2%3))/3 AS rank2_fin,
  cast(date as char) as date,
  open,
  gap_close_open
  FROM datos_desa.tb_i003_temp1 -- Contiene solo datos de UN ticker
  ORDER BY rank2 ASC, date ASC
) tabla1
GROUP BY rank2_fin
ORDER BY rank2_fin ASC


) JUNTOS
WHERE 
JUNTOS.date_concat LIKE '%,%,%' --Grupos de tres elementos. quitamos los que no lo sean para evitar el ruido de los extremos.
;
EOF

#Tabla FINAL
mysql -e "DROP TABLE IF EXISTS datos_desa.tb_i003_dataset;"
mysql -e "CREATE TABLE datos_desa.tb_i003_dataset;"


# Para cada elemento del array (ticker), asigno ID1, ID2, ID3 por grupos de 3, moviendo ventana

for item in array_tickers
do
    mysql -e "TRUNCATE datos_desa.tb_i003_temp1; SET @rank1=0; SET @rank2=0; SET @rank3=0;"
    mysql -e "INSERT INTO datos_desa.tb_i003_temp1 SELECT @rank1:=@rank1+1 AS rank1, @rank2:=@rank2+2 AS rank2, @rank3:=@rank3+3 AS rank3, ticker, date, gap_diario, open, close, volumen FROM datos_desa.tb_yf01 WHERE ticker=$item ORDER BY date ASC;"
    mysql -e "$CONSULTA"

done










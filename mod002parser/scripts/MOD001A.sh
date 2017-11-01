#!/bin/bash

PATH_LOG="/home/carloslinux/Desktop/LOGS/descarga_bruto.log"
PATH_SCRIPTS="/home/carloslinux/Desktop/GIT_REPO_BDML/bdml/mod002parser/scripts/"

echo "Modulo 001A - Obtener datos en BRUTO" 2>&1 1>>${PATH_LOG}

PATH_CARPETA="/home/carloslinux/Desktop/DATOS_BRUTO/bolsa/"
PATH_JAR="/home/carloslinux/Desktop/GIT_REPO_BDML/bdml/mod002parser/target/mod002parser-jar-with-dependencies.jar"


######## BOE - DIA ##################################
if [ $# -eq 0 ]
  then
    echo "ERROR Parametro de entrada vacio. Debes indicar el dia (BOE) que quieres procesar!"
    exit -1
fi

TAG_DIA_DESCARGA=${1}
anio=${TAG_DIA_DESCARGA:1:4}
mes=${TAG_DIA_DESCARGA:5:2}
dia=${TAG_DIA_DESCARGA:7:2}

echo 'ID de ejecucion parseado = '$anio'/'$mes'/'$dia

desde_dia=$dia
desde_mes=$mes
desde_anio=$anio
hasta_dia=$dia
hasta_mes=$mes
hasta_anio=$anio


##########################################
TAG_GF="GOOGLEFINANCE"
echo ${TAG_GF}"..." 2>&1 1>>${PATH_LOG}

#Solo se pueden pedir columnas en grupos de 12. Dividimos en varias peticiones:

#GF01-Columnas de tipo "PRICE" (11):
curl 'https://finance.google.com/finance?output=json&start=0&num=400&q=%5Bcurrency%20%3D%3D%20%22EUR%22%20%26%20%28exchange%20%3D%3D%20%22BME%22%29%20%26%20%28last_price%20%3E%3D%200%29%20%26%20%28last_price%20%3C%3D%20156%29%20%26%20%28earnings_per_share%20%3E%3D%20-4.73%29%20%26%20%28earnings_per_share%20%3C%3D%2026.85%29%20%26%20%28change_today_percent%20%3E%3D%20-101%29%20%26%20%28change_today_percent%20%3C%3D%2012.39%29%20%26%20%28high_52week%20%3E%3D%200%29%20%26%20%28high_52week%20%3C%3D%20600001%29%20%26%20%28low_52week%20%3E%3D%200%29%20%26%20%28low_52week%20%3C%3D%20500001%29%20%26%20%28price_change_52week%20%3E%3D%20-94.03%29%20%26%20%28price_change_52week%20%3C%3D%20234%29%20%26%20%28average_50day_price%20%3E%3D%200%29%20%26%20%28average_50day_price%20%3C%3D%20165%29%20%26%20%28average_150day_price%20%3E%3D%200%29%20%26%20%28average_150day_price%20%3C%3D%20160%29%20%26%20%28average_200day_price%20%3E%3D%200%29%20%26%20%28average_200day_price%20%3C%3D%20153%29%20%26%20%28price_change_13week%20%3E%3D%20-64.67%29%20%26%20%28price_change_13week%20%3C%3D%2050.76%29%20%26%20%28price_change_26week%20%3E%3D%20-90.66%29%20%26%20%28price_change_26week%20%3C%3D%20106%29%5D&restype=company' > "${PATH_CARPETA}${TAG_DIA_DESCARGA}_${TAG_GF}_01"

#GF02-Columnas de tipo "Valuation" (3) y Dividend (7):
curl 'https://finance.google.com/finance?output=json&start=0&num=400&q=%5Bcurrency%20%3D%3D%20%22EUR%22%20%26%20%28exchange%20%3D%3D%20%22BME%22%29%20%26%20%28market_cap%20%3E%3D%200%29%20%26%20%28market_cap%20%3C%3D%20100560000000%29%20%26%20%28pe_ratio%20%3E%3D%200%29%20%26%20%28pe_ratio%20%3C%3D%20694%29%20%26%20%28forward_pe_1year%20%3E%3D%200%29%20%26%20%28forward_pe_1year%20%3C%3D%200%29%20%26%20%28dividend_recent_quarter%20%3E%3D%200%29%20%26%20%28dividend_recent_quarter%20%3C%3D%201.12%29%20%26%20%28dividend_next_quarter%20%3E%3D%200%29%20%26%20%28dividend_next_quarter%20%3C%3D%203.84%29%20%26%20%28dividend_per_share%20%3E%3D%200%29%20%26%20%28dividend_per_share%20%3C%3D%204.58%29%20%26%20%28dividend_next_year%20%3E%3D%200%29%20%26%20%28dividend_next_year%20%3C%3D%203.84%29%20%26%20%28dividend_per_share_trailing_12months%20%3E%3D%200%29%20%26%20%28dividend_per_share_trailing_12months%20%3C%3D%203.84%29%20%26%20%28dividend_yield%20%3E%3D%200%29%20%26%20%28dividend_yield%20%3C%3D%2017.31%29%20%26%20%28dividend_recent_year%20%3E%3D%200%29%20%26%20%28dividend_recent_year%20%3C%3D%202907%29%5D&restype=company' > "${PATH_CARPETA}${TAG_DIA_DESCARGA}_${TAG_GF}_02"

#GF-03Columnas "financial ratios" (11):
curl 'https://finance.google.com/finance?output=json&start=0&num=400&q=%5Bcurrency%20%3D%3D%20%22EUR%22%20%26%20%28exchange%20%3D%3D%20%22BME%22%29%20%26%20%28book_value_per_share_year%20%3E%3D%20-50.59%29%20%26%20%28book_value_per_share_year%20%3C%3D%2067.2%29%20%26%20%28cash_per_share_year%20%3E%3D%200%29%20%26%20%28cash_per_share_year%20%3C%3D%2028.76%29%20%26%20%28current_assets_to_liabilities_ratio_year%20%3E%3D%200%29%20%26%20%28current_assets_to_liabilities_ratio_year%20%3C%3D%20805%29%20%26%20%28longterm_debt_to_assets_year%20%3E%3D%200%29%20%26%20%28longterm_debt_to_assets_year%20%3C%3D%20135%29%20%26%20%28longterm_debt_to_assets_quarter%20%3E%3D%200%29%20%26%20%28longterm_debt_to_assets_quarter%20%3C%3D%20135%29%20%26%20%28total_debt_to_assets_year%20%3E%3D%200%29%20%26%20%28total_debt_to_assets_year%20%3C%3D%20884%29%20%26%20%28total_debt_to_assets_quarter%20%3E%3D%200%29%20%26%20%28total_debt_to_assets_quarter%20%3C%3D%20926%29%20%26%20%28longterm_debt_to_equity_year%20%3E%3D%200%29%20%26%20%28longterm_debt_to_equity_year%20%3C%3D%202144%29%20%26%20%28longterm_debt_to_equity_quarter%20%3E%3D%200%29%20%26%20%28longterm_debt_to_equity_quarter%20%3C%3D%202144%29%20%26%20%28total_debt_to_equity_year%20%3E%3D%200%29%20%26%20%28total_debt_to_equity_year%20%3C%3D%202162%29%20%26%20%28total_debt_to_equity_quarter%20%3E%3D%200%29%20%26%20%28total_debt_to_equity_quarter%20%3C%3D%202162%29%5D&restype=company' > "${PATH_CARPETA}${TAG_DIA_DESCARGA}_${TAG_GF}_03"

#GF04-Columnas "Operating metrics" (10):
curl 'https://finance.google.com/finance?output=json&start=0&num=400&q=%5Bcurrency%20%3D%3D%20%22EUR%22%20%26%20%28exchange%20%3D%3D%20%22BME%22%29%20%26%20%28interest_coverage_year%20%3E%3D%20-373%29%20%26%20%28interest_coverage_year%20%3C%3D%209076%29%20%26%20%28return_on_investment_trailing_12months%20%3E%3D%20-524%29%20%26%20%28return_on_investment_trailing_12months%20%3C%3D%2062.93%29%20%26%20%28return_on_investment_5years%20%3E%3D%20-99.86%29%20%26%20%28return_on_investment_5years%20%3C%3D%2074.07%29%20%26%20%28return_on_investment_year%20%3E%3D%20-524%29%20%26%20%28return_on_investment_year%20%3C%3D%2083.17%29%20%26%20%28return_on_assets_trailing_12months%20%3E%3D%20-45.46%29%20%26%20%28return_on_assets_trailing_12months%20%3C%3D%2063.7%29%20%26%20%28return_on_assets_5years%20%3E%3D%20-34.52%29%20%26%20%28return_on_assets_5years%20%3C%3D%2033.75%29%20%26%20%28return_on_assets_year%20%3E%3D%20-79.52%29%20%26%20%28return_on_assets_year%20%3C%3D%2067.99%29%20%26%20%28return_on_equity_trailing_12months%20%3E%3D%20-231%29%20%26%20%28return_on_equity_trailing_12months%20%3C%3D%2072.49%29%20%26%20%28return_on_equity_5years%20%3E%3D%20-4255%29%20%26%20%28return_on_equity_5years%20%3C%3D%20376%29%20%26%20%28return_on_equity_year%20%3E%3D%20-171%29%20%26%20%28return_on_equity_year%20%3C%3D%20369%29%5D&restype=company' > "${PATH_CARPETA}${TAG_DIA_DESCARGA}_${TAG_GF}_04"

#GF05-Columnas "Stock metrics" (5) y Margins(4):
curl 'https://finance.google.com/finance?output=json&start=0&num=400&q=%5Bcurrency%20%3D%3D%20%22EUR%22%20%26%20%28exchange%20%3D%3D%20%22BME%22%29%20%26%20%28beta%20%3E%3D%20-0.58%29%20%26%20%28beta%20%3C%3D%202.53%29%20%26%20%28shares_floating%20%3E%3D%200%29%20%26%20%28shares_floating%20%3C%3D%2017674%29%20%26%20%28percent_institutional_held%20%3E%3D%200%29%20%26%20%28percent_institutional_held%20%3C%3D%200%29%20%26%20%28volume%20%3E%3D%200%29%20%26%20%28volume%20%3C%3D%2034590000%29%20%26%20%28average_volume%20%3E%3D%200%29%20%26%20%28average_volume%20%3C%3D%2086630000%29%20%26%20%28gross_margin_trailing_12months%20%3E%3D%20-787%29%20%26%20%28gross_margin_trailing_12months%20%3C%3D%20351%29%20%26%20%28ebitd_margin_trailing_12months%20%3E%3D%20-1306%29%20%26%20%28ebitd_margin_trailing_12months%20%3C%3D%2051713%29%20%26%20%28operating_margin_trailing_12months%20%3E%3D%20-2522%29%20%26%20%28operating_margin_trailing_12months%20%3C%3D%202814%29%20%26%20%28net_profit_margin_percent_trailing_12months%20%3E%3D%20-13970%29%20%26%20%28net_profit_margin_percent_trailing_12months%20%3C%3D%203952%29%5D&restype=company' > "${PATH_CARPETA}${TAG_DIA_DESCARGA}_${TAG_GF}_05"

#GF06-Columnas "Growth" (5):
curl 'https://finance.google.com/finance?output=json&start=0&num=400&q=%5Bcurrency%20%3D%3D%20%22EUR%22%20%26%20%28exchange%20%3D%3D%20%22BME%22%29%20%26%20%28net_income_growth_rate_5years%20%3E%3D%20-38.42%29%20%26%20%28net_income_growth_rate_5years%20%3C%3D%20186%29%20%26%20%28revenue_growth_rate_5years%20%3E%3D%20-84.98%29%20%26%20%28revenue_growth_rate_5years%20%3C%3D%20130%29%20%26%20%28revenue_growth_rate_10years%20%3E%3D%20-60.54%29%20%26%20%28revenue_growth_rate_10years%20%3C%3D%2023.43%29%20%26%20%28eps_growth_rate_5years%20%3E%3D%20-38.4%29%20%26%20%28eps_growth_rate_5years%20%3C%3D%20128%29%20%26%20%28eps_growth_rate_10years%20%3E%3D%20-52.44%29%20%26%20%28eps_growth_rate_10years%20%3C%3D%2052.08%29%5D&restype=company' > "${PATH_CARPETA}${TAG_DIA_DESCARGA}_${TAG_GF}_06"


##########################################
TAG_BM="BOLSAMADRID"
echo ${TAG_BM}"..." 2>&1 1>>${PATH_LOG}

#BM01-Cotizaciones del IBEX-35:
curl 'http://www.bolsamadrid.es/esp/aspx/Mercados/Precios.aspx?indice=ESI100000000' > "${PATH_CARPETA}${TAG_DIA_DESCARGA}_${TAG_BM}_01"

#BM02-Lista de empresas: DESCARGA MANUAL
curl 'http://www.bolsamadrid.es/esp/aspx/Empresas/Empresas.aspx' -H 'Host: www.bolsamadrid.es' -H 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:55.0) Gecko/20100101 Firefox/55.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Cookie: MsjCookies_esp=A%3B2013%2F09%2F23%3BThu%2C%2031%20Aug%202017%2015%3A51%3A11%20GMT; __utma=192527929.512519428.1504187472.1504274611.1505151193.4; __utmz=192527929.1505151193.4.3.utmcsr=google|utmccn=(organic)|utmcmd=organic|utmctr=(not%20provided); menuIzq=JS; __utmc=192527929; TopMsj=0; __utmb=192527929.3.10.1505151193; __utmt=1' -H 'Connection: keep-alive' -H 'Upgrade-Insecure-Requests: 1' -H 'Cache-Control: max-age=0' > "${PATH_CARPETA}${TAG_DIA_DESCARGA}_${TAG_BM}_02_01"

curl 'http://www.bolsamadrid.es/esp/aspx/Empresas/Empresas.aspx' -H 'Host: www.bolsamadrid.es' -H 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:55.0) Gecko/20100101 Firefox/55.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Content-Type: application/x-www-form-urlencoded' -H 'Cookie: MsjCookies_esp=A%3B2013%2F09%2F23%3BThu%2C%2031%20Aug%202017%2015%3A51%3A11%20GMT; __utma=192527929.512519428.1504187472.1504274611.1505151193.4; __utmz=192527929.1505151193.4.3.utmcsr=google|utmccn=(organic)|utmcmd=organic|utmctr=(not%20provided); menuIzq=JS; __utmc=192527929; TopMsj=0; __utmb=192527929.4.10.1505151193; __utmt=1' -H 'Connection: keep-alive' -H 'Upgrade-Insecure-Requests: 1' --data '__EVENTTARGET=&__EVENTARGUMENT=&__VIEWSTATE=h0b%2BpQi9NlV9BDgjYEPYXcKr1BKpX6bD1qocxGk6q1Sz4gcGH%2Fx7wVC5JHFC9mUnCSNofVb7gMMCzXFqI8aoVAilMNsYwHUrGO3kUYEtusjlIKd78x3RQVaseJgCIbU44xHIP5FL5X%2B4AToZ3g4SeO%2BhZJDJYLpwyXF3hq27aaskLGHD&__VIEWSTATEGENERATOR=65A1DED9&__EVENTVALIDATION=%2BvgPo8KGqht0jEQ6ihqfS83aj47Sr3TK0fDQo8xUHuo46K8CEOZzNMfpbLjGA7xDBz34GNIne7pZWdU0UZ5hGmKhNCoX4MYdSSRJEY0jd3J%2Bq6Y5fS3ac37xy5dG0BjP7nBlrz%2By26kZOqWGCYjIxktf05UOihN4bEg4ApZBVnDOvi3pJA8QEFUBkIMCdk%2BnVhiwpQ%3D%3D&ctl00%24Contenido%24GoPag=1' > "${PATH_CARPETA}${TAG_DIA_DESCARGA}_${TAG_BM}_02_02"

curl 'http://www.bolsamadrid.es/esp/aspx/Empresas/Empresas.aspx' -H 'Host: www.bolsamadrid.es' -H 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:55.0) Gecko/20100101 Firefox/55.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Content-Type: application/x-www-form-urlencoded' -H 'Cookie: MsjCookies_esp=A%3B2013%2F09%2F23%3BThu%2C%2031%20Aug%202017%2015%3A51%3A11%20GMT; __utma=192527929.512519428.1504187472.1504274611.1505151193.4; __utmz=192527929.1505151193.4.3.utmcsr=google|utmccn=(organic)|utmcmd=organic|utmctr=(not%20provided); menuIzq=JS; __utmc=192527929; TopMsj=0; __utmb=192527929.5.10.1505151193; __utmt=1' -H 'Connection: keep-alive' -H 'Upgrade-Insecure-Requests: 1' --data '__EVENTTARGET=&__EVENTARGUMENT=&__VIEWSTATE=XHj6EFM%2BInORd4YMdOx2gDHFlD9rOAdTO0rWxw9LSdfmVxgatlfVJG6f8daA9Dt5zXw%2FSNd8XCiyY3%2FA0RIW9NATSuoRzpbCsHaAoPAqih4T%2BZQtj2d9s1Ng92nJkGcT4Tef8HgTiLKki%2F1q1syEJJ5xYYjFJl7sX%2BLylhqidA5KT1Dafq9fhbwaifswIIVZKtTZOw%3D%3D&__VIEWSTATEGENERATOR=65A1DED9&__EVENTVALIDATION=nIZt2fvfByU0WgXZNHjn1%2FfIrVtW0EiP9uhg2qpMB4hGTkOr5PeVm9YinOIGmN3RSXA%2Fg3ZMwCR8OUtob%2FmdQ4PFdr8LMtZK%2FIdy8fmekoVj41Prz5%2F356WJMOraf%2FSPlBcNeCMZcSqq7vgvyDWIFfuNMtPodfw0%2BV%2FddPE0RkwW2YmOLGhh%2BJf%2BFIIhfbkTHmUJYzd94oQxScmVr8bNjdC%2FE0vn0nnC5wvkkGzAs5NYRC99&ctl00%24Contenido%24GoPag=2' > "${PATH_CARPETA}${TAG_DIA_DESCARGA}_${TAG_BM}_02_03"

curl 'http://www.bolsamadrid.es/esp/aspx/Empresas/Empresas.aspx' -H 'Host: www.bolsamadrid.es' -H 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:55.0) Gecko/20100101 Firefox/55.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Content-Type: application/x-www-form-urlencoded' -H 'Cookie: MsjCookies_esp=A%3B2013%2F09%2F23%3BThu%2C%2031%20Aug%202017%2015%3A51%3A11%20GMT; __utma=192527929.512519428.1504187472.1504274611.1505151193.4; __utmz=192527929.1505151193.4.3.utmcsr=google|utmccn=(organic)|utmcmd=organic|utmctr=(not%20provided); menuIzq=JS; __utmc=192527929; TopMsj=1; __utmb=192527929.6.10.1505151193; __utmt=1' -H 'Connection: keep-alive' -H 'Upgrade-Insecure-Requests: 1' --data '__EVENTTARGET=&__EVENTARGUMENT=&__VIEWSTATE=VQQmESoDErhm4KlRp7bnhcU2yfIyAxHKNi3sc%2Fjr8vL24qApfjh8Ye2xOVvrikOlxQrwYXOUtTz4NvbmlC8XriFKNvZjn95tHdkHJ%2BxurhSZjYNOM2cs17lPBsmOgcIn3QaO5ca6N3Q9soQevC3n6e4k8Q63283qHKaxYwTk2jBXxCensWHbsRirWXFz6vjNQFsbFQ%3D%3D&__VIEWSTATEGENERATOR=65A1DED9&__EVENTVALIDATION=91bvWy1gIjC1y3p6GGzB2RH0mk7TJ2nijlJ1u02OoZJiH%2FUQtubxBak6Mn6ktJa5GiNB3qqR4zNFl4f5nBc%2FZdUWkR2ZOFj69TnNRlmV7uPL0v189lzPyXZc1whvJgTrMzZAAOn2RvI4A2LMjn53CRZRq5qpFGuLpTycFFuLrts59UDF%2BFoEU7iNyq1FSVwoiK2FuvUoYaoOmLrYmYzWevgHsPuaYgkoDuBefGYdodbf%2FhLa&ctl00%24Contenido%24GoPag=3' > "${PATH_CARPETA}${TAG_DIA_DESCARGA}_${TAG_BM}_02_04"

curl 'http://www.bolsamadrid.es/esp/aspx/Empresas/Empresas.aspx' -H 'Host: www.bolsamadrid.es' -H 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:55.0) Gecko/20100101 Firefox/55.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Content-Type: application/x-www-form-urlencoded' -H 'Cookie: MsjCookies_esp=A%3B2013%2F09%2F23%3BThu%2C%2031%20Aug%202017%2015%3A51%3A11%20GMT; __utma=192527929.512519428.1504187472.1504274611.1505151193.4; __utmz=192527929.1505151193.4.3.utmcsr=google|utmccn=(organic)|utmcmd=organic|utmctr=(not%20provided); menuIzq=JS; __utmc=192527929; TopMsj=1; __utmb=192527929.7.10.1505151193; __utmt=1' -H 'Connection: keep-alive' -H 'Upgrade-Insecure-Requests: 1' --data '__EVENTTARGET=&__EVENTARGUMENT=&__VIEWSTATE=LF9PCmn2CWIcbjeIE0To4JIBK9ndyNddBdqRaSztfvpAExLBSJcLZLDWr1CjR5burtV8ihs04ZJwnfrQHVNHKjtSNesCrAXXuPmZjVclzeO35%2BqTf59EjZfvc08UbKGJhE%2BmKnMAgEmb0xuoS7gaDtgwwwEUjxkKwJ1PalbwqkMSPPx1Wlao7HGja9EaEzaE%2B2dsZg%3D%3D&__VIEWSTATEGENERATOR=65A1DED9&__EVENTVALIDATION=8XUpj0bQ3dZE1vrSsxueToo%2B%2FsHAHSfHu4%2BW8EYKf1aqhNm%2F6Zpn0gBqRybDqlzerh4JDpCRscU5APtUEUJHI9oeAlDlV6yt%2Bop35sAKXGgffAJZnrPM2K2KgCf1lrF6F8GsPUzXscNr7a0VjgW6ARvX7dj86%2FCPLvrDJR8n2cg8vX1LdU%2BoY2JmCBiEcD7d1UD%2Fga5Dw%2Fi0%2BLVxepFyYMRxvNX0JhEWEEukm%2F4yFWA6fxqZ&ctl00%24Contenido%24GoPag=4' > "${PATH_CARPETA}${TAG_DIA_DESCARGA}_${TAG_BM}_02_05"

curl 'http://www.bolsamadrid.es/esp/aspx/Empresas/Empresas.aspx' -H 'Host: www.bolsamadrid.es' -H 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:55.0) Gecko/20100101 Firefox/55.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Content-Type: application/x-www-form-urlencoded' -H 'Cookie: MsjCookies_esp=A%3B2013%2F09%2F23%3BThu%2C%2031%20Aug%202017%2015%3A51%3A11%20GMT; __utma=192527929.512519428.1504187472.1504274611.1505151193.4; __utmz=192527929.1505151193.4.3.utmcsr=google|utmccn=(organic)|utmcmd=organic|utmctr=(not%20provided); menuIzq=JS; __utmc=192527929; TopMsj=1; __utmb=192527929.8.10.1505151193; __utmt=1' -H 'Connection: keep-alive' -H 'Upgrade-Insecure-Requests: 1' --data '__EVENTTARGET=&__EVENTARGUMENT=&__VIEWSTATE=4yBRSbar1wyT8EDs%2FKdOA6JFPR%2Fv2cjpwOXBGOK52jF9xKNC8Gkk9Wj8FpUd4GuUDfDON96QvMjfNrALylRAQzzCYLAwBU2uj0BarxNJEbhY6JpKTo7cny92S00Nomr3Fyw6xCHjxApPbxwcke9gKpCNXPCG1omjYSPys6GM2vRRj%2FCX4lSSviIODKghqnvm8rj4iQ%3D%3D&__VIEWSTATEGENERATOR=65A1DED9&__EVENTVALIDATION=ug63%2FzYGjfGM9GByasCET4ZwzTz5xLQVBZ5rQ5KxY%2FBMBmGIa9%2BjeqCPZoZ%2BPBKJvVzwElKUEO6sYuXkPwwzl8aw6dvvaf20sdmtXT%2Bxpy1XsMpLXoehh25HRT4Myl%2BJ8EAopOLrwwUnmxFi5eM4DPSprBDQW8hvXdlMiSUlr6xJzaatzEOVhYECLTf48FYFNeYZcFzZArlkCE1abgNIZztj9YoqLDWrLNvyLUmRK67gf%2Bmg&ctl00%24Contenido%24GoPag=5' > "${PATH_CARPETA}${TAG_DIA_DESCARGA}_${TAG_BM}_02_06"

curl 'http://www.bolsamadrid.es/esp/aspx/Empresas/Empresas.aspx' -H 'Host: www.bolsamadrid.es' -H 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:55.0) Gecko/20100101 Firefox/55.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Content-Type: application/x-www-form-urlencoded' -H 'Cookie: MsjCookies_esp=A%3B2013%2F09%2F23%3BThu%2C%2031%20Aug%202017%2015%3A51%3A11%20GMT; __utma=192527929.512519428.1504187472.1504274611.1505151193.4; __utmz=192527929.1505151193.4.3.utmcsr=google|utmccn=(organic)|utmcmd=organic|utmctr=(not%20provided); menuIzq=JS; __utmc=192527929; TopMsj=1; __utmb=192527929.9.10.1505151193; __utmt=1' -H 'Connection: keep-alive' -H 'Upgrade-Insecure-Requests: 1' --data '__EVENTTARGET=&__EVENTARGUMENT=&__VIEWSTATE=UCZY1gg7rgfI0v1Lxo6RloIxZlczlXk8tUBzgiaYqbzgDG%2Bq%2Bjju0Q0MAUmLQsf2ugCkONBtnSmurIWBONbHBMW0KiecowBhHoLVrOeV6RPU67FmAWIFFOe4aYvdjQ8jXGGzefxDAyFQleLyqx2iMIts8vRvzcyq80LqJqupzrISr4HmHQr2C%2FlBaXaLzsUV2Q4ISg%3D%3D&__VIEWSTATEGENERATOR=65A1DED9&__EVENTVALIDATION=xEi5KiRTfGRMXW2lXlcccmLhN7lqFJH1ObXugOiRNOP25t%2FkDc8FZVtr5tOi8q6pGYETuwphfLsupkgGN%2Bef%2Bny0NO2cmEsh%2F0zIKh6uYARcztOEwWmckUlEHYEAvCsSSIFdF5VZCmRbXbuKQq4A0iWtxdOv3WOxfMWnkzQdc2HgRibdL4b734z8EeoEcfz3SWdyhX989oFo1mY2VQDVFpwP2sYEZPsGdCLbcKY9Ut0japv%2F&ctl00%24Contenido%24GoPag=6' > "${PATH_CARPETA}${TAG_DIA_DESCARGA}_${TAG_BM}_02_07"


#BM03-Hechos relevantes:

curl 'http://www.bolsamadrid.es/esp/aspx/Empresas/HechosRelevantes.aspx' -H 'Host: www.bolsamadrid.es' -H 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:55.0) Gecko/20100101 Firefox/55.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Content-Type: application/x-www-form-urlencoded' -H 'Cookie: MsjCookies_esp=A%3B2013%2F09%2F23%3BThu%2C%2031%20Aug%202017%2015%3A51%3A11%20GMT; __utma=192527929.512519428.1504187472.1504210667.1504274611.3; __utmz=192527929.1504274611.3.2.utmcsr=google|utmccn=(organic)|utmcmd=organic|utmctr=(not%20provided); __utmb=192527929.17.10.1504274611; __utmt=1; menuIzq=JS; __utmc=192527929; TopMsj=0' -H 'Connection: keep-alive' -H 'Upgrade-Insecure-Requests: 1' --data "__EVENTTARGET=&__EVENTARGUMENT=&__VIEWSTATE=VYjlsh0Dm67bxhU96HYip1W828rwrbYgXYWIQFnD8yMRv%2FNQDX788dyvWZca6nNP7dF%2B07oE7ZSw7MAKXKUIjgiz4z7VGjrT6oZWhom%2BY%2B7CnrMTpHYg2FJu8oYaP3qSiHuFS8THx6mJaFmybLYFo96Bftq8p7Dt6zTppVhHFE09EobAAFei1J4MCTBBhaknN2ejewH4iquvLcuqqw4EWvWEhBGMYvt%2F062dV2pjMrY46MX4OHCj%2BL348oHBbehIwr%2BmkdMcl3Q%2BAHOAgNrOcSFBLutg%2Fd3Lu98SxJ%2FEGTB0dLt495xszpmA9MMRag56IS1GEc04XT7mQX2llWD3%2F1s5sdi%2BEG%2FEIhltjjR7zpgtFEgTSEDji0alWGVwHQaGLxgeLgTdBwyN6Z2wVuj%2FS3UJdpRv8KSKOuHUX1dhD2MlTy%2BMqxaYxm5d5djOBDRle5BZpVg0Bkqh4yxcWM4DGSqkG6z8UQkoRB0Bpgx2%2B2fG%2BdTdooFeAEpSRjpu8epP9FvH7ZbTlByofF9X9wfyPbw7VXWx%2FomNO2wiS9aqKbFVCdXBJePfWmHWcCwbmGDQgvtE6g%3D%3D&__VIEWSTATEGENERATOR=C54CCDBB&__EVENTVALIDATION=0%2FjV5klMntKcEDTgZoih8cfQlQPiIrf1XK88E3DkoaKYllYgzTlCiSTpxHjL%2Fl928h8RmQ%2F0kIVQsxHTq%2BIQBgaZ3jjtH8WndDY36R9kEUliLkm%2FpSdOeVfagb9uI45pemB5rpanlTkx4e%2FrDOEu32tvusqehfskVi%2FMjPxxZn%2BJgqs9jq1wCpbismaEI%2BUwqq%2F0uWBGdQKrCYbzcUsqaiMXMTF6ao5pikK9NDtCpoSHrcQruOsJCxSYoh%2B330Xl8N10VCSfM0mVRVWpcEEZbYR%2F4Zlm%2BcXN1n7xDvf%2B2vnOA8irLt4JmjEc99D1BQOAoQeMnJ3NO%2FtdzrhWLgOO6WvJlJ2nS0ofU1AXZd4xdG3gssS9&ctl00%24Contenido%24Desde%24Dia=${desde_dia}&ctl00%24Contenido%24Desde%24Mes=${desde_mes}&ctl00%24Contenido%24Desde%24A%C3%B1o=${desde_anio}&ctl00%24Contenido%24Hasta%24Dia=${hasta_dia}&ctl00%24Contenido%24Hasta%24Mes=${hasta_mes}&ctl00%24Contenido%24Hasta%24A%C3%B1o=${hasta_anio}&ctl00%24Contenido%24Emisora%24Texto=&ctl00%24Contenido%24Emisora%24Resultado=&ctl00%24Contenido%24Buscar=+Buscar+"  > "${PATH_CARPETA}${TAG_DIA_DESCARGA}_${TAG_BM}_03"


#BM04-Cotizaciones del IBEX-MEDIUM-CAP:
curl 'http://www.bolsamadrid.es/esp/aspx/Mercados/Precios.aspx?indice=ESI060000000' > "${PATH_CARPETA}${TAG_DIA_DESCARGA}_${TAG_BM}_04"

#BM05-Cotizaciones del IBEX-SMALL-CAP:
curl 'http://www.bolsamadrid.es/esp/aspx/Mercados/Precios.aspx?indice=ESI240000000' > "${PATH_CARPETA}${TAG_DIA_DESCARGA}_${TAG_BM}_05"

#BM06-Cotizaciones del MERCADO CONTINUO completo (lleva un parametro que puede que caduque...):
curl 'http://www.bolsamadrid.es/esp/aspx/Mercados/Precios.aspx?indice=ESI250000000' -H 'Host: www.bolsamadrid.es' -H 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:55.0) Gecko/20100101 Firefox/55.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Content-Type: application/x-www-form-urlencoded' -H 'Connection: keep-alive' -H 'Upgrade-Insecure-Requests: 1' -H 'Pragma: no-cache' -H 'Cache-Control: no-cache' --data '__EVENTTARGET=ctl00%24Contenido%24Todos&__EVENTARGUMENT=&__VIEWSTATE=T%2Bsa4kE9nrciwzHx4gRV%2B3r0mgpFKIb7hxXNRCQQCGWd2xD%2FHXxgMZgvgt43oWxkjBWC3C7kica3MqtYWCsEVB353T455NC7Ufs1m8tt4%2BBgCj9L%2FzGgxpDbXRRpcJL4ESqthoqcJZhLP8wYZOdLKcYjX1nVcHP3XRzLKCI%2BU4yenKb%2F2yqjTmVSlPjOZ1LnV9BW9%2B%2FpXQBxsndJ6Z1gLv1Vee12Y7ZszRZ8JZ%2F8olhGRrLWYKCDOvbbqD7ikzhPcONvOQ%3D%3D&__VIEWSTATEGENERATOR=DC05C2DC&__EVENTVALIDATION=fbpzQBdzUbRc5AB475bkbL1A4l5B6UHfK9EPRLBDHnx%2Fs4sIMVO7tP3OvUjmqweZVLXFai3BNczckjjvFbwUkx627n800FNqeP1301wUdxGzllYrGrau2oLHt2cXfyGFtW36ghXAU1EiXkSXZGxubIiI3jH3yMb0p4GuVvvWY7hd3fKa1NicLBTukgo2H0Y5wY83hA%2B5FZzy%2FWmFcpg0zHD7VFZ%2Fbw9cLu1CqeUWrOONKjEOah9lG1rX4PX8PZKgIxsEnWwPGlmtOjOdu9zzq9DNSfVF%2Bgy%2BOHplHqvfkaYlSqZ5Gg53ltYxRPIflXKT1XJiGbIWLBTcis4XLXU85mprbW%2BnkAm%2Fju83o83r73qcuY5fBcluUihf1QivbbkqaJnbIm%2F7atcXg6wu4XPG5sOlNtd1Xr0rGnGM029%2Blm5qH16r4AFL3Wfc7smHdee7aYg1Qlk1pXp1NDWvdxPqKrqoRyUvbUrNnGZ5zHoDMmroLl7S7fv%2FK4rWRHZq9XtMjhrlEWK9%2Feb9nffm9NJexiLceNdmWIgWpTjusZKP5O5rnyuJFp1ocWcbdbYDBeW5emAXlJg1ylNZRvu561qxUCMGj624UnkKoyB%2FG75xrhIGt3dZBLKH7OvxysLDZ%2FyrYQ5cmwfKQ7JJHt9ToOY9c%2BAKFtmkyRB%2F45pqyNHrPjzTB49%2FkH7iRbFBk0QZj51YnoLrwo4JyW4tbzZrBwlRvK%2Fb15TWErTO1ehUU%2FNCxhsje%2FWUshKr%2FVLNqav45ASHkMAmAMQkZy9sb21nnXn4vCcHiprsic3F5sK6h1GsX7qv1d847nsWqwIq3csfeYKDn%2BNDnQ%3D%3D&ctl00%24Contenido%24SelMercado=MC&ctl00%24Contenido%24Sel%C3%8Dndice=&ctl00%24Contenido%24SelSector=' > "${PATH_CARPETA}${TAG_DIA_DESCARGA}_${TAG_BM}_06"


##########################################
TAG_INE="INE"
echo ${TAG_INE}"..." 2>&1 1>>${PATH_LOG}

#INE_01: datos basicos en la portada del INE
curl 'http://www.ine.es/welcome.shtml'   > "${PATH_CARPETA}${TAG_DIA_DESCARGA}_${TAG_INE}_01"


##########################################
TAG_DM="DATOSMACRO"
echo ${TAG_DM}"..." 2>&1 1>>${PATH_LOG}

#DM_01: paro (total, jovenes, sexo)
curl 'https://www.datosmacro.com/paro' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' > "${PATH_CARPETA}${TAG_DIA_DESCARGA}_${TAG_DM}_01"

#DM_02: IPC
curl 'https://www.datosmacro.com/ipc' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' > "${PATH_CARPETA}${TAG_DIA_DESCARGA}_${TAG_DM}_02"

#DM_03: Prima de riesgo
curl 'https://www.datosmacro.com/prima-riesgo' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' > "${PATH_CARPETA}${TAG_DIA_DESCARGA}_${TAG_DM}_03"

#DM_04: Bono
curl 'https://www.datosmacro.com/bono' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' > "${PATH_CARPETA}${TAG_DIA_DESCARGA}_${TAG_DM}_04"

#DM_05: Ratings
curl 'https://www.datosmacro.com/ratings' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' > "${PATH_CARPETA}${TAG_DIA_DESCARGA}_${TAG_DM}_05"

#DM_06: Deuda
curl 'https://www.datosmacro.com/deuda' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' > "${PATH_CARPETA}${TAG_DIA_DESCARGA}_${TAG_DM}_06"

#DM_07: Deficit
curl 'https://www.datosmacro.com/deficit' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' > "${PATH_CARPETA}${TAG_DIA_DESCARGA}_${TAG_DM}_07"

#DM_08: PIB
curl 'https://www.datosmacro.com/pib' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' > "${PATH_CARPETA}${TAG_DIA_DESCARGA}_${TAG_DM}_08"

#DM_09: Hipotecas
curl 'https://www.datosmacro.com/hipotecas' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' > "${PATH_CARPETA}${TAG_DIA_DESCARGA}_${TAG_DM}_09"

#DM_10: Tipo de interes
curl 'https://www.datosmacro.com/tipo-interes' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' > "${PATH_CARPETA}${TAG_DIA_DESCARGA}_${TAG_DM}_10"

#DM_11: salario minimo (SMI)
curl 'https://www.datosmacro.com/smi' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' > "${PATH_CARPETA}${TAG_DIA_DESCARGA}_${TAG_DM}_11"

#DM_12: Paro segun la EPA
curl 'https://www.datosmacro.com/paro-epa' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' > "${PATH_CARPETA}${TAG_DIA_DESCARGA}_${TAG_DM}_12"

#DM_13: Bolsas
curl 'https://www.datosmacro.com/bolsa' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' > "${PATH_CARPETA}${TAG_DIA_DESCARGA}_${TAG_DM}_13"

#DM_14: Divisas
curl 'https://www.datosmacro.com/divisas' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' > "${PATH_CARPETA}${TAG_DIA_DESCARGA}_${TAG_DM}_14"

#DM_15: Materias primas
curl 'https://www.datosmacro.com/materias-primas' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' > "${PATH_CARPETA}${TAG_DIA_DESCARGA}_${TAG_DM}_15"


########### SHELL que invoca a NODE.js ###############################
TAG_YAHOO_FINANCE="YF"

#Instalacion en local del programa descargador de yahoo finance
#npm install --save yahoo-finance

#Historico anual hasta hoy. En caso de reejecucion, se sobreescriben los ficheros brutos de ese anio.
${PATH_SCRIPTS}'MOD001A_yahoo_finance.sh' ${anio}



echo "Modulo 001A - FIN" 2>&1 1>>${PATH_LOG}



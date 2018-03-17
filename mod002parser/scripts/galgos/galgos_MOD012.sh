#!/bin/bash

source "/root/git/bdml/mod002parser/scripts/galgos/funciones.sh"

#Borrar log
rm -f ${LOG_012}

echo -e $(date +"%T")" | 012 | INICIO" >>$LOG_070
echo -e "MOD012 --> LOG = "${LOG_012}

##########################################
echo -e $(date +"%T")" NORMALIZACION NUMERICA - Normalizamos los campos NUMERICOS (que tenga sentido) de las tablas brutas iniciales (para que las tablas derivadas ya trabajen con datos normalizados)..." 2>&1 1>>${LOG_012}

read -d '' CONSULTA_NORMALIZACIONES <<- EOF
set @min_hora=(select MIN(hora) FROM datos_desa.tb_galgos_carreras_LIM);
set @diff_hora=(select CASE WHEN MIN(hora)=0 THEN MAX(hora) ELSE MAX(hora)-MIN(hora) END FROM datos_desa.tb_galgos_carreras_LIM);
set @min_distancia=(select MIN(distancia) FROM datos_desa.tb_galgos_carreras_LIM);
set @diff_distancia=(select CASE WHEN MIN(distancia)=0 THEN MAX(distancia) ELSE MAX(distancia)-MIN(distancia) END FROM datos_desa.tb_galgos_carreras_LIM);
set @min_num_galgos=(select MIN(num_galgos) FROM datos_desa.tb_galgos_carreras_LIM);
set @diff_num_galgos=(select CASE WHEN MIN(num_galgos)=0 THEN MAX(num_galgos) ELSE MAX(num_galgos)-MIN(num_galgos) END FROM datos_desa.tb_galgos_carreras_LIM);
set @min_premio_primero=(select MIN(premio_primero) FROM datos_desa.tb_galgos_carreras_LIM);
set @diff_premio_primero=(select CASE WHEN MIN(premio_primero)=0 THEN MAX(premio_primero) ELSE MAX(premio_primero)-MIN(premio_primero) END FROM datos_desa.tb_galgos_carreras_LIM);
set @min_premio_segundo=(select MIN(premio_segundo) FROM datos_desa.tb_galgos_carreras_LIM);
set @diff_premio_segundo=(select CASE WHEN MIN(premio_segundo)=0 THEN MAX(premio_segundo) ELSE MAX(premio_segundo)-MIN(premio_segundo) END FROM datos_desa.tb_galgos_carreras_LIM);
set @min_premio_otros=(select MIN(premio_otros) FROM datos_desa.tb_galgos_carreras_LIM);
set @diff_premio_otros=(select CASE WHEN MIN(premio_otros)=0 THEN MAX(premio_otros) ELSE MAX(premio_otros)-MIN(premio_otros) END FROM datos_desa.tb_galgos_carreras_LIM);
set @min_premio_total_carrera=(select MIN(premio_total_carrera) FROM datos_desa.tb_galgos_carreras_LIM);
set @diff_premio_total_carrera=(select CASE WHEN MIN(premio_total_carrera)=0 THEN MAX(premio_total_carrera) ELSE MAX(premio_total_carrera)-MIN(premio_total_carrera) END FROM datos_desa.tb_galgos_carreras_LIM);
set @min_going_allowance_segundos=(select MIN(going_allowance_segundos) FROM datos_desa.tb_galgos_carreras_LIM);
set @diff_going_allowance_segundos=(select CASE WHEN MIN(going_allowance_segundos)=0 THEN MAX(going_allowance_segundos) ELSE MAX(going_allowance_segundos)-MIN(going_allowance_segundos) END FROM datos_desa.tb_galgos_carreras_LIM);
set @min_fc_1=(select MIN(fc_1) FROM datos_desa.tb_galgos_carreras_LIM);
set @diff_fc_1=(select CASE WHEN MIN(fc_1)=0 THEN MAX(fc_1) ELSE MAX(fc_1)-MIN(fc_1) END FROM datos_desa.tb_galgos_carreras_LIM);
set @min_fc_2=(select MIN(fc_2) FROM datos_desa.tb_galgos_carreras_LIM);
set @diff_fc_2=(select CASE WHEN MIN(fc_2)=0 THEN MAX(fc_2) ELSE MAX(fc_2)-MIN(fc_2) END FROM datos_desa.tb_galgos_carreras_LIM);
set @min_fc_pounds=(select MIN(fc_pounds) FROM datos_desa.tb_galgos_carreras_LIM);
set @diff_fc_pounds=(select CASE WHEN MIN(fc_pounds)=0 THEN MAX(fc_pounds) ELSE MAX(fc_pounds)-MIN(fc_pounds) END FROM datos_desa.tb_galgos_carreras_LIM);
set @min_tc_1=(select MIN(tc_1) FROM datos_desa.tb_galgos_carreras_LIM);
set @diff_tc_1=(select CASE WHEN MIN(tc_1)=0 THEN MAX(tc_1) ELSE MAX(tc_1)-MIN(tc_1) END FROM datos_desa.tb_galgos_carreras_LIM);
set @min_tc_2=(select MIN(tc_2) FROM datos_desa.tb_galgos_carreras_LIM);
set @diff_tc_2=(select CASE WHEN MIN(tc_2)=0 THEN MAX(tc_2) ELSE MAX(tc_2)-MIN(tc_2) END FROM datos_desa.tb_galgos_carreras_LIM);
set @min_tc_3=(select MIN(tc_3) FROM datos_desa.tb_galgos_carreras_LIM);
set @diff_tc_3=(select CASE WHEN MIN(tc_3)=0 THEN MAX(tc_3) ELSE MAX(tc_3)-MIN(tc_3) END FROM datos_desa.tb_galgos_carreras_LIM);


DROP TABLE IF EXISTS datos_desa.tb_galgos_carreras_norm;

CREATE TABLE datos_desa.tb_galgos_carreras_norm AS 
SELECT 
dentro.*,
CASE WHEN dlmxjvs=1 THEN 1 ELSE 0 END AS dow_d,
CASE WHEN dlmxjvs=2 THEN 1 ELSE 0 END AS dow_l,
CASE WHEN dlmxjvs=3 THEN 1 ELSE 0 END AS dow_m,
CASE WHEN dlmxjvs=4 THEN 1 ELSE 0 END AS dow_x,
CASE WHEN dlmxjvs=5 THEN 1 ELSE 0 END AS dow_j,
CASE WHEN dlmxjvs=6 THEN 1 ELSE 0 END AS dow_v,
CASE WHEN dlmxjvs=7 THEN 1 ELSE 0 END AS dow_s,
CASE WHEN (dlmxjvs=6 OR dlmxjvs=7 OR dlmxjvs=1) THEN 1 ELSE 0 END AS dow_finde,
CASE WHEN (dlmxjvs<>6 AND dlmxjvs<>7 AND dlmxjvs<>1) THEN 1 ELSE 0 END AS dow_laborable

FROM (
  SELECT 
  id_carrera,
  id_campeonato,
  track,
  clase,
  DAYOFWEEK(concat(anio,'-',  LPAD(cast(mes as char), 2, '0')    ,'-',dia)) AS dlmxjvs,
  anio,
  mes, 
  CASE WHEN (mes <=7) THEN (-1/6 + mes/6) WHEN (mes >7) THEN (5/12 - 5*mes/144) ELSE 0.5 END AS mes_norm,
  dia,
  hora, 
  CASE WHEN (hora IS NULL OR @diff_hora=0) THEN NULL ELSE ((hora - @min_hora)/@diff_hora) END AS hora_norm,
  minuto,
  distancia, 
  CASE WHEN (distancia IS NULL OR @diff_distancia=0) THEN NULL ELSE ((distancia - @min_distancia)/@diff_distancia) END AS distancia_norm,
  num_galgos,
  CASE WHEN (num_galgos IS NULL OR @diff_num_galgos=0) THEN NULL ELSE ((num_galgos - @min_num_galgos)/@diff_num_galgos) END AS num_galgos_norm,
  premio_primero, 
  CASE WHEN (premio_primero IS NULL OR @diff_premio_primero=0) THEN NULL ELSE ((premio_primero - @min_premio_primero)/@diff_premio_primero) END AS premio_primero_norm,
  premio_segundo, 
  CASE WHEN (premio_segundo IS NULL OR @diff_premio_segundo=0) THEN NULL ELSE ((premio_segundo - @min_premio_segundo)/@diff_premio_segundo) END AS premio_segundo_norm,
  premio_otros, 
  CASE WHEN (premio_otros IS NULL OR @diff_premio_otros=0) THEN NULL ELSE ((premio_otros - @min_premio_otros)/@diff_premio_otros) END AS premio_otros_norm,
  premio_total_carrera, 
  CASE WHEN (premio_total_carrera IS NULL OR @diff_premio_total_carrera=0) THEN NULL ELSE ((premio_total_carrera - @min_premio_total_carrera)/@diff_premio_total_carrera) END AS premio_total_carrera_norm,
  going_allowance_segundos, 
  CASE WHEN (going_allowance_segundos IS NULL OR @diff_going_allowance_segundos=0) THEN NULL ELSE ROUND( ((going_allowance_segundos - @min_going_allowance_segundos)/@diff_going_allowance_segundos) ,6) END AS going_allowance_segundos_norm,
  fc_1, 
  CASE WHEN (fc_1 IS NULL OR @diff_fc_1=0) THEN NULL ELSE ((fc_1 - @min_fc_1)/@diff_fc_1) END AS fc_1_norm,
  fc_2, 
  CASE WHEN (fc_2 IS NULL OR @diff_fc_2=0) THEN NULL ELSE ((fc_2 - @min_fc_2)/@diff_fc_2) END AS fc_2_norm,
  fc_pounds, 
  CASE WHEN (fc_pounds IS NULL OR @diff_fc_pounds=0) THEN NULL ELSE ROUND( ((fc_pounds - @min_fc_pounds)/@diff_fc_pounds) ,6) END AS fc_pounds_norm,
  tc_1, 
  CASE WHEN (tc_1 IS NULL OR @diff_tc_1=0) THEN NULL ELSE ((tc_1 - @min_tc_1)/@diff_tc_1) END AS tc_1_norm,
  tc_2, 
  CASE WHEN (tc_2 IS NULL OR @diff_tc_2=0) THEN NULL ELSE ((tc_2 - @min_tc_2)/@diff_tc_2) END AS tc_2_norm,
  tc_3, 
  CASE WHEN (tc_3 IS NULL OR @diff_tc_3=0) THEN NULL ELSE ((tc_3 - @min_tc_3)/@diff_tc_3) END AS tc_3_norm,
  tc_pounds, 
  CASE WHEN (tc_pounds IS NULL OR @diff_tc_pounds=0) THEN NULL ELSE ROUND( ((tc_pounds - @min_tc_pounds)/@diff_tc_pounds) ,6) END AS tc_pounds_norm
  FROM datos_desa.tb_galgos_carreras_LIM
) dentro;


SELECT * FROM datos_desa.tb_galgos_carreras_norm LIMIT 5;
SELECT count(*) as num_carreras_norm FROM datos_desa.tb_galgos_carreras_norm LIMIT 5;



set @min_posicion=(select MIN(posicion) FROM datos_desa.tb_galgos_posiciones_en_carreras_LIM);
set @diff_posicion=(select CASE WHEN MIN(posicion)=0 THEN MAX(posicion) ELSE MAX(posicion)-MIN(posicion) END FROM datos_desa.tb_galgos_posiciones_en_carreras_LIM);
set @min_trap=(select MIN(trap) FROM datos_desa.tb_galgos_posiciones_en_carreras_LIM);
set @diff_trap=(select CASE WHEN MIN(trap)=0 THEN MAX(trap) ELSE MAX(trap)-MIN(trap) END FROM datos_desa.tb_galgos_posiciones_en_carreras_LIM);
set @min_time_sec=(select MIN(time_sec) FROM datos_desa.tb_galgos_posiciones_en_carreras_LIM);
set @diff_time_sec=(select CASE WHEN MIN(time_sec)=0 THEN MAX(time_sec) ELSE MAX(time_sec)-MIN(time_sec) END FROM datos_desa.tb_galgos_posiciones_en_carreras_LIM);
set @min_time_distance=(select MIN(time_distance) FROM datos_desa.tb_galgos_posiciones_en_carreras_LIM);
set @diff_time_distance=(select CASE WHEN MIN(time_distance)=0 THEN MAX(time_distance) ELSE MAX(time_distance)-MIN(time_distance) END FROM datos_desa.tb_galgos_posiciones_en_carreras_LIM);
set @min_peso_galgo=(select MIN(peso_galgo) FROM datos_desa.tb_galgos_posiciones_en_carreras_LIM);
set @diff_peso_galgo=(select CASE WHEN MIN(peso_galgo)=0 THEN MAX(peso_galgo) ELSE MAX(peso_galgo)-MIN(peso_galgo) END FROM datos_desa.tb_galgos_posiciones_en_carreras_LIM);
set @min_nacimiento=(select MIN(nacimiento) FROM datos_desa.tb_galgos_posiciones_en_carreras_LIM);
set @diff_nacimiento=(select CASE WHEN MIN(nacimiento)=0 THEN MAX(nacimiento) ELSE MAX(nacimiento)-MIN(nacimiento) END FROM datos_desa.tb_galgos_posiciones_en_carreras_LIM);

set @diff_edad_en_dias=(select CASE WHEN MIN(edad_en_dias)=0 THEN MAX(edad_en_dias) ELSE MAX(edad_en_dias)-MIN(edad_en_dias) END FROM datos_desa.tb_galgos_posiciones_en_carreras_LIM);


DROP TABLE IF EXISTS datos_desa.tb_galgos_posiciones_en_carreras_norm;

CREATE TABLE datos_desa.tb_galgos_posiciones_en_carreras_norm AS 
SELECT 
id_carrera,
id_campeonato,
posicion, 
CASE WHEN (posicion IS NULL OR @diff_posicion=0) THEN NULL ELSE ROUND( ((posicion - @min_posicion)/@diff_posicion) ,6) END AS posicion_norm,
galgo_nombre,
trap, 
CASE WHEN (trap IS NULL OR @diff_trap=0) THEN NULL ELSE ((trap - @min_trap)/@diff_trap) END AS trap_norm,
sp, 
CASE WHEN sp<=1 THEN 0 WHEN (sp>1 AND sp<=5) THEN ROUND( ((sp-1)/5) ,6) WHEN (sp>5 AND sp<=8) THEN ROUND( ((sp+7)/15) ,6) WHEN sp>8 THEN 1 ELSE NULL END AS sp_norm,
time_sec, 
CASE WHEN (time_sec IS NULL OR @diff_time_sec=0) THEN NULL ELSE ROUND( ((time_sec - @min_time_sec)/@diff_time_sec) ,6) END AS time_sec_norm,
time_distance, 
CASE WHEN (time_distance IS NULL OR @diff_time_distance=0) THEN NULL ELSE ROUND( ((time_distance - @min_time_distance)/@diff_time_distance) ,6) END AS time_distance_norm,
peso_galgo, 
CASE WHEN (peso_galgo IS NULL OR @diff_peso_galgo=0) THEN NULL ELSE ROUND( ((peso_galgo - @min_peso_galgo)/@diff_peso_galgo) ,6) END AS peso_galgo_norm,
entrenador_nombre,
galgo_padre,
galgo_madre,
comment,
edad_en_dias, 
CASE WHEN (edad_en_dias IS NULL OR @diff_eed=0) THEN NULL WHEN (edad_en_dias >=1600) THEN 1 ELSE (edad_en_dias/1600) END AS edad_en_dias_norm

FROM datos_desa.tb_galgos_posiciones_en_carreras_LIM;

ALTER TABLE datos_desa.tb_galgos_posiciones_en_carreras_norm ADD INDEX tb_GPECN_idx(id_carrera,galgo_nombre);

SELECT * FROM datos_desa.tb_galgos_posiciones_en_carreras_norm LIMIT 5;
SELECT count(*) as num_posiciones_en_carreras_norm FROM datos_desa.tb_galgos_posiciones_en_carreras_norm LIMIT 5;


set @min_distancia=(select MIN(distancia) FROM datos_desa.tb_galgos_historico_LIM);
set @diff_distancia=(select CASE WHEN MIN(distancia)=0 THEN MAX(distancia) ELSE MAX(distancia)-MIN(distancia) END FROM datos_desa.tb_galgos_historico_LIM);
set @min_trap=(select MIN(trap) FROM datos_desa.tb_galgos_historico_LIM);
set @diff_trap=(select CASE WHEN MIN(trap)=0 THEN MAX(trap) ELSE MAX(trap)-MIN(trap) END FROM datos_desa.tb_galgos_historico_LIM);
set @min_stmhcp=(select MIN(cast(stmhcp AS decimal(6,2))) FROM datos_desa.tb_galgos_historico_LIM);
set @diff_stmhcp=(select CASE WHEN MIN(cast(stmhcp AS decimal(6,2)))=0 THEN MAX(cast(stmhcp AS decimal(6,2))) ELSE MAX(cast(stmhcp AS decimal(6,2))) - MIN(cast(stmhcp AS decimal(6,2))) END FROM datos_desa.tb_galgos_historico_LIM);
set @min_posicion=(select MIN(posicion) FROM datos_desa.tb_galgos_historico_LIM);
set @diff_posicion=(select CASE WHEN MIN(posicion)=0 THEN MAX(posicion) ELSE MAX(posicion)-MIN(posicion) END FROM datos_desa.tb_galgos_historico_LIM);
set @min_win_time=(select MIN(win_time) FROM datos_desa.tb_galgos_historico_LIM);
set @diff_win_time=(select CASE WHEN MIN(win_time)=0 THEN MAX(win_time) ELSE MAX(win_time)-MIN(win_time) END FROM datos_desa.tb_galgos_historico_LIM);
set @min_calculated_time=(select MIN(calculated_time) FROM datos_desa.tb_galgos_historico_LIM);
set @diff_calculated_time=(select CASE WHEN MIN(calculated_time)=0 THEN MAX(calculated_time) ELSE MAX(calculated_time)-MIN(calculated_time) END FROM datos_desa.tb_galgos_historico_LIM);
set @min_velocidad_real=(select MIN(velocidad_real) FROM datos_desa.tb_galgos_historico_LIM);
set @diff_velocidad_real=(select CASE WHEN MIN(velocidad_real)=0 THEN MAX(velocidad_real) ELSE MAX(velocidad_real)-MIN(velocidad_real) END FROM datos_desa.tb_galgos_historico_LIM);
set @min_velocidad_con_going=(select MIN(velocidad_con_going) FROM datos_desa.tb_galgos_historico_LIM);
set @diff_velocidad_con_going=(select CASE WHEN MIN(velocidad_con_going)=0 THEN MAX(velocidad_con_going) ELSE MAX(velocidad_con_going)-MIN(velocidad_con_going) END FROM datos_desa.tb_galgos_historico_LIM);


DROP TABLE IF EXISTS datos_desa.tb_galgos_historico_norm;

CREATE TABLE datos_desa.tb_galgos_historico_norm AS 
SELECT 
galgo_nombre, entrenador, id_carrera, id_campeonato, anio,
mes, CASE WHEN (mes <=7) THEN (-1/6 + mes/6) WHEN (mes >7) THEN (5/12 - 5*mes/144) ELSE 0.5 END AS mes_norm,
dia,
distancia, 
CASE WHEN (distancia IS NULL OR @diff_distancia=0) THEN NULL ELSE ((distancia - @min_distancia)/@diff_distancia) END AS distancia_norm,
trap, 
CASE WHEN (trap IS NULL OR @diff_trap=0) THEN NULL ELSE ROUND( ((trap - @min_trap)/@diff_trap) ,6) END AS trap_norm,
cast(stmhcp AS decimal(6,2)) AS stmhcp,
CASE WHEN (stmhcp IS NULL OR @diff_stmhcp=0) THEN NULL ELSE ROUND( ((cast(stmhcp AS decimal(6,2)) - @min_stmhcp)/@diff_stmhcp) ,6) END AS stmhcp_norm,
posicion, 
CASE WHEN (posicion IS NULL OR @diff_posicion=0) THEN NULL ELSE ROUND( ((posicion - @min_posicion)/@diff_posicion) ,6) END AS posicion_norm,
by_dato,
galgo_primero_o_segundo,
venue,
remarks,
win_time, 
CASE WHEN (win_time IS NULL OR @diff_win_time=0) THEN NULL ELSE ROUND( ((win_time - @min_win_time)/@diff_win_time) ,6) END AS win_time_norm,
going,
sp, 
CASE WHEN sp<=1 THEN 0 WHEN (sp>1 AND sp<=5) THEN ((sp-1)/5) WHEN (sp>5 AND sp<=8) THEN ((sp+7)/15) WHEN sp>8 THEN 1 ELSE NULL END AS sp_norm,
clase,
calculated_time, 
CASE WHEN (calculated_time IS NULL OR @diff_calculated_time=0) THEN NULL ELSE ROUND( ((calculated_time - @min_calculated_time)/@diff_calculated_time) ,6) END AS calculated_time_norm,
velocidad_real, 
CASE WHEN (velocidad_real IS NULL OR @diff_velocidad_real=0) THEN NULL ELSE ROUND( ((velocidad_real - @min_velocidad_real)/@diff_velocidad_real) ,6) END AS velocidad_real_norm,
velocidad_con_going, 
CASE WHEN (velocidad_con_going IS NULL OR @diff_velocidad_con_going=0) THEN NULL ELSE ROUND( ((velocidad_con_going - @min_velocidad_con_going)/@diff_velocidad_con_going) ,6) END AS velocidad_con_going_norm
FROM datos_desa.tb_galgos_historico_LIM;

ALTER TABLE datos_desa.tb_galgos_historico_norm ADD INDEX tb_galgos_historico_norm_idx1(id_carrera, galgo_nombre);
ALTER TABLE datos_desa.tb_galgos_historico_norm ADD INDEX tb_galgos_historico_norm_idx2(galgo_nombre,clase);

SELECT * FROM datos_desa.tb_galgos_historico_norm LIMIT 5;
SELECT count(*) as num_GH_norm FROM datos_desa.tb_galgos_historico_norm LIMIT 5;


set @min_vel_real_cortas_mediana=(select MIN(vel_real_cortas_mediana) FROM datos_desa.tb_galgos_agregados_LIM);
set @diff_vel_real_cortas_mediana=(select CASE WHEN MIN(vel_real_cortas_mediana)=0 THEN MAX(vel_real_cortas_mediana) ELSE MAX(vel_real_cortas_mediana)-MIN(vel_real_cortas_mediana) END FROM datos_desa.tb_galgos_agregados_LIM);
set @min_vel_real_cortas_max=(select MIN(vel_real_cortas_max) FROM datos_desa.tb_galgos_agregados_LIM);
set @diff_vel_real_cortas_max=(select CASE WHEN MIN(vel_real_cortas_max)=0 THEN MAX(vel_real_cortas_max) ELSE MAX(vel_real_cortas_max)-MIN(vel_real_cortas_max) END FROM datos_desa.tb_galgos_agregados_LIM);
set @min_vel_going_cortas_mediana=(select MIN(vel_going_cortas_mediana) FROM datos_desa.tb_galgos_agregados_LIM);
set @diff_vel_going_cortas_mediana=(select CASE WHEN MIN(vel_going_cortas_mediana)=0 THEN MAX(vel_going_cortas_mediana) ELSE MAX(vel_going_cortas_mediana)-MIN(vel_going_cortas_mediana) END FROM datos_desa.tb_galgos_agregados_LIM);
set @min_vel_going_cortas_max=(select MIN(vel_going_cortas_max) FROM datos_desa.tb_galgos_agregados_LIM);
set @diff_vel_going_cortas_max=(select CASE WHEN MIN(vel_going_cortas_max)=0 THEN MAX(vel_going_cortas_max) ELSE MAX(vel_going_cortas_max)-MIN(vel_going_cortas_max) END FROM datos_desa.tb_galgos_agregados_LIM);
set @min_vel_real_longmedias_mediana=(select MIN(vel_real_longmedias_mediana) FROM datos_desa.tb_galgos_agregados_LIM);
set @diff_vel_real_longmedias_mediana=(select CASE WHEN MIN(vel_real_longmedias_mediana)=0 THEN MAX(vel_real_longmedias_mediana) ELSE MAX(vel_real_longmedias_mediana)-MIN(vel_real_longmedias_mediana) END FROM datos_desa.tb_galgos_agregados_LIM);
set @min_vel_real_longmedias_max=(select MIN(vel_real_longmedias_max) FROM datos_desa.tb_galgos_agregados_LIM);
set @diff_vel_real_longmedias_max=(select CASE WHEN MIN(vel_real_longmedias_max)=0 THEN MAX(vel_real_longmedias_max) ELSE MAX(vel_real_longmedias_max)-MIN(vel_real_longmedias_max) END FROM datos_desa.tb_galgos_agregados_LIM);
set @min_vel_going_longmedias_mediana=(select MIN(vel_going_longmedias_mediana) FROM datos_desa.tb_galgos_agregados_LIM);
set @diff_vel_going_longmedias_mediana=(select CASE WHEN MIN(vel_going_longmedias_mediana)=0 THEN MAX(vel_going_longmedias_mediana) ELSE MAX(vel_going_longmedias_mediana)-MIN(vel_going_longmedias_mediana) END FROM datos_desa.tb_galgos_agregados_LIM);
set @min_vel_going_longmedias_max=(select MIN(vel_going_longmedias_max) FROM datos_desa.tb_galgos_agregados_LIM);
set @diff_vel_going_longmedias_max=(select CASE WHEN MIN(vel_going_longmedias_max)=0 THEN MAX(vel_going_longmedias_max) ELSE MAX(vel_going_longmedias_max)-MIN(vel_going_longmedias_max) END FROM datos_desa.tb_galgos_agregados_LIM);
set @min_vel_real_largas_mediana=(select MIN(vel_real_largas_mediana) FROM datos_desa.tb_galgos_agregados_LIM);
set @diff_vel_real_largas_mediana=(select CASE WHEN MIN(vel_real_largas_mediana)=0 THEN MAX(vel_real_largas_mediana) ELSE MAX(vel_real_largas_mediana)-MIN(vel_real_largas_mediana) END FROM datos_desa.tb_galgos_agregados_LIM);
set @min_vel_real_largas_max=(select MIN(vel_real_largas_max) FROM datos_desa.tb_galgos_agregados_LIM);
set @diff_vel_real_largas_max=(select CASE WHEN MIN(vel_real_largas_max)=0 THEN MAX(vel_real_largas_max) ELSE MAX(vel_real_largas_max)-MIN(vel_real_largas_max) END FROM datos_desa.tb_galgos_agregados);
set @min_vel_going_largas_mediana=(select MIN(vel_going_largas_mediana) FROM datos_desa.tb_galgos_agregados_LIM);
set @diff_vel_going_largas_mediana=(select CASE WHEN MIN(vel_going_largas_mediana)=0 THEN MAX(vel_going_largas_mediana) ELSE MAX(vel_going_largas_mediana)-MIN(vel_going_largas_mediana) END FROM datos_desa.tb_galgos_agregados_LIM);
set @min_vel_going_largas_max=(select MIN(vel_going_largas_max) FROM datos_desa.tb_galgos_agregados_LIM);
set @diff_vel_going_largas_max=(select CASE WHEN MIN(vel_going_largas_max)=0 THEN MAX(vel_going_largas_max) ELSE MAX(vel_going_largas_max)-MIN(vel_going_largas_max) END FROM datos_desa.tb_galgos_agregados_LIM);


DROP TABLE IF EXISTS datos_desa.tb_galgos_agregados_norm;

CREATE TABLE datos_desa.tb_galgos_agregados_norm AS 
SELECT 
galgo_nombre,
vel_real_cortas_mediana, 
CASE WHEN (vel_real_cortas_mediana IS NULL OR @diff_vel_real_cortas_mediana=0) THEN NULL ELSE ROUND( ((vel_real_cortas_mediana - @min_vel_real_cortas_mediana)/@diff_vel_real_cortas_mediana) ,6) END AS vel_real_cortas_mediana_norm,
vel_real_cortas_max, 
CASE WHEN (vel_real_cortas_max IS NULL OR @diff_vel_real_cortas_max=0) THEN NULL ELSE ROUND( ((vel_real_cortas_max - @min_vel_real_cortas_max)/@diff_vel_real_cortas_max) ,6) END AS vel_real_cortas_max_norm,
vel_going_cortas_mediana, 
CASE WHEN (vel_going_cortas_mediana IS NULL OR @diff_vel_going_cortas_mediana=0) THEN NULL ELSE ROUND( ((vel_going_cortas_mediana - @min_vel_going_cortas_mediana)/@diff_vel_going_cortas_mediana) ,6) END AS vel_going_cortas_mediana_norm,
vel_going_cortas_max, 
CASE WHEN (vel_going_cortas_max IS NULL OR @diff_vel_going_cortas_max=0) THEN NULL ELSE ROUND( ((vel_going_cortas_max - @min_vel_going_cortas_max)/@diff_vel_going_cortas_max) ,6) END AS vel_going_cortas_max_norm,
vel_real_longmedias_mediana, 
CASE WHEN (vel_real_longmedias_mediana IS NULL OR @diff_vel_real_longmedias_mediana=0) THEN NULL ELSE ROUND( ((vel_real_longmedias_mediana - @min_vel_real_longmedias_mediana)/@diff_vel_real_longmedias_mediana) ,6) END AS vel_real_longmedias_mediana_norm,
vel_real_longmedias_max, 
CASE WHEN (vel_real_longmedias_max IS NULL OR @diff_vel_real_longmedias_max=0) THEN NULL ELSE ROUND( ((vel_real_longmedias_max - @min_vel_real_longmedias_max)/@diff_vel_real_longmedias_max) ,6) END AS vel_real_longmedias_max_norm,
vel_going_longmedias_mediana, 
CASE WHEN (vel_going_longmedias_mediana IS NULL OR @diff_vel_going_longmedias_mediana=0) THEN NULL ELSE ROUND( ((vel_going_longmedias_mediana - @min_vel_going_longmedias_mediana)/@diff_vel_going_longmedias_mediana) ,6) END AS vel_going_longmedias_mediana_norm,
vel_going_longmedias_max, 
CASE WHEN (vel_going_longmedias_max IS NULL OR @diff_vel_going_longmedias_max=0) THEN NULL ELSE ROUND( ((vel_going_longmedias_max - @min_vel_going_longmedias_max)/@diff_vel_going_longmedias_max) ,6) END AS vel_going_longmedias_max_norm,
vel_real_largas_mediana, 
CASE WHEN (vel_real_largas_mediana IS NULL OR @diff_vel_real_largas_mediana=0) THEN NULL ELSE ROUND( ((vel_real_largas_mediana - @min_vel_real_largas_mediana)/@diff_vel_real_largas_mediana) ,6) END AS vel_real_largas_mediana_norm,
vel_real_largas_max, 
CASE WHEN (vel_real_largas_max IS NULL OR @diff_vel_real_largas_max=0) THEN NULL ELSE ROUND( ((vel_real_largas_max - @min_vel_real_largas_max)/@diff_vel_real_largas_max) ,6) END AS vel_real_largas_max_norm,
vel_going_largas_mediana, 
CASE WHEN (vel_going_largas_mediana IS NULL OR @diff_vel_going_largas_mediana=0) THEN NULL ELSE ROUND( ((vel_going_largas_mediana - @min_vel_going_largas_mediana)/@diff_vel_going_largas_mediana) ,6) END AS vel_going_largas_mediana_norm,
vel_going_largas_max, 
CASE WHEN (vel_going_largas_max IS NULL OR @diff_vel_going_largas_max=0) THEN NULL ELSE ROUND( ((vel_going_largas_max - @min_vel_going_largas_max)/@diff_vel_going_largas_max) ,6) END AS vel_going_largas_max_norm

FROM datos_desa.tb_galgos_agregados_LIM;

SELECT * FROM datos_desa.tb_galgos_agregados_norm LIMIT 5;
SELECT count(*) as num_galgos_agregados_norm FROM datos_desa.tb_galgos_agregados_norm LIMIT 5;
EOF

#echo -e "$CONSULTA_NORMALIZACIONES" 2>&1 1>>${LOG_012}

echo -e "\n----------- Tablas NORMALIZADAS --------------" 2>&1 1>>${LOG_012}
echo -e "datos_desa.tb_galgos_carreras_norm" 2>&1 1>>${LOG_012}
echo -e "datos_desa.tb_galgos_posiciones_en_carreras_norm" 2>&1 1>>${LOG_012}
echo -e "datos_desa.tb_galgos_historico_norm" 2>&1 1>>${LOG_012}
echo -e "datos_desa.tb_galgos_agregados_norm" 2>&1 1>>${LOG_012}
echo -e "----------------------------------------------------\n\n\n" 2>&1 1>>${LOG_012}

mysql -u root --password=datos1986 --execute="$CONSULTA_NORMALIZACIONES" 2>&1 1>>${LOG_012}


##########################################

echo -e $(date +"%T")" | 012 | FIN" >>$LOG_070



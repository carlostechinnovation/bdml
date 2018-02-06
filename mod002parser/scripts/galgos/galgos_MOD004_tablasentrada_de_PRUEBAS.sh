#!/bin/bash


echo -e "Generando tablas de entrada de PRUEBAS para ver si los algoritmos de ML predicen bien." 2>&1 1>>${LOG_DS}

DROP TABLE datos_desa.tb_ds_pasado_train_features_SUBGRUPO_X2;
DROP TABLE datos_desa.tb_ds_pasado_train_targets_SUBGRUPO_X2;
DROP TABLE datos_desa.tb_ds_pasado_test_features_SUBGRUPO_X2;
DROP TABLE datos_desa.tb_ds_pasado_test_targets_SUBGRUPO_X2;
DROP TABLE datos_desa.tb_ds_pasado_validation_features_SUBGRUPO_X2;
DROP TABLE datos_desa.tb_ds_pasado_validation_targets_SUBGRUPO_X2;

CREATE TABLE datos_desa.tb_ds_pasado_train_features_SUBGRUPO_X2 (edad_en_dias_norm decimal(8,6) DEFAULT NULL, experiencia decimal(8,6) DEFAULT NULL, trap_norm double DEFAULT NULL);
CREATE TABLE datos_desa.tb_ds_pasado_test_features_SUBGRUPO_X2 (edad_en_dias_norm decimal(8,6) DEFAULT NULL, experiencia decimal(8,6) DEFAULT NULL, trap_norm double DEFAULT NULL);
CREATE TABLE datos_desa.tb_ds_pasado_validation_features_SUBGRUPO_X2 (edad_en_dias_norm decimal(8,6) DEFAULT NULL, experiencia decimal(8,6) DEFAULT NULL, trap_norm double DEFAULT NULL);

CREATE TABLE datos_desa.tb_ds_pasado_train_targets_SUBGRUPO_X2 (target decimal(8,6) DEFAULT NULL);
CREATE TABLE datos_desa.tb_ds_pasado_test_targets_SUBGRUPO_X2 (target decimal(8,6) DEFAULT NULL);
CREATE TABLE datos_desa.tb_ds_pasado_validation_targets_SUBGRUPO_X2 (target decimal(8,6) DEFAULT NULL);

INSERT INTO datos_desa.tb_ds_pasado_train_features_SUBGRUPO_X2 VALUES (0.2, 0.5, 0.1);
INSERT INTO datos_desa.tb_ds_pasado_train_features_SUBGRUPO_X2 VALUES (0.5, 0.5, 0.1);
INSERT INTO datos_desa.tb_ds_pasado_train_features_SUBGRUPO_X2 VALUES (0.9, 0.5, 0.1);
INSERT INTO datos_desa.tb_ds_pasado_train_features_SUBGRUPO_X2 VALUES (0.8, 0.5, 0.1);
INSERT INTO datos_desa.tb_ds_pasado_test_features_SUBGRUPO_X2 VALUES (0, 0.5, 0.1);
INSERT INTO datos_desa.tb_ds_pasado_test_features_SUBGRUPO_X2 VALUES (0.5, 0.5, 0.1);
INSERT INTO datos_desa.tb_ds_pasado_test_features_SUBGRUPO_X2 VALUES (1, 0.5, 0.1);
INSERT INTO datos_desa.tb_ds_pasado_validation_features_SUBGRUPO_X2 VALUES (0, 0.5, 0.1);
INSERT INTO datos_desa.tb_ds_pasado_validation_features_SUBGRUPO_X2 VALUES (1, 0.5, 0.1);
INSERT INTO datos_desa.tb_ds_pasado_validation_features_SUBGRUPO_X2 VALUES (0.7, 0.5, 0.1);

INSERT INTO datos_desa.tb_ds_pasado_train_targets_SUBGRUPO_X2 VALUES (0.87);
INSERT INTO datos_desa.tb_ds_pasado_train_targets_SUBGRUPO_X2 VALUES (0.7);
INSERT INTO datos_desa.tb_ds_pasado_train_targets_SUBGRUPO_X2 VALUES (0.3);
INSERT INTO datos_desa.tb_ds_pasado_train_targets_SUBGRUPO_X2 VALUES (0.4);
INSERT INTO datos_desa.tb_ds_pasado_test_targets_SUBGRUPO_X2 VALUES (0.9);
INSERT INTO datos_desa.tb_ds_pasado_test_targets_SUBGRUPO_X2 VALUES (0.7);
INSERT INTO datos_desa.tb_ds_pasado_test_targets_SUBGRUPO_X2 VALUES (0.2);
INSERT INTO datos_desa.tb_ds_pasado_validation_targets_SUBGRUPO_X2 VALUES (0.7);
INSERT INTO datos_desa.tb_ds_pasado_validation_targets_SUBGRUPO_X2 VALUES (0.7);
INSERT INTO datos_desa.tb_ds_pasado_validation_targets_SUBGRUPO_X2 VALUES (0.7);



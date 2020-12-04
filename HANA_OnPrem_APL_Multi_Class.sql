SET SESSION 'APL_CACHE_SCHEMA' = 'APL_CACHE';

-- 1.CREATING AND TRAINING THE APL CLASSIFICATION MODEL  
drop table FUNC_HEADER;
create table FUNC_HEADER like "SAP_PA_APL"."sap.pa.apl.base::BASE.T.FUNCTION_HEADER";
insert into FUNC_HEADER values ('Oid', 'IRIS');

drop table CREATE_AND_TRAIN_CONFIG;
create table CREATE_AND_TRAIN_CONFIG like "SAP_PA_APL"."sap.pa.apl.base::BASE.T.OPERATION_CONFIG_DETAILED";
insert into CREATE_AND_TRAIN_CONFIG values ('APL/ModelType', 'multiclass',null);
insert into CREATE_AND_TRAIN_CONFIG values ('APL/CuttingStrategy', 'random with no test',null);

drop table VARIABLE_DESC;
create table VARIABLE_DESC like "SAP_PA_APL"."sap.pa.apl.base::BASE.T.VARIABLE_DESC_OID";
insert into VARIABLE_DESC values (0,'ID','integer','continuous',1,0,NULL,NULL,'Unique Identifier',NULL);
insert into VARIABLE_DESC values (1,'SEPALLENGTHCM','number','continuous',0,0,NULL,NULL,NULL,NULL);
insert into VARIABLE_DESC values (2,'SEPALWIDTHCM','number','continuous',0,0,NULL,NULL,NULL,NULL);
insert into VARIABLE_DESC values (3,'PETALLENGTHCM','number','continuous',0,0,NULL,NULL,NULL,NULL);
insert into VARIABLE_DESC values (4,'PETALWIDTHCM','number','continuous',0,0,NULL,NULL,NULL,NULL);
insert into VARIABLE_DESC values (5,'SPECIES','string','nominal',0,0,NULL,NULL,'Flag',NULL);

drop table VARIABLE_ROLES;
create table VARIABLE_ROLES like "SAP_PA_APL"."sap.pa.apl.base::BASE.T.VARIABLE_ROLES_WITH_COMPOSITES_OID";

drop table MODEL_TRAIN_BIN;
create table MODEL_TRAIN_BIN like "SAP_PA_APL"."sap.pa.apl.base::BASE.T.MODEL_BIN_OID";

drop table OPERATION_LOG;
create table OPERATION_LOG like "SAP_PA_APL"."sap.pa.apl.base::BASE.T.OPERATION_LOG";

drop table SUMMARY;
create table SUMMARY like "SAP_PA_APL"."sap.pa.apl.base::BASE.T.SUMMARY";

drop table INDICATORS;
create table INDICATORS like "SAP_PA_APL"."sap.pa.apl.base::BASE.T.INDICATORS";

-- Run the APL function 
call "_SYS_AFL"."APL_CREATE_MODEL_AND_TRAIN"(FUNC_HEADER, CREATE_AND_TRAIN_CONFIG, VARIABLE_DESC, VARIABLE_ROLES, IRIS_DATA_TRAIN_TBL, MODEL_TRAIN_BIN, OPERATION_LOG, SUMMARY, INDICATORS) with overview;
select * from "MODEL_TRAIN_BIN";
select * from "OPERATION_LOG";
select * from "SUMMARY";
select * from "INDICATORS";

-- Display Variable Contributions  
select 
 OID as "Model Name",
row_number() OVER (partition by OID order by to_char(VALUE) desc) as "Rank",
VARIABLE as "Explanatory Variable", 
 round(to_double(to_char(VALUE)) *100 , 2) as "Individual Contribution",
round(sum(to_double(to_char(VALUE))) OVER (partition by OID order by to_char(VALUE) desc) *100 ,2) 
 as "Cumulative Contribution"
from 
 INDICATORS 
where 
 OID = 'IRIS'  and TARGET = 'SPECIES' and 
 KEY = 'VariableContribution'
order by 4 desc;

-- Display Learning Time
select 
 case key 
   when 'ModelVariableCount'			then 'Initial Number of Variables' 
   when 'ModelSelectedVariableCount'	then 'Number of Explanatory Variables'
   when 'NbVariablesKept'				then 'Number of Explanatory Variables'
   when 'ModelRecordCount'				then 'Number of Records'
   when 'ModelLearningTime' 			then 'Time to learn in seconds'
   else null 
  end as "Training Summary",
 to_double(value) as "Value"
from 
 SUMMARY 
where 
 OID = 'IRIS' and (KEY IN ('ModelLearningTime','NbVariablesKept') or KEY like 'Model%Count')
order by 1;

-- 2.APPLY THE APL CLASSIFICATION MODEL  
drop table APPLY_CONFIG;
create table APPLY_CONFIG like "SAP_PA_APL"."sap.pa.apl.base::BASE.T.OPERATION_CONFIG_DETAILED";
insert into APPLY_CONFIG values ('APL/ApplyExtraMode', 'BestProbabilityAndDecision',null);

drop table IRIS_SCORES;
create column table IRIS_SCORES (
    "ID" integer,
    "SPECIES" varchar(50),
    "gb_decision_SPECIES" varchar(50),
    "gb_best_proba_SPECIES" DOUBLE
);

drop table APPLY_LOG;
create column table APPLY_LOG like "SAP_PA_APL"."sap.pa.apl.base::BASE.T.OPERATION_LOG";

drop table APPLY_SUMMARY;
create column table APPLY_SUMMARY like "SAP_PA_APL"."sap.pa.apl.base::BASE.T.SUMMARY";

call "_SYS_AFL"."APL_APPLY_MODEL__OVERLOAD_4_1"(FUNC_HEADER, MODEL_TRAIN_BIN, APPLY_CONFIG, IRIS_DATA_TEST_TBL, IRIS_SCORES) with overview;

SELECT * FROM IRIS_SCORES;

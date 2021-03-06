CREATE COLUMN TABLE IRIS_DATA_TRAIN_TBL (
	 ID INTEGER,
	 SEPALLENGTHCM DOUBLE,
	 SEPALWIDTHCM DOUBLE,
	 PETALLENGTHCM DOUBLE,
	 PETALWIDTHCM DOUBLE,
	 SPECIES NVARCHAR(15));

CREATE COLUMN TABLE IRIS_DATA_TEST_TBL (
	 ID INTEGER,
	 SEPALLENGTHCM DOUBLE,
	 SEPALWIDTHCM DOUBLE,
	 PETALLENGTHCM DOUBLE,
	 PETALWIDTHCM DOUBLE,
	 SPECIES NVARCHAR(15));

CREATE COLUMN TABLE OZONERATE (
	 ID INTEGER NOT NULL,
	 OBSERVE_DATE DATE,
	 RATE NUMERIC(15,2));

CREATE COLUMN TABLE SUPPLIER (
   S_SUPPKEY INTEGER NOT NULL ,
	 S_NAME VARCHAR(25) NOT NULL ,
	 S_ADDRESS VARCHAR(40) NOT NULL ,
	 S_NATIONKEY INTEGER NOT NULL ,
	 S_PHONE VARCHAR(15) NOT NULL ,
	 S_ACCTBAL DECIMAL(15,2) NOT NULL ,
	 S_COMMENT VARCHAR(101) NOT NULL ) ;

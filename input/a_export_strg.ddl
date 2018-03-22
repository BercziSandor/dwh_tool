-- This CLP file was created using DB2LOOK Version "11.1" 
-- Timestamp: Tue Mar 20 10:18:50 MEZ 2018
-- Database Name: DWH_SV         
-- Database Manager Version: DB2/AIX64 Version 11.1.2.2    
-- Database Codepage: 819
-- Database Collating Sequence is: UNIQUE
-- Alternate collating sequence(alt_collate): null
-- varchar2 compatibility(varchar2_compat): OFF


CONNECT TO DWH_SV;

-----------------------------------------------------------
-- DDL Statements for Security Label Component "SCHUTZKLASSEN"
-----------------------------------------------------------

CREATE SECURITY LABEL COMPONENT "SCHUTZKLASSEN"
   SET {'DEPSEUDONYMISIERUNG'};

----------------------------------------------------------
-- DDL Statements for Security Policy "DATENZUGRIFF"
----------------------------------------------------------

CREATE SECURITY POLICY "DATENZUGRIFF" 
   COMPONENTS "SCHUTZKLASSEN"
   WITH DB2LBACRULES RESTRICT NOT AUTHORIZED WRITE SECURITY LABEL;

--------------------------------------------------------------
-- DDL Statements for Security Label "DATENZUGRIFF"."EINGESCHRAENKT"
--------------------------------------------------------------

CREATE SECURITY LABEL "DATENZUGRIFF"."EINGESCHRAENKT" 
   COMPONENT "SCHUTZKLASSEN" 'DEPSEUDONYMISIERUNG';

------------------------------------------------
-- DDL Statements for Table "DWH     "."A_EXPORT_STRG"
------------------------------------------------
 

CREATE TABLE "DWH     "."A_EXPORT_STRG"  (
		  "ZIELSYSTEM" VARCHAR(30) NOT NULL WITH DEFAULT '  ' , 
		  "TABNAME" VARCHAR(128) NOT NULL , 
		  "FILENAME_EXTENT" VARCHAR(64) NOT NULL WITH DEFAULT '  ' , 
		  "OUTVERZ" VARCHAR(128) NOT NULL , 
		  "DELIMITER" VARCHAR(4) , 
		  "AUSGABEFORMAT" CHAR(5) WITH DEFAULT 'DEL' , 
		  "MODIFIED" VARCHAR(150) , 
		  "AUSSCHLUSSFELD" VARCHAR(200) , 
		  "KOMP" CHAR(20) , 
		  "RESTART" CHAR(1) WITH DEFAULT 'J' , 
		  "WHERE_EXTENT" VARCHAR(200) , 
		  "ROW_DELIMITER" CHAR(10) , 
		  "PERIODE" CHAR(1) , 
		  "ZIELADRESSE" VARCHAR(30) , 
		  "ZIELVERZEICHNIS" VARCHAR(200) , 
		  "LOGIN" CHAR(20) , 
		  "PASSWD" CHAR(20) , 
		  "ZIEL_FILENAME" VARCHAR(128) , 
		  "FTP_CHK_FILE" CHAR(1) , 
		  "CHK_FILE_NAME" VARCHAR(128) , 
		  "CHK_FILE_FORMAT" VARCHAR(10) , 
		  "MERGE_OUTFILE" CHAR(1) , 
		  "ABNEHMER" VARCHAR(128) , 
		  "KEY_TYPE" VARCHAR(5) WITH DEFAULT '2' , 
		  "TRANS_VERFAHREN" VARCHAR(10) WITH DEFAULT 'FTP' , 
		  "CRYPT_TYPE" VARCHAR(10) WITH DEFAULT 'NO' , 
		  "CRYPT_KEY_FILE" VARCHAR(80) WITH DEFAULT 'NO' , 
		  "PORT" INTEGER WITH DEFAULT 22 , 
		  "CRYPT_LENGTH" VARCHAR(20) NOT NULL WITH DEFAULT 'NO' , 
		  "DYN_AUFTEILEN" CHAR(1) NOT NULL WITH DEFAULT 'N' , 
		  "DYN_AUFTEIL_FELD" VARCHAR(200) NOT NULL WITH DEFAULT 'NO' , 
		  "CODEPAGE" VARCHAR(10) , 
		  "SCHNITTSTELLEN_ID" CHAR(12) )   
		 IN "DW_NPART_TS" NOT LOGGED INITIALLY  
		 ORGANIZE BY ROW; 


-- DDL Statements for Primary Key on Table "DWH     "."A_EXPORT_STRG"

ALTER TABLE "DWH     "."A_EXPORT_STRG" 
	ADD PRIMARY KEY
		("ZIELSYSTEM",
		 "TABNAME",
		 "FILENAME_EXTENT");



-- ---------------------------
-- DDL Statements for WRAPPER
-- ---------------------------
CREATE WRAPPER "DRDA"
   LIBRARY 'libdb2drda.a' 
   OPTIONS (DB2_FENCED  'N'
     );


-- ---------------------------
-- DDL Statements for SERVER
-- ---------------------------
CREATE SERVER "SRCSRV" 
   TYPE DB2/UDB 
   VERSION '10.1' 
   WRAPPER "DRDA"  
   AUTHORIZATION ""
   PASSWORD ""
   OPTIONS
     (DB2_CONCAT_NULL_NULL  'Y'
     ,DB2_VARCHAR_BLANKPADDED_COMPARISON  'Y'
     ,DBNAME  'D_DWH_SV'
     ,NO_EMPTY_STRING  'N'
     );


-- --------------------------------
-- DDL Statements for USER MAPPING
-- --------------------------------
CREATE USER MAPPING FOR BDWHSV 
   SERVER "SRCSRV"
   OPTIONS
     (REMOTE_AUTHID  'dpcenter'
     ,REMOTE_PASSWORD  '***'
     );


-- --------------------------------
-- DDL Statements for NICKNAME
-- --------------------------------

-- DEFINER = BDWHSV  

CREATE NICKNAME "AWI     "."DUMMY" 
   FOR "SRCSRV"."DWH"."GER_DUMMY77";

ALTER NICKNAME "AWI     "."DUMMY" 
ALLOW CACHING;
CREATE NICKNAME "BDWHSV  "."DUMMY" 
   FOR "SRCSRV"."DWH"."GER_DUMMY77";

ALTER NICKNAME "BDWHSV  "."DUMMY" 
ALLOW CACHING;
CREATE NICKNAME "BDWHSV  "."MYANW" 
   FOR "SRCSRV"."DWH"."D_DEBITOR";

ALTER NICKNAME "BDWHSV  "."MYANW" 
   ALTER COLUMN "DEBITOR_NR" LOCAL TYPE CHARACTER (14);
ALTER NICKNAME "BDWHSV  "."MYANW" 
   ALTER COLUMN "GEO19_HA_ID" LOCAL TYPE CHARACTER (19);
ALTER NICKNAME "BDWHSV  "."MYANW" 
   ALTER COLUMN "GEOCODIERUNG_VERSION" LOCAL TYPE CHARACTER (6);
ALTER NICKNAME "BDWHSV  "."MYANW" 
   ALTER COLUMN "KUNDEN_NR" LOCAL TYPE CHARACTER (10);
ALTER NICKNAME "BDWHSV  "."MYANW" 
   ALTER COLUMN "FAKT_SYS" LOCAL TYPE CHARACTER (2);
ALTER NICKNAME "BDWHSV  "."MYANW" 
   ALTER COLUMN "TGR_BS_ST" LOCAL TYPE CHARACTER (2);
ALTER NICKNAME "BDWHSV  "."MYANW" 
   ALTER COLUMN "VBKZ_BS_ST" LOCAL TYPE CHARACTER (2);
ALTER NICKNAME "BDWHSV  "."MYANW" 
   ALTER COLUMN "ANREDESCHLUESSEL" LOCAL TYPE CHARACTER (1);
ALTER NICKNAME "BDWHSV  "."MYANW" 
   ALTER COLUMN "WERBUNG_JN" LOCAL TYPE CHARACTER (1);
ALTER NICKNAME "BDWHSV  "."MYANW" 
   ALTER COLUMN "SPERRKENNZ" LOCAL TYPE CHARACTER (1);
ALTER NICKNAME "BDWHSV  "."MYANW" 
   ALTER COLUMN "MAHNKENNZ" LOCAL TYPE CHARACTER (2);
ALTER NICKNAME "BDWHSV  "."MYANW" 
   ALTER COLUMN "MAHNVERFAHREN" LOCAL TYPE CHARACTER (2);
ALTER NICKNAME "BDWHSV  "."MYANW" 
   ALTER COLUMN "EVUE_VORHANDEN" LOCAL TYPE CHARACTER (1);
ALTER NICKNAME "BDWHSV  "."MYANW" 
ALLOW CACHING;



COMMIT WORK;

CONNECT RESET;

TERMINATE;


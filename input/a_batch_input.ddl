-- This CLP file was created using DB2LOOK Version "11.1" 
-- Timestamp: Tue Mar 20 16:56:12 MEZ 2018
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
-- DDL Statements for Table "DWH     "."A_BATCH_INPUT"
------------------------------------------------
 

CREATE TABLE "DWH     "."A_BATCH_INPUT"  (
		  "BATCHLAUF_TYP" VARCHAR(15) NOT NULL , 
		  "ZIELTABELLE" VARCHAR(50) NOT NULL , 
		  "REIHENFOLGE_NR" INTEGER NOT NULL , 
		  "FTP_VERZEICHNIS" VARCHAR(128) NOT NULL , 
		  "ARCHIV_VERZEICHNIS" VARCHAR(128) NOT NULL , 
		  "SUCHMUSTER" VARCHAR(80) NOT NULL , 
		  "DATEI_FEHLT_FEHLER" CHAR(1) NOT NULL , 
		  "DATEI_ABHOLEN" CHAR(1) , 
		  "LADE_ALLE_DATEIEN" CHAR(2) , 
		  "IGNORE_FIRSTLINE" CHAR(1) , 
		  "IGNORE_LASTLINE" CHAR(1) , 
		  "ENTPACKEN" VARCHAR(100) , 
		  "FELDER_AUS_DATNAME" VARCHAR(100) , 
		  "ZUSATZ_DATEIDATUM" CHAR(1) , 
		  "SESSIONS_AND_JOBS" VARCHAR(350) , 
		  "CHK_SUCHMUSTER" VARCHAR(80) , 
		  "CHK_ANZAHL_DS" VARCHAR(50) , 
		  "CHK_ANZAHL_BYTES" VARCHAR(50) , 
		  "CHK_ARCHIVIEREN" CHAR(1) , 
		  "CHK_IN_TAB_LADEN" CHAR(1) , 
		  "SCHNITTSTELLEN_ID" CHAR(12) , 
		  "ASP_ENTW" CHAR(3) , 
		  "IU_KENNER" CHAR(1) , 
		  "RELEASE" VARCHAR(10) )   
		 IN "DW_NPART_TS" NOT LOGGED INITIALLY  
		 ORGANIZE BY ROW; 


-- DDL Statements for Primary Key on Table "DWH     "."A_BATCH_INPUT"

ALTER TABLE "DWH     "."A_BATCH_INPUT" 
	ADD PRIMARY KEY
		("BATCHLAUF_TYP",
		 "ZIELTABELLE");









COMMIT WORK;

CONNECT RESET;

TERMINATE;


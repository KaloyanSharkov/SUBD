SET SCHEMA FN71945;

--процедура с курсор и входни и изходни параметри

SELECT * FROM NURSES;

CREATE OR REPLACE PROCEDURE NURSES_INFO(IN V_ID_NURSES INT, OUT P_WORK_POSITION VARCHAR(30))
RESULT SETS 1
BEGIN
    DECLARE V_NAME VARCHAR(30);
    DECLARE C1 CURSOR FOR SELECT WORK_POSITION
                                  FROM NURSES
                                  WHERE ID_STUFF = V_ID_NURSES;

    SET V_NAME = (SELECT NAME FROM NURSES WHERE ID_STUFF = V_ID_NURSES);


     IF(V_NAME IS NULL)THEN
        CALL DBMS_OUTPUT.PUT_LINE('NO SUCH EMPLOYEE ' || V_ID_NURSES );
    end if;

    OPEN C1;
    FETCH C1 INTO P_WORK_POSITION;

    IF (P_WORK_POSITION IS NULL) THEN
        UPDATE NURSES
        SET WORK_POSITION = 'NURSE'
        WHERE ID_STUFF = V_ID_NURSES;
    end if;
END ;

CALL FN71945.NURSES_INFO(311,?);

--процедура с прихващане на изключение

CREATE TABLE MSG_PROC(
    MSG VARCHAR(1000)
);

SELECT * FROM MSG_PROC;
DROP TABLE MSG_PROC;

CREATE PROCEDURE PROC()
RESULT SETS 1
BEGIN
     DECLARE med ANCHOR ROW FN71945.MEDICINES;
     DECLARE sqlcode INT;
     DECLARE NO_DESCRIPTION CONDITION ;
     DECLARE C1 CURSOR FOR SELECT * FROM MEDICINES;

     DECLARE CONTINUE HANDLER FOR NO_DESCRIPTION
       BEGIN
           INSERT INTO FN71945.MSG_PROC VALUES (med.ID || 'HAS NO DESCRIPTION');
       END ;
OPEN C1;
FETCH C1 INTO med;

WHILE sqlcode = 0 DO
    IF med.DESCRIPTION IS NULL THEN
        SIGNAL NO_DESCRIPTION;
    end if;
    FETCH C1 INTO med;
    end while;
     BEGIN
         DECLARE RES_SET CURSOR WITH RETURN FOR
             SELECT * FROM FN71945.MSG_PROC;
         OPEN RES_SET;
     end;
end;

CALL FN71945.PROC();

SELECT * FROM MEDICINES;

UPDATE MEDICINES
SET DESCRIPTION =NULL
WHERE ID = 435;

---- Процедура с курсор и while

CREATE OR REPLACE PROCEDURE PATIENTS_DIAGNOSIS_NULL()
BEGIN
    DECLARE V_NAME VARCHAR(30);
    DECLARE V_DIAGNOSIS VARCHAR(20);
    DECLARE V_EGN CHAR(10);
    DECLARE CNT INT DEFAULT 0;
    DECLARE N INT;
    DECLARE C1 CURSOR FOR SELECT EGN,NAME,DIAGNOSIS FROM PATIENTS;

    SET N = (SELECT COUNT(*) FROM PATIENTS);
    OPEN C1;
    WHILE (CNT < N) DO
        SET CNT = CNT + 1;
        FETCH C1 INTO V_EGN, V_NAME, V_DIAGNOSIS;
        IF (V_DIAGNOSIS IS NULL) THEN
                UPDATE PATIENTS SET DIAGNOSIS = 'COVID-19' WHERE EGN = V_EGN;
        end if;
    end while;

    CLOSE C1;
end;

DROP TRIGGER UPD_DIAG_PAT_TRIGG;

CALL FN71945.PATIENTS_DIAGNOSIS_NULL();

UPDATE PATIENTS
SET DIAGNOSIS = NULL
WHERE EGN = '7908271235';

SELECT * FROM PATIENTS;
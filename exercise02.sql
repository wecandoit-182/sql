-- A
UPDATE INPATIENT
SET PFee=PFee*1.1
WHERE (TRUNC(SYSDATE)-TO_DATE('2017-09-01','yyyy-mm-dd') > TRUNC(SYSDATE)-PAdmissionDate);

-- B
SELECT DISTINCT P.PID, CONCAT(P.PFname,CONCAT(' ', P.PLname)), P.PDOB, P.PGENDER, P.PPHONE, P.PADDRESS
FROM PATIENT P, EMPLOYEE E, DOCTOR D, INPATIENT I, OUTPATIENT O
WHERE CONCAT(E.EFname,CONCAT(' ', E.ELname)) = 'Chi Eve' AND E.EID = D.EID_Doc AND ((D.EID_Doc = I.EID_Doc AND I.PID_In = P.PID) OR (D.EID_Doc = O.EID_Doc AND O.PID_Out = P.PID));

-- C: function
CREATE OR REPLACE TYPE RES_OBJ_TYPE
AS OBJECT
( ID_ VARCHAR(9),
  TOTALPRICE DECIMAL(10,2)
  );

CREATE OR REPLACE TYPE RES_TABLE_TYPE IS TABLE OF RES_OBJ_TYPE;

CREATE OR REPLACE FUNCTION TOTAL_PRICE (PID IN PATIENT.PID%TYPE)
RETURN RES_TABLE_TYPE
IS
    Presence NUMBER;
    RES_DETAILS RES_TABLE_TYPE := RES_TABLE_TYPE();
BEGIN
    RES_DETAILS.EXTEND ();
    SELECT COUNT(PID_In) INTO Presence
    FROM INPATIENT
    WHERE INPATIENT.PID_In=PID;
    IF Presence != 0 THEN
        SELECT RES_OBJ_TYPE(TREATMENT.TrID, SUM(MPrice))
        bulk COLLECT INTO RES_DETAILS
        FROM TREATMENT, Uses_TREAT, MEDICATION
        WHERE TREATMENT.PID_In = PID AND TREATMENT.TrID = Uses_Treat.TrID And Uses_Treat.MID = MEDICATION.MID
        GROUP BY TREATMENT.TrID;
    ELSIF Presence = 0 THEN
        SELECT RES_OBJ_TYPE(EXAMINATION.ExID, SUM(MPrice))
        bulk COLLECT INTO RES_DETAILS
        FROM EXAMINATION, Uses_EXAM, MEDICATION
        WHERE EXAMINATION.PID_Out = PID AND EXAMINATION.ExID = Uses_Exam.ExID And Uses_Exam.MID = MEDICATION.MID
        GROUP BY EXAMINATION.ExID;
    END IF;
    RETURN RES_DETAILS;
END;


SELECT * FROM TABLE(TOTAL_PRICE('P00000231'));

-- D: procedure
CREATE OR REPLACE PROCEDURE SORT_NUM_PATIENT
(START_DATE DATE, END_DATE DATE)
IS
    DOC_ID  DOCTOR.EID_DOC%TYPE;
    DOC_FULLNAME VARCHAR(30);
    PATIENT_COUNT NUMBER;
    CURSOR C_DOC IS
        SELECT a1.eid_doc, a1.fullname, COALESCE(a1.num_out,0) + COALESCE(a2.num_in, 0) as patient_number
        FROM
        (SELECT DISTINCT d.eid_doc, a.efname || ' ' || a.elname as fullname, count(pid_out) as num_out
        FROM doctor d, examination e, employee a
        WHERE d.eid_doc = e.eid_doc and a.eid = d.eid_doc
        GROUP BY d.eid_doc, a.efname, a.elname) a1
        LEFT JOIN
        (SELECT DISTINCT d.eid_doc, a.efname || ' ' || a.elname as fullname, count(pid_in) as num_in
        FROM doctor d, treatment e, employee a
        WHERE d.eid_doc = e.eid_doc and a.eid = d.eid_doc
        GROUP BY d.eid_doc, a.efname, a.elname) a2
        ON a1.eid_doc = a2.eid_doc
        ORDER BY patient_number ASC;
BEGIN
    OPEN C_DOC;
    LOOP
        FETCH C_DOC into DOC_ID, DOC_FULLNAME, PATIENT_COUNT;
            EXIT WHEN C_DOC%notfound;
            dbms_output.put_line(DOC_ID || ' ' || DOC_FULLNAME || ' '|| PATIENT_COUNT);
    END LOOP;
    CLOSE C_DOC;
END;

Set serveroutput on;
EXEC SORT_NUM_PATIENT(TO_DATE('2017-01-01',('yyyy-mm-dd')),TO_DATE('2018-12-12','yyyy-mm-dd'));
-- Create tables with PK
CREATE TABLE DEPARTMENT (
    DID    CHAR(4)      NOT NULL,
    DTitle VARCHAR2(32),
    EID    CHAR(6)      NOT NULL,
    CONSTRAINT department_pk PRIMARY KEY(DID)
);

CREATE TABLE EMPLOYEE (
    EID         CHAR(6)      NOT NULL,
    EFname      VARCHAR2(16) NOT NULL,
    ELname      VARCHAR2(16) NOT NULL,
    EDoB        DATE,
    EGender     CHAR,
    ESpeciality VARCHAR2(32),
    EAddress    VARCHAR2(64),
    EStartDate  DATE,
    DID         CHAR(4)      NOT NULL,
    CONSTRAINT employee_pk PRIMARY KEY(EID)
);

CREATE TABLE EMP_Phone (
    EID    CHAR(6)      NOT NULL,
    EPhone VARCHAR2(15) NOT NULL,
    CONSTRAINT emp_phone_pk PRIMARY KEY(EID, EPhone)
);

CREATE TABLE DOCTOR (
    EID_Doc CHAR(6),
    CONSTRAINT doctor_pk PRIMARY KEY(EID_Doc)
);

CREATE TABLE NURSE (
    EID_Nur CHAR(6),
    CONSTRAINT nurse_pk PRIMARY KEY(EID_Nur)
);

CREATE TABLE PATIENT (
    PID      CHAR (9)     NOT NULL,
    PFname   VARCHAR2(16) NOT NULL,
    PLname   VARCHAR2(16) NOT NULL,
    PDoB     DATE,
    PGender  CHAR,
    PPhone   VARCHAR2(15),
    PAddress VARCHAR2(64),
    CONSTRAINT patient_pk PRIMARY KEY(PID)
);

CREATE TABLE OUTPATIENT (
    PID_Out CHAR(9) NOT NULL,
    EID_Doc CHAR(6) NOT NULL,
    CONSTRAINT outpatient_pk PRIMARY KEY(PID_Out)
);

CREATE TABLE INPATIENT (
    PID_In         CHAR(9)       NOT NULL,
    PAdmissionDate DATE,
    PDischargeDate DATE,
    PDiagnosis     VARCHAR2(64),
    PSickRoom      CHAR(3),
    PFee           NUMBER(10, 2),
    EID_Doc        CHAR(6)       NOT NULL,
    EID_Nur        CHAR(6)       NOT NULL,
    CONSTRAINT inpatient_pk PRIMARY KEY(PID_In)
);

CREATE TABLE EXAMINATION (
    EID_Doc                 CHAR(6)       NOT NULL,
    PID_Out                 CHAR(9)       NOT NULL,
    ExID                    CHAR(9)       NOT NULL,
    ExDate                  DATE,
    ExFee                   NUMBER(10, 2),
    ExDiagnosis             VARCHAR2(64),
    ExSecondExaminationDate DATE,
    CONSTRAINT examination_pk PRIMARY KEY(EID_Doc, PID_Out, ExID)
);

CREATE TABLE TREATMENT (
    EID_Doc  CHAR(6)      NOT NULL,
    PID_In   CHAR(9)      NOT NULL,
    TrID     CHAR(9)      NOT NULL,
    TrStart  DATE,
    TrEnd    DATE,
    TrResult VARCHAR2(64),
    CONSTRAINT treatment_pk PRIMARY KEY(EID_Doc, PID_In, TrID)
);

CREATE TABLE MEDICATION (
    MID      CHAR(6)       NOT NULL,
    MName    VARCHAR2(32)  NOT NULL,
    MEffects VARCHAR2(256),
    MPrice   NUMBER(10, 2),
    CONSTRAINT medication_pk PRIMARY KEY(MID)
);

CREATE TABLE Uses_Exam (
    EID_Doc CHAR(6) NOT NULL,
    PID_Out CHAR(9) NOT NULL,
    ExID    CHAR(9) NOT NULL,
    MID     CHAR(6) NOT NULL,
    CONSTRAINT uses_exam_pk PRIMARY KEY(EID_Doc, PID_Out, ExID, MID)
);

CREATE TABLE Uses_Treat (
    EID_Doc CHAR(6) NOT NULL,
    PID_In  CHAR(9) NOT NULL,
    TrID    CHAR(9) NOT NULL,
    MID     CHAR(6) NOT NULL,
    CONSTRAINT uses_treat_pk PRIMARY KEY(EID_Doc, PID_In, TrID, MID)
);

-- DEPARTMENT FK
ALTER TABLE DEPARTMENT
    ADD CONSTRAINT department_fk_eid
        FOREIGN KEY(EID) REFERENCES EMPLOYEE(EID);

-- EMPLOYEE FK
ALTER TABLE EMPLOYEE
    ADD CONSTRAINT employee_fk_did
        FOREIGN KEY(DID) REFERENCES DEPARTMENT(DID);

-- EMP_Phone FK
ALTER TABLE EMP_Phone
    ADD CONSTRAINT emp_phone_fk_eid
        FOREIGN KEY(EID) REFERENCES EMPLOYEE(EID);

-- DOCTOR FK
ALTER TABLE DOCTOR
    ADD CONSTRAINT doctor_fk_eid_doc
        FOREIGN KEY(EID_Doc) REFERENCES EMPLOYEE(EID);

-- NURSE FK
ALTER TABLE NURSE
    ADD CONSTRAINT nurse_fk_eid_nur
        FOREIGN KEY(EID_Nur) REFERENCES EMPLOYEE(EID);

-- OUTPATIENT FK
ALTER TABLE OUTPATIENT
    ADD CONSTRAINT outpatient_fk_pid_out
        FOREIGN KEY(PID_Out) REFERENCES PATIENT(PID);

ALTER TABLE OUTPATIENT
    ADD CONSTRAINT outpatient_fk_eid_doc
        FOREIGN KEY(EID_Doc) REFERENCES DOCTOR(EID_Doc);

--- INPATIENT FK
ALTER TABLE INPATIENT
    ADD CONSTRAINT inpatient_fk_pid_in
        FOREIGN KEY(PID_In) REFERENCES PATIENT(PID);

ALTER TABLE INPATIENT
    ADD CONSTRAINT inpatient_fk_eid_doc
        FOREIGN KEY(EID_Doc) REFERENCES DOCTOR(EID_Doc);

ALTER TABLE INPATIENT
    ADD CONSTRAINT inpatient_fk_eid_nur
        FOREIGN KEY(EID_Nur) REFERENCES NURSE(EID_Nur);

-- EXAMINATION FK
ALTER TABLE OUTPATIENT
    ADD CONSTRAINT outpatient_uk_eid_doc_pid_out
        UNIQUE(EID_Doc, PID_Out);

ALTER TABLE EXAMINATION
    ADD CONSTRAINT examination_fk_eid_doc_pid_out
        FOREIGN KEY(EID_Doc, PID_Out) REFERENCES OUTPATIENT(EID_Doc, PID_Out);

-- TREATMENT FK
ALTER TABLE INPATIENT
    ADD CONSTRAINT inpatient_uk_eid_doc_pid_in
        UNIQUE(EID_Doc, PID_In);

ALTER TABLE TREATMENT
    ADD CONSTRAINT treatment_fk_eid_doc_pid_in
        FOREIGN KEY(EID_Doc, PID_In) REFERENCES INPATIENT(EID_Doc, PID_In);

-- Uses_Exam FK
ALTER TABLE Uses_Exam
    ADD CONSTRAINT uses_exam_fk_eid_doc_pid_out_exid
        FOREIGN KEY(EID_Doc, PID_Out, ExID) REFERENCES EXAMINATION(EID_Doc, PID_Out, ExID);

ALTER TABLE Uses_Exam
    ADD CONSTRAINT uses_exam_fk_mid
        FOREIGN KEY(MID) REFERENCES MEDICATION(MID);

-- Uses_Treat FK
ALTER TABLE Uses_Treat
    ADD CONSTRAINT uses_treat_fk_eid_doc_pid_in_trid
        FOREIGN KEY(EID_Doc, PID_In, TrID) REFERENCES TREATMENT(EID_Doc, PID_In, TrID);

ALTER TABLE Uses_Treat
    ADD CONSTRAINT uses_treat_fk_mid
        FOREIGN KEY(MID) REFERENCES MEDICATION(MID);
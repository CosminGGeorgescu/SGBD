set SERVEROUTPUT on;
/
-- 1 
create or replace trigger ex1_cgg before delete on dept_cgg
begin 
    if user != upper('SCOTT')
        then raise_application_error(-20001, 'no se puede');
    end if;
end;
/
-- 2
CREATE OR REPLACE TRIGGER ex2_cgg BEFORE UPDATE OF commission_pct ON employees_cgg FOR EACH ROW
DECLARE
BEGIN
    IF :NEW.commission_pct > 0.5 THEN
        RAISE_APPLICATION_ERROR(-20001, 'comision prea mare');
    END IF;
END;
/
-- 3
-- a
create table info_dept_cgg as (select d.*,(select count(*) from employees e where e.department_id = d.department_id) as numar  from departments d);
/
-- b
create or replace trigger ex3_cgg after delete or insert or update of department_id on info_emp_cgg for each ROW
begin
    IF INSERTING THEN
        UPDATE info_dept_cgg
        SET numar = numar + 1
        WHERE department_id = :new.department_id;
    ELSIF UPDATING THEN
        UPDATE info_dept_cgg
        SET numar = numar - 1
        WHERE department_id = :old.department_id;
        
        UPDATE info_dept_cgg
        SET numar = numar + 1
        WHERE department_id = :new.department_id;
    ELSIF DELETING THEN
        UPDATE info_dept_cgg
        SET numar = numar - 1
        WHERE department_id = :old.department_id;
    END IF;
end;
/
-- 4
create or replace trigger ex4_cgg before insert or update of department_id on employees_cgg for each ROW
declare
    employees_number number;
begin
    select count(*) into employees_number from employees_cgg where department_id = :new.department_id;
    if employees_number > 45 then raise_application_error(-20001, 'no se puede mai mult de 45 angajati');
    end if;
end;
/
-- 5
-- a
create table emp_test_cgg (employee_id NUMBER(6,0) primary key, last_name VARCHAR2(25 BYTE), first_name VARCHAR2(20 BYTE), department_id NUMBER(4,0));
create table dept_test_cgg (department_id NUMBER(4,0) primary key, department_name VARCHAR2(30 BYTE));
/
-- b
create or replace trigger ex5_cgg before delete of department_id on dept_test_cgg for each ROW
begin
    if UPDATING THEN
        update emp_test_cgg set department_id = :new.department_id where department_id = :old.department_id;
    ELSIF DELETING
        delete from emp_test_cgg where department_id = :old.department_id;
    end if;
end;
/
-- 6
-- a
create table table_cgg(
    user_id VARCHAR2(50 BYTE),
    nume_bd VARCHAR2(50 BYTE),
    erori VARCHAR2(100 BYTE),
    data DATE
);
/
-- b
create or replace trigger ex6_cgg after suspend on schema
begin
    insert into table_cgg values (sys.login_user, sys.database_name, '', sysdate);
end;
/
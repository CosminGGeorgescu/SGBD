set SERVEROUTPUT on;

-- 1

CREATE TABLE info_cgg (
  utilizator VARCHAR2(50),
  data DATE,
  comanda VARCHAR2(100),
  nr_linii NUMBER,
  eroare VARCHAR2(50)
);

/

-- 2

CREATE OR REPLACE FUNCTION f2_cgg
(v_nume employees.last_name%TYPE DEFAULT 'Bell')
RETURN NUMBER IS 
    salariu employees.salary%type;
    utilizator varchar2(50);
    linii number;
BEGIN
    select user into utilizator from dual;
    
    linii := sql%rowcount;
    
    SELECT salary INTO salariu
    FROM employees
    WHERE last_name = v_nume;



    if linii = 1 then 
        insert into info_cgg values(utilizator, sysdate, 'f2_gcc', 1, 'un angajat');
    end if;


    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        insert into info_cgg values(utilizator, sysdate, 'f2_cgg', 0, 'zero angajati');
    WHEN TOO_MANY_ROWS THEN
        insert into info_cgg values(utilizator, sysdate, 'f2_cgg', linii, 'mai multi angajati');
    WHEN OTHERS THEN
        insert into info_cgg values(utilizator, sysdate, 'f2_cgg', linii, 'buba');
END f2_cgg;

/

CREATE OR REPLACE PROCEDURE p4_cgg
(v_nume employees.last_name%TYPE)
IS 
    salariu employees.salary%TYPE;
    utilizator varchar2(100);
    linii number;
BEGIN
    select user into utilizator from dual;
    
    SELECT salary INTO salariu
    FROM employees
    WHERE last_name = v_nume;
    
    linii := sql%rowcount;
    
    if linii = 1 then
        insert into info_cgg values(utilizator, sysdate, 'f2_cgg', 1, 'un angajat');
    end if;
    
    DBMS_OUTPUT.PUT_LINE('Salariul este '|| salariu);
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        insert into info_cgg values(utilizator, sysdate, 'f2_cgg', 0, 'zero angajati');    
    WHEN TOO_MANY_ROWS THEN
        insert into info_cgg values(utilizator, sysdate, 'f2_cgg', linii, 'mai multi angajati');    
    WHEN OTHERS THEN
        insert into info_cgg values(utilizator, sysdate, 'f2_cgg', linii, 'buba');    

END p4_cgg;

/

-- 3

CREATE OR REPLACE function ex3_cgg(v_oras locations.city%type) return number is
    utilizator  varchar2(100);
    oras locations.location_id%type;
    nr number;
BEGIN
    
    select user into utilizator from dual;
    
    select location_id into oras from locations where city = v_oras;
    
    select count(*) into nr
    from employees e
    join departments d on (e.department_id = d.department_id)
    join locations l on (l.location_id = d.location_id)
    where (select count(*) from job_history j where e.employee_id = j.employee_id) > 1 and l.location_id = oras;

    if nr = 0 then
        insert into info_cgg values(utilizator, sysdate, 'ex3_cgg', nr,'zero angajati');
    else 
        insert into info_cgg values(utilizator, sysdate, 'ex3_cgg', nr,'gasit angajati');
    end if;
    
    return nr;
    
    exception
        when NO_DATA_FOUND then
            insert into info_cgg values(utilizator, sysdate, 'ex3_cgg', 0, 'buba oras');
            return 0;
END ex3_cgg;

/

-- 4

CREATE OR REPLACE PROCEDURE ex4_cgg(manager IN employees.employee_id%TYPE)
IS
        utilizator  varchar2(100);

    manager_count number := 0;
    linii number;
BEGIN
        select user into utilizator from dual;

  SELECT COUNT(*)
  INTO manager_count
  FROM employees
  WHERE manager_id = manager;
    
  if manager_count = 0 then
     insert into info_cgg values(utilizator, sysdate, 'ex4_cgg', 0, 'nu gasit manager');
    dbms_output.put_line('Nu manager');
  else
    update employees
    set salary = salary * 1.1
    where manager_id = manager;
    linii := sql%rowcount;
               insert into info_cgg values(utilizator, sysdate, 'ex4_cgg', linii, 'updatat angajati');

      for i in (select employee_id from employees where manager_id = manager) loop
        ex4_cgg(i.employee_id);
        end loop;

    END IF;
END;

/

-- 5

CREATE OR REPLACE PROCEDURE ex5_cgg
IS
    nr number;
    zi number;
    vechime number;
    venit number;
BEGIN
    FOR d IN (SELECT * FROM departments) LOOP
        DBMS_OUTPUT.PUT_LINE(d.department_name);
        BEGIN
            select zi_sapt, num_hired into zi, nr from (select TO_CHAR(hire_date, 'D') as zi_sapt, count(*) as num_hired from employees e where e.department_id = d.department_id group by TO_CHAR(hire_date, 'D') order by num_hired desc) where rownum = 1;
            for e in (select first_name, last_name, hire_date, salary from employees e where TO_CHAR(hire_date, 'D') = zi and department_id = d.department_id) loop
                select EXTRACT(DAY FROM NUMTODSINTERVAL(sysdate - e.hire_date, 'DAY')) into vechime from dual;
                dbms_output.put_line(e.first_name || ' ' || e.last_name || ': ' || vechime || ' vechime, salariu: ' || e.salary);
            end loop;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                dbms_output.put_line('No data found');
                CONTINUE;
        END;
            DBMS_OUTPUT.PUT_LINE('');
    END LOOP;
END;
/

-- 6

CREATE OR REPLACE PROCEDURE ex6_cgg
IS
    nr number;
    zi number;
    vechime number;
    venit number;
BEGIN
    FOR d IN (SELECT * FROM departments) LOOP
        DBMS_OUTPUT.PUT_LINE(d.department_name);
        BEGIN
            select zi_sapt, num_hired into zi, nr from (select TO_CHAR(hire_date, 'D') as zi_sapt, count(*) as num_hired from employees e where e.department_id = d.department_id group by TO_CHAR(hire_date, 'D') order by num_hired desc) where rownum = 1;
            for e in (select first_name, last_name, hire_date, salary,  dense_rank() over (order by hire_date) as row_num from employees e where TO_CHAR(hire_date, 'D') = zi and department_id = d.department_id order by hire_date) loop
                select EXTRACT(DAY FROM NUMTODSINTERVAL(sysdate - e.hire_date, 'DAY')) into vechime from dual;
                dbms_output.put_line(e.row_num || '. ' || e.first_name || ' ' || e.last_name || ': ' || vechime || ' vechime, salariu: ' || e.salary);
            end loop;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                dbms_output.put_line('No data found');
                CONTINUE;
        END;
            DBMS_OUTPUT.PUT_LINE('');
    END LOOP;
END;
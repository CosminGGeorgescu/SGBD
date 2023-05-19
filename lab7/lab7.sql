set SERVEROUTPUT on;
/
-- 1
-- a
declare
    error exception;
    x number := &x;
begin
    if x < 0 then raise error;
    end if;
    dbms_output.put_line(sqrt(x));
    exception when error then insert into error_cgg values(-20001, 'nr negativ');
end;
/
--b
declare
    x number := &x;
    v_message varchar2(100);
    code number;
begin
    dbms_output.put_line(sqrt(x));
    exception when value_error then 
        code := sqlcode;
        v_message := SUBSTR(SQLERRM,1,100);
        insert into error_cgg values(code, v_message);
end;
/
-- 2
declare
    v_first_name employees_cgg.first_name%type;
    v_last_name employees_cgg.last_name%type;
    v_salary employees_cgg.salary%type  := &v_salary;
    code number;
begin
    select first_name, last_name into v_first_name, v_last_name from employees where salary = v_salary;
    dbms_output.put_line(v_first_name || ' ' || v_last_name);
    exception
        when no_data_found then 
            dbms_output.put_line('nu exista salariati care sa castige acest salariu');
            code := sqlcode;
            insert into error_mac values(code, 'nu exista salariati care sa castige acest salariu');
        when too_many_rows then 
            dbms_output.put_line('exista mai mulţi salariati care castiga acest salariu');
            code := sqlcode;
            insert into error_mac values(code, 'exista mai mulţi salariati care castiga acest salariu');
end;
/
-- 3
DECLARE    
    employees_nr NUMBER := 0;
    v_department_id departments.department_id%type  := &v_department_id;
    exc EXCEPTION;
BEGIN
    SELECT COUNT(*) INTO employees_nr FROM departments WHERE department_id = v_department_id;
    IF employees_nr > 0 THEN 
        RAISE exc;
    ELSE
        update departments set department_id = 0 where department_id = v_department_id;
    end if;
    EXCEPTION
        WHEN exc THEN
            DBMS_OUTPUT.PUT_LINE('lucreaza angajati');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('alceva');
END;
/
-- 4
declare
    error exception;
    a number := &a;
    b number := &b;
    employees_nr number;
begin
    select count(*) into employees_nr from employees where department_id = 10;
    if employees_nr < a or employees_nr > b then
        raise error;
    else
        dbms_output.put_line('Administration');
    end if;
    exception when error then dbms_output.put_line('in afara intervalului');
end;
/
-- 5
declare
    v_department_id departments.department_id%type := &v_department_id;
begin
    update dept_test_cdc set department_name = 'Someri' where department_id = v_department_id;
    if sql%NOTFOUND then RAISE_APPLICATION_ERROR(-20001, 'nu exista');
    end if;
end;
/
-- 6
-- a
declare
    v_location_id locations.location_id%type := &v_location_id;
    v_department_id departments.department_id%type := &v_department_id;
    v_department_name departments.department_name%type;
    x number := 0;
begin
    select department_name into v_department_name from departments where location_id = v_location_id;
    dbms_output.put_line(v_department_name);
    x := 1;
    select department_name into v_department_name from departments where department_id = v_department_id;
    dbms_output.put_line(v_department_name);
    exception when no_data_found then
        if x = 0 then dbms_output.put_line('buba select 1');
        elsif x = 1 then dbms_output.put_line('buba select 2');
        end if;
end;
/
-- b
declare
    v_location_id locations.location_id%type := &v_location_id;
    v_department_id departments.department_id%type := &v_department_id;
    v_department_name departments.department_name%type;
begin
    begin
        select department_name into v_department_name from departments where location_id = v_location_id;
        dbms_output.put_line(v_department_name);
        exception when no_data_found then dbms_output.put_line('buba select 1');
    end;
    begin
        select department_name into v_department_name from departments where department_id = v_department_id;
        dbms_output.put_line(v_department_name);
        exception when no_data_found then dbms_output.put_line('buba select 2');
    end;
end;
/
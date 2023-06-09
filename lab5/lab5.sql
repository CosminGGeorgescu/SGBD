set SERVEROUTPUT on;
/
create or replace package package_cgg as
    -- f
    cursor job_employees(v_job_id employees.job_id%type) return employees%rowtype;
    -- g
    cursor all_jobs return jobs%rowtype;
    -- a
    function find_manager_id(v_manager_first_name employees.first_name%type, v_manager_last_name employees.last_name%type) return employees.employee_id%type;
    function find_departament_id(v_departament_name departments.department_name%type) return departments.department_id%type;
    function find_job_id(v_job_title jobs.job_title%type) return jobs.job_id%type;
    function find_salary(v_departament_id departments.department_id%type, v_job_id jobs.job_id%type) return employees.salary%type;
    procedure add_employee(v_first_name employees.first_name%type, v_last_name employees.last_name%type, v_phone_number employees.phone_number%type, v_email employees.email%type, v_manager_first_name employees.first_name%type, v_manager_last_name employees.last_name%type, v_departament_name departments.department_name%type, v_job_title jobs.job_title%type);
    -- b
    procedure move_employee(v_first_name employees.first_name%type, v_last_name employees.last_name%type, v_departament_name departments.department_name%type, v_job_title jobs.job_title%type, v_manager_first_name employees.first_name%type, v_manager_last_name employees.last_name%type);
    -- c
    function subordinates_number(v_first_name employees.first_name%type, v_last_name employees.last_name%type) return number;
    -- e
    procedure update_salary(v_first_name employees.first_name%type, v_last_name employees.last_name%type, v_salary employees.salary%type);
    -- h
    procedure jobs_to_employees;
end package_cgg;
/
create or replace package body package_cgg as
    cursor job_employees(v_job_id employees.job_id%type) return employees%rowtype is select * from employees where job_id = v_job_id;

    cursor all_jobs return jobs%rowtype is select * from jobs;

    function find_manager_id(v_manager_first_name employees.first_name%type, v_manager_last_name employees.last_name%type) return employees.employee_id%type is
        id employees.employee_id%type;
    begin
        select employee_id into id from employees where first_name = v_manager_first_name and last_name = v_manager_last_name;
        return id;
        exception when OTHERS then dbms_output.put_line('buba find_manager_id');
    end find_manager_id;
    
    function find_departament_id(v_departament_name departments.department_name%type) return departments.department_id%type is 
        id departments.department_id%type;
    begin
        select department_id into id from departments where department_name = v_departament_name;
        return id;
        exception when OTHERS then dbms_output.put_line('buba find_department_id');
    end find_departament_id;

    function find_job_id(v_job_title jobs.job_title%type) return jobs.job_id%type is
        id jobs.job_id%type;
    begin
        select job_id into id from jobs where job_title = v_job_title;
        return id;
        exception when OTHERS then dbms_output.put_line('buba find_job_id');
    end find_job_id;

    function find_salary(v_departament_id departments.department_id%type, v_job_id jobs.job_id%type) return employees.salary%type is 
        salary employees.salary%type;
    begin
        select min(salary) into salary from employees where department_id = v_departament_id and job_id = v_job_id;
        return salary;
        exception when OTHERS then dbms_output.put_line('buba find_salary');
    end find_salary;

    procedure add_employee(v_first_name employees.first_name%type, v_last_name employees.last_name%type, v_phone_number employees.phone_number%type, v_email employees.email%type, v_manager_first_name employees.first_name%type, v_manager_last_name employees.last_name%type, v_departament_name departments.department_name%type, v_job_title jobs.job_title%type) is
        v_employee_id employees.employee_id%type;
        v_manager_id employees.employee_id%type := find_manager_id(v_manager_first_name, v_manager_last_name);
        v_departament_id departments.department_id%type := find_departament_id(v_departament_name);
        v_job_id jobs.job_id%type := find_job_id(v_job_title);
        v_salary employees.salary%type := find_salary(v_departament_id, v_job_id);
    begin
        select max(employee_id) into v_employee_id from employees;
        insert into employees values(v_employee_id, v_first_name, v_last_name, v_email, v_phone_number, sysdate, v_job_id, v_salary, null, v_manager_id, v_departament_id);
        exception when OTHERS then dbms_output.put_line('buba add_employee');
    end add_employee;

    procedure move_employee(v_first_name employees.first_name%type, v_last_name employees.last_name%type, v_departament_name departments.department_name%type, v_job_title jobs.job_title%type, v_manager_first_name employees.first_name%type, v_manager_last_name employees.last_name%type) is
        v_departament_id departments.department_id%type := find_departament_id(v_departament_name);
        v_job_id jobs.job_id%type := find_job_id(v_job_title);
        v_manager_id employees.employee_id%type := find_manager_id(v_manager_first_name, v_manager_last_name);
        v_salary employees.salary%type := find_salary(v_departament_id, v_job_id);
        curr_employee_id employees.employee_id%type;
        curr_hire_date employees.hire_date%type;
        curr_job_id employees.job_id%type;
        curr_salary employees.salary%type;
        curr_department_id employees.department_id%type;
    begin
        select employee_id, hire_date, job_id, salary, department_id into curr_employee_id, curr_hire_date, curr_job_id, curr_salary, curr_department_id from employees where first_name = v_first_name and last_name = v_last_name;
        if v_salary > curr_salary then v_salary := curr_salary;
        end if;
        update employees set hire_date = sysdate, job_id = v_job_id, salary = v_salary, commission_pct = (select min(commission_pct) from employees where department_id = v_departament_id and job_id = v_job_id), manager_id = v_manager_id, department_id = v_departament_id where first_name = v_first_name and last_name = v_last_name; 
        insert into job_history values(curr_department_id, curr_hire_date, sysdate, curr_job_id, curr_department_id);
    end move_employee;

    function subordinates_number(v_first_name employees.first_name%type, v_last_name employees.last_name%type) return number is
        v_employee_id employees.employee_id%type;
        v_subordinates_count number := 0;
    begin
        SELECT employee_id INTO v_employee_id FROM employees WHERE first_name = v_first_name AND last_name = v_last_name;
        select count(*) into v_subordinates_count from employees where manager_id = v_employee_id;
        for x in (select * from employees where manager_id = v_employee_id) loop
            v_subordinates_count := v_subordinates_count + subordinates_number(x.first_name, x.last_name);
        end loop;
        return v_subordinates_count;
    end subordinates_number;

    procedure update_salary(v_first_name employees.first_name%type, v_last_name employees.last_name%type, v_salary employees.salary%type) is
        v_employee_id employees.employee_id%type;
        v_job_id employees.job_id%type;
        v_min_salary jobs.min_salary%type;
        v_max_salary jobs.max_salary%type;
    begin
        select employee_id, job_id into v_employee_id, v_job_id from employees where first_name = v_first_name and last_name = v_last_name;
        select min_salary, max_salary into v_min_salary, v_max_salary from jobs where job_id = v_job_id;
        if v_salary < v_min_salary or v_salary > v_max_salary then
            return;
        end if;
        update employees set salary = v_salary where employee_id = v_employee_id;
        exception 
            when TOO_MANY_ROWS then 
                dbms_output.put_line('prea multi angajati');
                for x in (select employee_id from employees where first_name = v_first_name and last_name = v_last_name) loop
                    dbms_output.put_line(x.employee_id);
                end loop;
            when NO_DATA_FOUND then dbms_output.put_line('nu angajati');
    end update_salary;

    procedure jobs_to_employees is
        flag number;
    begin
        for j in all_jobs loop
            dbms_output.put_line('Job: ' || j.job_title);
            for e in job_employees(j.job_id) loop
                flag := 0;
                select count(*) into flag from job_history where employee_id = e.employee_id and job_id = e.job_id;
                if flag > 0 then 
                    dbms_output.put_line(e.first_name || ' ' || e.last_name || ' !A mai lucrat aici');
                else
                    dbms_output.put_line(e.first_name || ' ' || e.last_name);
                end if;
            end loop;
            dbms_output.put_line('');
        end loop;
    end;
end package_cgg;
/
begin
    package_cgg.jobs_to_employees;
end;
/


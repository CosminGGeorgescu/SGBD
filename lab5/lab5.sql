create or replace package package_cgg as
    -- a
    function find_manager_id(v_manager_first_name employees.first_name%type, v_manager_last_name employees.last_name%type) return employees.employee_id%type;
    function find_departament_id(v_departament_name departments.department_name%type) return departments.department_id%type;
    function find_job_id(v_job_title jobs.job_title%type) return jobs.job_id%type;
    function find_salary(v_departament_id departments.department_id%type, v_job_id jobs.job_id%type) return employees.salary%type;
    procedure add_employee(v_first_name employees.first_name%type, v_last_name employees.last_name%type, v_phone_number employees.phone_number%type, v_email employees.email%type, v_manager_first_name employees.first_name%type, v_manager_last_name employees.last_name%type, v_departament_name departments.department_name%type, v_job_title jobs.job_title%type);
end package_cgg;
/
create or replace package body package_cgg as
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
        insert into employees_cgg values(v_employee_id, v_first_name, v_last_name, v_email, v_phone_number, sysdate, v_job_id, v_salary, null, v_manager_id, v_departament_id);
        exception when OTHERS then dbms_output.put_line('buba add_employee');
    end add_employee;
end package_cgg;
/
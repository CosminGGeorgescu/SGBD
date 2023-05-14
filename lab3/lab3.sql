set SERVEROUTPUT on;
-- 1
-- cursoare clasice
declare 
    cursor employee_cursor is
    select j.job_title, e.first_name, e.salary
    from jobs j
    left join employees e on j.job_id = e.job_id
    order by j.job_title;
    job_title jobs.job_title%TYPE;
    employee_name employees.first_name%TYPE;
    employee_salary employees.salary%TYPE;
begin
    open employee_cursor;
    loop
        fetch employee_cursor into job_title, employee_name, employee_salary;
        exit when employee_cursor%NOTFOUND;
        if employee_name is not null then
            dbms_output.put_line(job_title || ': ' || employee_name || ', ' || employee_salary);
        else
            dbms_output.put_line(job_title || ': No employees');
        end if;
    end loop;
    close employee_cursor;
end;
/

--2
--cursoare clasice
declare 
    cursor employee_cursor is
    select j.job_title, e.first_name, e.salary, row_number() over (partition by j.job_id order by e.first_name asc) as emp_num
    from jobs j
    left join employees e on j.job_id = e.job_id
    order by j.job_title, emp_num asc;
    
    job_title jobs.job_title%TYPE;
    employee_name employees.first_name%TYPE;
    employee_salary employees.salary%TYPE;
    prev_job_title jobs.job_title%TYPE := null;
    emp_num number;
    job_employee_count number := 0;
    job_total_salary number := 0;
    job_average_salary number := 0;
    total_employee_count number := 0;
    total_salary number := 0;
    total_average_salary number := 0;
begin
    open employee_cursor;
    loop
        fetch employee_cursor into job_title, employee_name, employee_salary, emp_num;
        exit when employee_cursor%NOTFOUND;
        
        if prev_job_title is null then
            prev_job_title := job_title;
        end if;
        
        if prev_job_title <> job_title then
                    select sum(e.salary) into job_total_salary from employees e join jobs j on j.job_title = prev_job_title and e.job_id = j.job_id;

            dbms_output.put_line('Job title: ' || prev_job_title);
            dbms_output.put_line('Number of employees: ' || job_employee_count);
            dbms_output.put_line('Total salary: ' || job_total_salary);

            if job_employee_count > 0 then
                job_average_salary := job_total_salary / job_employee_count;
                dbms_output.put_line('Average salary: ' || job_average_salary);
            end if;
            dbms_output.put_line('----------------------------------');
            
            prev_job_title := job_title;
            job_employee_count := 0;
            job_total_salary := 0;
            job_average_salary := 0;
        end if;
        if employee_name is not null then
            dbms_output.put_line(job_title || ': ' || emp_num || ', ' || employee_name || ', ' || employee_salary);
            job_employee_count := job_employee_count + 1;
        else
            dbms_output.put_line(job_title || ': No employees');
        end if;
    end loop;
        select sum(e.salary) into job_total_salary from employees e join jobs j on j.job_title = prev_job_title and e.job_id = j.job_id;

    dbms_output.put_line('Job title: ' || prev_job_title);
    dbms_output.put_line('Number of employees: ' || job_employee_count);
    dbms_output.put_line('Salary: ' || job_total_salary);
    
    if job_employee_count > 0 then
        job_average_salary := job_total_salary / job_employee_count;
        dbms_output.put_line('Average salary: ' || job_average_salary);
    end if;
            select count(*) into total_employee_count from employees;
select sum(e.salary) into total_salary
    from employees e;
    if total_employee_count != 0 then
        total_average_salary := total_salary / total_employee_count;
    end if;
                dbms_output.put_line('----------------------------------');

    
    dbms_output.put_line('Total number of employees: ' || total_employee_count);
    dbms_output.put_line('Total salary: ' || total_salary);
    dbms_output.put_line('Total average salary: ' || total_average_salary);
    close employee_cursor;
end;
/

--3
--cursoare clasice
declare 
    cursor employee_cursor is
    select j.job_title, e.first_name, e.salary, row_number() over (partition by j.job_id order by e.first_name asc) as emp_num
    from jobs j
    left join employees e on j.job_id = e.job_id
    order by j.job_title, emp_num asc;
    
    job_title jobs.job_title%TYPE;
    employee_name employees.first_name%TYPE;
    employee_salary employees.salary%TYPE;
    prev_job_title jobs.job_title%TYPE := null;
    emp_num number;
    job_employee_count number := 0;
    job_total_salary number := 0;
    job_average_salary number := 0;
    total_employee_count number := 0;
    total_salary number := 0;
    total_average_salary number := 0;
begin
            select count(*) into total_employee_count from employees;
select sum(e.salary + (e.salary * nvl(e.commission_pct, 0))) into total_salary
    from employees e;
    open employee_cursor;
    loop
        fetch employee_cursor into job_title, employee_name, employee_salary, emp_num;
        exit when employee_cursor%NOTFOUND;
        
        if prev_job_title is null then
            prev_job_title := job_title;
        end if;
        
        if prev_job_title <> job_title then
                    select sum(e.salary + (e.salary * nvl(e.commission_pct, 0))) into job_total_salary from employees e join jobs j on j.job_title = prev_job_title and e.job_id = j.job_id;

            dbms_output.put_line('Job title: ' || prev_job_title);
            dbms_output.put_line('Number of employees: ' || job_employee_count);
            dbms_output.put_line('Total salary: ' || job_total_salary);

            if job_employee_count > 0 then
                job_average_salary := job_total_salary / job_employee_count;
                dbms_output.put_line('Average salary: ' || job_average_salary);
            end if;
            dbms_output.put_line('----------------------------------');
            
            prev_job_title := job_title;
            job_employee_count := 0;
            job_total_salary := 0;
            job_average_salary := 0;
        end if;
        if employee_name is not null then
            dbms_output.put_line(job_title || ': ' || emp_num || ', ' || employee_name || ', ' || employee_salary || ', ' || (100 * employee_salary) / total_salary || '%');
            job_employee_count := job_employee_count + 1;
        else
            dbms_output.put_line(job_title || ': No employees');
        end if;
    end loop;
        select sum(e.salary + (e.salary * nvl(e.commission_pct, 0))) into job_total_salary from employees e join jobs j on j.job_title = prev_job_title and e.job_id = j.job_id;

    dbms_output.put_line('Job title: ' || prev_job_title);
    dbms_output.put_line('Number of employees: ' || job_employee_count);
    dbms_output.put_line('Salary: ' || job_total_salary);
    
    if job_employee_count > 0 then
        job_average_salary := job_total_salary / job_employee_count;
        dbms_output.put_line('Average salary: ' || job_average_salary);
    end if;

    if total_employee_count != 0 then
        total_average_salary := total_salary / total_employee_count;
    end if;
                dbms_output.put_line('----------------------------------');

    
    dbms_output.put_line('Total number of employees: ' || total_employee_count);
    dbms_output.put_line('Total salary: ' || total_salary);
    dbms_output.put_line('Total average salary: ' || total_average_salary);
    close employee_cursor;
end;
/

--4
--cursoare clasice
declare 
    cursor employee_cursor is
    select j.job_title, e.first_name, e.salary, row_number() over (partition by j.job_id order by e.first_name asc) as emp_num
    from jobs j
    left join employees e on j.job_id = e.job_id
    order by j.job_title, emp_num asc;
    
    job_title jobs.job_title%TYPE;
    employee_name employees.first_name%TYPE;
    employee_salary employees.salary%TYPE;
    prev_job_title jobs.job_title%TYPE := null;
    emp_num number;
    job_employee_count number := 0;
    job_total_salary number := 0;
    job_average_salary number := 0;
    total_employee_count number := 0;
    total_salary number := 0;
    total_average_salary number := 0;
    linii number := 0;
begin
            select count(*) into total_employee_count from employees;
select sum(e.salary + (e.salary * nvl(e.commission_pct, 0))) into total_salary
    from employees e;
    open employee_cursor;
    loop
        fetch employee_cursor into job_title, employee_name, employee_salary, emp_num;
        exit when employee_cursor%NOTFOUND;
        
        if prev_job_title is null then
            prev_job_title := job_title;
        end if;
        
        if prev_job_title <> job_title then
                    select sum(e.salary + (e.salary * nvl(e.commission_pct, 0))) into job_total_salary from employees e join jobs j on j.job_title = prev_job_title and e.job_id = j.job_id;

            dbms_output.put_line('Job title: ' || prev_job_title);
            dbms_output.put_line('Number of employees: ' || job_employee_count);
            dbms_output.put_line('Total salary: ' || job_total_salary);

            if job_employee_count > 0 then
                job_average_salary := job_total_salary / job_employee_count;
                dbms_output.put_line('Average salary: ' || job_average_salary);
            end if;
            
            select count(*) into linii from (select *
from
(select e.first_name, e.last_name, j.job_title, e.salary, ROW_NUMBER() OVER (PARTITION BY j.job_title ORDER BY e.salary DESC) as rn
from jobs j
join employees e on e.job_id = j.job_id
order by j.job_title, e.salary desc) a
where rn <= 5 and a.job_title = prev_job_title);
if linii < 5 then
    dbms_output.put_line('!!!!!!!Mai putin de 5!!!!!!!');
    end if;
            
            for c in (select *
from
(select e.first_name, e.last_name, j.job_title, e.salary, ROW_NUMBER() OVER (PARTITION BY j.job_title ORDER BY e.salary DESC) as rn
from jobs j
join employees e on e.job_id = j.job_id
order by j.job_title, e.salary desc) a
where rn <= 5 and a.job_title = prev_job_title) loop
                dbms_output.put_line(c.rn || ': ' || c.first_name || ' ' || c.last_name);
            end loop;
                        dbms_output.put_line('----------------------------------');

            prev_job_title := job_title;
            job_employee_count := 0;
            job_total_salary := 0;
            job_average_salary := 0;
        end if;
        if employee_name is not null then
            dbms_output.put_line(job_title || ': ' || emp_num || ', ' || employee_name || ', ' || employee_salary || ', ' || (100 * employee_salary) / total_salary || '%');
            job_employee_count := job_employee_count + 1;
        else
            dbms_output.put_line(job_title || ': No employees');
        end if;
    end loop;
        select sum(e.salary + (e.salary * nvl(e.commission_pct, 0))) into job_total_salary from employees e join jobs j on j.job_title = prev_job_title and e.job_id = j.job_id;

    dbms_output.put_line('Job title: ' || prev_job_title);
    dbms_output.put_line('Number of employees: ' || job_employee_count);
    dbms_output.put_line('Salary: ' || job_total_salary);
    
    if job_employee_count > 0 then
        job_average_salary := job_total_salary / job_employee_count;
        dbms_output.put_line('Average salary: ' || job_average_salary);
    end if;

select count(*) into linii from (select *
from
(select e.first_name, e.last_name, j.job_title, e.salary, ROW_NUMBER() OVER (PARTITION BY j.job_title ORDER BY e.salary DESC) as rn
from jobs j
join employees e on e.job_id = j.job_id
order by j.job_title, e.salary desc) a
where rn <= 5 and a.job_title = prev_job_title);
if linii < 5 then
    dbms_output.put_line('!!!!!!!Mai putin de 5!!!!!!!');
    end if;
            
            for c in (select *
from
(select e.first_name, e.last_name, j.job_title, e.salary, ROW_NUMBER() OVER (PARTITION BY j.job_title ORDER BY e.salary DESC) as rn
from jobs j
join employees e on e.job_id = j.job_id
order by j.job_title, e.salary desc) a
where rn <= 5 and a.job_title = prev_job_title) loop
                dbms_output.put_line(c.rn || ': ' || c.first_name || ' ' || c.last_name);
            end loop;

    if total_employee_count != 0 then
        total_average_salary := total_salary / total_employee_count;
    end if;
                dbms_output.put_line('----------------------------------');

    
    dbms_output.put_line('Total number of employees: ' || total_employee_count);
    dbms_output.put_line('Total salary: ' || total_salary);
    dbms_output.put_line('Total average salary: ' || total_average_salary);
    close employee_cursor;
end;
/
--5

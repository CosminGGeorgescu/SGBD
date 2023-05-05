set SERVEROUTPUT on;
--1
declare
    type emp_id_list is table of employees.employee_id%TYPE;
    v_emp_ids emp_id_list := emp_id_list();
    v_old_salary employees.salary%TYPE;
begin
    select employee_id
    BULK collect into v_emp_ids
    from (select employee_id
          from employees
          where commission_pct is null
          order by salary asc)
    where ROWNUM <= 5;
    
    for i in v_emp_ids.FIRST..v_emp_ids.LAST loop
        select salary into v_old_salary
        from employees
        where employee_id = v_emp_ids(i);
        
        update employees_cgg
        set salary = salary * 1.05
        where employee_id = v_emp_ids(i);

        dbms_output.put_line(v_emp_ids(i) || ' vechi: ' || v_old_salary || ' nou: ' || (v_old_salary * 1.05));
    end loop;
end;
/
--2
create type tip_orase_cgg as table of varchar2(20);
/
create table excursie_cgg(
    cod_excursie number(4),
    denumire varchar2(20),
    orase tip_orase_cgg,
    status varchar2(20) check (status in ('disponibila', 'anulata'))
) nested table orase store as orase_tab;
/
drop table excursie_cgg;
/
--a
insert into excursie_cgg values (1, 'Transylvania Tour', tip_orase_cgg('Bucharest', 'Brasov', 'Sibiu'), 'disponibila');
insert into excursie_cgg values (2, 'West Coast USA', tip_orase_cgg('New York', 'San Francisco', 'Los Angeles', 'Las Vegas'), 'anulata');
insert into excursie_cgg values (3, 'European Capitals', tip_orase_cgg('Paris', 'Rome', 'Venice', 'Vienna'), 'disponibila');
insert into excursie_cgg values (4, 'Japan Highlights', tip_orase_cgg('Tokyo', 'Kyoto', 'Osaka'), 'disponibila');
insert into excursie_cgg values (5, 'Australia East Coast', tip_orase_cgg('Sydney', 'Melbourne', 'Brisbane'), 'disponibila');
/
--b
declare
    id_excursie number := &id_excursie;
    oras varchar(20) := '&oras';
begin
    update excursie_cgg
    set orase = orase multiset union tip_orase_cgg(oras)
    where cod_excursie = id_excursie;
end;
/
declare
    id_excursie number := &id_excursie;
    oras varchar(20) := '&oras';
    tabel tip_orase_cgg := tip_orase_cgg();
    aux tip_orase_cgg := tip_orase_cgg();
begin
    select orase
    into tabel
    from excursie_cgg
    where cod_excursie = id_excursie;
    
    for i in 1..tabel.count loop
        aux.extend;
        if i = 1
            then aux(i) := tabel(i);
        end if;
        if i = 2
            then aux(i) := oras2;
            aux.extend;
            aux(i + 1) := tabel(i);
        end if;
        if i > 2
            then aux(i + 1) := tabel(i);
        end if;
    end loop;
    
    update excursie_cgg
    set orase = aux
    where cod_excursie = id_excursie;    
end;
/
declare
    tabel tip_orase_cgg := tip_orase_cgg();
    id_excursie number := &id_excursie;
    oras1 varchar2(20) := '&oras1';
    oras2 varchar2(20) := '&oras2';
begin
    select orase
    into tabel
    from excursie_cgg
    where cod_excursie = id_excursie;
    
    for i in 1..tabel.count loop
        if tabel(i) = oras1
            then tabel(i) := oras2;
        else if tabel(i) = oras2
            then tabel(i) := oras1;
            end if;
        end if;
    end loop;
    
    update excursie_cgg
    set orase = tabel
    where cod_excursie = id_excursie;
end;
/
declare
    id_excursie number := &id_excursie;
    oras varchar(20) := '&oras';
    tabel tip_orase_cgg := tip_orase_cgg();
    aux tip_orase_cgg := tip_orase_cgg();
    idx number := 1;
begin
    select orase
    into tabel
    from excursie_cgg
    where cod_excursie = id_excursie;
    
    for i in 1..tabel.count loop
        if tabel(i) != oras
            then aux.extend;
                 aux(idx) := tabel(i);
                 idx := idx + 1;
        end if;
    end loop;
    
    update excursie_cgg
    set orase = aux
    where cod_excursie = id_excursie;
end;
/
declare
    tabel tip_orase_cgg := tip_orase_cgg();
    id_excursie number := &id_excursie;
begin
    select orase
    into tabel
    from excursie_cgg
    where cod_excursie = id_excursie;
    
    dbms_output.put_line(tabel.count);
    
    for i in 1..tabel.count loop
        dbms_output.put_line(tabel(i));
    end loop;
end;
/
declare
    tabel tip_orase_Cgg := tip_orase_cgg();
    TYPE tip_ids is varray(5) of number;
    ids tip_ids;
    id number;
begin
    select cod_excursie
    bulk collect into ids
    from excursie_cgg;
    
    for i in ids.FIRST..ids.LAST loop
        id := ids(i);
        select orase
        into tabel
        from excursie_cgg
        where cod_excursie = id;
        dbms_output.put_line(id);
        for i in 1..tabel.count loop
            dbms_output.put_line(tabel(i));
        end loop;
        dbms_output.put_line('');
    end loop;
end;
/
declare
    tabel tip_orase_cgg := tip_orase_cgg();
    TYPE tip_ids is varray(5) of number;
    ids tip_ids;
    id number;
    mini number;
    maxi number;
begin
    select cod_excursie 
    bulk collect into ids
    from excursie_cgg;
    
    id := ids(1);
    select orase
    into tabel
    from excursie_cgg
    where cod_excursie = id;
    
    mini := tabel.count;
    
    for i in 2..ids.LAST loop
        id := ids(i);
        select orase
        into tabel
        from excursie_cgg
        where cod_excursie = id;
        if tabel.count < mini
            then mini := tabel.count;
        end if;
    end loop;
    
    dbms_output.put_line(mini);
    
    for i in ids.FIRST..ids.LAST loop
        id := ids(i);
        select orase
        into tabel
        from excursie_cgg
        where cod_Excursie = id;
        if tabel.count = mini then
            update excursie_cgg
            set status = 'anulata'
            where cod_excursie = id;
        end if;
    end loop;
end;
--3
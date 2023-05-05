set SERVEROUTPUT ON;
--1
--a) 2
--b) text 2
--c) text 3 adaugat in sub-bloc
--d) 101
--e) text 1 adaugat un blocul principal
--f) text 2 adaugat in blocul principal

--2


--3
declare
    nume member.last_name%TYPE := '&nume';
    nr_filme number;
begin
    select count(distinct r.title_id)
    into nr_filme
    from rental r
    join member m on m.member_id = r.member_id
    where lower(m.last_name) like lower(nume);
    dbms_output.put_line(nume || ': ' || nr_filme || ' filme');
    exception
        when NO_DATA_FOUND then dbms_output.put_line('no se puede');
        when TOO_MANY_ROWS then dbms_output.put_line('no se puede');
end;
/
--4
declare
    nr_filme number(6);
    nume member.last_name%TYPE := '&nume';
    total number(6);
begin
    select count(distinct r.title_id)
    into nr_filme
    from rental r
    join member m on m.member_id = r.member_id
    where lower(m.last_name) like lower(nume);
    
    select count(title_id)
    into total
    from title;
    dbms_output.put_line(nume || ': ');
    case
        when nr_filme >= 0.75 * total
            then dbms_output.put_line('cat1');
        when nr_filme between (0.5 * total) and (0.75 * total)
            then dbms_output.put_line('cat2');
        when nr_filme between 0.25 * total and 0.5 * total
            then dbms_output.put_line('cat3');
        else dbms_output.put_line('cat4');
    end case;
end;
/
--5
create table member_cgg as select * from member;
alter table member_cgg add discount NUMBER;
declare
    nr_filme number(6);
    nume member.last_name%TYPE := '&nume';
    total number(6);
    dscnt number;
begin
    select count(distinct r.title_id)
    into nr_filme
    from rental r
    join member m on m.member_id = r.member_id
    where lower(m.last_name) like lower(nume);
    
    select count(title_id)
    into total
    from title;
    case
        when nr_filme >= 0.75 * total
            then dscnt := 10;
        when nr_filme between (0.5 * total) and (0.75 * total)
            then dscnt := 5;
        when nr_filme between 0.25 * total and 0.5 * total
            then dscnt := 3;
        else dscnt := 0;
    end case;
    
    update member_cgg
    set member_cgg.discount = dscnt
    where lower(member_cgg.last_name) like lower(nume);
    
    if SQL%ROWCOUNT > 0 then dbms_output.put_line('s-a facut update');
    end if;
end;
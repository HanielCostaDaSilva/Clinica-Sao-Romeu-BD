
/*Triggers relacionados com a data de nascimento do funcionário*/
create or replace function checkDatas() 
returns trigger as $$
begin

    IF AGE(new.Data_Nascimento) <= interval '18 years' then 
        raise exception  'O funcionário não possui idade suficiente para trabalhar!';
	end if;
    return new;
	end;
$$ language 'plpgsql';

create or replace trigger checkDataFunc 
before insert 
on FUNCIONARIO 
FOR EACH ROW
EXECUTE PROCEDURE checkDatas();
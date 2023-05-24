/*Tables Triggers functions*/
/*F--F--F--F--F--F--F--F--F--F--F--F--F--F--F--F--F--F--F--F--F--F--F--F--F--F--F*/

/*Para inserir novas especialidades na tabela especialidade*/
create or replace function inserirNovaEspecialidade() returns trigger as $$
declare 
    newEspecialidadeId integer;
    especialidadeNome text;
begin
    select COALESCE(max(id) + 1, 1 ) into newEspecialidadeId from especialidade; 
    select lower(new.descricao) into especialidadeNome;
    
    new.id:= newEspecialidadeId;
    new.descricao := especialidadeNome;

    return new;

    exception
      when unique_violation then 
        raise exception 'Essa especialidade Já havia sido adicionada anteriormente!'  USING ERRCODE = -50002;
    
end;

$$ language 'plpgsql';


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
/*F--F--F--F--F--F--F--F--F--F--F--F--F--F--F--F--F--F--F--F--F--F--F--F--F--F--F*/
/*Views Triggers functions*/
/*V--V--V--V--V--V--V--V--V--V--V--V--V--V--V--V--V--V--V--V--V--V--V--V--V--V--V*/

create or replace function inserirEspecialidadeCatalogo() returns trigger as $$
    declare
        precoDecimal decimal;
    begin
      SELECT cast(regexp_replace(new.preco, '[^0-9.]', '', 'g') AS DECIMAL) into precoDecimal;
      insert into Especialidade values(0, new.descricao, precoDecimal);
      return new;

    end;
$$ language 'plpgsql'; 

f.matricula, f.CPF, f.Nome, f.Data_nascimento, f.Data_admissao, c.funcao;

create or replace function inserirfuncionariosEncarregados() returns trigger as $$
    declare
        newCargoId integer;

        begin
            select Cargo.id into newCargoId 
            from Cargo where lower(new.funcao) = lower(Cargo.funcao);

            if newCargoId is null then  
                insert into Cargo values(default, new.funcao) returning Cargo.id into newId;
            end if;
            insert into funcionario 
            values(new.matricula, new.CPF, Null, new.Nome, new.Data_nascimento,COALESCE(new.Data_admissao, current_date), newId);
            
        return new;
        end;
    $$ language 'plpgsql';

/*V--V--V--V--V--V--V--V--V--V--V--V--V--V--V--V--V--V--V--V--V--V--V--V--V--V--V*/
/*!--!--!!--!--!!--!--!!--!--!!--!--!!--!--!!--!--!!--!--!!--!--!!--!--!!--!--!!--!--!!--!--!*/
/*Triggers creation*/
/*!--!--!!--!--!!--!--!!--!--!!--!--!!--!--!!--!--!!--!--!!--!--!!--!--!!--!--!!--!--!!--!--!*/

/*Tables Triggers*/

/*Funcionario*/
create or replace trigger checkDataFunc 
before insert 
on FUNCIONARIO 
FOR EACH ROW
EXECUTE PROCEDURE checkDatas();

/*Especialidade*/
create trigger insertNewEspecialidade 
before insert 
on  Especialidade 
for each ROW
execute PROCEDURE inserirNovaEspecialidade();

/*View Triggers*/

/* catalogoEspecialidade trigger */

create trigger insertNewEspecialidadeOnCatalago 
instead of insert 
on  catalogoEspecialidade 
for each ROW
execute PROCEDURE inserirEspecialidadeCatalogo();


/* catalogoEspecialidade trigger */

create or replace trigger InsertfuncionariosEncarregados
instead of insert 
on funcionariosEncarregados 
for each ROW
execute PROCEDURE inserirfuncionariosEncarregados();


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

create or replace function LimiteUpdateSalario()
RETURNS TRIGGER AS $$
DECLARE
    limiteSalarioSuperior decimal;
    limiteSalarioInferior decimal;
    porcentagemLim decimal;
BEGIN
    porcentagemLim := 0.45;

    if (new.salario_base > old.salario_base) THEN
        limiteSalarioSuperior := (old.salario_base * (1 + porcentagemLim));
        if (new.salario_base not between old.salario_base and limiteSalarioSuperior ) THEN
            raise EXCEPTION 'O novo salário extrapolou o limite superior de % por cento', (porcentagemLim * 100)
                USING HINT = 'Insira um novo salário menor que: R$ ' || limiteSalarioSuperior,
                      ERRCODE = '70001';
        end if;

        raise notice 'O salário base da função % sofreu um aumento.', new.funcao;
        raise notice 'Salário anterior =====> %', old.salario_base;
        raise notice 'Salário Novo =====> %', new.salario_base;
        raise notice 'Aumento de =====>  R$ %', new.salario_base - old.salario_base;
        raise notice '';

    ELSIF (new.salario_base < old.salario_base) THEN
        
        limiteSalarioInferior :=  old.salario_base - (old.salario_base * porcentagemLim); 

        IF (new.salario_base not between limiteSalarioInferior and old.salario_base ) THEN
            raise EXCEPTION 'O novo salário extrapolou o limite inferior de % por cento.', (porcentagemLim * 100)
                USING HINT = 'Insira um novo salário maior que: R$ ' || limiteSalarioInferior,
                      ERRCODE = '70002';
        END IF;

        raise notice 'O salário base da função % sofreu um decréscimo.', new.funcao;
        raise notice 'Salário anterior =====> %', old.salario_base;
        raise notice 'Salário Novo =====> %', new.salario_base;
        raise notice 'Decréscimo de =====>  R$ %', old.salario_base - new.salario_base;
        raise notice '';
    END IF;

    RETURN new;
END;
$$ LANGUAGE 'plpgsql';

create or replace function InsertNewCargo()
returns trigger as $$

declare
    idCargoExistente integer;
    novoID integer;
begin
    new.funcao := lower(new.funcao);
    
    select distinct id into idCargoExistente from cargo 
    where lower(funcao)= new.funcao;
    
    if idCargoExistente is null then
        --Referente a inserção
            select max(coalesce(cargo.id, 0)) + 1 into novoID from cargo;
            new.id := novoID;
        new.salario_base := new.salario_base; 
        
        raise notice ' A função % foi inserida com o salário base: R$ %', new.funcao, new.salario_base;
    else
        --Referente a atualização
        update Cargo set salario_base = new.salario_base where Cargo.id = idCargoExistente;
        raise notice ' o salario base da função % foi atualizado para: R$ %', new.funcao, new.salario_base;

    end if;

    return new;
end;
$$ language 'plpgsql';

/*Este trigger deverá garantir que um supervisor receba um bônus de 15% no seu salario, e verificar caso ele tenha sido excluído da lista de supervisores.  Se isso acontecer, ele perderá o bônus 15%*/
create or replace function checarAumentoBonus() returns trigger as $$
declare
    bonusSupervisor integer = 15;
    supervisores text[];
    antigoSupervisor boolean;
begin
    select array_agg(distinct supervisor) into supervisores from funcionario where supervisor is not null;

    -- Checa se é um Update funcionário que está sendo adicionado
    if TG_OP = 'UPDATE' then
        -- Houve alteração no supervisor

            if new.supervisor <> all(supervisores) then
                update Funcionario
                set percentual_bonus = percentual_bonus + bonusSupervisor
                where matricula = new.supervisor;
            end if;
            
            -- Verifica se o antigo supervisor não é mais um supervisor
            select not exists (select 1 from funcionario where matricula = old.supervisor and matricula <> new.supervisor) into antigoSupervisor;
            if antigoSupervisor then
                update Funcionario
                set percentual_bonus = greatest(percentual_bonus - bonusSupervisor, 0)
                where matricula = old.supervisor;
            end if;

    -- Caso seja um novo funcionário 
    elsif TG_OP = 'INSERT' then 
        -- Checa se é um novo supervisor, caso seja, aplica o bônus.
        if new.supervisor <> all(supervisores) then
            update Funcionario
            set percentual_bonus = percentual_bonus + bonusSupervisor
            where matricula = new.supervisor;
        end if;
    
    elsif TG_OP = 'DELETE' then
        select not exists (select 1 from funcionario where matricula = old.supervisor and matricula <> new.supervisor) into antigoSupervisor;
    
            if antigoSupervisor then
                update Funcionario
                set percentual_bonus = greatest(percentual_bonus - bonusSupervisor, 0)
                where matricula = old.supervisor;
            
        end if;
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

create or replace function inserirfuncionariosEncarregados() returns trigger as $$
    declare
        newCargoId integer;

        begin
            select Cargo.id into newCargoId 
            from Cargo where lower(new.funcao) = lower(Cargo.funcao);

            if newCargoId is null then  
                insert into Cargo values(default, new.funcao) returning Cargo.id into newCargoId;
            end if;
            insert into funcionario 
            values(new.matricula, new.CPF, new.Nome, null,new.Data_nascimento,COALESCE(new.Data_admissao, current_date), newCargoId);

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

-- Trigger para operações de UPDATE na coluna "supervisor"
CREATE TRIGGER ChecarBonusSupervisor_Update
BEFORE UPDATE ON funcionario
FOR EACH ROW
WHEN (OLD.supervisor IS DISTINCT FROM NEW.supervisor)
EXECUTE PROCEDURE checarAumentoBonus();

-- Trigger para operações de INSERT na coluna "supervisor"
CREATE TRIGGER ChecarBonusSupervisor_Insert
BEFORE INSERT ON funcionario
FOR EACH ROW
WHEN (NEW.supervisor IS NOT NULL)
EXECUTE PROCEDURE checarAumentoBonus();

-- Trigger para operações de DELETE na coluna "supervisor"
CREATE TRIGGER ChecarBonusSupervisor_Delete
BEFORE DELETE ON funcionario
FOR EACH ROW
WHEN (OLD.supervisor IS NOT NULL)
EXECUTE PROCEDURE checarAumentoBonus();

/*Especialidade*/
create trigger insertNewEspecialidade 
before insert 
on  Especialidade 
for each ROW
execute PROCEDURE inserirNovaEspecialidade();


/*Cargo*/
create trigger UpdateCargo 
before Update 
on  Cargo 
for each ROW
execute PROCEDURE LimiteUpdateSalario();


create trigger InsertCargo 
before insert 
on  Cargo 
for each ROW
execute PROCEDURE InsertNewCargo();

/*View Triggers*/

/* catalogoEspecialidade trigger */

create trigger insertNewEspecialidadeOnCatalago 
instead of insert 
on catalogoEspecialidade 
for each ROW
execute PROCEDURE inserirEspecialidadeCatalogo();


/* funcionariosEncarregados trigger */

create or replace trigger InsertfuncionariosEncarregados
instead of insert 
on funcionariosEncarregados 
for each ROW
execute PROCEDURE inserirfuncionariosEncarregados();


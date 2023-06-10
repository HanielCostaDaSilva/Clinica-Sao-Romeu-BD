-- TODO O SCRIPT NECESSÁRIO PARA A CLÍNICA

-- Tabelas da Base de Dados da Clínica
CREATE TABLE PACIENTE (
    cpf char(11) NOT NULL PRIMARY KEY,
    Nome varChar(50) Not Null, 
    estado_urgencia int Not Null,
    Data_Nascimento  DATE Not Null,
    Rua  varChar(50) Not Null, 
    Bairro varChar(40) Not Null, 
    Cidade varChar(30) Not Null 
);

CREATE TABLE Numero_Telefone_Paciente(
    pacienteCPF char(11) NOT NULL,
    Numero_telefone char(11) Not Null,
    PRIMARY KEY (pacienteCPF, Numero_telefone)
);

CREATE TABLE FUNCIONARIO (
    matricula char(5) NOT NULL PRIMARY KEY,
    CPF char(11) NOT NULL UNIQUE,
    Nome varchar(50) NOT NULL,
	Supervisor char(5),
    Data_nascimento date NOT NULL,
    Data_admissao date NOT NULL,
    idCargo int NOT NULL,
    percentual_bonus int NOT NULL default 0.0
);

CREATE TABLE CARGO (
	id serial PRIMARY KEY Not Null,
	funcao varchar(45) UNIQUE Not Null,
	salario_base decimal(10,2) Not null
);

CREATE TABLE ESPECIALIDADE (
    id Serial  PRIMARY KEY   Not Null ,
    descricao Varchar(45) UNIQUE Not Null,
    preco_consulta Decimal(10,2) Not Null
);

CREATE TABLE MEDICO (
    Matricula char(5) PRIMARY KEY Not Null,
    crm char(6) UNIQUE Not Null,
    EspId int Not Null
);

CREATE TABLE RECEITA(
    id Serial  PRIMARY KEY  Not NUll ,
    MatMedico char(5) Not Null,
    CPFPaciente char(13) Not Null,
    Data_Realizacao date Not NUll,
    Data_Validade date Not Null
);

CREATE TABLE REMEDIO(
    id serial Not Null PRIMARY KEY,
    nome text UNIQUE Not Null 
);

CREATE TABLE PRESCRICAO (
    idReceita int,
    idRemedio int,
    descricao text Not Null,
    PRIMARY KEY (idReceita, idRemedio)
);

ALTER TABLE Numero_Telefone_Paciente ADD CONSTRAINT FK_Numero_telefone_2
    FOREIGN KEY (pacienteCPF)
    REFERENCES PACIENTE (cpf);
 
ALTER TABLE FUNCIONARIO ADD CONSTRAINT Cargo_FK
	FOREIGN KEY (idCargo)
	REFERENCES CARGO (id);
	
ALTER TABLE FUNCIONARIO ADD CONSTRAINT Supervisor_FK
    FOREIGN KEY (Supervisor)
    REFERENCES FUNCIONARIO (matricula);
 
ALTER TABLE MEDICO ADD CONSTRAINT Matricula_FK
    FOREIGN KEY (Matricula)
    REFERENCES FUNCIONARIO (matricula)
    ON DELETE CASCADE;
 
ALTER TABLE MEDICO ADD CONSTRAINT EspId_FK
    FOREIGN KEY (EspId)
    REFERENCES ESPECIALIDADE (id)
    ON DELETE CASCADE;

ALTER TABLE RECEITA ADD CONSTRAINT MatMedico_FK
    FOREIGN KEY (MatMedico)
    REFERENCES MEDICO (Matricula);

ALTER TABLE RECEITA ADD CONSTRAINT CPFPacient_Fk
    FOREIGN KEY (CPFPaciente)
    REFERENCES PACIENTE (cpf);

ALTER TABLE PRESCRICAO ADD CONSTRAINT FK_PRESCRICAO1
    FOREIGN KEY (idRemedio)
    REFERENCES REMEDIO (id);

ALTER TABLE PRESCRICAO ADD CONSTRAINT FK_PRESCRICAO2
    FOREIGN KEY (idReceita)
    REFERENCES RECEITA (id);

-- Checks
ALTER TABLE PACIENTE ADD CONSTRAINT checkEstadoUrgencia  check (estado_urgencia between 1 and 5);

ALTER TABLE PACIENTE ADD CONSTRAINT checkDataNascimento check (data_nascimento <= current_date);

ALTER TABLE PACIENTE ADD CONSTRAINT checkCPF check (cpf ~ '^[0-9]{11}$');

ALTER TABLE Numero_Telefone_Paciente ADD CONSTRAINT checkNumeroTelefone check (Numero_telefone ~ '^[0-9]{11}$');

ALTER TABLE FUNCIONARIO ADD CONSTRAINT checkCPFFuncionario check (CPF ~ '^[0-9]{11}$');

ALTER TABLE FUNCIONARIO ADD CONSTRAINT checkData_admissao check (Data_admissao <= current_date);

ALTER TABLE FUNCIONARIO ADD CONSTRAINT checkMatricula check (matricula ~ '^[A-Z]{5}$');

ALTER TABLE CARGO ADD CONSTRAINT checkSalarioBase check (salario_base > 0.0);

ALTER TABLE ESPECIALIDADE ADD CONSTRAINT checkPreco_consulta check (preco_consulta >= 0.0);

ALTER TABLE RECEITA ADD CONSTRAINT checkDataValidade check (Data_Validade < current_date + INTERVAL '60 days');

ALTER TABLE RECEITA ADD CONSTRAINT checkData_Realizacao check (Data_Realizacao <= current_date);

ALTER TABLE REMEDIO ADD CONSTRAINT checkDescricao check (length(nome) <= 100);

ALTER TABLE PRESCRICAO ADD CONSTRAINT checkIdReceita check (idReceita > 0);

ALTER TABLE PRESCRICAO ADD CONSTRAINT checkIdRemedio check (idRemedio > 0);

-- Índices para o base de dados da clínica São Romeu

-- Índice para os CPFs dos paciente nas receitas médicas
create index idx_cpfPaciente
on receita (cpfPaciente);
/* Justificativa: acessar os dados de determinado paciente mais rapidamente dentro da tabela RECEITA */

-- Índice para otimizar as pesquisas via data de realização da consulta médica
create index idx_consultas_realizadas
on receita (data_realizacao);
/* Justificativa: agrupar o acesso às receitas de acordo com a data de realização das mesmas */

-- Índice no estado de emergência do paciente
create index idx_estado_paciente
on paciente (estado_urgencia);
/* Justificativa: de acordo com os estado de urgência, é possível saber quais são os pacientes que
precisem de mais atenção (os mais graves). Por isso, acessar mais rapidamente esta condição
é de extrema importância para o contexto da clínica. */

-- Views da clínica São Romeu

/*View relacionada a demonstrar  quais os médicos da clínica e suas respectivas especialidades */
create or replace View catalogoMedico as
select f.matricula, m.crm, f.nome, e.descricao as "Especialidade"
from funcionario f inner join medico m on f.matricula = m.matricula 
inner join especialidade e on e.id = m.espid;


/*View que apressenta a quantidade de pacientes que visitaram a clínica a partir de um endereço*/
create or replace View pacientePorEndereco as
select bairro, cidade, count(*) 
from paciente
group by  bairro,cidade;

select * from pacientePorEndereco;

/*View que apresenta a quantidade de consultas e o valor monetário arrecado para cada especialidade na clínica.*/
create or replace View arrecadadoPorEspecialidade as 
select e.descricao as "Especialidade",count(e.id) as "total_Consulta", to_char( Sum(e.preco_consulta), 'R$999,999,999.99') as "total_Arrecadado"
from receita r 
	inner join medico m on r.matmedico = m.matricula
	inner join especialidade e on m.espid = e.id
group by e.descricao;

/* View que projeta os remédios receitados, e quem recebeu pela
primeira vez o medicamento*/
create or replace view RemediosReceitados as
select rem.nome as remedio, 
	f.nome AS medico, 
	e.descricao AS especialidade, 
	p.nome AS primeiro_paciente,
	rec.data_realizacao
from paciente p 
	join receita rec on p.cpf = rec.cpfpaciente
	join medico m on rec.MatMedico = m.Matricula
	join especialidade e on e.id = m.espid
	join funcionario f on m.matricula = f.matricula
	join prescricao prec on prec.idReceita = rec.id
	join remedio rem on rem.id = prec.idRemedio
where prec.idReceita = (
    select min(idReceita)
    from prescricao
    where idRemedio = prec.idRemedio
);
--drop view remediosReceitados;
select * from RemediosReceitados;

create or replace view SupervisoresClinica as
select f.matricula,
       f.nome,
       (select count(*) FROM funcionario where supervisor = f.matricula) as total_subordinados,
       case when me.espid is not null then 'Sim' else 'Não' end as e_medico
from medico me
right join funcionario f on f.matricula = me.matricula
left join funcionario m on f.matricula = m.supervisor
where f.matricula in (select distinct supervisor from funcionario)
group by f.matricula, f.nome, e_medico;

-- drop view SupervisoresClinica;
select * from SupervisoresClinica;

/*View que permitirá inserção de dados.*/
/*View que apressenta um catálogo a respeito das especialidades oferecidas e seus respectivos preços*/
create or replace View catalogoEspecialidade(descricao, preco) as
select descricao as "Especialidade",  to_char(preco_consulta, 'R$999,999,999.99')  as "consulta"
from especialidade;

select * from catalogoEspecialidade;

/*View que permitirá inserção de dados.*/
/*View que apressenta  as formas de contato para os pacientes; */
create or replace View contatoPacientes as
select p.cpf,p.nome, ntp.numero_telefone as "numero" 
from paciente p inner join numero_telefone_paciente ntp on p.cpf = ntp.pacientecpf;

select * from ContatoPacientes;

/*View que permitirá inserção de dados.*/
/*View que apressenta todos os funcionários que possuem, ou não, função na clínica ; */

create or replace view funcionariosencarregados as
select f.matricula, f.CPF, f.Nome, f.Data_nascimento, f.Data_admissao, c.funcao
from FUNCIONARIO f left outer join CARGO c on f.idCargo = c.id;

select * from funcionariosencarregados;

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
        select coalesce(max(cargo.id), 0) + 1 into novoID from cargo;
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
            if new.supervisor not in (select unnest(supervisores)) then
                update Funcionario
                set percentual_bonus = percentual_bonus + bonusSupervisor
                where matricula = new.supervisor;
            end if;
            
            -- Verifica se o antigo supervisor não é mais um supervisor
            select not exists (select 1 from funcionario where matricula = old.supervisor and matricula <> new.supervisor) into antigoSupervisor;
            if antigoSupervisor then
				if (select count(*) from funcionario where supervisor = old.supervisor) = 0 then
					supervisores := array_remove(supervisores, old.supervisor);
					update Funcionario
					set percentual_bonus = greatest(percentual_bonus - bonusSupervisor, 0)
					where matricula = old.supervisor;
            	end if;
			end if;
			
    -- Caso seja um novo funcionário 
    elsif TG_OP = 'INSERT' then 
        -- Checa se é um novo supervisor, caso seja, aplica o bônus.
        if new.supervisor not in (select unnest(supervisores)) then
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
AFTER UPDATE ON funcionario
FOR EACH ROW
WHEN (NEW.supervisor IS DISTINCT FROM OLD.supervisor)
EXECUTE PROCEDURE checarAumentoBonus();
-- drop trigger ChecarBonusSupervisor_Update on funcionario;

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

/* catalogoEspecialidade trigger */
create or replace trigger InsertfuncionariosEncarregados
instead of insert 
on funcionariosEncarregados 
for each ROW
execute PROCEDURE inserirfuncionariosEncarregados();

-- Funções usadas na inserção na Base de Dados da clínica
CREATE or replace Function inserirEspecialidade (
    descricaoInserir Varchar(45),
    preco_consultaInserir Decimal(10, 2)
) 
returns void as $$
    Declare
        especialidadeCadastrada Especialidade.id%type;
		e_new_id integer;
    Begin 
        select E.id into especialidadeCadastrada from Especialidade E where E.descricao ilike lower(descricaoInserir);
        if preco_consultaInserir < 0.0 then RAISE EXCEPTION 'O valor não pode ser negativo.'; 
        ELSE 
            IF especialidadeCadastrada IS NOT NULL THEN 
                UPDATE Especialidade SET preco_consulta = preco_consultaInserir WHERE id = especialidadeCadastrada;
            ELSE
				select coalesce(max(id)+1, 1) into e_new_id from especialidade;
                INSERT INTO Especialidade VALUES (e_new_id, lower(descricaoInserir), preco_consultaInserir);
            END IF;
        END IF;
    end;
$$ LANGUAGE 'plpgsql';

create or replace function inserirTelefonePaciente(
    pacienteCPF char(11),
    Numero_telefone char(11)
) returns void as $$    
    Begin
        INSERT INTO Numero_telefone_paciente VALUES (pacienteCPF, Numero_telefone);
    end;
$$LANGUAGE 'plpgsql';


/*Dá para transformar em trigger*/
create or replace function inserirRemedio(
    nomeRemedio text
) returns int as $$
    
    Declare
        remedioNewId Remedio.id%type;

    begin
        select id into remedioNewId from Remedio r where lower(r.nome) like lower(nomeRemedio);

        if remedioNewId is Null then
            select COALESCE(max(id) + 1, 1) into remedioNewId from remedio;
            insert into Remedio values (remedioNewId,nomeRemedio);
        end If;
        
        return remedioNewId;
    end;

    $$ LANGUAGE 'plpgsql';
    

create or replace function inserirPrescricao(
    receitaId PRESCRICAO.idReceita%type,
    remedioNome REMEDIO.nome%type,
    descricao text
)returns void as  $$
    
    Declare
    remedioId Remedio.id%type;
    begin

        remedioId := inserirRemedio(remedioNome);
        insert into PRESCRICAO values (receitaId, remedioId, descricao);

    end; 
    $$ LANGUAGE 'plpgsql';

create or replace function inserirReceitaMedica(
    MatMedico char(5),
    CPFPaciente char(13),
    Data_Realizacao date,
    Data_Validade date,
    remediosReceitados text[] DEFAULT '{}',
    descricao PRESCRICAO.descricao%type default 'nenhuma descricao'
) returns void as $$
    
    Declare
        receitaId integer;
		 v_remedio TEXT;  
    Begin
        select COALESCE(max(id) +1, 1) into receitaId from Receita;
        INSERT INTO Receita  VALUES (receitaId, MatMedico, CPFPaciente,Data_Realizacao,Data_Validade);

        if array_length(remediosReceitados,1) > 0 then 
            
            FOREACH v_remedio IN ARRAY remediosReceitados LOOP
                PERFORM inserirPrescricao(receitaId, v_remedio, descricao);
            END LOOP;
        End If;
    END;
$$ LANGUAGE 'plpgsql';

create or replace function inserirCargo(
	funcao text,
	salario_base decimal default 0.0
) RETURNS void  as $$

Declare newId integer; 

Declare
begin
    SELECT  COALESCE(MAX(id)+ 1,1) INTO newId
    FROM CARGO; 
    IF salario_base < 0 THEN RAISE EXCEPTION 'O salário base não pode ser negativo.'; end if; begin
    INSERT INTO CARGO 
    values(newId, Trim(lower(funcao)), salario_base); exception WHEN unique_violation THEN raise exception 'funcao %, já havia sido inserida', funcao; end;

end;

$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION inserirFuncionario(
    matricula char(5),
    CPF char(11),
    Nome varchar(50),
    Data_nascimento date,
    Data_admissao date,
    cargoInserir text DEFAULT NULL,
    Supervisor char(5) DEFAULT NULL,
    percentualBonus int DEFAULT 0,
    crmInserir char(6) DEFAULT NULL,
    espIdInserir int DEFAULT NULL
) RETURNS void AS $$
DECLARE
    newIdCargo integer;
BEGIN
    IF percentualBonus < 0 THEN
        RAISE EXCEPTION 'O valor não pode ser negativo.';
    END IF;

    IF age(Data_nascimento) < interval '18 years' THEN
        RAISE EXCEPTION 'O funcionário é menor de idade.';
    END IF;

    IF cargoInserir IS NOT NULL THEN
        BEGIN
            PERFORM inserirCargo(cargoInserir);
        EXCEPTION
            WHEN OTHERS THEN
                NULL;
        END;

        SELECT id INTO newIdCargo FROM CARGO WHERE funcao = Trim(lower(cargoInserir));
    END IF;

    INSERT INTO FUNCIONARIO VALUES (matricula, CPF, Nome, Supervisor, Data_nascimento, Data_admissao, newIdCargo, percentualBonus);

    IF crmInserir IS NOT NULL THEN
        INSERT INTO MEDICO VALUES (matricula, crmInserir, espIdInserir);
    END IF;
END;
$$ LANGUAGE 'plpgsql';


CREATE or replace Function inserirPaciente(
    cpf char(11),
    Nome varChar(50),
    estado_urgencia int, -- Valores de 1 a 5, sendo 5 o mais urgente
    Data_Nascimento DATE,
    Rua varChar(50),
    Bairro varChar(40),
    Cidade varChar(30),
    Numeros_telefones text[] DEFAULT '{}'
) returns void as $$
    Declare
    v_telefone text;
    Begin
		-- Têm que ser valores de 1 a 5, sendo 5 o mais urgente
        IF estado_urgencia >5 or estado_urgencia < 1  then RAISE EXCEPTION 'Foi inserido um valor inválido no nível de Emergência.';
    end if;
    insert into Paciente values( cpf, Nome, estado_urgencia, Data_Nascimento, lower(Rua), lower(Bairro), lower(Cidade));
        FOREACH v_telefone in Array Numeros_telefones LOOP
            PERFORM inserirTelefonePaciente(cpf,v_telefone);
        end LOOP;
    end;
$$ LANGUAGE 'plpgsql';

-- Função com dados estatísticos da Clínica
create or replace function dadosEstatisticosClinica() returns table (
    total_pacientes        int,
    total_medicos          int,
    media_salario_base     numeric(10,2),
    paciente_mais_novo     varchar(50),
    paciente_mais_velho    varchar(50),
	media_idade_pacientes  NUMERIC(10,2),
    menor_salario          numeric(10,2),
    maior_salario          numeric(10,2),
    gastos_salariais       numeric(10,2)
) -- As colunas são os outputs da função
as
$$
begin -- Todas as consultas serão jogadas para cada variável/parâmetro
    select COUNT(*) into total_pacientes from paciente;
    select COUNT(*) into total_medicos from medico;
    select round(AVG(c.salario_base),2) into media_salario_base from funcionario f join cargo c on f.idcargo = c.id;
    select nome into paciente_mais_novo from paciente order by Data_Nascimento DESC LIMIT 1;
    select nome into paciente_mais_velho from paciente order by Data_Nascimento LIMIT 1;
	SELECT round(AVG(extract(year from age(Data_Nascimento))),2) INTO media_idade_pacientes FROM paciente;
    select MIN(c.salario_base) into menor_salario from funcionario f join cargo c on f.idcargo = c.id;
    select MAX(c.salario_base) into maior_salario from funcionario f join cargo c on f.idcargo = c.id;
    select (SUM(c.salario_base)+SUM(f.percentual_bonus)) into gastos_salariais from funcionario f join cargo c on f.idcargo = c.id;
    
    return NEXT;
	return;
end;
$$
language 'plpgsql';
--drop FUNCTION dadosestatisticosclinica()

select * from dadosEstatisticosClinica();

-- Procedures para a tabela Cargo

-- Função que atualiza o salário de um funcionário específico
create or replace procedure atualizarSalarioBase(
  idCargo cargo.id%type,
  aumentoSalarial cargo.salario_base%type
)  as $$
begin
  update cargo
  set salario_base = salario_base * (1 + (aumentoSalarial / 100)::numeric)
  where id = idCargo;
  if not found then
    raise notice 'Cargo com código % não encontrado.', idCargo;
  end if;
end;
$$ language plpgsql;

select * from cargo order by id;
select * from funcionario;

-- Função que atualiza o salário de todos os funcionários a partir de um valor percentual
create or replace procedure atualizarTodosSalarios(percentual numeric) as $$
begin
  update cargo
  set salario_base = salario_base * (1 + percentual/100)::numeric;
end;
$$ language 'plpgsql';

select * from cargo;
select * from funcionario;

-- Procedure para a tabela Especialidade

create or replace procedure atualizarPrecoConsulta(
    p_especialidade_id INT,
    p_novo_preco decimal(10,2)
)
as $$
declare preco_anterior decimal(10,2);
begin
	select preco_consulta into preco_anterior from especialidade where id=p_especialidade_id;
	if p_novo_preco = preco_anterior then raise exception 'O novo preço é o mesmo que o anterior!';
	end if;
	
    update especialidade
    set preco_consulta = p_novo_preco
    where id = p_especialidade_id;

    if found then
        raise notice 'Preço da consulta atualizado com sucesso!';
    else
        raise exception 'Especialidade não encontrada.'
		using hint = 'Verifique se o id está correto.';
    end if;
end;
$$ language plpgsql;

select * from especialidade order by id;
--call atualizarPrecoConsulta(1,100.00);

-- Funções para a tabela Funcionario

create or replace function mostrarSalariosFuncionarios()
returns table (matricula CHAR(50), nome varchar(40), funcao varchar(25),
			   percentual_bonus integer, salario_base numeric)
as $$
begin
    return query
    select f.matricula, f.nome, c.funcao, f.percentual_bonus,
			round(c.salario_base + (c.salario_base * f.percentual_bonus / 100), 2) as salario_base
    from funcionario f
    left join cargo c on f.idCargo = c.id;
end;
$$ language plpgsql;

select * from mostrarSalariosFuncionarios();

-- Testes com as functions criadas
-- Especialidades
select inserirEspecialidade('Oftalmologia',90.00);
select inserirEspecialidade('Pediatria',120.00);
select inserirEspecialidade('Otorrinolaringologia',150.00);
select * from especialidade;

-- Cargos
select inserirCargo('Diretor', 8000.00);
select inserirCargo('Atendente', 2500.00);
select inserirCargo('Zelador', 2100.00);
select inserirCargo('Motorista', 1600.00);
select inserirCargo('Pediatra', 5500.00);
select inserirCargo('Enfermeiro', 4750.00);
select inserirCargo('Otorrino', 5000.00);
select inserirCargo('Oftalmologo', 5400.00);

select * from cargo;

/*Supervisores*/
select inserirFuncionario('JULME','12345678901','Julieta Capuleto','03-01-1983', '12-05-2020','Diretor');
select inserirFuncionario('MARAS','39834594958','Maria Claudia','02-10-2000', '01-04-2019','Atendente','JULME');
select inserirFuncionario('METIA','22345078901','Melissa Gracias', '07-11-1990', '1-12-2021','Pediatra','JULME',0,'123456',2);
select * from FUNCIONARIO;

/*Funcionários Normais*/
select inserirFuncionario('JOMTE','56734594949','Joaquim Fagundes','09-01-1999', '01-05-2020','Atendente','MARAS');
select inserirFuncionario('QUEMT','50754594993','Quirino Gracias','05-11-1989', '23-09-2020','Zelador','MARAS');
select inserirFuncionario('IRTMA','12754594938','Iracema Gracias','03-01-1990', '12-05-2020','Zelador','MARAS');
select inserirFuncionario('JOIEC','45958958459','Joana Maria','07-11-2000', '1-12-2021','Motorista');
select inserirFuncionario('ATUFO','91889438403','Atélio Marcos','02-11-1999', '1-03-2021','Enfermeiro','MARAS');
select inserirFuncionario('KJDFD','37837530942','Joana Maria','02-11-1999', '1-03-2021','Enfermeiro','MARAS');
select * from FUNCIONARIO;

/*Médicos*/
select inserirFuncionario('AMFRO','94859485934','Amós Luís', '07-12-2000', '1-12-2021','Pediatra','METIA',0,'128084',2);
select inserirFuncionario('RUMCA','44355566472','Rubens Magno', '02-10-1983', '1-12-2019','Oftalmologo','METIA',0,'125756',1);
select inserirFuncionario('WILTN','45563565367','Wilter Venenoso', '02-09-1983', '1-09-2019','Oftalmologo','METIA',0,'128089',1);
select inserirFuncionario('FEJSA','13424462564','Felipe Jorge', '02-10-1980', '1-12-2020','Otorrino','METIA',0,'549854',3);
select inserirFuncionario('LOSJF','13424562564','Lorena Cerrana', '01-12-1989', '1-11-2020','Otorrino','METIA',0,'129454',3);
select * from MEDICO;
select * from FUNCIONARIO;

/*Pacientes*/
select inserirPaciente('82691696191', 'Allan Amancio', 1, '04-11-2004', 'Rua Chá de Camomila', 'Centro', 'São Miguel de Taipu', ARRAY['83982292523', '83986751649']);
select inserirPaciente('81763444962', 'João Silva', 2, '1990-05-15', 'Rua 2 de Novembro', 'Centro', 'São Miguel de Taipu', ARRAY['83912345678', '83987654321']);
select inserirPaciente('30729081210', 'Maria Souza', 1, '1985-09-20', 'Rua Laranja', 'Café do Vento', 'Sobrado', ARRAY['83911111111', '83922222222']);
select inserirPaciente('17583999459', 'Pedro Santos', 3, '2000-03-10', 'Rua Batista', 'Centro', 'São Miguel de Taipu', ARRAY['83933333333']);
select inserirPaciente('61814352624', 'Ana Oliveira', 1, '1995-07-02', 'Avenida São Jorge', 'Centro', 'São Miguel de Taipu', ARRAY['83944444444']);
select inserirPaciente('98521676000', 'Lucas Rodrigues', 2, '1980-12-30', 'Avenida Josemar', 'Amarelas', 'Pilar', ARRAY['83955555555']);
select inserirPaciente('82691692345', 'Pedro Alves', 3, '1998-12-10', 'Rua dos Bobos', 'Jardim Amália', 'Itabaiana', ARRAY['83912345678', '83998765432']);
select inserirPaciente('73536904461', 'Bruna Bastos', 4, '2000-02-20', 'Rua das Flores', 'Centro', 'São Miguel de Taipu', ARRAY['83911112222']);
select inserirPaciente('24874727359', 'Carlos Cunha', 1, '1985-05-05', 'Av. Paulista', 'Bela Vista', 'Pilar', ARRAY['83933334444', '83955556666']);
select inserirPaciente('00593248718', 'Daniela Duarte', 2, '1972-10-22', 'Rua do Comércio', 'Centro', 'São Miguel de Taipu', ARRAY['83977778888']);
select inserirpaciente('59485598603','Lucas Alvares',5,'03-11-2004','Marieta Araujo','Ernani Satiro','João Pessoa');
select inserirPaciente('93084818410','João Oliveira',5,'11-11-1962','Honório Neto','Bosque Velho','Pilar',ARRAY['83923893490']);
select inserirPaciente('13424462564','Felipe Jorge',1,'02-10-1980','Rua Vitorino','Bessa','João Pessoa',ARRAY['83919287093']);

select * from PACIENTE;
select * from Numero_Telefone_Paciente;

/*Receitas Médicas*/
select inserirReceitaMedica('RUMCA', '82691696191', '2023-04-30', '2023-05-30', '{"Dipirona","Lentes para miopia","Lacribell"}', 'Dificuldades para enxergar de perto e dores de cabeça.');
select inserirReceitaMedica('WILTN', '81763444962', '2023-04-30', '2023-05-30', '{"Proteção contra luz azul"}', 'Dores de cabeça ao se expor a luz solar');
select inserirReceitaMedica('AMFRO', '30729081210', '2023-04-30', '2023-05-30', '{"Dextrometorfano", "Guaifenesina"}', 'Dores no peito, dificuldade para respirar.');
select inserirReceitaMedica('FEJSA', '17583999459', '2023-04-30', '2023-05-30', '{"Amoxicilina", "Clavulanato de potássio"}', 'Dificuldade para respirar.');
select inserirReceitaMedica('RUMCA', '61814352624', '2023-04-30', '2023-05-30', '{"Lentes para astigmatismo"}', 'Dificuldades para enxergar ');
select inserirReceitaMedica('METIA', '98521676000', '2023-04-30', '2023-05-30', '{"Tríplice viral"}', 'Vacina contra sarampo');
select inserirReceitaMedica('LOSJF', '82691692345', '2023-04-30', '2023-05-30', '{"Tríplice viral"}', 'Vacina contra rubéola');
select inserirReceitaMedica('AMFRO', '73536904461', '2023-05-01', '2023-06-01', '{"Clorfeniramina"}', 'Medicação para alergia');
select inserirReceitaMedica('FEJSA', '24874727359', '2023-04-30', '2023-05-15', '{"Dramin", "Betahistina"}', 'Tratamento para labirintite');
select inserirReceitaMedica('METIA', '00593248718', '2023-04-30', '2023-06-15', '{"Diane 35", "Dipirona"}', 'Anticoncepcional oral');
select inserirReceitaMedica('LOSJF', '93084818410', '2023-06-04', '2023-07-15', '{"Prednisona"}', 'Corticosteroide anti-inflamatório e imunossupressor');

select * from receita;
select * from prescricao;
select * from remedio;

/*!!! You need active all triggers!!!*/
-- Testes com Views que permitem inserção

insert into catalogoespecialidade values('Ortopedista','R$ 159.34');
insert into catalogoespecialidade values('Demartologia','R$ 302.40');
select * from catalogoespecialidade;

insert into funcionariosEncarregados values('PAMER','56890312909','Paulo Costa','05-12-1970',null,'Zelador');
insert into funcionariosEncarregados values('JOAOE','56861267832','João Gomes','05-12-1980',null,'Atendente');
select * from funcionariosEncarregados;

-- Consultas de acordo com os requitos do modelo BDR propostos
/*
1- A clínica quer saber os pacientes mais graves, com estado de urgência maior ou igual a 4,
e com receituário nos últimos 3 meses. Sendo assim, faça uma consulta para estes casos. 
(Uso de operador básico de filtro)
*/
select p.nome as nome_paciente, pre.descricao, r.data_realizacao
from paciente p 
	inner join receita r
	on p.cpf = r.cpfpaciente
	inner join prescricao pre
	on pre.idReceita = r.id
where p.estado_urgencia >= 4 
	and r.data_realizacao >= current_date - interval '3 months';

/*
2- Obtenha o nome dos pacientes, nome dos médicos e descrição das especialidades para os pacientes
que possuem receitas prescritas por determinados médicos, juntamente com as descrições dos remédios,
no ano de 2023. (uso de INNER JOIN)
*/
select p.nome as nome_paciente, f.nome as nome_medico, 
		e.descricao as especialidade, r.nome as nome_remedio
from paciente p
		join receita rec on p.cpf = rec.cpfPaciente
		join medico m on rec.matMedico = m.matricula
		join funcionario f on f.matricula = m.matricula
		join especialidade e on m.espid = e.id
		join prescricao pres on rec.id = pres.idReceita
		join remedio r on pres.idRemedio = r.id
where extract(year from data_realizacao) = 2023;

/*
3- Consulte os funcionários que possuem um salário abaixo dos 4000 reais, para que sejam bonificados
pela direção geral.
*/
select f.nome, c.salario_base, f.percentual_bonus
from funcionario f
	inner join cargo c on f.idcargo = c.id
where salario_base + percentual_bonus < 4000.00;

/*
4- A clínica está fazendo uma promoção especial para pacientes maiores de 60 anos. Ela quer saber quem
são os sortudos e também seus números de telefone. Por isso, faça uma consulta. (Uso de INNER JOIN)
*/
select p.Nome, p.Data_Nascimento, t.numero_telefone
from PACIENTE p
join Numero_Telefone_Paciente t on p.cpf = t.pacienteCPF
where p.Data_Nascimento <= (current_date - INTERVAL '60 years');

/*
5- Obtenha o nome dos pacientes, a data da prescrição e o nome do medicamento para todas as
prescrições registradas na clínica, incluindo os pacientes que não possuem prescrições.
Certifique-se de listar todos os medicamentos, mesmo que não estejam associados a uma prescrição.
(Uso de Left e Right Outer Join)
*/
select
    p.Nome as nome_paciente,
    rec.Data_Realizacao as data_prescricao,
    rem.nome as nome_medicamento
from
    PACIENTE p
    left join RECEITA rec on p.cpf = rec.CPFPaciente
    left join PRESCRICAO pres on rec.id = pres.idReceita
    right join REMEDIO rem on pres.idRemedio = rem.id;

/*
6- Obtenha o número de prescrições realizadas por cada médico na clínica,
listando o nome do médico e a contagem de prescrições. Apenas inclua os médicos
que tenham realizado 2 ou mais prescrições. (Uso de agrupamento)
*/
select f.nome as nome_medico, count(*) as total_prescricoes
from funcionario f
	join medico m on f.matricula = m.matricula
	join receita r ON m.matricula = r.matmedico
group by f.nome
having count(*) >= 2;

/*
7- Obtenha a contagem de pacientes agrupados por faixa etária, incluindo as faixas de
idade de 0 a 18 anos, 19 a 30 anos, 31 a 45 anos, 46 a 55 anos e acima de 55 anos.
Os resultados devem ser ordenados em ordem decrescente de quantidade de pacientes em cada faixa etária.
(Uso de agrupamento)
*/
select
    case
        when extract(year from age(Data_Nascimento)) between 0 and 18 then '0-18 anos'
        when extract(year from age(Data_Nascimento)) between 19 and 30 then '19-30 anos'
        when extract(year from age(Data_Nascimento)) between 31 and 45 then '31-45 anos'
        when extract(year from age(Data_Nascimento)) between 46 and 55 then '46-55 anos'
        else 'Mais de 55 anos'
    end as faixa_etaria,
    count(*) as quantidade
from paciente
group by faixa_etaria
order by quantidade desc;

/*
8- Liste os médicos que também são pacientes. (Uso de uma operação com conjuntos)
*/
select nome
from funcionario f
	join medico m on f.matricula = m.matricula
intersect
select p.nome
from paciente p;

/*
9-  Selecionar os médicos que possuem o maior número de pacientes atendidos, e suas
respectivas matrículas. (Uso de subqueries)
*/
select f.nome, m.matricula
from medico m
	join funcionario f on m.matricula = f.matricula
where (select count(*) from receita r where r.matmedico = m.matricula) = 
    (select max(num_pacientes) from
        (select count(*) AS num_pacientes from receita group by matmedico) as t);

/*
10- Consulte os remédios prescritos mais de uma vez, independente do médico
que receitou. (Uso de subquerie)
*/
select r.nome
from remedio r
where r.id in (
    select pr.idRemedio
    from prescricao pr
    group by pr.idRemedio
    having count(pr.idRemedio) > 1
);

/*Consultas que foram melhoradas*/
-- Consulta 3
select f.nome, c.salario_base, f.percentual_bonus
from funcionario f
left join cargo c ON f.idCargo = c.id
where c.salario_base + f.percentual_bonus < 4000.00;

/* Justificativa: a consulta foi reescrita para utilizar a junção LEFT JOIN e selecionar
todos os funcionários, inclusive quem não possui cargo ainda, e outros campos
relevantes. Dessa forma, quem não possui cargo deverá receber um cargo posteriormente. */

-- Consulta 4
select p.Nome, p.Data_Nascimento, t.numero_telefone
from PACIENTE p
left join Numero_Telefone_Paciente t on p.cpf = t.pacienteCPF
where p.Data_Nascimento <= current_date - INTERVAL '60 years';

/* Justificativa: a consulta foi reescrita com LEFT JOIN para incluir todos os pacientes,
mesmo aqueles que não possuem número de telefone cadastrado. Isso permite
obter pacientes e seus números de telefone, caso existam. */
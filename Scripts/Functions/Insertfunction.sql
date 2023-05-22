-- Funções usadas na Base de Dados da clínica
create or replace function inserirFuncionario(
    matricula char(5),
    CPF char(11),
	Supervisor char(5) default NULL,
    Nome varChar(50),
	Data_nascimento date,
	Data_admissao date,
	idCargo integer default NULL,
    percentualBonus int,
    crmInserir char(6) default NULL,
    espIdInserir int default NULL
) returns void as $$ 
    Begin 
        if percentualBonus < 0 then RAISE EXCEPTION  'O valor não pode ser negativo.'; 
        end if;
    	IF age(Data_nascimento) < interval '18 years' THEN 
        	RAISE EXCEPTION 'O funcionário é menor de idade.'; 
    	END IF;
        insert into FUNCIONARIO (matricula, CPF, Supervisor, Nome, Data_Nascimento,
								 Data_Admissao, idCargo, percentualBonus)
		values (matricula, CPF, Supervisor, Nome, Data_nascimento,
									   Data_admissao, idCargo, percentualBonus);
        if crmInserir is not Null then 
        	insert into MEDICO values(upper(matricula), crmInserir, espIdInserir);
		end if;
   	end;
$$ LANGUAGE 'plpgsql';

CREATE or replace Function inserirPaciente(
    cpf char(11),
    Func_Cadastrante char(5),
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
    insert into Paciente values( cpf, Func_Cadastrante, Nome, estado_urgencia, Data_Nascimento, Rua, Bairro, Cidade);
        FOREACH v_telefone in Array Numeros_telefones LOOP
            PERFORM inserirTelefonePaciente(cpf,v_telefone);
        end LOOP;
    end;
$$ LANGUAGE 'plpgsql';

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
        select id into remedioNewId from Remedio r where lower(r.descricao) like lower(nomeRemedio);

        if remedioNewId is Null then
            select COALESCE(max(id) + 1, 1) into remedioNewId from remedio;
            insert into Remedio values (remedioNewId,nomeRemedio);
        end If;
        
        return remedioNewId;
    end;

    $$ LANGUAGE 'plpgsql';
    

create or replace function inserirPrescricao(
    receitaId PRESCRICAO.idReceita%type,
    remedioNome text
)returns void as  $$
    
    Declare
    remedioId Remedio.id%type;
    begin

        remedioId := inserirRemedio(remedioNome);
        insert into PRESCRICAO values (receitaId, remedioId);

    end; 
    $$ LANGUAGE 'plpgsql';

create or replace function inserirReceitaMedica(
    MatMedico char(5) ,
    CPFPaciente char(13) ,
    Descricao text ,
    Data_Realizacao date ,
    Data_Validade date,
    remediosReceitados text[] DEFAULT '{}'
) returns void as $$
    
    Declare
        receitaId Receita.id%type;
		 v_remedio TEXT;
    
    Begin

        select COALESCE(max(id) +1, 1) into receitaId from Receita;

        INSERT INTO Receita  VALUES (receitaId, MatMedico, CPFPaciente, Descricao, Data_Realizacao,Data_Validade);

        if array_length(remediosReceitados,1) > 0 then 
            
            FOREACH v_remedio IN ARRAY remediosReceitados LOOP
                PERFORM inserirPrescricao(receitaId, v_remedio);
            END LOOP;
        End If;
    END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION inserirCargo (
    funcaoInserir varchar(45),
    salario_baseInserir decimal(10, 2)
) 
RETURNS void AS $$
DECLARE
    cargoCadastrado cargo.id%TYPE;
    c_new_id integer;
BEGIN
    SELECT C.id INTO cargoCadastrado
    FROM cargo C
    WHERE C.funcao ILIKE lower(funcaoInserir);
    
    IF salario_baseInserir < 0.0 THEN
        RAISE EXCEPTION 'O salário base não pode ser negativo.';
    ELSE
        IF cargoCadastrado IS NOT NULL THEN
            UPDATE cargo
            SET salario_base = salario_baseInserir
            WHERE id = cargoCadastrado;
        ELSE
            SELECT COALESCE(MAX(id) + 1, 1) INTO c_new_id FROM cargo;
            INSERT INTO cargo (id, funcao, salario_base)
            VALUES (c_new_id, lower(funcaoInserir), salario_baseInserir);
			raise notice 'Cargo inserido com sucesso!';
        END IF;
    END IF;
END;
$$ LANGUAGE plpgsql;



create or replace function inserirCargo(
	funcao text,
	salario_base integer default 0
) as $$

    Declare
    newId integer;
    begin
    newId:= select COALESCE(max(id)+ 1,1) from CARGO;

    begin
        insert into CARGO values(newId, lower(funcao), salario_base (decimal));
    exception
        when sqlstate 'P0003' then raise exception 'o cargo: % já existe!',funcao;
    end;

    end;
$$LANGUAGE 'plpgsql'
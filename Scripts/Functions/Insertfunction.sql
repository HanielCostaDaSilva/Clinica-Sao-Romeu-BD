-- Funções usadas na Base de Dados da clínica

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


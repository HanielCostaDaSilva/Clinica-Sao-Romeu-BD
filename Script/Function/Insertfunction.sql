create or replace function inserirFuncionario(
    matricula char(5),
    CPF char(13),
    Nome varChar(50),
    funcao varChar(15),
    salario Decimal(2),
    Supervisor char(5),
    Data_nascimento date,
    Data_admissao date
) returns void as $$ 
    Begin 
        if salario < 0.0 then RAISE EXCEPTION  'O valor não pode ser negativo.'; 
        end if;

        if DATEDIF(year, Data_Nascimento, getDate()) < 18 then Raise Exception'O funcionário é menor de idade.'; 
        end if;

        insert into FUNCIONARIO values(
                matricula,
                cpf,
                funcao,
                salario,
                Supervisor,
                Data_Nascimento,
                Data_admissao
            );
        end;
    $$ LANGUAGE 'plpgsql';

CREATE or replace Function inserirPaciente(
    cpf char(13),
    Func_Cadastrante char(5),
    Nome varChar(50),
    estado_urgencia int,
    Data_Nascimento DATE,
    Rua varChar(50),
    Bairro varChar(40),
    Cidade varChar(30)
) returns void as $$

Begin
insert into Paciente values( cpf, Func_Cadastrante, Nome, estado_urgencia, Data_Nascimento, Rua, Bairro, Cidade);

end;

$$ LANGUAGE 'plpgsql';

CREATE or replace Function inserirEspecialidade (
    descricaoInserir Varchar(45),
    preco_consultaInserir Decimal(10, 2)
) 
returns void as $$
    
    Declare
        especialidadeCadastrada Especialidade.id%type;
    Begin 

        select E.id into especialidadeCadastrada from Especialidade E where E.descricao like lower(descricaoInserir);

        if preco_consultaInserir < 0.0 then RAISE EXCEPTION 'O valor não pode ser negativo.'; 

        ELSE 
            IF especialidadeCadastrada IS NOT NULL THEN 
                UPDATE Especialidade SET preco_consulta = preco_consultaInserir WHERE id = especialidadeCadastrada;
            ELSE 
                INSERT INTO Especialidade VALUES (default, lower(descricaoInserir), preco_consultaInserir);
            END IF;
        
        END IF;
    end;

$$ LANGUAGE 'plpgsql';
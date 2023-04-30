create or replace function inserirFuncionario(
    matricula char(5),
    CPF char(11),
    Nome varChar(50),
    funcao varChar(15),
    salario Decimal(10,2),
    Data_nascimento date,
    Data_admissao date,
	Supervisor char(5) default NULL,
    crmInserir char(6) default NULL,
    espIdInserir int default NULL
) returns void as $$ 
    Begin 
        if salario < 0.0 then RAISE EXCEPTION  'O valor não pode ser negativo.'; 
        end if;

    	IF age(Data_Nascimento) < interval '18 years' THEN 
        	RAISE EXCEPTION 'O funcionário é menor de idade.'; 
    	END IF;

        insert into FUNCIONARIO values(matricula, cpf, nome, funcao, salario, Supervisor, Data_Nascimento, Data_admissao);
        
        if crmInserir is not Null then 
        	insert into MEDICO values(upper(matricula), crmInserir, espIdInserir);
		end if;
   	end;
$$ LANGUAGE 'plpgsql';

CREATE or replace Function inserirPaciente(
    cpf char(11),
    Func_Cadastrante char(5),
    Nome varChar(50),
    estado_urgencia int,
    Data_Nascimento DATE,
    Rua varChar(50),
    Bairro varChar(40),
    Cidade varChar(30),
    Numeros_telefones text[] DEFAULT '{}'

) returns void as $$

    Declare
    v_telefone text;
    Begin

        IF estado_urgencia >10 or estado_urgencia < 1  then RAISE EXCEPTION 'Foi inserido um valor inválido no nível de Emergência.';
    end if;

    insert into Paciente values( cpf, Func_Cadastrante, Nome, estado_urgencia, Data_Nascimento, Rua, Bairro, Cidade);

        FOREACH v_telefone in Array Numeros_telefones LOOP
            
            select inserirTelefonePaciente(cpf,v_telefone);

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


create or replace function inserirTelefonePaciente(
    pacienteCPF char(11),
    Numero_telefone char(11)
) returns void as $$    
    
    Begin
        INSERT INTO Numero_telefone VALUES (pacienteCPF, Numero_telefone);

    end;
$$LANGUAGE 'plpgsql';

create or replace function inserirReceitaMedica(
    MatMedico char(5) ,
    CPFPaciente char(13) ,
    Descricao text ,
    Data_Realizacao date ,
    Data_Validade date,
    remediosReceitados text[] DEFAULT '{}'
) returns void as $$

    Declare
        ReceitaId Receita.id%type;
		 v_remedio TEXT;

    Begin
        INSERT INTO Receita  VALUES (default, MatMedico, CPFPaciente, Descricao, Data_Realizacao,Data_Validade) RETURNING id INTO ReceitaId;
 		 
		FOREACH v_remedio IN ARRAY remediosReceitados LOOP
        
			INSERT INTO REMEDIO_RECEITADO VALUES (ReceitaId, v_remedio);
        
		END LOOP;
    END;
$$LANGUAGE 'plpgsql';
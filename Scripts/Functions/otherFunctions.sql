-- Outras funções utilitárias

-- Função que atualiza o salário de um funcionário específico
create or replace function atualizarSalario(
  codigoFuncionario char(5),
  novoSalario numeric
) returns void as $$
begin
  update funcionario
  set salario = novosalario
  where matricula = codigofuncionario;
  if not found then
    raise notice 'Funcionário com código % não encontrado.', codigofuncionario;
  end if;
end;
$$ language plpgsql;

select * from funcionario;

-- Função que atualiza o salário de todos os funcionários a partir de um valor percentual
create or replace function atualizarTodosSalarios(percentual numeric) 
returns void as $$
begin
  update funcionario
  set salario = salario * (1 + percentual/100);
end;
$$ language 'plpgsql';

select * from funcionario;

-- Função que atualiza os salários a partir do cargo de ocupação, em valor percentual
create or replace function atualizarSalariosPorCargo(
	cargo varchar(15),
	percentual numeric
) returns void as $$
begin
	update funcionario
	set salario = salario * (1+ percentual/100)
	where funcao = cargo;
	if not found then
		raise notice 'Cargo (%) não encontrado', cargo;
	end if;
end;
$$ language 'plpgsql';

select * from funcionario;

-- Função complementar para novo piso salarial por cargo, em valores decimais
create or replace function atualizarSalariosPorCargo(
	novoPisoSalarial numeric,
	cargo varchar(15)
) returns void as $$
DECLARE
    salarioFuncionario NUMERIC;
    novo_salario NUMERIC;
begin
	SELECT salario INTO salarioFuncionario FROM Funcionario WHERE funcao = cargo;
	if novoPisoSalarial <= salarioFuncionario then
		raise exception 'Piso salarial menor ou igual ao salário anterior. Impossível atualizar.';
	end if;
	update funcionario
	set salario = novoPisoSalarial
	where funcao = cargo;
	if not found then
		raise notice 'Cargo (%) não encontrado.', cargo;
	end if;
end;
$$ language 'plpgsql';

select * from funcionario;

-- Função que retorna o relatório médico das consultas. <Sigilo médico>
create or replace function relatorioMedico()
returns table (
    nome_medico VARCHAR(50),
    matricula_medico CHAR(5),
    funcao VARCHAR(15),
    data_realizacao DATE,
    valor DECIMAL(10,2),
    nome_paciente VARCHAR(50),
    cpf_paciente CHAR(11),
    remedio VARCHAR(25)
)
as $$
declare
    cursor_medico cursor for
        select f.nome as nome_medico,
            m.matricula as matricula_medico,
            f.funcao,
            r.data_realizacao,
            e.preco_consulta as valor,
            p.nome as nome_paciente,
            r.cpfpaciente,
            rr.nome as remedio
        from receita r
            inner join medico m on m.matricula = r.matmedico
            inner join funcionario f on f.matricula = m.matricula
            inner join paciente p on p.cpf = r.cpfpaciente
            inner join remedio_receitado rr on rr.receitaid = r.id
            inner join especialidade e on e.id = m.espid;
begin
    open cursor_medico;
    LOOP
        FETCH cursor_medico INTO nome_medico, matricula_medico, funcao, data_realizacao, valor, nome_paciente, cpf_paciente, remedio;
        EXIT WHEN NOT FOUND;
        RETURN NEXT;
    END LOOP;
    CLOSE cursor_medico;
END;
$$ LANGUAGE plpgsql;
select * from relatorioMedico();
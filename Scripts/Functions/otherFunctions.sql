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
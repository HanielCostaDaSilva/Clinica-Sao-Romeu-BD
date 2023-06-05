-- Outras funções utilitárias

-- Função que atualiza o salário de um funcionário específico
create or replace function atualizarSalarioBase(
  idCargo cargo.id%type,
  aumentoSalarial cargo.salario_base%type
) returns void as $$
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
create or replace function atualizarTodosSalarios(percentual numeric) 
returns void as $$
begin
  update cargo
  set salario_base = salario_base * (1 + percentual/100)::numeric;
end;
$$ language 'plpgsql';

select * from cargo;
select * from funcionario;
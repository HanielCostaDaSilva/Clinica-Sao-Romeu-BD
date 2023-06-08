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
-- Procedures para a tabela Especialidade

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
-- Função que mostra dados estatísticos da clínica
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
	select  round(AVG(extract(year from age(Data_Nascimento))),2) INTO media_idade_pacientes FROM paciente;
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
-- Consultas de acordo com os requitos do modelo BDR propostos
/*
1- A clínica quer saber os pacientes mais graves, com estado de urgência maior ou igual a 4,
e com receituário nos últimos 3 meses. Sendo assim, faça uma consulta para estes casos. 
(Uso de operador básico de filtro)
*/
select p.nome as nome_paciente, pre.descricao, r.data_realizacao
from paciente p 
	inner join receita r
	on p.cpf = r.cpfpaciente
	inner join prescricao pre
	on pre.idReceita = r.id
where p.estado_urgencia >= 4 
	and r.data_realizacao >= current_date - interval '3 months';

/*
2- Obtenha o nome dos pacientes, nome dos médicos e descrição das especialidades para os pacientes
que possuem receitas prescritas por determinados médicos, juntamente com as descrições dos remédios,
no ano de 2023. (uso de INNER JOIN)
*/
select p.nome as nome_paciente, f.nome as nome_medico, 
		e.descricao as especialidade, r.nome as nome_remedio
from paciente p
		join receita rec on p.cpf = rec.cpfPaciente
		join medico m on rec.matMedico = m.matricula
		join funcionario f on f.matricula = m.matricula
		join especialidade e on m.espid = e.id
		join prescricao pres on rec.id = pres.idReceita
		join remedio r on pres.idRemedio = r.id
where abs(extract(year from (data_realizacao))) = 2023;

/*
3- Consulte os funcionários que possuem um salário abaixo dos 5000 reais, para que sejam bonificados
pela direção geral.
*/
select * from funcionario;
select
from funcionario f
	inner join medico m on f.matricula = m.matricula
	inner join cargo c on f.idcargo = c.id
where salario_base + percentual_bonus < 5000.00
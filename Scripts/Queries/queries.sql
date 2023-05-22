-- Consultas de acordo com os requitos do modelo BDR propostos
/*
1- A clínica quer saber os pacientes mais graves, com estado de urgência maior ou igual a 4,
e com receituário nos últimos 3 meses. Sendo assim, faça uma consulta para estes casos. 
(Uso de operador básico)
*/
select p.nome as nome_paciente, r.descricao, r.data_realizacao
from paciente p 
	inner join receita r
	on p.cpf = r.cpfpaciente
where p.estado_urgencia >= 4 
	and r.data_realizacao >= current_date - interval '3 months';

/*
2- Obtenha o nome dos pacientes, nome dos médicos e descrição das especialidades para os pacientes
que possuem receitas prescritas por determinados médicos, juntamente com as descrições dos remédios,
no ano de 2023. (uso de INNER JOIN)
*/
select p.nome as nome_paciente, f.nome as nome_medico, 
		e.descricao as especialidade, r.descricao as descricao_remedio
from paciente p
		join receita rec on p.cpf = rec.cpfPaciente
		join medico m on rec.matMedico = m.matricula
		join funcionario f on f.matricula = m.matricula
		join especialidade e on m.espid = e.id
		join prescricao pres on rec.id = pres.idReceita
		join remedio r on pres.idRemedio = r.id;
where 
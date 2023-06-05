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
where extract(year from data_realizacao) = 2023;

/*
3- Consulte os funcionários que possuem um salário abaixo dos 4000 reais, para que sejam bonificados
pela direção geral.
*/
select f.nome, c.salario_base, f.percentual_bonus
from funcionario f
	inner join cargo c on f.idcargo = c.id
where salario_base + percentual_bonus < 4000.00;

/*
4- A clínica está fazendo uma promoção especial para pacientes maiores de 60 anos. Ela quer saber quem
são os sortudos e também seus números de telefone. Por isso, faça uma consulta. (Uso de INNER JOIN)
*/
select p.Nome, p.Data_Nascimento, t.numero_telefone
from PACIENTE p
join Numero_Telefone_Paciente t on p.cpf = t.pacienteCPF
where p.Data_Nascimento <= (current_date - INTERVAL '60 years');

/*
5- Obtenha o nome dos pacientes, a data da prescrição e o nome do medicamento para todas as
prescrições registradas na clínica, incluindo os pacientes que não possuem prescrições.
Certifique-se de listar todos os medicamentos, mesmo que não estejam associados a uma prescrição.
(Uso de Left e Right Outer Join)
*/
select
    p.Nome as nome_paciente,
    rec.Data_Realizacao as data_prescricao,
    rem.nome as nome_medicamento
from
    PACIENTE p
    left join RECEITA rec on p.cpf = rec.CPFPaciente
    left join PRESCRICAO pres on rec.id = pres.idReceita
    right join REMEDIO rem on pres.idRemedio = rem.id;

/*
6- Obtenha o número de prescrições realizadas por cada médico na clínica,
listando o nome do médico e a contagem de prescrições. Apenas inclua os médicos
que tenham realizado 2 ou mais prescrições. (Uso de agrupamento)
*/
select f.nome as nome_medico, count(*) as total_prescricoes
from funcionario f
	join medico m on f.matricula = m.matricula
	join receita r ON m.matricula = r.matmedico
group by f.nome
having count(*) >= 2;

/*
7- Obtenha a média de salário por cargo na clínica, listando o nome do cargo
e a média salarial. Apenas inclua os cargos que tenham mais de duas pessoas.
*/
select c.funcao as cargo, round(avg(c.salario_base), 2) as media_salarial
from cargo c
	join funcionario f ON c.id = f.idcargo
group by c.funcao
having count(f.matricula) > 1;

/*
8- Liste os médicos que também são pacientes. (Uso de uma operação com conjuntos)
*/
select nome
from funcionario f
	join medico m on f.matricula = m.matricula
intersect
select p.nome
from paciente p;

/*
9-  Selecionar os médicos que possuem o maior número de pacientes atendidos, e suas
respectivas matrículas. (Uso de subqueries)
*/
select f.nome, m.matricula
from medico m
	join funcionario f on m.matricula = f.matricula
where (select count(*) from receita r where r.matmedico = m.matricula) = 
    (select max(num_pacientes) from
        (select count(*) AS num_pacientes from receita group by matmedico) as t);

/*
10- Consulte os remédios prescritos mais de uma vez, independente do médico
que receitou. (Uso de subquerie)
*/
select r.nome
from remedio r
where r.id in (
    select pr.idRemedio
    from prescricao pr
    group by pr.idRemedio
    having count(pr.idRemedio) > 1
);

/*Consultas que foram melhoradas*/
-- Consulta 3
select f.nome, c.salario_base, f.percentual_bonus
from funcionario f
left join cargo c ON f.idCargo = c.id
where c.salario_base + f.percentual_bonus < 4000.00;

/* Justificativa: a consulta foi reescrita para utilizar a junção LEFT JOIN e selecionar
todos os funcionários, inclusive quem não possui cargo ainda, e outros campos
relevantes. Dessa forma, quem não possui cargo deverá receber um cargo posteriormente. */

-- Consulta 4
select p.Nome, p.Data_Nascimento, t.numero_telefone
from PACIENTE p
left join Numero_Telefone_Paciente t on p.cpf = t.pacienteCPF
where p.Data_Nascimento <= current_date - INTERVAL '60 years';

/* Justificativa: a consulta foi reescrita com LEFT JOIN para incluir todos os pacientes,
mesmo aqueles que não possuem número de telefone cadastrado. Isso permite
obter pacientes e seus números de telefone, caso existam. */
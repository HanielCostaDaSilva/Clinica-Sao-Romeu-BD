/*View relacionada a demonstrar  quais os médicos da clínica e suas respectivas especialidades */

create or replace View catalogoMedico as
select f.matricula, m.crm, f.nome, e.descricao as "Especialidade"
from funcionario f inner join medico m on f.matricula = m.matricula 
inner join especialidade e on e.id = m.espid;

select * from Especialidade;

/*View que apressenta um catálogo a respeito das especialidades oferecidas e seus respectivos preços*/

create or replace View catalogoEspecialidade(descricao, preco) as
select descricao as "Especialidade",  to_char(preco_consulta, 'R$999,999,999.99')  as "consulta"
from especialidade;

select * from catalogoEspecialidade;

/*View que apressenta  as formas de contato para os pacientes; */
create or replace View ContatoPacientes as
select p.nome, ntp.numero_telefone as "numero" 
from paciente p inner join numero_telefone_paciente ntp on p.cpf = ntp.pacientecpf;

select * from ContatoPacientes;

/*View que apressenta a quantidade de pacientes que visitaram a clínica a partir de um endereço*/
create or replace View pacientePorEndereco as
select bairro, cidade, count(*) 
from paciente
group by  bairro,cidade;

select * from pacientePorEndereco;

/*View que apressenta a quantidade de consultas e o valor monetário arrecado para cada especialidade na clínica.*/
create or replace View arrecadacoPorEspecialidade as 
select e.descricao as "Especialidade",count(e.id) as "total_Consulta", to_char( Sum(e.preco_consulta), 'R$999,999,999.99') as "total_Arrecadado"
from receita r 
	inner join medico m on r.matmedico = m.matricula
	inner join especialidade e on m.espid = e.id
group by e.descricao;

select * from arrecadacoPorEspecialidade;

/*View que apresenta o relatório médico das consultas.*/
create or replace View relatorioMedico as
select f.nome as nome_medico,
		m.matricula as matricula_medico,
		f.funcao,
		r.data_realizacao,
		e.preco_consulta as valor,
		p.nome as nome_paciente,
		r.cpfpaciente,
		rr.nome as remedio
FROM receita r
	inner join medico m on m.Matricula = r.MatMedico
	inner join funcionario f on f.Matricula = m.Matricula
	inner join paciente p on p.CPF = r.CPFPaciente
	inner join remedio_receitado rr on rr.receitaId = r.id
	inner join especialidade e on e.id = m.espid;

select *  from relatorioMedico;
-- Índices para o base de dados da clínica São Romeu

/* Índice para os CPFs dos paciente nas receitas médicas */
create index idx_cpfPaciente
on receita (cpfPaciente);
-- Justificativa: acessar os dados de determinado paciente mais rapidamente dentro da tabela RECEITA

/* Índice para otimizar as pesquisas via data de realização
da consulta médica */
create index idx_consultas_realizadas
on receita (data_realizacao);
-- Justificativa: agrupar o acesso às receitas de acordo com a data de realização das mesmas

/* Índice no estado de emergência do paciente */
create index idx_estado_paciente
on paciente (estado_urgencia);
-- Justificativa: de acordo com os estado de urgência, é possível saber quais são os pacientes que
-- precisem de mais atenção (os mais graves). Por isso, acessar mais rapidamente esta condição
-- é de extrema importância para o contexto da clínica.
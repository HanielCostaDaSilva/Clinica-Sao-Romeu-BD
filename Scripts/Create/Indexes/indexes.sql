-- Índices para o base de dados da clínica São Romeu

/* Índice para os CPFs dos paciente nas receitas médicas */
create index idx_cpfPaciente
on receita (cpfPaciente);

/* Índice para otimizar as pesquisas via data de realização
da consulta médica */
create index idx_consultas_realizadas
on receita (data_realizacao);
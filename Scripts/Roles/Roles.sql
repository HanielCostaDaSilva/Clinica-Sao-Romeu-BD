-- Criar Roles
CREATE ROLE med LOGIN
	PASSWORD 'med123' nosuperuser;
CREATE ROLE aten LOGIN
	PASSWORD 'aten123' nosuperuser;
CREATE ROLE adm LOGIN
	PASSWORD 'adm123' superuser;

-- Conceder Rules do que pode ser feito na Base de Dados
-- Diretor geral
GRANT ALL ON ALL tables TO adm;

-- Atendentes
GRANT select, insert, update(valor) ON Paciente TO aten;
GRANT select, insert, update(valor) ON Numero_Telefone_Paciente TO aten;
GRANT select ON Especialidade TO aten;
GRANT select ON Medico TO aten;

-- Médicos
GRANT select, insert, update(valor) ON Paciente TO med;
GRANT select, insert, update(valor) ON Receita TO med;
GRANT select, insert, update(valor) ON Remedio_receitado TO med;
GRANT select ON Especialidade TO med;
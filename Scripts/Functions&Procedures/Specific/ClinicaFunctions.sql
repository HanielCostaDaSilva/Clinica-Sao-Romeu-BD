-- Função que mostra dados estatísticos
CREATE OR REPLACE FUNCTION dadosEstatisticosClinica() RETURNS VOID AS
$$
BEGIN
	SELECT COUNT(cpf) FROM paciente	GROUPY BY cidade;
	SELECT MIN(data_nascimento) FROM paciente;
	SELECT MAX(data_nascimento) FROM paciente;
END;
$$
LANGUAGE 'plpgsql';

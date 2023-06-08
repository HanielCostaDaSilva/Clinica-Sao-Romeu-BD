-- Função que mostra dados estatísticos
CREATE OR REPLACE FUNCTION dadosEstatisticosClinica() RETURNS TABLE (
	totalPacientes		INT,
	totalMedicos		INT,
	mediaBonusSal		NUMERIC(10,2),
	pacienteMaisNovo	VARCHAR(50),
	pacienteMaisVelho	VARCHAR(50)
	) 
AS
$$
BEGIN
	SELECT COUNT(*) INTO totalPacientes FROM paciente;
	SELECT COUNT(*) INTO totalMedicos FROM medico;
	SELECT AVG(percentual_bonus) INTO mediaBonusSalario FROM funcionario;
	SELECT nome INTO pacienteMaisNovo FROM paciente ORDER BY Data_Nascimento DESC LIMIT 1;
	SELECT nome INTO pacienteMaisVelho FROM paciente ORDER BY Data_Nascimento LIMIT 1;
	RETURN;
END;
$$
LANGUAGE 'plpgsql';

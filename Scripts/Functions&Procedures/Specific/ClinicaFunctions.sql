-- Função que mostra dados estatísticos da Clínica
CREATE OR REPLACE FUNCTION dadosEstatisticosClinica() RETURNS TABLE (
	totalPacientes		INT,
	totalMedicos		INT,
	mediaSalarioBase		NUMERIC(10,2),
	pacienteMaisNovo	VARCHAR(50),
	pacienteMaisVelho	VARCHAR(50)
	) 
AS
$$
BEGIN
	SELECT COUNT(*) INTO totalPacientes FROM paciente;
	SELECT COUNT(*) INTO totalMedicos FROM medico;
	SELECT AVG(salario_base) INTO mediaSalarioBase FROM funcionario;
	SELECT nome INTO pacienteMaisNovo FROM paciente ORDER BY Data_Nascimento DESC LIMIT 1;
	SELECT nome INTO pacienteMaisVelho FROM paciente ORDER BY Data_Nascimento LIMIT 1;
	RETURN;
END;
$$
LANGUAGE 'plpgsql';

select dadosEstatisticosClinica();
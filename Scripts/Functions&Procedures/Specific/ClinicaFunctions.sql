-- Função que mostra dados estatísticos da Clínica
CREATE OR REPLACE FUNCTION dadosEstatisticosClinica() RETURNS TABLE (
	totalPacientes		INT,
	totalMedicos		INT,
	pacienteMaisNovo	VARCHAR(50),
	pacienteMaisVelho	VARCHAR(50)
	) 
AS
$$
BEGIN
	SELECT COUNT(*) INTO totalPacientes FROM paciente;
	SELECT COUNT(*) INTO totalMedicos FROM medico;
	SELECT nome INTO pacienteMaisNovo FROM paciente ORDER BY Data_Nascimento DESC LIMIT 1;
	SELECT nome INTO pacienteMaisVelho FROM paciente ORDER BY Data_Nascimento LIMIT 1;
	RETURN NEXT;
END;
$$
LANGUAGE 'plpgsql';

SELECT dadosEstatisticosClinica();

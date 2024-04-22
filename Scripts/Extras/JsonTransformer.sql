SELECT p.*, array_agg(n.numero_telefone) AS telefones,
json_agg(array_agg(json_build_object('id', r.id, 'data_realizacao', r.data_realizacao, 'data_validade', r.data_validade))) AS receitas
FROM paciente p
LEFT JOIN numero_telefone_paciente n ON n.pacientecpf = p.cpf
LEFT JOIN receita r ON p.cpf = r.cpfpaciente
GROUP BY p.cpf;


select p.* , array_agg(t.numero_telefone) AS telefones 
from paciente p right join numero_telefone_paciente n on n.pacientecpf = p.cpf;


SELECT p.*, json_agg(json_build_object('id', r.id, 'data_realizacao', r.data_realizacao, 'data_validade', r.data_validade)) AS receitas
FROM paciente p
LEFT JOIN receita r ON p.cpf = r.cpfpaciente
GROUP BY p.cpf;


SELECT r.*, json_agg(json_build_object('nome_remedio', re.nome, 'descricao', pre.descricao)) AS dados_remedio
FROM receita r
LEFT JOIN prescricao pre ON pre.idreceita = r.id
LEFT JOIN remedio re ON re.id = pre.idremedio
GROUP BY r.id;



SELECT p.*, array_agg(n.numero_telefone) AS telefones, json_agg(json_build_object('id', r.id, 'dataRealizacao', r.data_realizacao, 'dataValidade', r.data_validade, 'remedios', json_build_object('nome', re.nome, 'descricaoUso', pre.descricao))) AS receitas FROM paciente p LEFT JOIN numero_telefone_paciente n ON n.pacientecpf = p.cpf
LEFT JOIN receita r ON p.cpf = r.cpfpaciente
LEFT JOIN prescricao pre ON pre.idreceita = r.id
LEFT JOIN remedio re ON re.id = pre.idremedio
GROUP BY p.cpf;
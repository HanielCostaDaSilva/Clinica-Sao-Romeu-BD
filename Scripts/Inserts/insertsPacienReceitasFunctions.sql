/*Pacientes*/
select inserirPaciente('82691696191', 'JOMTE', 'Allan Alves Amancio', 1, '04-11-2004', 'Rua Chá de Camomila', 'Centro', 'São Miguel de Taipu', ARRAY['83982292523', '83986751649']);
select inserirPaciente('81763444962', 'MARAS', 'João Silva', 2, '1990-05-15', 'Rua 2 de Novembro', 'Centro', 'São Miguel de Taipu', ARRAY['83912345678', '83987654321']);
select inserirPaciente('30729081210', 'JOMTE', 'Maria Souza', 1, '1985-09-20', 'Rua Laranja', 'Café do Vento', 'Sobrado', ARRAY['83911111111', '83922222222']);
select inserirPaciente('17583999459', 'MARAS', 'Pedro Santos', 3, '2000-03-10', 'Rua Batista', 'Centro', 'São Miguel de Taipu', ARRAY['83933333333']);
select inserirPaciente('61814352624', 'JOMTE', 'Ana Oliveira', 1, '1995-07-02', 'Avenida São Jorge', 'Centro', 'São Miguel de Taipu', ARRAY['83944444444']);
select inserirPaciente('98521676000', 'MARAS', 'Lucas Rodrigues', 2, '1980-12-30', 'Avenida Josemar', 'Amarelas', 'Pilar', ARRAY['83955555555']);
select inserirPaciente('82691692345', 'JOMTE', 'Pedro Alves', 3, '1998-12-10', 'Rua dos Bobos, 0', 'Jardim Amália', 'Itabaiana', ARRAY['83912345678', '83998765432']);
select inserirPaciente('73536904461', 'JOMTE', 'Bruna Bastos', 4, '2000-02-20', 'Rua das Flores, 10', 'Centro', 'São Miguel de Taipu', ARRAY['83911112222']);
select inserirPaciente('24874727359', 'JOMTE', 'Carlos Cunha', 1, '1985-05-05', 'Av. Paulista, 1000', 'Bela Vista', 'Pilar', ARRAY['83933334444', '83955556666']);
select inserirPaciente('00593248718', 'JOMTE', 'Daniela Duarte', 2, '1972-10-22', 'Rua do Comércio, 500', 'Centro', 'São Miguel de Taipu', ARRAY['83977778888']);
select * from PACIENTE;
select * from Numero_Telefone_Paciente;

/*Receitas Médicas*/
select inserirReceitaMedica('RUMCA', '82691696191', 'Óculos com lente de grau', '2023-04-30', '2023-05-30', '{"Lentes para miopia"}');
select inserirReceitaMedica('WILTN', '81763444962', 'Óculos de proteção', '2023-04-30', '2023-05-30', '{"Proteção contra luz azul"}');
select inserirReceitaMedica('AMFRO', '30729081210', 'Xarope para tosse', '2023-04-30', '2023-05-30', '{"Dextrometorfano", "Guaifenesina"}');
select inserirReceitaMedica('FEJSA', '17583999459', 'Antibiótico para sinusite', '2023-04-30', '2023-05-30', '{"Amoxicilina", "Clavulanato de potássio"}');
select inserirReceitaMedica('RUMCA', '61814352624', 'Óculos de grau', '2023-04-30', '2023-05-30', '{"Lentes para astigmatismo"}');
select inserirReceitaMedica('METIA', '98521676000', 'Vacina contra sarampo', '2023-04-30', '2023-05-30', '{"Tríplice viral"}');
select inserirReceitaMedica('LOSJF', '82691692345', 'Vacina contra rubéola', '2023-04-30', '2023-05-30', '{"Tríplice viral"}');
select inserirReceitaMedica('AMFRO', '73536904461', 'Medicação para alergia', '2023-05-01', '2023-06-01', '{"Clorfeniramina"}');
select inserirReceitaMedica('FEJSA', '24874727359', 'Tratamento para labirintite', '2023-04-30', '2023-05-15', '{"Dramin", "Betahistina"}');
select inserirReceitaMedica('METIA', '00593248718', 'Anticoncepcional oral', '2023-04-30', '2024-04-30', '{"Diane 35"}');
select * from receita;
select * from remedio_receitado;
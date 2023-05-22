-- Testes com as functions criadas
-- Especialidades
select inserirEspecialidade('Oftalmologia',90.00);
select inserirEspecialidade('Pediatria',120.00);
select inserirEspecialidade('Otorrinolaringologia',150.00);
select * from especialidade;

-- Cargos
select inserirCargo('Diretor', 8000.00);
select inserirCargo('Pediatra', 5500.00);
select inserirCargo('Atendente', 2500.00);
select inserirCargo('Zelador', 2100.00);
select inserirCargo('Motorista', 1600.00);
select inserirCargo('Enfermeiro', 4750.00);
select inserirCargo('Otorrino', 5000.00);
select inserirCargo('Oftalmologo', 5400.00);

select * from cargo;

/*Supervisores*/
select inserirFuncionario('JULME','12345678901','Julieta Capuleto','Diretora',5359.32,'03-01-1983', '12-05-2020');
select inserirFuncionario('MARAS','39834594958','Maria Claudia','Atendimento',2492.42,'02-10-2000', '01-04-2019','JULME');
select inserirFuncionario('METIA','22345078901','Melissa Gracias','Pediatra',5590.22, '07-11-1990', '1-12-2021','JULME','123456',2);
select * from FUNCIONARIO;

/*Funcionários Normais*/
select inserirFuncionario('JOMTE','56734594949','Joaquim Fagundes','Atendimento',2092.32,'09-01-1999', '01-05-2020','MARAS');
select inserirFuncionario('QUEMT','50754594993','Quirino Gracias','Zeladoria',1609.93,'05-11-1989', '23-09-2020','MARAS');
select inserirFuncionario('IRTMA','12754594938','Iracema Gracias','Zeladoria',1609.93,'03-01-1990', '12-05-2020','MARAS');
select inserirFuncionario('JOIEC','45958958459','Joana Maria','Motorista',1390.12,'07-11-2000', '1-12-2021');
select inserirFuncionario('ATUFO','91889438403','Atélio Marcos','Enfermaria',2390.12,'02-11-1999', '1-03-2021','MARAS');
select inserirFuncionario('KJDFD','37837530942','Joana Maria','Enfermaria',2390.12,'02-11-1999', '1-03-2021','MARAS');
select * from FUNCIONARIO;

/*Médicos*/
select inserirFuncionario('AMFRO','94I85948593','Amós Luís','Pediatra ',5000.22, '07-12-2000', '1-12-2021','METIA','128084',2);
select inserirFuncionario('RUMCA','44355566472','Rubens Magno','Oftalmologo',5390.22, '02-10-1983', '1-12-2019','METIA','125756',1);
select inserirFuncionario('WILTN','45563565367','Wilter Venenoso','Oftalmologo',5390.22, '02-09-1983', '1-09-2019','METIA','128089',1);
select inserirFuncionario('FEJSA','13424462564','Felipe Jorge','Otorrino',4999.22, '02-10-1980', '1-12-2020','METIA','549854',3);
select inserirFuncionario('LOSJF','13424562564','Lorena Cerrana','Otorrino',4999.22, '01-12-1989', '1-11-2020','METIA','129454',3);
select * from MEDICO;
select * from FUNCIONARIO;

/*Pacientes*/
select inserirPaciente('82691696191', 'JOMTE', 'Allan Alves Amancio', 1, '04-11-2004', 'Rua Chá de Camomila', 'Centro', 'São Miguel de Taipu', ARRAY['83982292523', '83986751649']);
select inserirPaciente('81763444962', 'MARAS', 'João Silva', 2, '1990-05-15', 'Rua 2 de Novembro', 'Centro', 'São Miguel de Taipu', ARRAY['83912345678', '83987654321']);
select inserirPaciente('30729081210', 'JOMTE', 'Maria Souza', 1, '1985-09-20', 'Rua Laranja', 'Café do Vento', 'Sobrado', ARRAY['83911111111', '83922222222']);
select inserirPaciente('17583999459', 'MARAS', 'Pedro Santos', 3, '2000-03-10', 'Rua Batista', 'Centro', 'São Miguel de Taipu', ARRAY['83933333333']);
select inserirPaciente('61814352624', 'JOMTE', 'Ana Oliveira', 1, '1995-07-02', 'Avenida São Jorge', 'Centro', 'São Miguel de Taipu', ARRAY['83944444444']);
select inserirPaciente('98521676000', 'MARAS', 'Lucas Rodrigues', 2, '1980-12-30', 'Avenida Josemar', 'Amarelas', 'Pilar', ARRAY['83955555555']);
select inserirPaciente('82691692345', 'JOMTE', 'Pedro Alves', 3, '1998-12-10', 'Rua dos Bobos', 'Jardim Amália', 'Itabaiana', ARRAY['83912345678', '83998765432']);
select inserirPaciente('73536904461', 'JOMTE', 'Bruna Bastos', 4, '2000-02-20', 'Rua das Flores', 'Centro', 'São Miguel de Taipu', ARRAY['83911112222']);
select inserirPaciente('24874727359', 'JOMTE', 'Carlos Cunha', 1, '1985-05-05', 'Av. Paulista', 'Bela Vista', 'Pilar', ARRAY['83933334444', '83955556666']);
select inserirPaciente('00593248718', 'JOMTE', 'Daniela Duarte', 2, '1972-10-22', 'Rua do Comércio', 'Centro', 'São Miguel de Taipu', ARRAY['83977778888']);
select * from PACIENTE;
select * from Numero_Telefone_Paciente;

/*Receitas Médicas*/
select inserirReceitaMedica('RUMCA', '82691696191', 'Dificuldades para enxergar de perto e dores de cabeça.', '2023-04-30', '2023-05-30', '{"Dipirona","Lentes para miopia","lacribel"}');
select inserirReceitaMedica('WILTN', '81763444962', 'Dores de cabeça ao se expor a luz solar', '2023-04-30', '2023-05-30', '{"Proteção contra luz azul"}');
select inserirReceitaMedica('AMFRO', '30729081210', 'Dores no peito, dificuldade para respirar.', '2023-04-30', '2023-05-30', '{"Dextrometorfano", "Guaifenesina"}');
select inserirReceitaMedica('FEJSA', '17583999459', 'Dificuldade para respirar.', '2023-04-30', '2023-05-30', '{"Amoxicilina", "Clavulanato de potássio"}');
select inserirReceitaMedica('RUMCA', '61814352624', 'Dificuldades para enxergar ', '2023-04-30', '2023-05-30', '{"Lentes para astigmatismo"}');
select inserirReceitaMedica('METIA', '98521676000', 'Vacina contra sarampo', '2023-04-30', '2023-05-30', '{"Tríplice viral"}');
select inserirReceitaMedica('LOSJF', '82691692345', 'Vacina contra rubéola', '2023-04-30', '2023-05-30', '{"Tríplice viral"}');
select inserirReceitaMedica('AMFRO', '73536904461', 'Medicação para alergia', '2023-05-01', '2023-06-01', '{"Clorfeniramina"}');
select inserirReceitaMedica('FEJSA', '24874727359', 'Tratamento para labirintite', '2023-04-30', '2023-05-15', '{"Dramin", "Betahistina"}');
select inserirReceitaMedica('METIA', '00593248718', 'Anticoncepcional oral', '2023-04-30', '2024-04-30', '{"Diane 35","Dipirona" }');

select * from receita;
select * from remedio;

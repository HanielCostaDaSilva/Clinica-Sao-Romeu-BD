-- Testes com as functions criadas
select inserirEspecialidade('Oftamologia',90.04);
select inserirEspecialidade('Pediatria',120.05);
select inserirEspecialidade('otorrinolaringologia ',150.05);

select * from especialidade;

/*Supervisores*/
select inserirFuncionario('JULME','12345678901','Julieta Capuleto','Diretora',5359.32,'03-01-1983', '12-05-2020');
select inserirFuncionario('MARAS','39834594958','Maria Claudia','Atendimento',2492.42,'02-10-2000', '01-04-2019','JULME');
select inserirFuncionario('METIA','22345078901','Melissa Gracias','Pediatra',5590.22, '07-11-1990', '1-12-2021','JULME','123456',2);
select * from FUNCIONARIO;

/*Funcionários Normais*/
select inserirFuncionario('JOMTE','56734594949','jOAQUIM FAGUNDES','Atendimento',2092.32,'09-01-1999', '01-05-2020','MARAS');
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
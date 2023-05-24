-- Tabelas da Base de Dados da Clínica
CREATE TABLE PACIENTE (
    cpf char(11) NOT NULL PRIMARY KEY,
    Func_Cadastrante char(5) Not Null, 
    Nome varChar(50) Not Null, 
    estado_urgencia int Not Null,
    Data_Nascimento  DATE Not Null,
    Rua  varChar(50) Not Null, 
    Bairro varChar(40) Not Null, 
    Cidade varChar(30) Not Null 
);

CREATE TABLE Numero_Telefone_Paciente(
    pacienteCPF char(11) NOT NULL,
    Numero_telefone char(11) Not Null,
    PRIMARY KEY (pacienteCPF, Numero_telefone)
);


CREATE TABLE FUNCIONARIO (
    matricula char(5) NOT NULL PRIMARY KEY,
    CPF char(11) NOT NULL UNIQUE,
    Supervisor char(5),
    Nome varchar(50) NOT NULL,
    Data_nascimento date NOT NULL,
    Data_admissao date NOT NULL,
    idCargo int NOT NULL,
    percentual_bonus int NOT NULL
);


CREATE TABLE CARGO (
	id serial PRIMARY KEY Not Null,
	funcao varchar(45) UNIQUE Not Null,
	salario_base decimal(10,2) Not null
);

CREATE TABLE ESPECIALIDADE (
    id Serial  PRIMARY KEY   Not Null ,
    descricao Varchar(45) UNIQUE Not Null,
    preco_consulta Decimal(10,2) Not Null
);

CREATE TABLE MEDICO (
    Matricula char(5) PRIMARY KEY Not Null,
    crm char(6) UNIQUE Not Null,
    EspId int Not Null
);

CREATE TABLE RECEITA(
    id Serial  PRIMARY KEY  Not NUll ,
    MatMedico char(5) Not Null,
    CPFPaciente char(13) Not Null,
    Descricao text Not Null,
    Data_Realizacao date Not NUll,
    Data_Validade date Not Null
);

CREATE TABLE REMEDIO(
    id serial Not Null PRIMARY KEY,
    descricao text UNIQUE Not Null 
);

CREATE TABLE PRESCRICAO (
    idReceita int,
    idRemedio int,
    PRIMARY KEY (idReceita, idRemedio)
);

ALTER TABLE PACIENTE ADD CONSTRAINT Func_Cadastrante_FK
    FOREIGN KEY (Func_Cadastrante)
    REFERENCES FUNCIONARIO (matricula)
    ON DELETE CASCADE;

ALTER TABLE Numero_Telefone_Paciente ADD CONSTRAINT FK_Numero_telefone_2
    FOREIGN KEY (pacienteCPF)
    REFERENCES PACIENTE (cpf);
 
ALTER TABLE FUNCIONARIO ADD CONSTRAINT Cargo_FK
	FOREIGN KEY (idCargo)
	REFERENCES CARGO (id);
	
ALTER TABLE FUNCIONARIO ADD CONSTRAINT Supervisor_FK
    FOREIGN KEY (Supervisor)
    REFERENCES FUNCIONARIO (matricula);
 
ALTER TABLE MEDICO ADD CONSTRAINT Matricula_FK
    FOREIGN KEY (Matricula)
    REFERENCES FUNCIONARIO (matricula)
    ON DELETE CASCADE;
 
ALTER TABLE MEDICO ADD CONSTRAINT EspId_FK
    FOREIGN KEY (EspId)
    REFERENCES ESPECIALIDADE (id)
    ON DELETE CASCADE;

ALTER TABLE RECEITA ADD CONSTRAINT MatMedico_FK
    FOREIGN KEY (MatMedico)
    REFERENCES MEDICO (Matricula);

ALTER TABLE RECEITA ADD CONSTRAINT CPFPacient_Fk
    FOREIGN KEY (CPFPaciente)
    REFERENCES PACIENTE (cpf);

ALTER TABLE PRESCRICAO ADD CONSTRAINT FK_PRESCRICAO1
    FOREIGN KEY (idRemedio)
    REFERENCES REMEDIO (id);



ALTER TABLE PRESCRICAO ADD CONSTRAINT FK_PRESCRICAO2 FOREIGN KEY (idReceita) REFERENCES RECEITA (id);

ALTER TABLE PACIENTE ADD CONSTRAINT checkEstadoUrgencia  check (estado_urgencia < 6 and estado_urgencia > 0 );

ALTER TABLE FUNCIONARIO ADD CONSTRAINT checkData_admissao check (Data_admissao <= current_date);

ALTER TABLE CARGO ADD CONSTRAINT checkSalarioBase check (salario_base > 0.0);

ALTER TABLE ESPECIALIDADE ADD CONSTRAINT checkPreco_consulta check (preco_consulta >= 0.0);

ALTER TABLE RECEITA ADD CONSTRAINT checkData_Realizacao check (Data_Realizacao <= current_date);
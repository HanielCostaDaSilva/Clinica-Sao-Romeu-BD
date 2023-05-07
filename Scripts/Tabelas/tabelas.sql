-- Tabelas do Base de Dados da Clínica
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

CREATE TABLE FUNCIONARIO (
    matricula char(5) Not Null PRIMARY KEY,
    CPF char(11) Not Null UNIQUE,
    Nome varChar(50) Not Null,
    funcao varChar(15) Not Null,
    salario Decimal(10,2) Not Null,   
    Supervisor char(5),
    Data_nascimento date Not Null,
    Data_admissao date Not Null
);

CREATE TABLE MEDICO (
    Matricula char(5) PRIMARY KEY Not Null,
    crm char(6) UNIQUE Not Null,
    EspId int Not Null
);

CREATE TABLE REMEDIO_RECEITADO (
    receitaId int Not Null,
	nome varChar(25) Not Null
);

CREATE TABLE ESPECIALIDADE (
    id Serial  PRIMARY KEY   Not Null ,
    descricao Varchar(45) UNIQUE Not Null,
    preco_consulta Decimal(10,2) Not Null
);

CREATE TABLE RECEITA(
    id Serial  PRIMARY KEY  Not NUll ,
    MatMedico char(5) Not Null,
    CPFPaciente char(13) Not Null,
    Descricao text Not Null,
    Data_Realizacao date Not NUll,
    Data_Validade date Not Null
);

CREATE TABLE Numero_Telefone_Paciente(
    pacienteCPF char(11) NOT NULL,
    Numero_telefone char(11) Not Null,
    PRIMARY KEY (pacienteCPF, Numero_telefone)
);
 
ALTER TABLE PACIENTE ADD CONSTRAINT Func_Cadastrante_FK
    FOREIGN KEY (Func_Cadastrante)
    REFERENCES FUNCIONARIO (matricula)
    ON DELETE CASCADE;
 
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

ALTER TABLE REMEDIO_RECEITADO ADD CONSTRAINT receita_FK
    FOREIGN KEY (receitaId)
    REFERENCES RECEITA (id)
    ON DELETE CASCADE;
 
ALTER TABLE RECEITA ADD CONSTRAINT FK_RECEITA_3
    FOREIGN KEY (CPFPaciente)
    REFERENCES PACIENTE (cpf);
 
ALTER TABLE Numero_Telefone_Paciente ADD CONSTRAINT FK_Numero_telefone_2
    FOREIGN KEY (pacienteCPF)
    REFERENCES PACIENTE (cpf);
/*!!! You need active all triggers!!!*/
-- Testes com Views que permitem inserção

insert into catalogoespecialidade values('Ortopedista','R$ 159.34');
insert into catalogoespecialidade values('Demartologia','R$ 302.40');
select * from catalogoespecialidade;

insert into funcionariosEncarregados values('PAMER','56890312909','Paulo Costa','05-12-1970',null,'Zelador');
insert into funcionariosEncarregados values('JOAOE','56861267832','João Gomes','05-12-1980',null,'Atendente');
select * from funcionariosEncarregados;
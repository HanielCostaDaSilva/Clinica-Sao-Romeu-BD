/*Trigger Cargo*/

insert into cargo values(default,'Matador',3000.00);

update cargo
   set salario_base=4000.00
 where cargo.funcao = 'matador';

update cargo
   set salario_base=2000.00
 where cargo.funcao = 'matador';


/*Trigger funcionario*/
update Funcionario
   set supervisor=Null
 where matricula ='ATUFO';
select * from funcionario;

 update Funcionario
   set supervisor='MARAS'
 where matricula ='ATUFO';

 select * from funcionario;

 insert into Funcionario values('ROQEU','38754874570','Robinhos Graus','JOIEC','10/02/2004',current_date,4 0.0);
 select * from funcionario;
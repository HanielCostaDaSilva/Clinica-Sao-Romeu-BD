/*Trigger Cargo*/

insert into cargo values(default,'Matador',3000.00);

update cargo
   set salario_base=4000.00
 where cargo.funcao = 'matador';

update cargo
   set salario_base=2000.00
 where cargo.funcao = 'matador';

 
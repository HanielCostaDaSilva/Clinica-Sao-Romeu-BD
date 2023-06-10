/*Trigger Cargo*/

insert into cargo values(default,'Matador',3000.00);

update cargo
   set salario_base=4000.00
 where cargo.funcao = 'matador';

update cargo
   set salario_base=2000.00
 where cargo.funcao = 'matador';


/*Trigger funcionario*/
-- truncate table funcionario cascade;
-- Updates singulares -- não pode perder o bonus só porque um deixou de ser subordinado
  update Funcionario
    set supervisor=Null
  where matricula ='ATUFO';
  select * from funcionario;

  update Funcionario
    set supervisor='MARAS'
  where matricula ='ATUFO';
 select * from funcionario;
 
-- Operação insert
insert into Funcionario values('ROQEU','38754874570','Robinhos Graus','JOIEC','10/02/2004',current_date,4, 0.0);

-- Deletação de subordinado
delete from funcionario where matricula = 'ROQEU';
 
 select * from funcionario;
 
-- Operação de Update
-- 1- Todos de uma vez;
update funcionario
set supervisor = null
where supervisor = 'MARAS';

-- 2- Ou um por um
update funcionario
set supervisor = null
where matricula = 'ATUFO';

update funcionario
set supervisor = null
where matricula = 'KJDFD';

update funcionario
set supervisor = null
where matricula = 'IRTMA';

update funcionario
set supervisor = null
where matricula = 'JOMTE';

update funcionario
set supervisor = null
where matricula = 'QUEMT';

-- No final, o supervisor perde o percentual_bonus
select * from funcionario;
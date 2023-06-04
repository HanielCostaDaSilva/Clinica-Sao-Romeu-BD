/*Este trigger deverá garantir que um supervisor receba um bônus de 15% no seu salario, e verificar caso ele tenha sido excluído da lista de supervisores.  Se isso acontecer, ele perderá o bônus 15%*/
create or replace function checarAumentoBonus() returns trigger as $$
declare
    bonusSupervisor integer =15;
    supervisores text[];
begin
    select array_agg(distinct supervisor) into supervisores from funcionario where supervisor is not null;

    --Checa se é um Update funcionário que está sendo adicionado
    if TG_OP ='UPDATE' then

    -- houve alteração no supervisor.
        if new.supervisor <> old.supervisor then 

            -- Houve apenas  a troca entre supervisores 
            if new.supervisor <> all(supervisores) then
                update Funcionario
                    SET percentual_bonus = percentual_bonus + bonusSupervisor
                    WHERE matricula = new.supervisor;
        
            end if;
            --No final, o antigo supervisor perderá o bônus
            update Funcionario
                set percentual_bonus= greatest(percentual_bonus - bonusSupervisor, 0)
                where matricula= old.supervisor;
        end if;
    -- Caso seja um novo funcionário 
    elsif TG_OP='INSERT' then 
        --checamos se é um novo supervisor, caso seja, aplicamos o bonus.
        if new.supervisor <> all(supervisores) then
            update Funcionario
                SET percentual_bonus = percentual_bonus + bonusSupervisor
                WHERE matricula = new.supervisor;
				
	    end if;
	end if;
    return new;
end;
$$ language 'plpgsql';


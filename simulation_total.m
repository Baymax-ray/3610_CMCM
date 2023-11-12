function total=simulation_total(num_county,traffic_matrix,...
    food_condition,tree_trap_effectiveness,inspection_effectiveness,...
    Sen,San,F,policy,years,population)
    for y = 1:years
        eggs_with_traffic=zeros(num_county,1);
        % eggs and traffic
        for i = 1:num_county
            old_population=population(i,:,y);
            eggs=old_population(end)*F;
            population(i,1,y+1)=eggs;
            local_eggs=eggs*traffic_matrix(i,i);
            if policy(i,2,y)==0 %tree trap reduce local eggs
                eggs_with_traffic(i)=eggs_with_traffic(i)+local_eggs;
            else
                eggs_with_traffic(i)=eggs_with_traffic(i)+local_eggs*(1-tree_trap_effectiveness*policy(i,2,y));
            end
            for j = 1:num_county
                if i~=j && policy(i,1,y)~=0 %inspection reduce eggs transfered to other county
                    eggs_with_traffic(j)=eggs_with_traffic(j)+eggs*traffic_matrix(i,j);
                else
                    eggs_with_traffic(j)=eggs_with_traffic(j)+eggs*traffic_matrix(i,j)*(1-inspection_effectiveness*policy(i,1,y));
                end
            end
        end
        % Nymphs and adults
        for i =1:num_county
            nymphs=eggs_with_traffic(i)*Sen;
            population(i,2,y+1)=nymphs;
            adults=nymphs*San*food_condition(i);
            population(i,3,y+1)=adults;
        end
    end
    total=sum(population(:,3,end));
end

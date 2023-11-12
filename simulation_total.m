function population=simulation_total(num_county,traffic_matrix,...
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
            eggs_with_traffic(i)=eggs_with_traffic(i)+local_eggs;
            for j = 1:num_county
                if i~=j %inspection reduce eggs transfered to other county
                    eggs_with_traffic(j)=eggs_with_traffic(j)+eggs*traffic_matrix(i,j)*(1-inspection_effectiveness*policy(i,1,y));
                end
            end
        end
       % Nymphs and adults
        for i =1:num_county
            nymphs=eggs_with_traffic(i)*Sen;
            population(i,2,y+1)=nymphs;
            %tree trap reduce local adults and remove the effect of TOH as food
            adults=nymphs*San*(1-tree_trap_effectiveness*policy(i,2,y))*((1-food_condition(i))*policy(i,2,y)+food_condition(i));
            population(i,3,y+1)=adults;
        end
    end
    
end

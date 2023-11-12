%% parameters
%parameter
[num_county, years, initial_population, traffic_matrix, food_condition, tree_trap_effectiveness, inspection_effectiveness, Sen, San, F] = initialize_parameters();
%initial population of each county, 1st column is eggs, 2nd is Nymphs and 3rd is Adults


% policy matrix
% 2 policy and 5 years
% one row is one county and one page is one year; first is inspection, second is tree trap; 0 means no action
policy=zeros(num_county,2,years); %total cost in each year should be less than total_reource_per_year
policy=opt_policy;
% population matrix
% one row is one county and one page is one year
population=zeros(num_county, 3 ,years+1);
population(:,:,1)=initial_population;

final_population=simulation(num_county,traffic_matrix,...
    food_condition,tree_trap_effectiveness,inspection_effectiveness,...
    Sen,San,F,policy,years,population);

valid=check_valid(policy,total_reource_per_year,C_inspection,C_tree_trap);

function population=simulation(num_county,traffic_matrix,...
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

function valid=check_valid(policy,total_reource_per_year,C_inspection,C_tree_trap)
    valid=1;
    for y = 1:size(policy,3)
        if sum(policy(:,1,y))*C_inspection+sum(policy(:,2,y))*C_tree_trap>total_reource_per_year
            valid=0;
            return
        end
    end
end

%% parameters
%暂时先设成这样，麻烦你们填入真实的数据
num_county=15;
initial_population=zeros(num_county,3);
initial_population(:,3)=100; %initial population of each county, 1st column is eggs, 2nd is Nymphs and 3rd is Adults
traffic_matrix=diag(ones(num_county,1)); %traffic_matrix(i,j)表示从i到j的流量,(i,i)表示留在i的量，一行和为1
C_inspection=1; %cost for action
C_tree_trap=1;
food_condition=ones(num_county,1); %food condition based on tree of heaven, 1 means normal, >1 means better
tree_trap_effectiveness=0.5; %trap effectiveness
inspection_effectiveness=0.5; %inspection effectiveness

%other parameters
years=5;
total_reource_per_year=10;
% these are survival rate of different stages and reproduction rate
Sen=0.62*0.74;
San=0.25;
F=47.73;

% policy matrix
% 2 policy and 5 years
% one row is one county and one page is one year; first is inspection, second is tree trap; 0 means no action
policy=zeros(num_county,2,years); %total cost in each year should be less than total_reource_per_year

% population matrix
% one row is one county and one page is one year
population=zeros(num_county, 3 ,years+1);
population(:,:,1)=initial_population;

final_population=simulation(num_county,traffic_matrix,...
    food_condition,tree_trap_effectiveness,inspection_effectiveness,...
    Sen,San,F,policy,years,population);

function total=simulation(num_county,traffic_matrix,...
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

function valid=check_valid(policy,total_reource_per_year,C_inspection,C_tree_trap)
    valid=1;
    for y = 1:size(policy,3)
        if sum(policy(:,1,y))*C_inspection+sum(policy(:,2,y))*C_tree_trap>total_reource_per_year
            valid=0;
            return
        end
    end
end

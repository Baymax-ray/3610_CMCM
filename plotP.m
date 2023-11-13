%% parameters
%parameter
[num_county, years, initial_population, traffic_matrix, food_condition, tree_trap_effectiveness, inspection_effectiveness, Sen, San, F] = initialize_parameters();
%initial population of each county, 1st column is eggs, 2nd is Nymphs and 3rd is Adults


% policy matrix
% 2 policy and 5 years
% one row is one county and one page is one year; first is inspection, second is tree trap; 0 means no action

% population matrix
% one row is one county and one page is one year
population=zeros(num_county, 3 ,years+1);
population(:,:,1)=initial_population;


fields = fieldnames(results);
% store all the final populaiton here
final_storage=zeros(num_county,3,years+1,16);
%loop over opt policy in results
for i = 1:16
    temp=results.(fields{i});
    
    policy=temp.opt_policy;
    population=zeros(num_county, 3 ,years+1);
    population(:,:,1)=initial_population;

    final_population=simulation(num_county,traffic_matrix,...
    food_condition,tree_trap_effectiveness,inspection_effectiveness,...
    Sen,San,F,policy,years,population);
    final_storage(:,:,:,i)=final_population;
end
%% plot
figure
colors = jet(16);
for i=1:16
    fieldParts = strsplit(fields{i}, '_');
    inspectionCost = fieldParts{2}; % Get the inspection cost
    treeTrapCost = fieldParts{4};   % Get the tree trap cost
    %get cost to be 1/10 of the original cost
    inspectionCost=str2num(inspectionCost)/10;
    treeTrapCost=str2num(treeTrapCost)/10;

    population=final_storage(:,:,:,i);
    %sum the amount of adult (2nd dimenstion=end) over regions (1st dimension)
    plot(1:years+1, squeeze(sum(population(:,3,:),1)), 'LineWidth', 2, 'Color', colors(i,:))
    hold on
    legendInfo{i} = ['Inspection Cost ', num2str(inspectionCost), ' Tree Trap Cost ', num2str(treeTrapCost)];

end
legend(legendInfo)
xlabel('Year')
ylabel('Adult Population')
title('Adult Population over Years')
hold off

%% 

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

[opt_policy, min_population]=optimize_policy();

function [optimal_policy, minimal_population] = optimize_policy()
    % Define optimization options
    options = optimoptions('ga');


%暂时先设成这样，麻烦你们填入真实的数据
num_county=15;
years=5;

    
    % Define genetic algorithm parameters
    nvars = num_county * 2 * years; % number of decision variables
    lb = zeros(1, nvars); % lower bounds
    ub = ones(1, nvars); % upper bounds
    intcon = 1:nvars; % integer constraints

    % Run genetic algorithm
    %这样可以跑，但是是小数
    [x, fval] = ga(@objective_function, nvars, [], [], [], [], lb, ub, @constraint_function, options);
    %理论上应该是这样的
    %[x, fval] = ga(@objective_function, nvars, [], [], [], [], lb, ub, @constraint_function,intcon, options);

    % Reshape solution into policy format
    optimal_policy = reshape(x, [num_county, 2, years]);
    minimal_population = fval;
end
function total = objective_function(x)
    num_county=15;%暂时先设成这样，麻烦你们填入真实的数据
    years=5;
    % Reshape x into policy format
    policy = reshape(x, [num_county, 2, years]);
    %暂时先设成这样，麻烦你们填入真实的数据
initial_population=zeros(num_county,3);
initial_population(:,3)=100; %initial population of each county, 1st column is eggs, 2nd is Nymphs and 3rd is Adults
traffic_matrix=diag(ones(num_county,1)); %traffic_matrix(i,j)表示从i到j的流量,(i,i)表示留在i的量，一行和为1

food_condition=ones(num_county,1); %food condition based on tree of heaven, 1 means normal, >1 means better
tree_trap_effectiveness=0.5; %trap effectiveness
inspection_effectiveness=0.5; %inspection effectiveness

%other parameters
% these are survival rate of different stages and reproduction rate
Sen=0.62*0.74;
San=0.25;
F=47.73;

% population matrix
% one row is one county and one page is one year
population=zeros(num_county, 3 ,years+1);
population(:,:,1)=initial_population;
    % Run simulation
    final_population = simulation_total(num_county,traffic_matrix,...
    food_condition,tree_trap_effectiveness,inspection_effectiveness,...
    Sen,San,F,policy,years,population);

    % Objective is to minimize population
    total = final_population; % Negative for minimization
end

function [c, ceq] = constraint_function(x)
    C_inspection=1; %cost for action
    C_tree_trap=1;
    num_county=15;
    years=5;
    % Reshape x into policy format
    policy = reshape(x, [num_county, 2, years]);
    total_reource_per_year=10;

    % Inequality constraints (none in this case)
    c = [];

    % Equality constraints )
    ceq =[ total_reource_per_year-(sum(policy(:,1,1))*C_inspection+sum(policy(:,2,1))*C_tree_trap);
        total_reource_per_year-(sum(policy(:,1,2))*C_inspection+sum(policy(:,2,2))*C_tree_trap);
        total_reource_per_year-(sum(policy(:,1,3))*C_inspection+sum(policy(:,2,3))*C_tree_trap);
        total_reource_per_year-(sum(policy(:,1,4))*C_inspection+sum(policy(:,2,4))*C_tree_trap);
        total_reource_per_year-(sum(policy(:,1,5))*C_inspection+sum(policy(:,2,5))*C_tree_trap)];
end

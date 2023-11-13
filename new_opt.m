% Define ranges for C_inspection and C_tree_trap
C_inspection_values = [1]; % Example values
C_tree_trap_values = [1]; % Example values

% Prepare a structure or cell array to store results
results = struct();

% Grid search
for i = 1:length(C_inspection_values)
    for j = 1:length(C_tree_trap_values)
        % Update costs
        C_inspection = C_inspection_values(i);
        C_tree_trap = C_tree_trap_values(j);
        tic;  % Start timing
        % Run optimization with updated costs
        [opt_policy, min_population] = optimize_policy(C_inspection, C_tree_trap);
        elapsedTime = toc;  % End timing and store the elapsed time in elapsedTime
        fprintf('Elapsed time: %.3f seconds\n', elapsedTime);
        % Store results
        key = sprintf('Inspection_%d_TreeTrap_%d', round(C_inspection * 10), round(C_tree_trap * 10));
        results.(key).opt_policy = opt_policy;
        results.(key).min_population = min_population;
    end
end


function [optimal_policy, minimal_population] = optimize_policy(C_inspection, C_tree_trap)
    % Define optimization options
    options = optimoptions('ga','MaxGenerations', 800);

    num_county=14;
    years=5;
    
    % Define genetic algorithm parameters
    nvars = num_county * 2 * years; % number of decision variables
    lb = zeros(1, nvars); % lower bounds
    ub = ones(1, nvars); % upper bounds

    % Run genetic algorithm
    %这样可以跑，但是是小数
    [x, fval] = ga(@objective_function, nvars, [], [], [], [], lb, ub, @(x)constraint_function(x, C_inspection, C_tree_trap), options);

    % Reshape solution into policy format
    optimal_policy = reshape(x, [num_county, 2, years]);
    minimal_population = fval;
end

function eco_loss = objective_function(x)
    %parameter
    [num_county, years, initial_population, traffic_matrix, food_condition, tree_trap_effectiveness, inspection_effectiveness, Sen, San, F] = initialize_parameters();
    %initial population of each county, 1st column is eggs, 2nd is Nymphs and 3rd is Adults

    % population matrix
    % one row is one county and one page is one year
    population=zeros(num_county, 3 ,years+1);
    population(:,:,1)=initial_population;

    % Reshape x into policy format
    policy = reshape(x, [num_county, 2, years]);

    
    % Run simulation
    final_population = simulation_total(num_county,traffic_matrix,...
    food_condition,tree_trap_effectiveness,inspection_effectiveness,...
    Sen,San,F,policy,years,population);

    % Objective is to minimize total population
    total = sum(final_population(:,3,end));
    % eco
    eco_loss=E_loss(final_population);
end

function [c, ceq] = constraint_function(x, C_inspection, C_tree_trap)
   
    num_county=14;
    years=5;
    % Reshape x into policy format
    policy = reshape(x, [num_county, 2, years]);
    total_reource_per_year=5;

    % Inequality constraints (none in this case)
    c = [];

    % Equality constraints )
    ceq =[ total_reource_per_year-(sum(policy(:,1,1))*C_inspection+sum(policy(:,2,1))*C_tree_trap);
        total_reource_per_year-(sum(policy(:,1,2))*C_inspection+sum(policy(:,2,2))*C_tree_trap);
        total_reource_per_year-(sum(policy(:,1,3))*C_inspection+sum(policy(:,2,3))*C_tree_trap);
        total_reource_per_year-(sum(policy(:,1,4))*C_inspection+sum(policy(:,2,4))*C_tree_trap);
        total_reource_per_year-(sum(policy(:,1,5))*C_inspection+sum(policy(:,2,5))*C_tree_trap)];
end



%% 进行优化：
[x,fval] = runGA();
%x = zeros(1,28);
simulationfunction(x);
% 
% figure;
% histogram(population_for_each_simulation);
% xlabel('population');
% ylabel('frequency');
% title('Population distribution');





%% 总优化方程：遗传算法
function [x, fval] = runGA()
    nvars = 28; % 变量数量
    Aeq = ones(1, nvars);% 用于约束方程的系数向量
    beq = 5;% 用于约束方程的等式值
    lb = zeros(1, nvars);
    ub = ones(1, nvars);
    intcon = 1:nvars;

    options = optimoptions('ga', 'PopulationSize', 10, ...% 初始种群设置
        'MaxGenerations', 10, ...% 最大迭代数
        'FunctionTolerance', 1e-6, ...% 如果多次迭代变化量小于1e-6，终止迭代
        'CrossoverFcn', @customCrossover, ...% 交叉函数自定义，每次交叉得保证约束条件被满足
        'MutationFcn', @customMutation);% 变异函数自定义，每次变异得保证约束条件被满足
    [x, fval] = ga(@simulationfunction, nvars, [], [], Aeq, beq, lb, ub, [],intcon, options);

end




%% 蒙特卡洛模拟过程
function y = simulationfunction(x)
    % 确保输入是一个 28 维向量
    if length(x) ~= 28
        error('Input must be a 28-dimensional vector.');
    end
 
    % Simulation
    population_for_each_simulation = [];
    average_population = 0;
    figure;
    for simulation  = 1 % 模拟100次
        num_egg = 0;
        num_SLF = 40+20+10+70+60+110+920+45020+1060; % 我们的模型从年初开始模拟，M = 1
        num_E = 14; % 环境单元总数
        num_eggmass = 1; % Reproduction rate
        T = 60; % Total number of time steps
        N1 = 9; %交通发达地区的数目
        N2 = num_E - N1; %交通不发达地区的数目
        P2 = 1/(1.5*N1+N2); % 假设交通发达地区迁进率为交通不发达地区迁进率的1.5倍
        P1 = 1.5/(1.5*N1+N2); % 交通发达地区的迁进率 
        D_egg = 0.14; % 虫卵的死亡率
        D_nymph = 0.29; % 幼虫的死亡率
        D_adult= 0.19; % 成虫的死亡率
    
        % 卵堆的分布
        S0 = [0,0,0,0,0,0,0,0,0,0,0,0,0,0];
        % 虫的分布
        S  = [0,0,0,0,40,20,0,10,70,60,110,920,45020,1060]; 
        % 树的分布
        Tree = [1,1,1,0,0,1,1,0,1,0,2,1,2,2]; 
        % 交通是否发达
        Traffic = [0,0,0,0,0,1,1,1,1,1,1,1,1,1];
        g_path = [];
        time = 1:T;

        for t = 1:T % t从1-60，5年共60个月
            
            M = mod(t+7,12); % M 是几月
            if M == 0
                M = 12;
            end
            disp(M)
            
    
            %繁殖
            if M == 9 || M == 10 || M == 11 % 繁殖期为9-11月
                
                for env = 1:num_E % 每个环境单元的卵都要更新数目
                    if Tree(env) == 2 % 如果有天堂树，产卵批数增加
                        num_eggmass = 7;
                    elseif Tree(env) == 1
                        num_eggmass = 4;
                    else
                        num_eggmass = 1;
                    end
    
                    %if x(env) == 1 % 有隔离措施
                        %num_eggmass = num_eggmass-0.3;
                    %end
    
                    S0(env) = floor(1/2 * S(env) * num_eggmass *1/3);
                end
            end
    
            % 迁移
            
            delta_S0 = zeros(1,num_E); % 用于存储每次循环迁移的变化量
            
            for env = 1:num_E
                if S0(env) > 0
                    for j = 1: S0(env) %对于每个分区的每一个卵堆来说
                        a = rand(1);
                        possib_to_emigrate=rand(1); 
                        if env<=5 % 起点为交通不发达区
                            if possib_to_emigrate<0.3 %迁出 
                                if floor(a/P2) < N2 %飞入交通不发达地区
                                    k = floor(a/P2); %具体飞进了哪个交通不发达地区
                          
                                        if  x(env) == 1  %隔离 和tree trap 选1
                                            delta_S0(env) = delta_S0(env)-1;
                                            delta_S0(k+1) = delta_S0(k+1)+1*0.75;%杀了0.1的卵
                                        else
                                            delta_S0(env) = delta_S0(env)-1;
                                            delta_S0(k+1) = delta_S0(k+1)+1;
                                        end
                                else % 飞入了交通发达地区
                                    m = floor((a-N2*P2)/P1);
                                    k = m+1+N2; %具体飞入了哪个地区
                                    if  x(env) == 1  %隔离 和tree trap 选1
                                        delta_S0(env) = delta_S0(env)-1;
                                        delta_S0(k) = delta_S0(k)+1*0.75;%杀了0.1的卵
                                    else
                                        delta_S0(env) = delta_S0(env)-1;
                                        delta_S0(k) = delta_S0(k)+1;
                                    end
                                end
                               
                            end
                        else%起点为发达地区
                            if possib_to_emigrate<0.8 %迁出 
                                if floor(a/P2) < N2 %飞入交通不发达地区
                                    k = floor(a/P2); %具体飞进了哪个交通不发达地区
                                        if  x(env) == 1  %隔离 和tree trap 选1
                                            delta_S0(env) = delta_S0(env)-1;
                                            delta_S0(k+1) = delta_S0(k+1)+1*0.75;%杀了0.1的卵
                                        else
                                            delta_S0(env) = delta_S0(env)-1;
                                            delta_S0(k+1) = delta_S0(k+1)+1;
                                        end
                                else % 飞入了交通发达地区
                                    m = floor((a-N2*P2)/P1);
                                    k = m+1+N2; %具体飞入了哪个地区
                                    if  x(env) == 1  %隔离 和tree trap 选1
                                        delta_S0(env) = delta_S0(env)-1;
                                        delta_S0(k) = delta_S0(k)+1*0.75;%杀了0.1的卵
                                    else
                                        delta_S0(env) = delta_S0(env)-1;
                                        delta_S0(k) = delta_S0(k)+1;
                                    end
                                end
                            end
                        end
                    end
                end
            end
            S0 = S0 +delta_S0; % 本月更新卵堆数量（存活）

            
    
            % 成长
            if M == 4
                S = S0*35;
                S0 = zeros(1,14);
            end

            
    
    
            % 死亡
            if M == 12 
                S = zeros(1,num_E);
                for env = 1:num_E % 每个分区
                    if  x(env) + x(env+14) == 1 % 隔离 和tree trap 选1
                        D_egg = D_egg*1.01;
                    elseif x(env) + x(env+14) == 0 %都没有
                        D_egg = D_egg;
                    else % 两种措施
                        D_egg = D_egg*1.01*1.01;
                    end
    
                    S0(env) = S0(env) *(1-D_egg);
                    S0(env) = max(S0(env), 0); % 确保 S0 不为负
                    S(env) = max(S(env), 0); % 确保 S 不为负
               end
            elseif M == 1 || M == 2 || M == 3 % 只有虫卵
                for env = 1:num_E % 每个分区
                    if  x(env) + x(env+14) == 1 % 隔离 和tree trap 选1
                        D_egg = D_egg*1.01;
                    elseif x(env) + x(env+14) == 0 %都没有
                        D_egg = D_egg;
                    else % 两种措施
                        D_egg = D_egg*1.01*1.01;
                    end
    
                    S0(env) = S0(env) *(1-D_egg);
                    S0(env) = max(S0(env), 0); % 确保 S0 不为负
                    S(env) = max(S(env), 0); % 确保 S 不为负
               end
            elseif M == 4 || M == 5 || M == 6 || M == 7
                % 只有幼虫
                for env = 1:num_E
                    if  x(env+14) == 1 % tree trap 选1
                        D_nymph = D_nymph * 1.01;
                        
                    else
                        D_nymph = D_nymph;
                    end
    
                    S(env) = S(env) *(1-D_nymph);
                    S0(env) = max(S0(env), 0); % 确保 S0 不为负
                    S(env) = max(S(env), 0); % 确保 S 不为负
                end
            elseif M == 8
                %刚成虫，无卵
                for env = 1:num_E
                    if  x(env+14) == 1 % tree trap 选1
                        D_adult = D_adult * 1.01;
                    
                    else
                        D_adult = D_adult;
                    end
    
                    S(env) = S(env) *(1-D_adult);
                    S0(env) = max(S0(env), 0); % 确保 S0 不为负
                    S(env) = max(S(env), 0); % 确保 S 不为负
                end
            elseif M == 9 || M == 10 || M == 11
                % 有虫，有卵
                for env = 1:num_E
                    if  x(env) + x(env+14) == 2 % 两种措施
                        D_adult = D_adult * 1.01;
                        D_egg = D_egg*1.01*1.01;
                        
                    elseif x(env+14) == 1 % 只有tree trap，没有隔离
                        D_adult = D_adult * 1.01;
                        D_egg = D_egg*1.01;
                    elseif x(env) ==1 % 只有隔离
                        D_adult = D_adult;
                        D_egg = D_egg *1.01;
                    else
                        D_adult = D_adult;
                        D_egg = D_egg;
         
                    end
    
                    S(env) = S(env) *(1-D_adult);
                    S0(env) = S0(env) *(1-D_egg);
                    S0(env) = max(S0(env), 0); % 确保 S0 不为负
                    S(env) = max(S(env), 0); % 确保 S 不为负
                end

                
            
            
            end
            population = 35*S0+S; % 当前时间t下的虫口
            population = sum(population);
            disp(population)
            g_path = [g_path,population];
            
            
        end
        
        plot(time, g_path); % 将绘图命令移动到这里
        xlabel('month');
        ylabel('Population');
        title('Population Growth');
        hold on;

        population_for_each_simulation = [population_for_each_simulation,population]; %每次模拟完的人口总量

        disp(population_for_each_simulation)
    end
    average_population =  population_for_each_simulation
    % average_population = sum(population_for_each_simulation)/100;
    y = average_population;
end

%% 遗传算法的自定义交叉函数
function xoverKids = customCrossover(parents, options, nvars, FitnessFcn, unused, thisPopulation)
    % parents - 父代的索引
    % options - 遗传算法选项
    % nvars - 变量的数量（在您的问题中为28）
    % FitnessFcn - 适应度函数
    % unused - 未使用的参数（保持为模板中的样子）
    % thisPopulation - 当前种群


    % 父代数量
    nParents = length(parents) / 2;
    % 预分配空间给子代
    xoverKids = zeros(nParents, nvars);

    % 对每一对父代进行循环
    for i = 1:nParents
        % 选取一对父代
        parent1 = thisPopulation(parents(i), :);
        parent2 = thisPopulation(parents(i + nParents), :);

        % 随机选择交叉点
        crossoverPoint = randi(nvars);

        % 生成子代
        child = [parent1(1:crossoverPoint), parent2(crossoverPoint+1:end)];

        % 确保子代满足约束条件（元素之和为10）
        child = adjustChild(child);

        % 存储子代
        xoverKids(i, :) = child;
    end
end

function child = adjustChild(child)
    disp(child)
    % 调整子代以满足元素之和为10的约束
    while sum(child) > 10
        onesIndices = find(child == 1);
        child(onesIndices(randi(numel(onesIndices)))) = 0;
    end
    while sum(child) < 10
        zerosIndices = find(child == 0);
        child(zerosIndices(randi(numel(zerosIndices)))) = 1;
    end
    
end

%% 自定义交叉方程
function mutationChildren = customMutation(parents, options, nvars, ...
                                           FitnessFcn, state, thisScore, ...
                                           thisPopulation, mutationRate)
    % parents - 选择进行突变的解的索引
    % options - 遗传算法选项
    % nvars - 变量的数量（在您的问题中为28）
    % 其他参数 - 用于标准突变函数的参数，这里未使用

    % 选择进行突变的解的数量
    nParents = length(parents);
    % 预分配空间给子代
    mutationChildren = zeros(nParents, nvars);

    % 对每一个选定的解进行循环
    for i = 1:nParents
        % 选择一个父代
        parent = thisPopulation(parents(i), :);

        % 随机选择一个位置进行突变
        mutationPoint = randi(nvars);
        if parent(mutationPoint) == 1
            parent(mutationPoint) = 0;
            onesIndices = find(parent == 1);
            parent(onesIndices(randi(numel(onesIndices)))) = 1;
        else
            parent(mutationPoint) = 1;
            zerosIndices = find(parent == 0);
            parent(zerosIndices(randi(numel(zerosIndices)))) = 0;
        end

        % 存储突变后的子代
        mutationChildren(i, :) = parent;
    end
end



function [num_county, years, initial_population, traffic_matrix, food_condition, tree_trap_effectiveness, inspection_effectiveness, Sen, San, F] = initialize_parameters()
    num_county = 14;
    years = 5;
    
    % Define initial population and other parameters
    initial_population=[0 0 0 0 0 0 0 0 0 0 0 0 0 0;
0 0 0 0 0 0 0 0 0 0 0 0 0 0;
0 20 0 0 0 10 70 0 40 60 110 920 45020 1060]';
    traffic_matrix = generate_traffic_matrix();
    food_condition=[1.5;1.5;1.5;1.5;1.5;1;1.5;1;1;1;2;1.5;2;2]; %food condition based on tree of heaven, 1 means normal, >1 means better
    tree_trap_effectiveness=0.7; %trap effectiveness
    inspection_effectiveness=0.7; %inspection effectiveness
    % these are survival rate of different stages and reproduction rate
    Sen = 0.62 * 0.74;
    San = 0.25;
    F = 47.73;
end

function initial_population_new=population_with_uncertainty(initial_population)
    initial_population_new=zeros(14,3);
    for i=1:14
        if initial_population(i,end)==0
            %uniform distribution from 0 to 200
            initial_population_new(i,end)=200*rand;
        else
            %uniform distribution error from -0.5% to 0.5%
            initial_population_new(i,end)=initial_population(i,end)*(1+0.005*(2*rand-1));
        end
    end
end

function traffic_matrix = generate_traffic_matrix()
    traffic_matrix1=diag([0.5 0.5 0.5 0.5 0.2 0.5 0.5 0.2 0.2 0.5 0.2 0.5 0.8 0.5]);
    traffic_matrix2=zeros(14,14);
    traffic_matrix2(:,1)=0.0883;
    traffic_matrix2(:,2)=0.0883;
    traffic_matrix2(:,3)=0.0883;
    traffic_matrix2(:,4)=0.0883;
    traffic_matrix2(:,5)=0.0417;
    traffic_matrix2(:,6)=0.0883;
    traffic_matrix2(:,7)=0.0883;
    traffic_matrix2(:,8)=0.0417;
    traffic_matrix2(:,9)=0.0417;
    traffic_matrix2(:,10)=0.0883;
    traffic_matrix2(:,11)=0.0417;
    traffic_matrix2(:,12)=0.0883;
    traffic_matrix2(:,13)=0.1250;
    traffic_matrix2(:,14)=0.0417;
    traffic_matrix=traffic_matrix1*traffic_matrix2; 
    traffic_matrix(1,1)=1-sum(traffic_matrix(1,2:14));
    traffic_matrix(2,2)=1-sum(traffic_matrix(2,3:14))-sum(traffic_matrix(2,1));
    traffic_matrix(3,3)=1-sum(traffic_matrix(3,4:14))-sum(traffic_matrix(3,1:2));
    traffic_matrix(4,4)=1-sum(traffic_matrix(4,5:14))-sum(traffic_matrix(4,1:3));
    traffic_matrix(5,5)=1-sum(traffic_matrix(5,6:14))-sum(traffic_matrix(5,1:4));
    traffic_matrix(6,6)=1-sum(traffic_matrix(6,7:14))-sum(traffic_matrix(6,1:5));
    traffic_matrix(7,7)=1-sum(traffic_matrix(7,8:14))-sum(traffic_matrix(7,1:6));
    traffic_matrix(8,8)=1-sum(traffic_matrix(8,9:14))-sum(traffic_matrix(8,1:7));
    traffic_matrix(9,9)=1-sum(traffic_matrix(9,10:14))-sum(traffic_matrix(9,1:8));
    traffic_matrix(10,10)=1-sum(traffic_matrix(10,11:14))-sum(traffic_matrix(10,1:9));
    traffic_matrix(11,11)=1-sum(traffic_matrix(11,12:14))-sum(traffic_matrix(11,1:10));
    traffic_matrix(12,12)=1-sum(traffic_matrix(12,13:14))-sum(traffic_matrix(12,1:11));
    traffic_matrix(13,13)=1-sum(traffic_matrix(13,14:14))-sum(traffic_matrix(13,1:12));
    traffic_matrix(14,14)=1-sum(traffic_matrix(14,1:13));
    %traffic_matrix(i,j)表示从i到j的流量,(i,i)表示留在i的量，一行和为1
end
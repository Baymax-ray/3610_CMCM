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
%% 

[opt_policy, min_population]=optimize_policy();


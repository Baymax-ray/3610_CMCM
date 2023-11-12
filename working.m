%% parameters
%暂时先设成这样，麻烦你们填入真实的数据
num_county=15;
initial_population=ones(num_county,1)*100;
traffic_matrix=ones(num_county,num_county)/num_county; %traffic_matrix(i,j)表示从i到j的流量
C_inspection_l=[0.1,1,3]; %cost for action
C_tree_trap_l=[0.1,1,3];

%other parameters
years=5;
total_reource=10;
% these are survival rate of different stages and reproduction rate
Spo=0.62;
Snp=0.74;
San=0.25;
F=47.73;

%
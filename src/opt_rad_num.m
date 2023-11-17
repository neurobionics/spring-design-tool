function [rad_tip,num_flex,theta,ball_rad] = opt_rad_num(rad_root,z_thick,num_flex,deflection,k,design_stress,E,min_ball_rad)

% rad_root = 26.0e-3; % m
% z_thick = 4.5e-3; % m
% num_flex = []; % number of flexures in spring
% deflection = []; % deg
% k = 150; % Nm/rad
% design_stress = 912e6; %1225e6*.85; % Pa
% E = 200e9; % Pa (Young's Modulus)

lb = rad_root/30; % lower bound for tip/contact radius
ub = rad_root; % upper bound for tip/contact radius
vars = {rad_root z_thick design_stress k E num_flex deflection min_ball_rad}; % pack relevant variables for optimizer

%% Set up GA to optimize tip/contact radius
num_generations = 100;
initial_guess = linspace(lb,ub,30)';
num_population = length(initial_guess);
options = optimoptions('ga','InitialPopulation',initial_guess,'PopulationSize',num_population,'Generations',num_generations,'Display','off');
[x, ~] = ga(@(x)defl_calc(x,vars),1,[],[],[],[],lb,ub,[],[],options); % optimize tip/contact radius

rad_tip = x; % optimized tip/contact radius
[~,num_flex,ball_rad,theta] = defl_calc(x,vars); % rerun to extract other important variables

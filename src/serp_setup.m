function [profiles,returnVals] = serp_setup(rad_out,z_thick,k,design_stress,E,rad_root,rad_tip,num_flex,pins_num,pins_rad,defl_des,run_time,step,n_ctrl_p,gap,min_ball_rad)

%% Section 0: If you'd like to run as a script, comment out line 1 and uncomment lines 5-30
% % 
% close all
% clear
% clc
% 
% %% Function inputs %%
% % Required
% rad_out = 33.5e-3; % (m) radius of the whole spring
% z_thick = 4.5e-3; % (m) thickness of spring disc
% k = 150; % (Nm/rad) desired stiffness
% design_stress = 912e6; % (Pa) percentage of yield stress, depending on desired safety factor and fatigue life
% E = 200e9; % (Pa) Young's Modulus
% 
% % Optional
% rad_root = [];%31e-3; % (m) root radius, or radius at which flexures meet rim
% rad_tip = [];%6e-3; % (m) distance from flexure tip to spring center
% num_flex = [];%24; % number of flexures in spring
% pins_num = [];%24; % number of pinholes on outer rim
% pins_rad = [];%1.5e-3; % (m) radius of pinholes
% defl_des = 15; % (deg)
% run_time = 15; % (s) allowable run time for serpentine shape calculator
% 
% % Advanced
% step = []; % (m) distance between plotted points on centerline
% n_ctrl_p = []; % number of control points used to define center spline
% gap = []; % (m) gap between ball and cam
% min_ball_rad = 0.375e-3; % (m) minimum allowable radius for ball flexure tip

%% Section 1: Calculate optional parameters
if ~isempty(rad_root) % if root radius has been set
    if isempty(num_flex) && isempty(rad_tip) % if tip radius and flexure number have not been set 
        [rad_tip,num_flex,theta,ball_rad] = opt_rad_num(rad_root,z_thick,num_flex,[],k,design_stress,E,min_ball_rad); % optimize contact/tip radius, maximize number of flexures and calculate ball/tip radius
        defl_straight = theta*180/pi; % possible deflection for straight flexures (deg)
    else
        [num_flex,ball_rad,theta] = n_calc(rad_root,rad_tip,z_thick,num_flex,[],k,design_stress,E,min_ball_rad); % maximize number of flexures and calculate ball/tip radius
        defl_straight = theta*180/pi; % possible deflection for straight flexures (deg)
    end
else % if root radius has not been set
    % set bounds and initial guess:
    x0 = rad_out*0.95;
    lb = rad_out*0.5;
    ub = rad_out;

    %  Calculate root radius, optimize contact/tip radius, maximize number of flexures and calculate ball/tip radius
    options = optimoptions('fmincon','Display','off');
    rad_root = fmincon(@(x)rad_root_calc(x,rad_out,rad_tip,z_thick,num_flex,k,defl_des,design_stress,E,min_ball_rad),x0,[],[],[],[],lb,ub,[],options);
    [~,num_flex,ball_rad,theta,rad_tip,defl_straight] = rad_root_calc(rad_root,rad_out,rad_tip,z_thick,num_flex,k,defl_des,design_stress,E,min_ball_rad);
end

% If a target deflection isn't given, add 1 degree to the straight-flexure
% deflection value:
if isempty(defl_des)
    defl_des = defl_straight + 1;
end
%% Section 2: Optimize flexure geometry
if defl_straight < defl_des % if desired deflection is greater than the straight-flexure deflection, optimize flexure geometry (will be serpentine)
    [side_left, side_right, step, tip_load, min_dist, n_ctrl_p, x_flag] = spring_design(rad_root,rad_tip,z_thick,num_flex,defl_des,k,design_stress,E,run_time,step,n_ctrl_p);
elseif defl_straight >= defl_des % if desired deflection is less than the straight-flexure deflection, optimize flexure geometry (will be straight)
    % In this case, a smaller spring could be designed with serpentine
    % flexures and still meet the stiffness and deflection requirements
    defl_des = defl_straight;
    [side_left, side_right, step, tip_load, min_dist, n_ctrl_p, x_flag] = spring_design(rad_root,rad_tip,z_thick,num_flex,defl_des,k,design_stress,E,run_time,step,n_ctrl_p);
end

if x_flag <= 0
    profiles = [];
    returnVals = struct('Flag',x_flag);
else
    
    %% Section 3: Add tip/fillets to flexure and create cam
    [raw_mm,pattern_mm,wedge_mm,inner_mm,outer_mm,pins_rad,pins_num] = create_geometry([side_left side_right],rad_out,rad_root,rad_tip,num_flex,step,ball_rad,pins_num,pins_rad);
    [cam_profile_mm, deflection_fac, gap] = cam_design(rad_tip,ball_rad,num_flex,tip_load,k,gap);
    % writematrix(pattern_mm/1000,'C:\Users\zbons\Downloads\pattern.csv')
    
    %% Package return variables:
    profiles = struct('raw',raw_mm,'pattern',pattern_mm,'wedge',wedge_mm, ...
        'inner',inner_mm,'outer',outer_mm,'cam_profile',cam_profile_mm);
    returnVals = struct('RootRadius',rad_root,'ContactRadius',rad_tip, ...
        'NumberFlexures',num_flex,'NumberPins',pins_num,'PinRadius',pins_rad, ...
        'DesiredDeflection',defl_des,'RunTime',run_time,'StepSize',step, ...
        'NumControlPoints',n_ctrl_p,'TipCamGap',gap,'MinTipRadius',ball_rad, ...
        'AllowableDeflection',defl_des,'FlexureCloseness',min_dist,'Flag',x_flag);
end



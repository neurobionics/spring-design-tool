function [fval,num_flex,ball_rad,theta] = defl_calc(x,vars)
%     vars = [rad_root z_thick design_stress k E num_flex deflection];
    %% Unpack variables
    rad_root = vars{1,1};
    z_thick = vars{1,2};
    design_stress = vars{1,3};
    k = vars{1,4};
    E = vars{1,5};
    num_flex = vars{1,6};
    deflection = vars{1,7};
    min_ball_rad = vars{1,8};
    rad_tip = x;

    %% Calculate objective
    % Calculate the maximum number of allowable flexures and the
    % corresponding deflection:
    [num_flex,ball_rad,theta] = n_calc(rad_root,rad_tip,z_thick,num_flex,deflection,k,design_stress,E,min_ball_rad);
    fval = 1/theta; % Maximize deflection by minimizing its inverse
end
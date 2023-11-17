function [fval,num_flex,ball_rad,theta,rad_tip,defl_straight] = rad_root_calc(rad_root,rad_out,rad_tip,z_thick,num_flex,k,defl_des,design_stress,E,min_ball_rad)

    if isempty(num_flex) && isempty(rad_tip) % if tip radius and flexure number have not been set 
        [rad_tip,num_flex,theta,ball_rad] = opt_rad_num(rad_root,z_thick,num_flex,[],k,design_stress,E,min_ball_rad); % optimize contact/tip radius, maximize number of flexures and calculate ball/tip radius
        defl_straight = theta*180/pi; % possible deflection for straight flexures (deg)
    else
        [num_flex,ball_rad,theta] = n_calc(rad_root,rad_tip,z_thick,num_flex,[],k,design_stress,E,min_ball_rad); % maximize number of flexures and calculate ball/tip radius
        defl_straight = theta*180/pi; % possible deflection for straight flexures (deg)
    end

    % Calculate desired deflection if not assigned as input
    if isempty(defl_des)
        defl_des = defl_straight + 1;
    end
    
    [~,~,tip_load,~] = serp_calc(rad_root,rad_tip,z_thick,num_flex,defl_des,k,E,design_stress); % Calculate the expected load
    
    arc = rad_root*2*pi/num_flex; % arc length at the root radius
    w = sqrt(6*tip_load*(rad_root-rad_tip)/(z_thick*design_stress)); % width of the flexure at the base/root radius
    b = (arc - w)/1.5; % Calculate desired thickness of the rim
    fval = abs(rad_out - rad_root - b); % Objective: rad_out = rad_root + b

function [defl_nom,defl_serp,tip_load,serp_des] = serp_calc(rad_root,rad_tip,z_thick,num_flex,defl,k,E,design_stress)
% This function uses basic strain energy calculations to determine the
% required serpentine factor in order to achieve the desired behavior. For
% a clearer derivation, check the paper

    %% Calculate beam math
    peak_strain = design_stress/E; % Pa/(Pa/(m/m))
    peak_strain_energy = .5 * peak_strain^2 * E; % Pa
    bending_strain_energy = peak_strain_energy * (1/3); % Pa
    
    defl_rad = defl*pi/180; % target deflection (rad)
    total_target_torque = k*defl_rad; % target peak torque
    tau_Nm = total_target_torque/num_flex; % torque per flexure
    
    E_J = 0.5*defl_rad*tau_Nm; % target spring energy for one flexure [J]
    tip_load = tau_Nm/rad_tip; % force on each flexure [N]
    nominal_volume = sqrt(6*z_thick*tip_load/design_stress)*2/3*(rad_root-rad_tip)^(3/2); % see Spring Design in paper
    E_nom = nominal_volume * bending_strain_energy; % bending strain energy stored in straight beam of same load capacity
    defl_nom = sqrt(2*E_nom/k*num_flex)*180/pi; % deflection of straight beam
    defl_serp = sqrt(2*E_J/k*num_flex)*180/pi; % deflection of serpentine beam
    serp_des = E_J / E_nom; % serpentine factor calculated based on energy
    
%%%%%%%%%%%%%%% ALTERNATIVE MATH %%%%%%%%%%%%%%%%
%     theta = (num_flex*8*z_thick*design_stress^3*(rad_root - rad_tip)^3/(27*E^2*k*rad_tip))^(1/3); % deflection of straight beam
%     E_J = .5* defl_rad * tau_Nm; % peak spring energy [J]
%     tip_load = tau_Nm/rad_tip; % force [N]
%     nominal_volume = sqrt(6*z_thick*k*theta/rad_tip/num_flex/design_stress)*2/3*(rad_root-rad_tip)^(3/2);
%     E_nom = nominal_volume * bending_strain_energy;
%     defl_nom = 180/pi*theta % deflection of straight beam
%     defl_serp = sqrt(2*E_J/k*num_flex)*180/pi % deflection of serpentine beam
%     serp_des = E_J / E_nom;

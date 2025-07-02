function [cam_profile_mm, deflection_fac, gap, cam_shape_raw_mm] = cam_design(rad_tip,ball_rad,num_flex,tip_load,k,gap)
% This function numerically generates a cam profile which will apply forces
% in the correct direction to approximate ideal bending.

dF = 25; % discretization fidelity
deflection_fac = 2; % multiplication factor for estimated load/deflection
flag = true; % flag to check that tooth will not be too wide
inc_res = true; % flag to increase resolution (mult) if glitches occur
mult = 1000; % changes the tolerance in find_itrst to avoid glitches
if isempty(gap)
    gap = .025e-3; % gap between ball and cam
end

while flag || inc_res
    %% Linear Approximation - assumes that the tip of the flexure
    %  deflects purely horizontally (small angle approximation)
    k_lin = k/num_flex/rad_tip^2; % Linear stiffness [N/m]
    loads = linspace(0,tip_load*deflection_fac,dF); % Range of expected loads [N]
    x_lin = loads/k_lin; % Deflections corresponding to the loads [m]
    tip_locs = [x_lin; rad_tip*ones(1,dF)]'; % Locations of flexure tip throughout deflection
    cont_locs = [tip_locs(:,1)-ball_rad tip_locs(:,2)]; % Locations of contact point throughout deflection


    %% Generate cam profile point-by-point
    rotz = @(theta) [cos(theta) -sin(theta); sin(theta) cos(theta)]; % Rotation matrix as a function of theta
    find_vert = @(theta,point,contact) abs(contact(1) - point(1)*cos(theta) + point(2)*sin(theta)); % Find angle that creates a vertical line
    p(1,:) = [-ball_rad rad_tip - ball_rad/4];
    % setting up constraints and initialization:
    lb = -pi/4;
    ub = pi/4;
    x0 = pi/4;
    total_ang = 0;
    direction_old = [0 1];
    for i = 1:dF-1
        line = [cont_locs(i,:); p(i,:)]; % line from current point to contact point
        next_contact = cont_locs(i+1,:);
        options = optimoptions('fmincon','Display','off');
        x1 = fmincon(@(x)find_itrst(x,line',next_contact',mult), x0, [], [], [], [], lb, ub,[],options); % Calculate angle needed to rotate until line is collinear with next contact point
        p = transpose(rotz(x1)*p'); % Rotate the profile by the angle found
        direction = next_contact - p(i,:);
        % If the profile has a change in slope that is too sharp, restart
        % with a higher cost in the optimization:
        if acos(abs(dot(direction,direction_old))/norm(direction)/norm(direction_old)) > 10*pi/180
            inc_res = true;
            mult = mult*10;
            break
        else
            inc_res = false;
        end
        direction_old = direction; % reassign value
        p(i+1,:) = p(i,:) + direction/2; % add point to the cam profile
        options = optimoptions('fmincon','Display','off');
        x2 = fmincon(@(x)find_vert(x,p(i+1,:)',next_contact'), x0, [], [], [], [], lb, ub,[],options); % calculate angle needed to rotate until most recent profile point (p) is vertically aligned with the next contact point
        p = transpose(rotz(x2)*p'); % rotate the profile by the angle found
        total_ang = total_ang + x1 + x2; % keep track of total angular displacement for later use
    end
    direction = next_contact - p(end,:);
    p(end+1,:) = p(end,:) + direction*2; % Create last point
    cam_shape = transpose(rotz(-total_ang)*p'); % Rotate profile back into original frame
    cam_shape = cam_shape - gap*[ones(size(cam_shape,1),1) zeros(size(cam_shape,1),1)]; % Offset by gap input according to manufacturing precision
    total_defl = total_ang*180/pi;
    
    top_ang = atan2(cam_shape(end,2),cam_shape(end,1)) - pi/2;
    if top_ang < pi/num_flex
        flag = false;
    else
%         if deflection_fac - 0.1 < 1
%             error('This cam design will not allow full deflection of the spring')
%         else
        if 1
            deflection_fac = deflection_fac - 0.1;
            clear p cam_shape cont_locs tip_locs loads x_lin
        end     
    end
end
% PLOTS FOR DEBUGGING
% figure()
% axis equal
% hold on
% plot(p(:,1),p(:,2),'.')
% plot(cam_shape(:,1),cam_shape(:,2),'.')

%% Save shape before adding to it
cam_shape_raw_mm = 1000*[cam_shape zeros(size(cam_shape,1),1)];
%% Add Fillets at base of cam profile
cam_shape = flip(cam_shape);
fillet_center = cam_shape(end,:) + [ball_rad -2*gap];
[fillet_x,fillet_y] = pol2cart(linspace(pi,3*pi/2,15),ball_rad);
fillet = [fillet_x + fillet_center(1); fillet_y + fillet_center(2)]';
cam_shape = [cam_shape; fillet(2:end,:)];

%% Mirror and Circular Pattern
pattern = [cam_shape; flip([-cam_shape(:,1) cam_shape(:,2)])]'; % mirror
rot_pat = rotz(-2*pi/num_flex); % create rotation matrix
full_cam = pattern;

for j = 1:num_flex-1
    sz = size(full_cam,2);
    for i = 1:size(pattern,2)
        full_cam(:,sz+i) = rot_pat*full_cam(:,i+size(pattern,2)*(j-1));
    end
end
full_cam = full_cam';
full_cam = [full_cam; full_cam(1,:)];
cam_profile_mm = 1000*[full_cam zeros(size(full_cam,1),1)];
% cam_profile_mm = 1000*[zeros(size(full_cam,1),1) full_cam(:,2) full_cam(:,1)]; % this is just for importing curves into the testbed camshaft CAD
% writematrix((cam_profile_mm),'cam_profile_mm.txt') % flex_uncut
% plot(cam_profile_mm(:,1),cam_profile_mm(:,2))

    function fval = find_itrst(theta,line,contact,mult)
        dx = line(1,2) - line(1,1);
        dy = line(2,2) - line(2,1);
        xc = contact(1);
        yc = contact(2);
        r = xc*dx + yc*dy;
        s = xc*dy - yc*dx;
        t = line(1,1)*dy - line(2,1)*dx;

        fval = abs(r*sin(theta) + s*cos(theta) - t)*mult;
    end
end

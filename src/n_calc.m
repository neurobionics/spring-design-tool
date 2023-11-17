function [n,ball_rad,theta] = n_calc(rad_root,rad_tip,z_thick,n,deflection,k,design_stress,E,min_ball_rad)
% Calculates the maximum number of flexures that can fit within the spring
% while considering which inputs have been assigned/unassigned by the user

if isempty(min_ball_rad)
    l1 = 0.0006; % flexure tip width lower limit
else
    l1 = min_ball_rad*2; % multiply to get diameter
end

%% If n is unnassigned, start with minimum tip width and increase until 
if isempty(n) % if number of flexures is unnasigned
    violated = true; % set flag
    n_limit = floor(pi*sqrt(l1^2/4 + rad_tip^2)/l1); % geometric flexure limit based on tip width
    while violated == true
        n = n_limit;
        theta = (n*8*z_thick*design_stress^3*(rad_root - rad_tip)^3/(27*E^2*k*rad_tip))^(1/3);
        tau = k*theta;

        m = tan(pi/6);
        a = m^2;
        b = -(2*m^2*rad_tip + 3*tau/(2*n*rad_tip*z_thick*design_stress));
        c = m^2*rad_tip^2 + 3*tau/(2*n*z_thick*design_stress);
        xi = (-b + sqrt(b^2 - 4*a*c))/2/a;
        yi = m*xi - m*rad_tip;
        ball_rad = norm([xi-rad_tip yi]);
        l1_new = 2*ball_rad;
        n_limit_new = floor(pi*sqrt(l1_new^2/4 + rad_tip^2)/l1_new);

        if n_limit_new >= n_limit
            ball_rad = l1/2;
            violated = false;
        else
            n_limit = n_limit_new;
            l1 = l1_new;
        end

    end

    % Calculate the expected deflection
    if isempty(deflection)
        n = n_limit;
        theta = (n*8*z_thick*design_stress^3*(rad_root - rad_tip)^3/(27*E^2*k*rad_tip))^(1/3);
    else % Check that the desired deflection corresponds to a number of flexures that is lower than the allowable limit 
        theta = deflection/180*pi;
        n = ceil(27*E^2*k*theta^3*rad_tip/(8*z_thick*design_stress^3*(rad_root - rad_tip)^3));
        if n > n_limit
            n = n_limit;
            theta = (n*8*z_thick*design_stress^3*(rad_root - rad_tip)^3/(27*E^2*k*rad_tip))^(1/3);
            deflection_new = theta*180/pi;
            sprintf('Desired deflection is unachievable with straight flexures. Changed from %0.5g to %0.5g',deflection,deflection_new);
        end
    end

%% If n is assigned, calculate deflection and tip/ball radius directly
else
    theta = (n*8*z_thick*design_stress^3*(rad_root - rad_tip)^3/(27*E^2*k*rad_tip))^(1/3);
    if ~isempty(deflection)
        deflection_new = theta*180/pi;
        error('Desired deflection is constrained to %0.5g with straight flexures for your given inputs. Rerun with either n = [], or deflection = [], or both.',deflection_new);
    end
    tau = k*theta;
    m = tan(pi/6);
    a = m^2;
    b = -(2*m^2*rad_tip + 3*tau/(2*n*rad_tip*z_thick*design_stress));
    c = m^2*rad_tip^2 + 3*tau/(2*n*z_thick*design_stress);
    xi = (-b + sqrt(b^2 - 4*a*c))/2/a;
    yi = m*xi - m*rad_tip;
    ball_rad = norm([xi-rad_tip yi]);
    if ball_rad < l1/2 % if lower than threshold
        ball_rad = l1/2; % set to the lower limit
    end
    n_limit = floor(pi*sqrt(ball_rad^2 + rad_tip^2)/(2*ball_rad)); % calculate allowable flexure limit
    if n_limit < n % check that the user-selected number of flexures is within allowable bounds
        error('Infeasible design: try using a smaller number of flexures');
    end

end
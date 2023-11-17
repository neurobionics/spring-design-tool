function [c, ceq] = curve_nonlcon(x,vars)

    %% Parameters    
    rad_root = vars(1);
    rad_tip = vars(2);
    z_thick = vars(3);
    num_flex = vars(4);
    serp_des = vars(5);
    tip_load = vars(6);
    design_stress = vars(7);
    step = vars(8);
    n = vars(9);
    
    %% Convert input
    x_p = [0 x(1:n)' 0];
    y_p = [rad_tip x((n+1):end)' rad_root]; % y_p is controlled by fmincon
    % y_p = linspace(rad_tip,rad_root,length(x_p)); % y_p is fixed

    %% Create spline for neutral axis
    t = rad_root:-step:rad_tip;
    spline = csape(y_p,x_p,'clamped',[0 0]); % constrained to 0 slope at tip and root
    x_n = fnval(spline,t);
    y_n = t;
    s_prime = fnder(spline);
    slope = fnval(s_prime,t); % calculate slope of spline at every point

    %% Initialize variables
    w = sqrt(6*tip_load*(t-rad_tip)/(z_thick*design_stress)); % calculate the required flexure width at each point along the spline
    w_side = w/2;

    side1 = zeros(length(t),2);
    side2 = zeros(length(t),2);

    %% Calculate flexure profile
    for i = 1:length(t) % for each point along spline
        if slope(i) == 0
            m = 1e9; % near-vertical line to avoid errors
        else
            m = -1/slope(i);
        end
        dx = sign(m)*sqrt(w_side(i)^2/(m^2 + 1)); % calculate x-distance from the neutral axis
        dy = m*dx; % calculate y-distance from neutral axis
        side1(i,:) = [x_n(i)+dy y_n(i)+dx]; % build one edge of the flexure
        side2(i,:) = [x_n(i)-dy y_n(i)-dx]; % build the opposite edge of the flexure
    end

    %% Area calculations
    A_wedge = pi/num_flex*(rad_root^2 - rad_tip^2); % calculate area of "pie-slice" alotted to each flexure
    A_nom = -trapz(t,w_side)*2; % calculate area of nominal straight flexure
    A_serp = trapz(side2(:,2),side2(:,1),1) - trapz(side1(:,2),side1(:,1),1); % calculate area of serpentine flexure
    fac_serp = A_serp/A_nom; % serpentine factor
    fac_dens = A_serp/A_wedge; % density factor

    %% Define constraints

    % Lateral balance:
    c(:,1) = abs(sum(x_n)) - 1e-3; % the sum of the x-distances to the neutral axis must be less than 1mm
    
    % Match target flexure area:
    A_err = serp_des - fac_serp; % error in area target
    c(:,end+1) = abs(A_err) - .001; % If you want to implement A_err as an inequality constraint instead of equality (set ceq to [])
    
    % Strengthen constraints:
    c = c*1e2; % If you want a stricter constraint
    ceq = [];

end
function [opt_var, side1, side2, A_err, flex_oth, min_dist] = curve_func(x,vars)

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
    edge = [side1; flip(side2)];

    %% Optimization Variable Options

    %% Closeness to other flexures v2.0
    theta = 2*pi/num_flex; % angular offset of each flexure
    M = [cos(theta) -sin(theta) 0; sin(theta) cos(theta) 0; 0 0 1]; % rotation matrix
    % side2 is on the left, side 1 is on the right
    flex_oth = [side1 zeros(size(side1,1),1)];
    flex_oth = M*flex_oth'; % build 'neighboring flexure' by rotating one side by theta
    flex_oth = flex_oth(1:2,:)';
    dist = 100*ones(1,size(side1,1));

    for i = 1:size(side1,1) % for every point on one edge
        for j = 1:size(side1,1) % run through every point on the other edge
            d = norm(flex_oth(j,:) - side2(i,:)); % calculate the distance between the two points
            if d < dist(i)
                dist(i) = d; % save the smallest distance between one point and the other edge
                if d < 2*step
                    break; % if the lines get too close/intersect, break out of the loop
                end
            end
        end
    end
    min_dist = min(dist); % select the overall closest distance
    min_dist_sq = sqrt(min_dist);

    %% Radius of curvature
%     vecs = [x_n; y_n; zeros(1,length(t))];
%     r_o_c = zeros(size(t));
%     for i = 2:length(t)-1
%         r_o_c(i) = circumcenter(vecs(:,i-1),vecs(:,i),vecs(:,i+1));
%         if r_o_c(i) == Inf
%             r_o_c(i) = 1e9;
%         end
%     end
%     r_o_c(1) = r_o_c(2);
%     r_o_c(end) = r_o_c(end-1);
%     r_int = trapz(t,r_o_c);
    
    %% Curvature
    vecs = [x_n; y_n; zeros(1,length(t))]; % construct neutral axis
    r_o_c = zeros(size(t));
    for i = 2:length(t)-1
        r_o_c(i) = circumcenter(vecs(:,i-1),vecs(:,i),vecs(:,i+1)); % calculate radius of curvature
        if r_o_c(i) == Inf % handle edge case of Infinity by assigning large value
            r_o_c(i) = 1e9;
        end
    end
    r_o_c(1) = r_o_c(2); % approximate beginning radius
    r_o_c(end) = r_o_c(end-1); % approximate ending radius
    K = 1./r_o_c; % calculate curvature at each point

    %% Accuracy of area
    A_err = serp_des - fac_serp;
    
    %% Choose the cost
%     opt_var = r_int; % Maximizes the radius of curvature along flexure
    opt_var = 1e5/min_dist_sq + sum(K.^2); % OBJECTIVE: maximize distance between flexures and minimize curvature
%     opt_var = sum(K.^2);

end

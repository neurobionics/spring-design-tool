function [side_left, side_right, step, tip_load, min_dist, n, x_flag] = spring_design(rad_root,rad_tip,z_thick,num_flex,defl,k,design_stress,E,run_time,step,n)

% num_disks = 1; % number of spring disks anticipated
if isempty(run_time)
    run_time = 1;
end

%% Calculate area properties of new spring and desired serpentine factor
[~,defl_serp,tip_load,serp_des] = serp_calc(rad_root,rad_tip,z_thick,num_flex,defl,k,E,design_stress);
defl_straight = (num_flex*8*z_thick*design_stress^3*(rad_root - rad_tip)^3/(27*E^2*k*rad_tip))^(1/3)*180/pi;

if defl_serp < defl_straight
    error("Straight flexures will provide more deflection than required. Try decreasing rad_root or increasing deflection.");
end

%% Design optimizer inputs
if isempty(step)
    step = rad_root/300; % step size along flexure (m)
end
if isempty(n)
    n = 2; % number of inner control points (not including end points)
end
lims = [0 (rad_root - rad_tip)/2]; % Range of random x magnitudes (m)

%% Run optimization for allotted time
iterations = 0;
tic
while iterations == 0 || toc < run_time

    %% Build x0
    x_guess = (lims(2)-lims(1)).*rand(n,1) + lims(1); % x-coordinates assigned randomly within range
    for i = 1:n
        if mod(i,2) == 0
            x_guess(i) = -x_guess(i); % force x-coordinates to alternate positive and negative for the inital guess
        end
    end
    y_pre = linspace(rad_tip,rad_root, n+2)'; % evenly distribute y-coordinate guesses along the length of the flexure
    y_guess = y_pre(2:end-1);
    x0 = [x_guess; y_guess]; % compile initial guess vector

    %% Linear Constraints
    A = zeros(n-1,length(x0));
    y_close = (rad_root - rad_tip)*.1; % constrains proximity of control points based on percentage of flexure length
    
    % Force control points to maintain ascending order and distance of at
    % least y_close:
    for i = 1:n-1
        A(i,end-n + i) = 1;
        A(i,end-n + i + 1) = -1;
    end
    b = ones(n-1,1)*-y_close;

    % Bounds on control point coordinates:
    xlim = lims(2);
    lb = [-xlim*ones(n,1); (rad_tip + y_close)*ones(n,1)];
    ub = [xlim*ones(n,1); (rad_root - y_close)*ones(n,1)];

    % Force x-coordinates of control points to lie on alternating sides of
    % the neutral axis (lateral balance)
    for i = 1:n
        if x_guess(i)>0
            lb(i) = 0;
            ub(i) = xlim;
        else
            lb(i) = -xlim;
            ub(i) = 0;
        end
    end

    %% Run constrained nonlinear optimization of flexure geometry
    vars = [rad_root rad_tip z_thick num_flex serp_des tip_load design_stress step n]; % package variables for objective function
    options = optimoptions('fmincon','MaxFunctionEvaluations',3000,'MaxIterations',1000,'Display','off');
    [x, fval, exitflag] = fmincon(@(x)curve_func(x,vars), x0, A, b, [], [], lb, ub, @(x)curve_nonlcon(x,vars), options); % optimize flexure geometry
    
    %% Count and score iterations of the optimization
    iterations = iterations + 1;
    xs(:,iterations) = x;
    if exitflag <= 0
        scores(iterations) = 1e99; % if convergence was not achieved or constraints were unsatisfied, the score is placed artificially high (effectively disqualified)
    else
        scores(iterations) = fval;
    end
    flags(iterations) = exitflag;
    time(iterations) = toc;
end

%% Choose best set of control points
[score, best] = min(scores);
x_fin = xs(:,best);
x_flag = flags(:,best);

%% Plot Results
% x_fin(1:n) = zeros(n,1);
[opt_var, side_right, side_left, A_err, flex_oth, min_dist] = curve_func(x_fin,vars);
% serp_des;
% [pattern_mm, inner_mm, outer_mm] = create_geometry([side_left side_right],rad_out,rad_root,rad_tip,num_flex,step);

% figure()
% hold on
% plot(edge(:,1), edge(:,2));
% axis equal
% plot(flex_oth(:,1),flex_oth(:,2))
% xlabel("x (m)")
% ylabel("y (m)")

if 0 > 1
    %% Plot All Results
    figure();
    for i = 1:iterations
        [opt_var, edge, A_err, flex_oth] = curve_func(xs(:,i));
        serp_des;
        subplot(3,7,i)
        plot(edge(:,1), edge(:,2));
        axis equal
        hold on
        plot(flex_oth(:,1),flex_oth(:,2))
        if flags(i) < 0
            xlabel("INFEASIBLE")
        end
    end
end
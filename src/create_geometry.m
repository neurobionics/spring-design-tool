function [raw_mm,pattern_mm,wedge_mm,inner_mm,outer_mm,pins_rad,pins_num] = create_geometry(sides,rad_out,rad_root,rad_tip,num_flex,step,ball_rad,pins_num,pins_rad)

% This function uses geometry to add fillets at the root of each flexure,
% add a circular tip to the flexure, add fillets to the connect the
% circular tip, create the outer edge of the spring and pattern the flexure profile to generate the xyz
% coordinates of the entire spring.
    
    pin_szs = [1 1.5 2 2.5 3 4 5 6 8 10 12 14 16 18 20 25]/2*1e-3; % standard dowel pin radii
    rim_thick = rad_out - rad_root;
    if isempty(pins_rad)
        rough_guess = rim_thick/2;
        if rough_guess < min(pin_szs)
            pins_rad = min(pin_szs);
        elseif rough_guess > max(pin_szs)
            pins_rad = max(pin_szs);
        else
            pins_rad = interp1(pin_szs,pin_szs,(rad_out - rad_root)/2,'nearest');
        end
    end
    if isempty(pins_num)
        pins_num = num_flex;
    end
    rad_fs = [rim_thick/2 rim_thick/2]; % [m] radii at root [left right]
    rad_tf = ball_rad/2; % [m] tip fillet radius    
    step_small = step/2;

    for i = 1:2

        pattern = sides(:,2*i-1:2*i)';
        %% Find root fillets
        bad_fs = true;
        while bad_fs
            % Search section of edge
            j = 1;
            while norm(pattern(1:2,j)) > rad_root - 2*rad_fs(i)
                j = j + 1;
            end
            root_search = pattern(1:2,1:j);

            if pattern(1,1) >= 0
                lb = -pi/2;
                ub = atan2(root_search(2,1),root_search(1,1)) - pi/2;
            else
                lb = atan2(root_search(2,1),root_search(1,1)) - pi/2;
                ub = pi/2;
            end
            x0 = lb;
            options = optimoptions('fmincon','Display','off');
            x = fmincon(@(x)fillet_finder(x,root_search,rad_root,rad_fs(i),[]), x0, [], [], [], [], lb, ub,[],options);
            [~,index,fillet_center] = fillet_finder(x,root_search,rad_root,rad_fs(i),[]);
            if abs(atan2(fillet_center(2),fillet_center(1)) - pi/2) <= pi/num_flex
                bad_fs = false;
            else
                rad_fs(i) = rad_fs(i)*0.9;
            end
        end
            
        %% Find tip fillets
        % Search section of edge
        j = size(pattern,2);
        while norm(pattern(1:2,j)) < rad_tip + ball_rad + 2*rad_tf
            j = j - 1;
        end
        tip_search = pattern(1:2,j:end);
        tip_searchHR(2,:) = linspace(tip_search(2,1),tip_search(2,end),ceil((tip_search(2,1)-tip_search(2,end))/step_small));
        tip_searchHR(1,:) = interp1(tip_search(2,:),tip_search(1,:),tip_searchHR(2,:));
        tip_search = tip_searchHR;
        pattern = [pattern(1:2,1:j-1) tip_search];

        if pattern(1,1) >= 0
            lb = -pi/2;
            ub = atan2(tip_search(2,1),tip_search(1,1)) - pi/2;
        else
            lb = atan2(tip_search(2,1),tip_search(1,1)) - pi/2;
            ub = pi/2;
        end
        x0 = lb;
        options = optimoptions('fmincon','Display','off');
        xtip = fmincon(@(x)fillet_finder(x,tip_search,ball_rad,rad_tf,rad_tip), x0, [], [], [], [], lb, ub,[],options);
        [~,index_tip,tipfil_center] = fillet_finder(xtip,tip_search,ball_rad,rad_tf,rad_tip);    
        index_tip = j - 1 + index_tip;
        %% Trim

        % Flexure root
        pattern_new = pattern(:,index:index_tip)';

        % Fillet root
        fil_rim_ang = atan2(fillet_center(2),fillet_center(1));
        center_to_flex = pattern(:,index) - fillet_center';
        if pattern(1,1) >= 0    
            fil_flex_ang = atan2(center_to_flex(2),center_to_flex(1));
            if fil_flex_ang < 0
                fil_flex_ang = fil_flex_ang + 2*pi;
            end
        else
            fil_flex_ang = atan2(center_to_flex(2),center_to_flex(1));
        end
        res = ceil(rad_fs(i)*abs(fil_rim_ang - fil_flex_ang)/step);
        [fillet_x,fillet_y] = pol2cart(linspace(fil_flex_ang,fil_rim_ang,res),rad_fs(i));
        fillet = [fillet_x + fillet_center(1); fillet_y + fillet_center(2)]';

        % Tail
        if pattern(1,1) >= 0
            res = ceil(rad_root*abs(pi/2-pi/num_flex - fil_rim_ang)/step);
            [tail(:,1), tail(:,2)] = pol2cart(linspace(pi/2 - pi/num_flex,fil_rim_ang,res),rad_root);
        else
            res = ceil(rad_root*abs(pi/2+pi/num_flex - fil_rim_ang)/step);
            [tail(:,1), tail(:,2)] = pol2cart(linspace(pi/2 + pi/num_flex,fil_rim_ang,res),rad_root);
        end

        % Fillet tip
        tfcen_to_flex = pattern(:,index_tip) - tipfil_center';
        if pattern(1,1) >= 0    
            fil_tip_ang = atan2(tipfil_center(2)-rad_tip,tipfil_center(1))+pi;
            filtip_flex_ang = atan2(tfcen_to_flex(2),tfcen_to_flex(1));
            if filtip_flex_ang < 0
                filtip_flex_ang = filtip_flex_ang + 2*pi;
            end
        else
            fil_tip_ang = atan2(tipfil_center(2)-rad_tip,tipfil_center(1))-pi;
            filtip_flex_ang = atan2(tfcen_to_flex(2),tfcen_to_flex(1));
        end
        res = 2*ceil(rad_tf*abs(fil_tip_ang - filtip_flex_ang)/step_small);
        [fillet_tx,fillet_ty] = pol2cart(linspace(filtip_flex_ang,fil_tip_ang,res),rad_tf);
        fillet_tip = [fillet_tx + tipfil_center(1); fillet_ty + tipfil_center(2)]';

        % Circle tip
        fil_tip_ang = atan2(tipfil_center(2)-rad_tip,tipfil_center(1));
        if pattern(1,1) >= 0    
            res = 2*ceil(rad_tf*abs(fil_tip_ang + pi/2)/step_small);
            [ball_x,ball_y] = pol2cart(linspace(-pi/2,fil_tip_ang,res),ball_rad);
        else
            res = 2*ceil(rad_tf*abs(fil_tip_ang - 3*pi/2)/step_small);
            [ball_x,ball_y] = pol2cart(linspace(3*pi/2,fil_tip_ang,res),ball_rad);
        end
        ball_tip = [ball_x; ball_y + rad_tip]';    

        if i == 1
            pattern_new1 = [tail(1:end-1,:); flip(fillet); pattern_new(2:end,:); fillet_tip(2:end-1,:); flip(ball_tip)];
        else
            pattern_new2 = [tail(1:end-1,:); flip(fillet); pattern_new(2:end,:); fillet_tip(2:end-1,:); flip(ball_tip)];
        end
        clear tail pattern pattern_new fillet_tip fillet tail ball_tip tip_searchHR
    end

    pin_var = (2*rad_out^2 - pins_rad^2)/(2*rad_out);
    pin_ang = pi/2 - atan2(pin_var-rad_out,sqrt(rad_out^2 - pin_var^2));

    res = ceil(pins_rad*abs(2*pi - 2*pin_ang)/step);
    [pinhole_x, pinhole_y] = pol2cart(linspace(pi/2 - pin_ang,-3*pi/2 + pin_ang,res),pins_rad);
    pinhole = [pinhole_x; pinhole_y + rad_out]';

    pin_ang = pi/2 - atan2(pin_var,sqrt(rad_out^2 - pin_var^2));
    res = ceil(rad_out*abs(pi/pins_num - pin_ang)/step);
    [top_curve1(:,1), top_curve1(:,2)] = pol2cart(linspace(pi/2 - pi/pins_num,pi/2 - pin_ang,res),rad_out);

    [top_curve2(:,1), top_curve2(:,2)] = pol2cart(linspace(pi/2 + pin_ang,pi/2 + pi/pins_num,res),rad_out);
    outer_curve = [top_curve1(1:end-1,:); pinhole(2:end-1,:); top_curve2(2:end,:)];
    outer_curve = [outer_curve zeros(size(outer_curve,1),1)]';
    inner_curve = [pattern_new1(1:end-1,:); flip(pattern_new2)];
    inner_curve = [inner_curve zeros(size(inner_curve,1),1)]';

    raw = [sides(1:end-1,1:2); flip(sides(:,3:4))];
    raw = [raw zeros(size(raw,1),1)];
    pattern_piece = inner_curve;
    wedge = [outer_curve(:,end) inner_curve outer_curve];

    rotz = @(theta) [cos(theta) -sin(theta) 0; sin(theta) cos(theta) 0; 0 0 1];
    rot_in = rotz(-2*pi/num_flex);
    rot_out = rotz(2*pi/pins_num);


    inner_curve = inner_curve(:,1:end-1);
    outer_curve = outer_curve(:,1:end-1);
    pattern_inner = inner_curve;
    pattern_outer = outer_curve;

    for j = 1:num_flex-1
        sz = size(pattern_inner,2);
        for i = 1:size(inner_curve,2)
            pattern_inner(:,sz+i) = rot_in*pattern_inner(:,i+size(inner_curve,2)*(j-1));
        end
    end
    
    for j = 1:pins_num-1
        sz = size(pattern_outer,2);
        for i = 1:size(outer_curve,2)
            pattern_outer(:,sz+i) = rot_out*pattern_outer(:,i+size(outer_curve,2)*(j-1));
        end
    end

    pattern_inner = [pattern_inner(:,end) pattern_inner];
    pattern_outer = [pattern_outer(:,end) pattern_outer];

    %% Scale profiles to mm
    raw_mm = raw*1e3;
%     writematrix((raw_mm),'raw_mm.txt') % flex_uncut
    pattern_mm = pattern_piece'*1e3;
%     writematrix((pattern_mm),'pattern_mm.txt') % flex_uncut
    wedge_mm = wedge'*1e3;
%     writematrix((wedge_mm),'wedge_mm.txt') % flex_uncut
    inner_mm = pattern_inner'*1e3;
%     writematrix((inner_mm),'inner_mm.txt') % flex_uncut
    outer_mm = pattern_outer'*1e3;
%     writematrix((outer_mm),'outer_mm.txt') % flex_uncut

    %% Plot the spring profiles: uncomment this section if you'd like to see the plot after running the code
    figure()
    axis equal
    hold on
    plot(inner_mm(:,1), inner_mm(:,2));
    plot(outer_mm(:,1), outer_mm(:,2));
%     plot(wedge_mm(:,1), wedge_mm(:,2));
%     plot(pattern_mm(:,1), pattern_mm(:,2));
%     plot(raw_mm(:,1), raw_mm(:,2));
% 
    xlabel("x (mm)")
    ylabel("y (mm)")


    %% Visualization of solution space
    % x = linspace(lb,ub,300);
    % for i = 1:length(x)
    %     [fval(i),index] = fillet_finder(x(i),tip_search,ball_rad,rad_tf,rad_tip); 
    % end
    % figure()
    % plot(x,fval)
    function [fval,index,center] = fillet_finder(x,points,R,r,r_tip)

        if isempty(r_tip)
            center = [(R-r)*cos(pi/2+x) (R-r)*sin(pi/2+x)];
        else
            center = [(R+r)*cos(pi/2+x) (R+r)*sin(pi/2+x)+r_tip];
        end
        vecs = zeros(1,size(points,2));

        for k = 1:length(vecs)
            vecs(k) = norm([center(2) - points(2,k);center(1) - points(1,k)]);
        end
        [min_dist,index] = min(vecs);
        fval = abs(min_dist - r);
    end

end
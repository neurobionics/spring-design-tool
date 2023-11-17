function [R] = circumcenter(A,B,C)
    % Center and radius of the circumscribed circle for the triangle ABC
    %  A,B,C  3D coordinate vectors for the triangle corners
    %  R      Radius
    %  M      3D coordinate vector for the center
    %  k      Vector of length 1/R in the direction from A towards M
    %         (Curvature vector)
    D = cross(B-A,C-A);
    b = norm(A-C);
    c = norm(A-B);
    a = norm(B-C);     % slightly faster if only R is required
    R = a*b*c/2/norm(D);

end
function circle = circle_mask(radius)

    x = -radius:radius;
    [xx, yy] = meshgrid(x,x);
    circle = zeros(size(xx));
    circle((xx.^2 + yy.^2) < radius^2) = 1;  % create circle mask
    circle = circle(2:end-1, 2:end-1);    % trim edges

end
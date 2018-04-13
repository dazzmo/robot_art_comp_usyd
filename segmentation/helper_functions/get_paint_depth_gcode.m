function gcode = get_paint_depth_gcode(r)

    global mm_per_pixel;
    global pen_touching;    % min value
    global pen_down;        % max value
    global max_pen_width;   % max value in mm
    global decimal_places
    
    z = r*mm_per_pixel;
    if z >= max_pen_width
        pen_depth = pen_down;
    else
        pen_depth = (z/max_pen_width)*(sind(pen_down) - sind(pen_touching)) + sind(pen_touching);
        pen_depth = asind(pen_depth);
    end
            
    gcode = strcat('M3 S', num2str(pen_depth, decimal_places), '\n');
    
end
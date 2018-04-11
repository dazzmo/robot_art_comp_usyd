function gcode = get_paint_gcode(x, y, z)

    global mm_per_pixel;
    global pen_up;          % min value
    global pen_down;        % max value
    global max_pen_width;   % max value in mm
    
    z = z*mm_per_pixel;
    if z >= max_pen_width
        pen_depth = pen_down;
    else
        pen_depth = (z/max_pen_width)*(pen_down - pen_up) + pen_up;
    end
        
    gcode_z = strcat('M3 S', num2str(pen_depth), '\n');
    gcode_xy = strcat('G1 X', num2str(x*mm_per_pixel), ' Y', num2str(y*mm_per_pixel), '\n');
    gcode = strcat(gcode_z, gcode_xy);
    
end
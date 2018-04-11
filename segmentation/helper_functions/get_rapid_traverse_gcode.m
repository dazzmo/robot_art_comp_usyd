function gcode = get_rapid_traverse_gcode(x, y)

    global mm_per_pixel;
    gcode = strcat('G0 X', num2str(x*mm_per_pixel), ' Y', num2str(y*mm_per_pixel), '\n');

end
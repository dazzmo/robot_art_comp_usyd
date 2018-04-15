function ink_str = get_ink_gcode(ink)

    global pen_up_str;
    global pen_down_str;
    
    ink_str = strcat(pen_up_str, 'G0 X', num2str(ink.x), ' Y', num2str(ink.y), '   (dip ink)\n', pen_down_str, pen_up_str);

end
function gcode = get_rapid_traverse_gcode(x, y)

    global decimal_places

    [y_plotter, x_plotter] = convert_image_to_plotter_range(y, x);
    gcode = strcat('G0 X', num2str(x_plotter, decimal_places), ' Y', num2str(y_plotter, decimal_places), '\n');

end
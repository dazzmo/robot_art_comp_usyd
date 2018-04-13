function [y_plotter, x_plotter] = convert_image_to_plotter_range(y_image, x_image)
    
    global n_rows;  % y value
    global n_cols;  % x value
    global min_x
    global max_x
    global min_y
    global max_y

    x_plotter = (x_image/n_cols)*(max_x - min_x) + min_x;
    y_plotter = (y_image/n_rows)*(max_y - min_y) + min_y;

end
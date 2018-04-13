function [y_plotter, x_plotter] = convert_image_to_plotter_range(y_image, x_image)
    
    global n_rows;  % y value
    global n_cols;  % x value
    global new_min_x
    global new_max_x
    global new_min_y
    global new_max_y

    x_plotter = (x_image/n_cols)*(new_max_x - new_min_x) + new_min_x;
    y_plotter = (y_image/n_rows)*(new_max_y - new_min_y) + new_min_y;

end
function range_values = set_new_plotter_range(old_min_x, old_max_x, old_min_y, old_max_y)

    % new_max + new_min = old_max + old_min
    % new_max - new_min = (old_max - old_min)*(scaling factor)
    % new_max = (1/2)*(old_max + old_min + ((old_max - old_min)*(scaling factor)))
    global new_min_x
    global new_max_x
    global new_min_y
    global new_max_y    
    global n_rows;          % y
    global n_cols;          % x
    global mm_per_pixel;

        
    % find maximum scaling factor, which is the minimum scaling factor
    % along any of x or y direction
    scale_img = n_rows/n_cols;
    scale_plotter = (old_max_y - old_min_y)/(old_max_x - old_min_x);
    % scale = min([scale_x, scale_y]);

    if (scale_plotter > scale_img)
        % y-values need to be changed
        scale = (old_max_x - old_min_x)/n_cols;
        new_max_y = (old_max_y + old_min_y + n_rows*scale)/2;    % new_max_y
        new_min_y = old_max_y + old_min_y - new_max_y;                              % new_min_y
        new_min_x = old_min_x;
        new_max_x = old_max_x;        
    elseif (scale_plotter < scale_img)
        % x-values need to be changed
        scale = (old_max_y - old_min_y)/n_rows;
        new_max_x = (old_max_x + old_min_x + n_cols*scale)/2;   % new_max_x
        new_min_x = old_max_x + old_min_x - new_max_x;                        % new_min_x
        new_min_y = old_min_y;
        new_max_y = old_max_y;
    else
        new_min_x = old_min_x;
        new_max_x = old_max_x;
        new_min_y = old_min_y;
        new_max_y = old_max_y;
        scale = 1;
    end
    
    mm_per_pixel = scale;

    
end
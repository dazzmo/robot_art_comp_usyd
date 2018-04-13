% find the widest endpoint, which is the starting point of the
% brushstroke
endpoints = find(stroke.endpoints);
widest_endpoint = max(max(stroke.endpoints.*euclidean));
for kk = endpoints'
    if euclidean(kk) == widest_endpoint
        widest_endpoint_index = kk;
        break;      % found the widest endpoint index
    end
end

stroke_order = bwdistgeodesic(stroke.skeleton, widest_endpoint_index);

% pen down for starting point of the brushstroke
[stroke_y, stroke_x] = find(stroke_order == 0);     % first stroke
fprintf(gcode, get_rapid_traverse_gcode(stroke_x, stroke_y));   % move to first stroke

if max(max(stroke_order)) == Inf
    disp('inf stroke');
end

pixels_in_stroke = max(max(stroke_order));

% first iteration
[stroke_y, stroke_x] = find(stroke_order == 1);
last_z = euclidean(stroke_y, stroke_x);
fprintf(gcode, get_paint_depth_gcode(last_z));


% loop through all pixel points
for kk = 2:(pixels_in_stroke-1)
    [stroke_y, stroke_x] = find(stroke_order == kk);
%         if ~mod(jj, speed_multiplier)
%             new_z = euclidean(stroke_y, stroke_x);
%             fprintf(gcode, get_paint_depth_gcode(0.9*last_z + 0.1*new_z));
%             last_z = new_z;
%         end
    fprintf(gcode, get_paint_gcode(stroke_x, stroke_y));  % paint the next pixel
end

% last iteration
[stroke_y, stroke_x] = find(stroke_order == pixels_in_stroke);
%     new_z = euclidean(stroke_y, stroke_x);
%     fprintf(gcode, get_paint_depth_gcode(0.9*last_z + 0.1*new_z));
fprintf(gcode, get_paint_gcode(stroke_x, stroke_y));

if pixels_in_stroke > min_paint_refill
    fprintf(gcode, get_ink_gcode(ink(current_ink)));
else
    fprintf(gcode, pen_up_str);
end
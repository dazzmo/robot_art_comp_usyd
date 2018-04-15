gcode = fopen(gcode_file, 'w');
fprintf(gcode, rapid_feed_rate_str);
fprintf(gcode, paint_feed_rate_str);
fprintf(gcode, 'G90\n');
fprintf(gcode, pen_up_str);
fprintf(gcode, ink(current_ink).gcode);
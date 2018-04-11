%% image processing constants

global d_threshold;
d_threshold = 3;

branch_threshold = 6;
area_threshold = 6;

%% machine constants

min_x = 0;
max_x = 220;
min_y = 0;
max_y = 130;

global max_pen_width
max_pen_width = 5;          % in mm
global pen_up;
pen_up = 10;
global pen_down;
pen_down = 30;

rapid_feed_rate = 2000;

n_ink_pots = 4;
ink.x = 20;
ink.y = 30;
ink_y_offset = 20;

global mm_per_pixel;
mm_per_pixel = 0.2;         % scale image down


%% gcode strings

global pen_up_str;
pen_up_str = strcat('M3 S', num2str(pen_up), '\n');

global pen_down_str;
pen_down_str = strcat('M3 S', num2str(pen_down), '\n');

rapid_feed_rate_str = strcat('G0 F', num2str(rapid_feed_rate), '\n');

ink.gcode = get_ink_gcode(ink);
ink(1:n_ink_pots) = struct(ink);
for ii = 2:n_ink_pots
    ink(ii).x = ink(1).x;
    ink(ii).y = ink(ii-1).y + ink_y_offset;
    ink(ii).gcode = get_ink_gcode(ink(ii));
end
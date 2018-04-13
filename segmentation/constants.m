%% image processing constants

branch_threshold = 7;
area_threshold = 5;

%% machine constants

global new_min_x
global new_max_x
global new_min_y
global new_max_y
old_min_x = 30;
old_max_x = 230;
old_min_y = 0;
old_max_y = 140;

global max_pen_width
max_pen_width = 5;          % in mm
global pen_up;
pen_up = 5;
global pen_touching;        % pen is just touching the page
pen_touching = 15;
global pen_down;
pen_down = 35;

rapid_feed_rate = 1000;
paint_feed_rate = 500;

n_ink_pots = 4;
ink.x = 0;
ink.y = 70;
ink_y_offset = 0;

global mm_per_pixel;
% mm_per_pixel = 0.15;         % scale image down


%% gcode strings

global decimal_places
decimal_places = '%.1f';

speed_multiplier = 6;      % only look at one in every 10 pixels so as to speed the gcode up

min_paint_refill = 40;

global pen_up_str;
pen_up_str = strcat('M3 S', num2str(pen_up), '\n');

global pen_down_str;
pen_down_str = strcat('M3 S', num2str(pen_down), '\n');

rapid_feed_rate_str = strcat('G0 F', num2str(rapid_feed_rate), '\n');
paint_feed_rate_str = strcat('G1 F', num2str(paint_feed_rate), '\n');

ink.gcode = get_ink_gcode(ink);
ink(1:n_ink_pots) = struct(ink);
for ii = 2:n_ink_pots
    ink(ii).x = ink(1).x;
    ink(ii).y = ink(ii-1).y + ink_y_offset;
    ink(ii).gcode = get_ink_gcode(ink(ii));
end
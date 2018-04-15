%% image processing constants

branch_threshold = 5;
area_threshold = 8;

SE_light = strel('disk',5);
SE_medium = strel('disk',2);

%% machine constants

global plotter_blue

if plotter_blue == true
    old_min_x = 0;
    old_max_x = 200;
    old_min_y = 0;
    old_max_y = 140;    
else
    old_min_x = 30;
    old_max_x = 230;
    old_min_y = 0;
    old_max_y = 140;
end

global pen_up
global pen_touching;        % pen is just touching the page
global pen_down
if plotter_blue == true
    pen_up = 5;
    pen_touching = 20;
    pen_down = 30; 
%     pen_down = 25;
else
    pen_up = 5;
    pen_touching = 15;
    pen_down = 35;
end

global max_pen_width
max_pen_width = 8;          % in mm

rapid_feed_rate = 500;
paint_feed_rate = 500;

if plotter_blue == true
    n_ink_pots = 4;
    ink.x = 240;
    ink.y = 45;
    ink_y_offset = 25;
else
    n_ink_pots = 4;
    ink.x = 0;
    ink.y = 70;
    ink_y_offset = 0;
end

%% gcode strings

global decimal_places
decimal_places = '%.1f';

speed_multiplier = 6;      % only look at one in every 10 pixels so as to speed the gcode up

min_paint_refill = 30;

global pen_up_str;
pen_up_str = strcat('M3 S', num2str(pen_up), '\n');

global pen_down_str;
pen_down_str = strcat('M3 S', num2str(pen_down), '\n');

global pen_touching_str;
pen_touching_str = strcat('M3 S', num2str(pen_touching), '\n');

rapid_feed_rate_str = strcat('G0 F', num2str(rapid_feed_rate), '\n');
paint_feed_rate_str = strcat('G1 F', num2str(paint_feed_rate), '\n');

ink.gcode = get_ink_gcode(ink);
ink(1:n_ink_pots) = struct(ink);
for ii = 2:n_ink_pots
    ink(ii).x = ink(1).x;
    ink(ii).y = ink(ii-1).y + ink_y_offset;
    ink(ii).gcode = get_ink_gcode(ink(ii));
end

%% original input image

% file_in = 'flower.jpg';
% file_in = 'fire.jpg';
% file_in = 'woman.jpg';
% file_in = 'cat.jpg';
% file_in = 'sumi-e-bonsai-one-lori-grimmett.jpg';
% file_in = 'bamboo2.jpg';
% file_in = 'tree1.jpg';
% file_in = 'dragon.jpg';
% file_in = 'dragon2.jpg';
file_in = 'dog2.jpg';
file_out = 'result9.png';

original_img = imread(file_in);
if plotter_blue == true
    original_img = flip(original_img,1);
else
    original_img = flip(original_img,2);
end
global n_rows
global n_cols
n_rows = size(original_img, 1);      % y-values
n_cols = size(original_img, 2);      % x-values
if n_rows > n_cols
    original_img = imrotate(original_img, 90);
    n_rows = size(original_img, 1);      % y-values
    n_cols = size(original_img, 2);      % x-values
end
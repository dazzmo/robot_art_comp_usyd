%% robot art comp
%
% https://au.mathworks.com/matlabcentral/answers/88284-remove-the-spurious-edge-of-skeleton#answer_97852
% https://au.mathworks.com/matlabcentral/answers/137424-total-area-of-a-region-of-binary-image

clearvars;
close all;

addpath('./images/', './helper_functions/');

plotting = true;
saving = false;

global plotter_blue
plotter_blue = true;
constants;

original_img = imgaussfilt(original_img,0.8);             % apply Gaussian filter

set_new_plotter_range(old_min_x, old_max_x, old_min_y, old_max_y);

blank_image = false(n_rows, n_cols);

%% lightest

gcode_file = 'output_light.txt';
current_ink = 3;
start_gcode;

img = rgb2gray(original_img);           % convert to grayscale
mask = blank_image;
mask(img < 100) = 1;
mask = imdilate(mask, SE_light);
img(mask) = 255;
BW = imbinarize(img);              % convert to black and white

main2_lol;

%% medium

gcode_file = 'output_medium.txt';
current_ink = 2;
start_gcode;

img = rgb2gray(original_img);           % convert to grayscale
mask = blank_image;
mask(img < 35) = 1;
mask(img > 110) = 1;
mask = imdilate(mask, SE_medium);
img(mask) = 255;
BW = imbinarize(img);              % convert to black and white
imshow(img);

main2_lol;

%% darkest

current_ink = 1;
gcode_file = 'output_dark.txt';
start_gcode;

img = rgb2gray(original_img);           % convert to grayscale
mask = blank_image;
mask(img > 40) = 1;
img(mask) = 255;
imshow(img);

BW = imbinarize(img);              % convert to black and white
imshow(BW);

main2_lol;
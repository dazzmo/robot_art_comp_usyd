%% robot art comp

clearvars;
close all;

addpath('./images/', './helper_functions/');
constants;

plotting = true;
saving = false;

%% original image

file_in = 'flower.jpg';
% file_in = 'fire.jpg';
% file_in = 'bird.png';
% file_in = 'koi.jpg';
file_out = 'result5.png';
img = imread(file_in);
n_rows = size(img, 1);
n_cols = size(img, 2);

%% process the image

img = imgaussfilt(img);         % apply Gaussian filter
% BW = im2bw(img, 0.9);           % convert to black and white image
img = rgb2gray(img);            % convert to grayscale
BW = imbinarize(img);           % convert to black and white
BW = bwmorph(BW, 'spur');       % remove random pixels
BW = imfill(1- BW, 'holes');       % fill missing pixels
BW = 1 - BW;
D = bwdist(BW);                 % Euclidean distance to nearest white point
% D = imgaussfilt(D);            	% apply Gaussian filter
[r_maxima, c_maxima] = get_local_maxima_2d(D);  % get the stroke centres
img_outline = get_image_outline(BW, true);

%% find regions within the image

img_regions = zeros(n_rows, n_cols);            % binary image that stores the different regions
CC = bwconncomp(1 - BW);                        % compute the regions
for ii = 1:CC.NumObjects
    img_regions(CC.PixelIdxList{ii}) = ii;      % label the region
    CC.Strokes_r{ii} = [];
    CC.Strokes_c{ii} = [];
    CC.Strokes_image{ii} = zeros(n_rows, n_cols);
end

%% organise the stroke centres by region

for ii = 1:length(r_maxima)
    region = img_regions(r_maxima(ii), c_maxima(ii));
    CC.Strokes_r{region} = [CC.Strokes_r{region}; r_maxima(ii)];
    CC.Strokes_c{region} = [CC.Strokes_c{region}; c_maxima(ii)];
    CC.Strokes_image{region}(r_maxima(ii), c_maxima(ii)) = true;
end

%% get endpoints for each stroke

for ii = 1:CC.NumObjects
    
    CC.Strokes_image{ii} = bwmorph(CC.Strokes_image{ii}, 'bridge');         % connect regions separated by one pixel
    CC.Strokes_skeleton{ii} = bwmorph(CC.Strokes_image{ii}, 'skel', Inf);   % get skeleton
    CC.Strokes_endpoints{ii} = bwmorph(CC.Strokes_skeleton{ii}, 'endpoints', Inf);  % get endpoints of skeleton
    CC.Strokes_endpoints{ii} = join_close_endpoints(CC.Strokes_skeleton{ii}, CC.Strokes_endpoints{ii});
    
end

%% Bezier curve fit with the new endpoints

%% plots

if plotting
    
    figure;

    subplot(1, 2, 1);
    imagesc(img_regions);
    axis equal;
    hold on;
    
    subplot(1, 2, 2);
    imagesc(img_outline);
    axis equal;
    hold on;
    for ii = 1:CC.NumObjects
        scatter(CC.Strokes_c{ii}, CC.Strokes_r{ii}, '.');
    end

    if saving
        saveas(gcf, file_out);
    end
    
end

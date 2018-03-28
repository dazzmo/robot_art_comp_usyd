%% robot art comp
%
% circle method for finding strokes

addpath('./images/', './helper_functions/');

clearvars;
close all;

plotting = true;
saving = false;

%% original image

file_in = 'sumi-e-koi-one-lori-grimmett.jpg';
file_out = 'result3.png';
img = imread(file_in);

%% process the image

img = imgaussfilt(img);
BW = im2bw(img, 0.9);       % convert to black and white image
% img = img < 1;              % convert to boolean array
D = bwdist(BW);             % Euclidean distance to nearest white point
D = imgaussfilt(D, 2);      % apply Gaussian filter

RGB = repmat(rescale(D), [1 1 3]);

img_outlint = get_image_outline(BW);

%% plots

if plotting
    
    figure;
    subplot(1, 3, 1);
    imagesc(BW);
    axis equal;

    subplot(1, 3, 2);
    imagesc(D);
    axis equal;

    subplot(1, 3, 3);
%     imagesc(D);
%     hold on;
    imagesc(img_outline);
    axis equal;
    grid on;
    
    if saving
        saveas(gcf, file_out);
    end
    
end

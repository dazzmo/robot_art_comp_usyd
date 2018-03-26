%% robot art comp
%
% circle method for finding strokes

addpath('./images/');

clearvars;
close all;

plotting = true;

%% original image

img = imread('sumi-e-bonsai-one-lori-grimmett.jpg');
img = imgaussfilt(img);

%% process the image

BW = im2bw(img, 0.9);       % convert to black and white image
% img = img < 1;              % convert to boolean array
D = bwdist(BW);             % Euclidean distance to nearest white point
D = imgaussfilt(D, 2);      % apply Gaussian filter

%% get strokes

[lmaxima,indices] = localmax(D);            % find a line of local maximas
[rows, cols] = ind2sub(size(D),indices);
rows = size(D, 2) - rows;

%% plots

if plotting
    
    figure;
    subplot(1, 3, 1);
    imagesc(img);
    axis equal;

    subplot(1, 3, 2);
    imagesc(D);
    axis equal;

    subplot(1, 3, 3);
    scatter(cols, rows);
    axis equal;
    grid on;
    
end

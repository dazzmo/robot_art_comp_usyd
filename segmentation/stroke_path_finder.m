%% robot art comp
%
% circle method for finding strokes

addpath('./images/');

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
D = imgaussfilt(D, 3);      % apply Gaussian filter

RGB = repmat(rescale(D), [1 1 3]);

%% get strokes

[~,indices] = localmax(D);            % find local maximas of each row
[rows1, cols1] = ind2sub(size(D),indices);

[~, indices_transpose] = localmax(transpose(D));
[cols2, rows2] = ind2sub(size(transpose(D)),indices_transpose);

cols = [cols1; cols2];
rows = [rows1; rows2];

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
    imagesc(D);
    hold on;
    scatter(cols, rows, '.r');
    axis equal;
    grid on;
    
    if saving
        saveas(gcf, file_out);
    end
    
end

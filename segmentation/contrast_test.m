clearvars;
close all;

addpath('./images/', './helper_functions/');
constants;

plotting = true;
saving = true;

%% original image

% file_in = 'flower.jpg';
% file_in = 'fire.jpg';
% file_in = 'bird.png';
file_in = 'koi.jpg';
% file_in = 'sumi-e-bonsai-one-lori-grimmett.jpg';
file_out = 'result7.png';
img = imread(file_in);
% n_rows = size(img, 1);
% n_cols = size(img, 2);
% blank_image = false(n_rows, n_cols);

img = rgb2gray(img);            % convert to grayscale
histogram = imhist(img);

%% get grayscale histogram of image


%% adjust contrast into 4 images

% contrast = [0, 1/4, 1/2, 3/4; 1/4, 1/2, 3/4, 1];
% J = cell(4, 1);
% 
% for ii = 1:4
%     J{ii} = imadjust(img, contrast(:,ii), [0,1]);
%     imshow(J{ii});
%     pause;
% end
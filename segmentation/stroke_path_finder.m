%% robot art comp
%
% circle method for finding strokes

addpath('./images/');

clearvars;
close all;

%% original image

img = imread('fire.jpg');
figure;
subplot(1, 3, 1);
imagesc(img);
axis equal;

%% process the image

img = im2bw(img, 0.5);      % convert to black and white image
% img = img < 1;              % convert to boolean array
D = bwdist(img);            % Euclidean distance to nearest white point
D = imgaussfilt(D);         % apply Gaussian filter

%% get strokes

[lmaxima,indices] = localmax(D);            % find a line of local maximas
[rows, cols] = ind2sub(size(D),indices);
rows = size(D,2) - rows;

%% more plots

subplot(1, 3, 2);
imagesc(D);
axis equal;

subplot(1, 3, 3);
scatter(cols, rows);
axis equal;
grid on;

%% old stuff - gonna commit it now and delete later so we at least have a copy on git

% stroke = imregionalmax(D, 4);
% 
% figure;
% spy(sparse(stroke));

% [y_ai, x_ai] = find(img);          % get array indices of logical 1s
% img_outline = zeros(size(img,1), size(img,2)); % stores the outline only

% for ii = 1:length(y_ai)
%     xx = x_ai(ii);
%     yy = y_ai(ii);
%     if (xx == 1) || (yy == 1) || (xx == size(img, 2)) || (yy == size(img, 1))
%         continue
%     end
%     if ((~img(yy, xx+1)) || (~img(yy, xx-1)) || (~img(yy+1, xx)) || (~img(yy-1, xx)))
%         img_outline(yy,xx) = 1;
%     end
% end
% 
% img_fill = img - img_outline;

% figure;
% spy(sparse(img));
% figure;
% spy(sparse(img_outline));
% figure;
% spy(sparse(img_fill));

% circle = circle_mask(10);

%% robot art comp

clearvars;
close all;

addpath('./images/', './helper_functions/');
constants;

plotting = false;
saving = false;

%% original image

% file_in = 'flower.jpg';
file_in = 'fire.jpg';
% file_in = 'bird.png';
% file_in = 'koi.jpg';
file_out = 'result5.png';
img = imread(file_in);
n_rows = size(img, 1);
n_cols = size(img, 2);
blank_image = false(n_rows, n_cols);

%% process the image

img = imgaussfilt(img);         % apply Gaussian filter
img = rgb2gray(img);            % convert to grayscale
BW = imbinarize(img);           % convert to black and white
BW = bwmorph(BW, 'spur');       % remove random pixels
BW = imfill(1- BW, 'holes');    % fill missing pixels
BW = 1 - BW;

%% find regions within the image

regions = bwconncomp(1 - BW);
strokes.image = blank_image;
strokes.outline = blank_image;
strokes.skeleton = blank_image;
strokes.branchpoints = blank_image;
strokes.endpoints = blank_image;
strokes.len_shortest_branch = 0;
strokes(1:regions.NumObjects, 1) = struct(strokes);

for ii = 1:size(strokes, 1)
    
    strokes(ii).image = extract_labelled_region(blank_image, regions.PixelIdxList{ii});   % extract only the current region
    strokes(ii).outline = bwmorph(strokes(ii).image, 'remove');                 % get the outline of the shape
    strokes(ii).skeleton = bwmorph(strokes(ii).image, 'skel', Inf);             % skeletonise the outline
    
    strokes(ii) = get_shortest_branch(strokes(ii));
    
    % remove branches that are too short
%     while d_shortest < branch_threshold
%         
%     end
    
%     for jj = 1:numel(end_x)
%         D = bwdistgeodesic(strokes.skeleton{ii}, end_x(jj), end_y(jj));
%         distanceToBranchPt = min(D(branch_idx));
%         Dmask(D < distanceToBranchPt) =true;
%     end
%     skelD = strokes.skeleton{ii} - Dmask;
%     imagesc(skelD);
%     pause;

end

%% plots

if plotting
    
    figure;

    subplot(1, 2, 1);
    imagesc(BW);
    axis equal;
    hold on;
    
    subplot(1, 2, 2);
    for ii = 1:strokes.NumObjects
        imagesc(strokes.skeleton{ii});
        axis equal;
        pause;
    end

    if saving
        saveas(gcf, file_out);
    end
    
end

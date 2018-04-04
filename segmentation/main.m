%% robot art comp
%
% https://au.mathworks.com/matlabcentral/answers/88284-remove-the-spurious-edge-of-skeleton#answer_97852
% https://au.mathworks.com/matlabcentral/answers/137424-total-area-of-a-region-of-binary-image

clearvars;
close all;

addpath('./images/', './helper_functions/');
constants;

plotting = true;
saving = false;

%% original image

% file_in = 'flower.jpg';
% file_in = 'fire.jpg';
% file_in = 'bird.png';
% file_in = 'koi.jpg';
file_in = 'sumi-e-bonsai-one-lori-grimmett.jpg';
file_out = 'result9.png';
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
imshow(BW);

%% find regions within the image

regions = bwconncomp(BW);
strokes.image = blank_image;            
strokes.outline = blank_image;
strokes.skeleton = blank_image;
strokes.branchpoints = blank_image;
strokes.endpoints = blank_image;
strokes.len_shortest_branch = 0;
strokes(1:regions.NumObjects, 1) = struct(strokes);

skeleton_old = false(size(BW));
skeleton_new = false(size(BW));

branchpoints_x_old = [];
branchpoints_y_old = [];
branchpoints_x_new = [];
branchpoints_y_new = [];

endpoints_x_old = [];
endpoints_y_old = [];
endpoints_x_new = [];
endpoints_y_new = [];

for ii = 1:size(strokes, 1)
    
    strokes(ii).image = extract_labelled_region(blank_image, regions.PixelIdxList{ii});   % extract only the current region
    strokes(ii).outline = bwmorph(strokes(ii).image, 'remove');                 % get the outline of the shape
    
    % skeleton
    strokes(ii).skeleton = bwmorph(strokes(ii).image, 'skel', Inf);             % skeletonise the outline
    if numel(find(strokes(ii).skeleton)) < area_threshold                       % skip strokes that are too short
        continue
    end
    skeleton_old = skeleton_old + strokes(ii).skeleton;
    
    % branchpoints
    strokes(ii).branchpoints = bwmorph(strokes(ii).skeleton, 'branchpoints');
    [temp_y, temp_x] = find(strokes(ii).branchpoints);
    branchpoints_y_old = [branchpoints_y_old; temp_y];
    branchpoints_x_old = [branchpoints_x_old; temp_x];
    
    % endpoints
    strokes(ii).endpoints = bwmorph(strokes(ii).skeleton, 'endpoints');
    [temp_y, temp_x] = find(strokes(ii).endpoints);
    endpoints_y_old = [endpoints_y_old; temp_y];
    endpoints_x_old = [endpoints_x_old; temp_x];
    
    % remove branches that are too short
    strokes(ii).len_shortest_branch = get_shortest_branch(strokes(ii));
    while strokes(ii).len_shortest_branch < branch_threshold
        strokes(ii) = remove_shortest_branch(strokes(ii));
    end
    
    % store everything to be plotted
    skeleton_new = skeleton_new + strokes(ii).skeleton;
    [temp_y, temp_x] = find(strokes(ii).branchpoints);
    branchpoints_y_new = [branchpoints_y_new; temp_y];
    branchpoints_x_new = [branchpoints_x_new; temp_x];
    [temp_y, temp_x] = find(strokes(ii).endpoints);
    endpoints_y_new = [endpoints_y_new; temp_y];
    endpoints_x_new = [endpoints_x_new; temp_x];

end

%% plots

if plotting
    
    figure;
    
    subplot(1, 3, 1);
    imshow(img);
    title('Original image');
%     axis equal;

    % without pruning branches
    subplot(1, 3, 2);
    imshow(skeleton_old);
    hold on;
    scatter(branchpoints_x_old, branchpoints_y_old, 'r*');
    scatter(endpoints_x_old, endpoints_y_old, 'oc');
    title('Before pruning branches');
    legend('branchpoints', 'endpoints');
    
    subplot(1, 3, 3);
    imshow(skeleton_new);
    hold on;
    scatter(branchpoints_x_new, branchpoints_y_new, 'r*');
    scatter(endpoints_x_new, endpoints_y_new, 'oc');
    title('After pruning branches');
    legend('branchpoints', 'endpoints');
    
    if saving
        saveas(gcf, file_out);
    end
    
end
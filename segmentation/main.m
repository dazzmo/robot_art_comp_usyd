%% robot art comp
%
% https://au.mathworks.com/matlabcentral/answers/88284-remove-the-spurious-edge-of-skeleton#answer_97852
% https://au.mathworks.com/matlabcentral/answers/137424-total-area-of-a-region-of-binary-image

clearvars;
close all;

addpath('./images/', './helper_functions/');

plotting = true;
saving = false;

plotter_blue = true;
constants;

%% original input image

% file_in = 'flower.jpg';
% file_in = 'fire.jpg';
% file_in = 'bird.png';
% file_in = 'koi.jpg';
file_in = 'cat.jpg';
% file_in = 'sumi-e-bonsai-one-lori-grimmett.jpg';
file_out = 'result9.png';

img = imread(file_in);
if plotter_blue == true
    img = flip(img,1);
else
    img = flip(img,2);
end
global n_rows
global n_cols
n_rows = size(img, 1);      % y-values
n_cols = size(img, 2);      % x-values
if n_rows > n_cols
    img = imrotate(img, 90);
    n_rows = size(img, 1);      % y-values
    n_cols = size(img, 2);      % x-values
end

set_new_plotter_range(old_min_x, old_max_x, old_min_y, old_max_y);

blank_image = false(n_rows, n_cols);

%% gcode

gcode_file = 'output.txt';
gcode = fopen(gcode_file, 'w');
fprintf(gcode, rapid_feed_rate_str);
fprintf(gcode, paint_feed_rate_str);
fprintf(gcode, 'G90\n');
fprintf(gcode, pen_up_str);
fprintf(gcode, ink(4).gcode);

%% process the image

img = imgaussfilt(img);                 % apply Gaussian filter
img = rgb2gray(img);                    % convert to grayscale
BW = imbinarize(img);                   % convert to black and white
BW = bwmorph(BW, 'spur');               % remove random pixels
BW = imfill(1-BW, 'holes');             % fill missing pixels
euclidean = bwdist(1-BW);               % Euclidean distance to nearest white point
euclidean = imgaussfilt(euclidean, 2);  % apply Gaussian filter
% outline = bwmorph(BW, 'remove');        % get the outline of the shape

%% find regions within the image

regions = bwconncomp(BW);

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

for ii = 1:regions.NumObjects
    
    % get region outline
    stroke.image = extract_labelled_region(blank_image, regions.PixelIdxList{ii});   % extract only the current region
    stroke.outline = bwmorph(stroke.image, 'remove');              
    
    % skeleton
    stroke.skeleton = bwmorph(stroke.image, 'skel', Inf);             % skeletonise the outline
    if numel(find(stroke.skeleton)) < area_threshold                  % skip strokes that are too short
        continue
    end
    skeleton_old = skeleton_old + stroke.skeleton;
    
    % branchpoints before pruning
    stroke.branchpoints = bwmorph(stroke.skeleton, 'branchpoints');
    [temp_y, temp_x] = find(stroke.branchpoints);
    branchpoints_y_old = [branchpoints_y_old; temp_y];
    branchpoints_x_old = [branchpoints_x_old; temp_x];
    
    % endpoints before pruning
    stroke.endpoints = bwmorph(stroke.skeleton, 'endpoints');
    [temp_y, temp_x] = find(stroke.endpoints);
    endpoints_y_old = [endpoints_y_old; temp_y];
    endpoints_x_old = [endpoints_x_old; temp_x];
    
    % remove branches that are too short
    stroke.len_shortest_branch = get_shortest_branch(stroke);
    while stroke.len_shortest_branch < branch_threshold
        stroke = remove_shortest_branch(stroke);
    end
        
    % skip strokes that are too short
    if numel(find(stroke.skeleton)) < area_threshold
        continue
    end
        
    % get rid of spurious regions
    current_stroke = bwconncomp(stroke.skeleton);
    stroke.skeleton = blank_image;
    longest_skeleton = 0;
    for jj = 1:current_stroke.NumObjects
        if length(current_stroke.PixelIdxList{jj}) > longest_skeleton
            longest_skeleton = length(current_stroke.PixelIdxList{jj});
            skeleton_temp = extract_labelled_region(blank_image, current_stroke.PixelIdxList{jj});
        else
            continue;
        end
    end
    stroke.skeleton = logical(skeleton_temp);
    stroke.branchpoints = bwmorph(stroke.skeleton, 'branchpoints');
    stroke.endpoints = bwmorph(stroke.skeleton, 'endpoints');
            
    % skeleton after pruning branches
    skeleton_new = skeleton_new + stroke.skeleton;
    [temp_y, temp_x] = find(stroke.branchpoints);
    branchpoints_y_new = [branchpoints_y_new; temp_y];
    branchpoints_x_new = [branchpoints_x_new; temp_x];
    [temp_y, temp_x] = find(stroke.endpoints);
    endpoints_y_new = [endpoints_y_new; temp_y];
    endpoints_x_new = [endpoints_x_new; temp_x];

    %% gcode
        
    % find the widest endpoint, which is the starting point of the
    % brushstroke
    endpoints = find(stroke.endpoints);
    widest_endpoint = max(max(stroke.endpoints.*euclidean));
    for kk = endpoints'
        if euclidean(kk) == widest_endpoint
            widest_endpoint_index = kk;
            break;      % found the widest endpoint index
        end
    end
    
    stroke_order = bwdistgeodesic(stroke.skeleton, widest_endpoint_index);

    % pen down for starting point of the brushstroke
    [stroke_y, stroke_x] = find(stroke_order == 0);     % first stroke
    fprintf(gcode, get_rapid_traverse_gcode(stroke_x, stroke_y));   % move to first stroke

    if max(max(stroke_order)) == Inf
        disp('inf stroke');
    end
    
    pixels_in_stroke = max(max(stroke_order));
    
    % first iteration
    [stroke_y, stroke_x] = find(stroke_order == jj);
    fprintf(gcode, get_paint_depth_gcode(euclidean(stroke_y, stroke_x)));
    
    % loop through all pixel points
    for jj = 2:(pixels_in_stroke-1)
        [stroke_y, stroke_x] = find(stroke_order == jj);
        fprintf(gcode, get_paint_gcode(stroke_x, stroke_y));  % paint the next pixel
        if ~mod(jj, speed_multiplier)
            fprintf(gcode, get_paint_depth_gcode(euclidean(stroke_y, stroke_x)));
        end
    end
    
    % last iteration
    [stroke_y, stroke_x] = find(stroke_order == pixels_in_stroke);
    fprintf(gcode, get_paint_depth_gcode(euclidean(stroke_y, stroke_x)));
    fprintf(gcode, get_paint_gcode(stroke_x, stroke_y));
    
    if pixels_in_stroke > min_paint_refill
        fprintf(gcode, get_ink_gcode(ink(4)));
    else
        fprintf(gcode, pen_up_str);
    end
end

%% end of gcode

fprintf(gcode, pen_up_str);     % better to be safe
fclose(gcode);

%% plots

if plotting
    
    figure;
    
    subplot(3, 1, 1);
    imshow(img);
    title('Original image');

    % without pruning branches
    subplot(3, 1, 2);
    imshow(skeleton_old);
    hold on;
    scatter(branchpoints_x_old, branchpoints_y_old, 'r*');
    scatter(endpoints_x_old, endpoints_y_old, 'oc');
    title('Before pruning branches');
    legend('branchpoints', 'endpoints');
    
    subplot(3, 1, 3);
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
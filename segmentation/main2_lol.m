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
    
    if find(stroke.branchpoints)
        while find(stroke.branchpoints)
            stroke.skeleton = logical(stroke.skeleton - stroke.branchpoints);
            stroke.branchpoints = bwmorph(stroke.skeleton, 'branchpoints');
        end
        
        skeleton_regions = bwconncomp(stroke.skeleton);        
        for jj = 1:skeleton_regions.NumObjects
            
            stroke.skeleton = extract_labelled_region(blank_image, skeleton_regions.PixelIdxList{jj});
            stroke.branchpoints = bwmorph(stroke.skeleton, 'branchpoints');
            stroke.endpoints = bwmorph(stroke.skeleton, 'endpoints');
            
            % skip strokes that are too short
            if numel(find(stroke.skeleton)) < area_threshold
                continue
            end
            
            % get rid of spurious regions
            current_stroke = bwconncomp(stroke.skeleton);
            stroke.skeleton = blank_image;
            longest_skeleton = 0;
            for kk = 1:current_stroke.NumObjects
                if length(current_stroke.PixelIdxList{kk}) > longest_skeleton
                    longest_skeleton = length(current_stroke.PixelIdxList{kk});
                    skeleton_temp = extract_labelled_region(blank_image, current_stroke.PixelIdxList{kk});
                else
                    continue;
                end
            end
            stroke.skeleton = logical(skeleton_temp);
            stroke.branchpoints = bwmorph(stroke.skeleton, 'branchpoints');
            stroke.endpoints = bwmorph(stroke.skeleton, 'endpoints');
            
            gcode_script;
            
        end
        
    else
        
        gcode_script;
    
    end
end

%% end of gcode

fprintf(gcode, pen_up_str);     % better to be safe
fprintf(gcode, ink(current_ink).gcode);
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
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
blank_img = zeros(n_rows, n_cols);

%% process the image

img = imgaussfilt(img);         % apply Gaussian filter
img = rgb2gray(img);            % convert to grayscale
BW = imbinarize(img);           % convert to black and white
BW = bwmorph(BW, 'spur');       % remove random pixels
BW = imfill(1- BW, 'holes');    % fill missing pixels
BW = 1 - BW;

%% find regions within the image

strokes = bwconncomp(1 - BW);
strokes.image = cell(strokes.NumObjects, 1);    % images with the strokes organised by region
strokes.outline = cell(strokes.NumObjects, 1);  % image region outlines
strokes.skeleton = cell(strokes.NumObjects, 1); % image region skeletons
strokes.branchpoints = cell(strokes.NumObjects, 1);	% image skeleton branchpoints
strokes.branches = cell(strokes.NumObjects, 1); % image skeleton branches

for ii = 1:strokes.NumObjects
    
    strokes.image{ii} = extract_labelled_region(blank_img, strokes.PixelIdxList{ii});   % extract only the current region
    strokes.outline{ii} = bwmorph(strokes.image{ii}, 'remove');                 % get the outline of the shape
    strokes.skeleton{ii} = bwmorph(strokes.image{ii}, 'skel', Inf);             % skeletonise the outline
    strokes.branchpoints{ii} = bwmorph(strokes.skeleton{ii}, 'branchpoints');   % get the branchpoints of the skeleton
    strokes.endpoints{ii} = bwmorph(strokes.skeleton{ii}, 'endpoints');         % get the endpoints of the skeleton
    
    % remove branches that are too short
    [end_y, end_x] = find(strokes.endpoints{ii});
    branch_idx = find(strokes.branchpoints{ii});
    Dmask = false(size(strokes.skeleton{ii}));
    for jj = 1:numel(end_x)
        D = bwdistgeodesic(strokes.skeleton{ii}, end_x(jj), end_y(jj));
        distanceToBranchPt = min(D(branch_idx));
        Dmask(D < distanceToBranchPt) =true;
    end
    skelD = strokes.skeleton{ii} - Dmask;
    imagesc(skelD);
    pause;
%     strokes.branchpoints{ii} = bwmorph(strokes.branchpoints{ii}, 'thicken', 1) .* strokes.skeleton{ii};     % dilate the branchpoints
% 
%     
%     strokes.branches{ii} = bwconncomp(strokes.skeleton{ii} - strokes.branchpoints{ii}); % subtract dilated branchpoints from original skeleton to split the skeleton into branches
%        
%     branch_areas = zeros(strokes.branches{ii}.NumObjects, 1);
%     for jj = 1:strokes.branches{ii}.NumObjects
%         current_branch = extract_labelled_region(blank_img, jj);
% %         branch_areas(jj) = bwarea(current_branch);
%         
%     end
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
        imagesc(strokes.branches{ii});
        axis equal;
        pause;
    end

    if saving
        saveas(gcf, file_out);
    end
    
end

%% robot art comp
%
% circle method for finding strokes

addpath('./images/', './helper_functions/');

clearvars;
close all;

plotting = true;
saving = true;

%% original image

% file_in = 'fire.jpg';
file_in = 'koi.jpg';
file_out = 'result5.png';
img = imread(file_in);

%% process the image

img = imgaussfilt(img,1);
BW = im2bw(img, 0.9);           % convert to black and white image
% img = img < 1;              % convert to boolean array
D = bwdist(BW);                 % Euclidean distance to nearest white point
max_radius = ceil(max(max(D))); % largest circle radius we can fit in the image
% D = imgaussfilt(D);            	% apply Gaussian filter

img_outline = get_image_outline(BW, true);
[r_outline, c_outline] = find(img_outline);
img_stroke = zeros(size(img_outline,1), size(img_outline,2));

[r_maxima, c_maxima] = get_local_maxima_2d(D);

fit_shape_vector = [1 zeros(1, max_radius-1)]; % radius 1 always works because the circle is just a 1x1 mask (i.e. pixel)
fit_shape_array = repmat(fit_shape_vector, length(r_outline), 1);
fit_circle_centres = [r_outline, c_outline];

% loop through each pixel of the image shape outline
for ii = 1:length(r_outline)
    
    for radius = 2:max_radius
    
    circle = circle_mask(radius);           % get the circle mask
    [r_circle, c_circle] = find(circle);    % get indices of the circle outline
    ind_offset = (radius-1)*2;              % index offset required to get image chunk
    
        % loop through circle mask and test against image shape
        for jj = 1:length(r_circle)

            rr = r_outline(ii) - (r_circle(jj) - 1);
            if (rr < 1) || (rr+ind_offset > size(BW, 1))    % check if indices exceed original image boundaries
                continue
            end
            cc = c_outline(ii) - (c_circle(jj) - 1);
            if (cc < 1) || (cc+ind_offset > size(BW, 2))    % check if indices exceed original image boundaries
                continue
            end
            
            % see if circle mask falls outside the shape
%             img_chunk = BW(rr:rr+ind_offset, cc:cc+ind_offset);
            if sum(sum(BW(rr:rr+ind_offset, cc:cc+ind_offset).*circle)) == 0
                fit_shape_array(ii, radius) = true;
                fit_circle_centres(ii, :) = [round(mean([rr, rr+ind_offset])), round(mean([cc, cc+ind_offset]))];
                break;  % only get one circle (even if multiple circles of current radius fit within shape)
            end

        end
        
        % if none of the circles of the current radius work, then the
        % larger circles won't either
        if fit_shape_array(ii, radius) == false
            break;
        end
        
    end
    
end

% for kk = 1:size(fit_circle_centres,1)
%     img_stroke(fit_circle_centres(kk,1), fit_circle_centres(kk,2)) = 1;
% end

%% plots

if plotting
    
    figure;

    subplot(1, 2, 1);
    imagesc(img_outline);
    axis equal;
    hold on;
    scatter(fit_circle_centres(:,2), fit_circle_centres(:,1), '.r');
    
    subplot(1, 2, 2);
    imagesc(img_outline);
    axis equal;
    hold on;
    scatter(c_maxima, r_maxima, '.r');

    if saving
        saveas(gcf, file_out);
    end
    
end

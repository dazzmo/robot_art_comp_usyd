% return a black and white image with the region described by the index
% list set as true (true = 1 = white);
function region = extract_labelled_region(blank_image, idx_list)
    blank_image(idx_list) = true;
    region = blank_image;
end
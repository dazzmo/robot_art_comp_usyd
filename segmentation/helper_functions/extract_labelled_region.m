function region = extract_labelled_region(blank_image, idx_list)
%     img = uint8(img);       % convert to integer image
%     img(img ~= label) = 0;  % set other regions to zero
%     region = img > 0;       % convert to binary image
    blank_image(idx_list) = true;
    region = blank_image;
end
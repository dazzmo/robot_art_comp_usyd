function img_outline = get_image_outline(img, BW)

    if BW == false
        img = 1 - img;
    end
    
    [rows, cols] = find(1 - img);                   % get indices of shape fill
    img_outline = zeros(size(img,1), size(img,2));  % stores the outline only

    for ii = 1:length(rows)
        xx = cols(ii);
        yy = rows(ii);
        if (xx == 1) || (yy == 1) || (xx == size(img, 2)) || (yy == size(img, 1))
            continue
        end
        if ((img(yy, xx+1)) || (img(yy, xx-1)) || (img(yy+1, xx)) || (img(yy-1, xx)))
            img_outline(yy,xx) = 1;
        end
    end

end
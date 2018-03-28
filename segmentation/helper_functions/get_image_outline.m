function img_outline = get_image_outline(img_BW)

    [rows, cols] = find(1 - img_BW);          % get array indices of logical 1s
    img_outline = zeros(size(img_BW,1), size(img_BW,2)); % stores the outline only

    for ii = 1:length(rows)
        xx = cols(ii);
        yy = rows(ii);
        if (xx == 1) || (yy == 1) || (xx == size(img_BW, 2)) || (yy == size(img_BW, 1))
            continue
        end
        if ((img_BW(yy, xx+1)) || (img_BW(yy, xx-1)) || (img_BW(yy+1, xx)) || (img_BW(yy-1, xx)))
            img_outline(yy,xx) = 1;
        end
    end

end
function [rows, cols] = get_local_maxima_2d(image)

    [~,indices] = localmax(image);            % find local maximas of each row
    [rows1, cols1] = ind2sub(size(image),indices);

    [~, indices_transpose] = localmax(transpose(image));
    [cols2, rows2] = ind2sub(size(transpose(image)),indices_transpose);

    rows = [rows1; rows2];
    cols = [cols1; cols2];

end
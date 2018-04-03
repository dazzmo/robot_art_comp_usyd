function strokes = get_shortest_branch(strokes)

    strokes.branchpoints = bwmorph(strokes.skeleton, 'branchpoints');
    strokes.endpoints = bwmorph(strokes.skeleton, 'endpoints');
    
%     [end_y, end_x] = find(strokes.endpoints{ii});
%     branch_idx = find(branchpoints);

    D = bwdistgeodesic(strokes.skeleton, strokes.endpoints);
    strokes.len_shortest_branch = min(D(strokes.branchpoints));
    
end
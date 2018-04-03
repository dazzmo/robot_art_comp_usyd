function len_shortest_branch = get_shortest_branch(strokes)

%     [end_y, end_x] = find(strokes.endpoints{ii});
%     branch_idx = find(branchpoints);

    D = bwdistgeodesic(strokes.skeleton, strokes.endpoints);
    len_shortest_branch = min(D(strokes.branchpoints));
    
end
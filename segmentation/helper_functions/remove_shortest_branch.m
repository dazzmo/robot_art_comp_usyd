function strokes = remove_shortest_branch(strokes)

    for jj = 1:numel(end_x)
        D = bwdistgeodesic(strokes.skeleton{ii}, end_x(jj), end_y(jj));
        distanceToBranchPt = min(D(branch_idx));
        Dmask(D < distanceToBranchPt) =true;
    end

end
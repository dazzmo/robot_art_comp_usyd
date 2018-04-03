function strokes = remove_shortest_branch(strokes)
    
    [y, x] = find(strokes.endpoints);
    Dmask = false(size(strokes.skeleton));
    for ii = 1:numel(x)
        D = bwdistgeodesic(strokes.skeleton, x(ii), y(ii));
        distance_to_branchpoint = min(D(strokes.branchpoints));
        if distance_to_branchpoint == strokes.len_shortest_branch
            Dmask(D < strokes.len_shortest_branch) = true;            
        end
    end
    
    strokes.skeleton = bwmorph(strokes.skeleton - Dmask, 'skel', Inf);
    strokes.branchpoints = bwmorph(strokes.skeleton, 'branchpoints');
    strokes.endpoints = bwmorph(strokes.skeleton, 'endpoints');
    strokes.len_shortest_branch = get_shortest_branch(strokes);
    
end
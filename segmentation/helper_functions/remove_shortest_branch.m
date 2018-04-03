% remove the short 
function strokes = remove_shortest_branch(strokes)
    
    [y, x] = find(strokes.endpoints);       % indices of the endpoints
    Dmask = false(size(strokes.skeleton));  % mask to remove the shortest branch
    
    % loop through each end point to isolate the shortest branch (unlike
    % get_shortest_branch() which looks at distances in the image globally
    for ii = 1:numel(x)
        D = bwdistgeodesic(strokes.skeleton, x(ii), y(ii));
        distance_to_branchpoint = min(D(strokes.branchpoints));
        if distance_to_branchpoint == strokes.len_shortest_branch
            Dmask(D < strokes.len_shortest_branch) = true;      % set branch to be removed to true
        end
    end
    
    % update the stroke skeleton after removing the shortest branch
    strokes.skeleton = bwmorph(strokes.skeleton - Dmask, 'skel', Inf);
    strokes.branchpoints = bwmorph(strokes.skeleton, 'branchpoints');
    strokes.endpoints = bwmorph(strokes.skeleton, 'endpoints');
    strokes.len_shortest_branch = get_shortest_branch(strokes);
    
end
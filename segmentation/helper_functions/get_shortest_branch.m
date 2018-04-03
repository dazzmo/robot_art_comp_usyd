% get the length of the current shortest branch (i.e. distance from a
% branchpoint to an endpoint
function len_shortest_branch = get_shortest_branch(strokes)
    
    % get of each point in the skeleton to the nearest endpoint
    D = bwdistgeodesic(strokes.skeleton, strokes.endpoints);
    
    % only look at the branchpoints to get minimum distance from any branch
    % to any closest endpoint
    len_shortest_branch = min(D(strokes.branchpoints));
    
end
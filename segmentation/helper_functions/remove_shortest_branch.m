% remove the short 
function stroke = remove_shortest_branch(stroke)
    
    [y, x] = find(stroke.endpoints);       % indices of the endpoints
    Dmask = false(size(stroke.skeleton));  % mask to remove the shortest branch
    
    % loop through each end point to isolate the shortest branch (unlike
    % get_shortest_branch() which looks at distances in the image globally
    for ii = 1:numel(x)
        D = bwdistgeodesic(stroke.skeleton, x(ii), y(ii));
        distance_to_branchpoint = min(D(stroke.branchpoints));
        if distance_to_branchpoint == stroke.len_shortest_branch
            Dmask(D < stroke.len_shortest_branch) = true;      % set branch to be removed to true
        end
    end
    
    % update the stroke skeleton after removing the shortest branch
    stroke.skeleton = bwmorph(stroke.skeleton - Dmask, 'skel', Inf);
    stroke.branchpoints = bwmorph(stroke.skeleton, 'branchpoints');
    stroke.endpoints = bwmorph(stroke.skeleton, 'endpoints');
    stroke.len_shortest_branch = get_shortest_branch(stroke);
    
end
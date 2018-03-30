

function endpoints = join_close_endpoints(skeleton, endpoints_old)

%     endpoint_indices = find(endpoints_old);
%     segments = bwconncomp(skeleton);
%     for ii = 1:segments.NumObjects
%         endpoints_old(segments.PixelIdxList{ii}) = ii;      % label the region
%     end
    endpoints = endpoints_old;

end
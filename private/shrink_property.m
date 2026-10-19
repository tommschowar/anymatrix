function p = shrink_property(p)
    if iscell(p)
        for i = 1:numel(p)
            p{i} = shrink_property(p{i});
        end
    elseif isstruct(p)
        st = struct;
        for fn = fieldnames(p)'
            st.(shrink_property(fn{1})) = p.(fn{1});
        end
        p = st;
    else
        p = shrink_property_worker(p);
    end
end

function p = shrink_property_worker(p)
    p = lower(p);
    p = strtrim(p);
    p(p=='_') = [];
    p(p=='-') = [];
    p(p==' ') = [];
end

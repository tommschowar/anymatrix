function ret = isfalse( x )
    if isempty( x )
        ret = false;
    elseif ~isscalar( x )
        ret = false;
    else
        ret = ~x;
    end
end

function st = structp( varargin )
% generates a struct from name-value pairs
% does not special case cell arrays
    assert( ~mod( numel(varargin), 2 ) );
    st = struct;
    for i = 1:2:numel( varargin )
        st.(varargin{i}) = varargin{i+1};
    end
end

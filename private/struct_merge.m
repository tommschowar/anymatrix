function [ st ] = struct_merge( varargin );
% [ st ] = struct_merge( struct1, ..., structn, prefix );
% Merges multiple structs
%
% Input:
%   struct_i    structs or struct array
%               if a struct array is given, all structs need to have the same size
%   prefix
%   
% Note:
%    Overwrites values if same field is present multiple times
%
% Written by: tommsch, 2025

    if( nargin == 0);
        st = struct( [] );
        return; end;
    prefix = '';
    index = [];
    while( true );
        if( ischar(varargin{end}) || isstring(varargin{end}) );
            prefix = char( varargin{end} );
            varargin(end) = [];
            continue; end;
        if( isnumeric(varargin{end}) );
            index = varargin{end};
            varargin(end) = [];
            continue; end;
        break; end;

    st = varargin{1};
    sze = size( st );

    if( isempty(index) );
        index = 1:numel( varargin{1} ); end;
    
    for i = 2:numel( varargin );
        assert( isequal( size(varargin{i}), sze ), 'struct_merge:size', 'The size of all input structs must be the same.' );
        for name_ = fieldnames( varargin{i} )'; name = name_{1};
            for l = index;
                st(l).([prefix name]) = varargin{i}(l).(name); end; end; end;
end

function dummy; end  %#ok<DEFNU>  % Generates an error, if the 'end' of a function is missing.
%#ok<*NOSEL,*NOSEMI,*ALIGN>

function [ help_content_ ] = scan_help( matrix_IDs, root_path, clear_content )
    persistent help_content
    if nargin >= 3 && clear_content
        help_content = [];
        help_content_ = [];
        return;
    end
    if isempty( help_content )
        fprintf( 'Scanning help content of all matrices:     ' );
        help_content = cell( size(matrix_IDs) );
        for i = 1:numel( matrix_IDs )
            slashloc = find(matrix_IDs{i} == '/');
            group_name = matrix_IDs{i}(1:slashloc-1);
            matrix_name = matrix_IDs{i}(slashloc+1:end);
            path_to_mat = [root_path '/groups/' group_name ...
                           '/private/' matrix_name];  %#ok<NASGU>
            if strcmp('gallery', group_name)
                help_content{i} = evalc( 'help([''private/'' matrix_name])' );
            elseif strcmp('matlab', group_name)
                help_content{i} = evalc( 'help(matrix_name)' );
            else
                help_content{i} = evalc( 'help(path_to_mat)' );
            end
            fprintf( '\b\b\b\b\b%4i%%', floor(100*i/numel( matrix_IDs) ) );
        end
        fprintf( '\nDone\n\n' );
    end
    help_content_ = help_content;
end

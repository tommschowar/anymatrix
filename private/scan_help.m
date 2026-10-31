function [ help_content_ ] = scan_help( matrix_IDs, root_path, rescan )
    persistent help_content
    if isempty( help_content ) || rescan
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

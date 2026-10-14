% Top level function for scanning the files.
function [set_IDs, group_IDs, matrix_IDs, properties, supported_properties] = scan_filesystem( root_path, rescan )
%

% Changelog:    tommsch,    2026-10-01,     Allow wildcards in am_properties.m to define properties for multiple files
%                                           Slightly different (and more robust) parsing of the "properties" string in files to determine whether it is a "matrix-file"
%                                           Allow placing `am_prop_list.m`,`am_prop_map.m`,`am_inv_prop_map.m` files in private folder to read additional matrix properties


    persistent set_IDs_
    persistent group_IDs_
    persistent matrix_IDs_
    persistent properties_
    persistent supported_properties_

    if nargin <= 1 || isempty( rescan )
        rescan = false;
    end

    if isempty(set_IDs_) || rescan
        set_IDs_ = scan_sets(root_path);
        group_IDs_ = scan_groups(root_path);
        matrix_IDs_ = scan_matrices(group_IDs_, root_path);
        properties_ = scan_properties(matrix_IDs_, root_path);

        [pm,im] = scan_prop_map(group_IDs_, root_path);
        properties_ = add_implied_properties(properties_, pm, im);

        supported_properties_ = scan_supported_properties(group_IDs_, root_path);
        check_properties(matrix_IDs_, properties_, supported_properties_)
        disp('Anymatrix scanning done.');
    end

    set_IDs = set_IDs_;
    group_IDs = group_IDs_;
    matrix_IDs = matrix_IDs_;
    properties = properties_;
    supported_properties = supported_properties_;
end

% Scan the sets folder and obtain the set IDs.
function set_IDs = scan_sets( root_path )
    set_IDs = {dir([root_path, '/sets/*.txt']).name};
    
    % Remove '.txt' extensions from the IDs.
    for k = 1:numel(set_IDs)
        dotloc = find(set_IDs{k} == '.');
        set_IDs{k} = set_IDs{k}(1:dotloc(1)-1);
    end
    set_IDs = set_IDs.';
end

% Scan the root folder and obtain the group IDs.
function IDs = scan_groups( root_path )
    contents = dir(root_path);
    IDs = {};
    for k = 1:numel(contents)
        if contents(k).isdir && is_group_dir(contents(k).name, root_path)
            IDs{end+1} = contents(k).name;  %#ok<AGROW>
            addpath([root_path '/' contents(k).name]);
        end
    end
    IDs = IDs.';
end

% Scan the group folders and obtain the matrix IDs.
function matrix_IDs = scan_matrices(group_IDs, root_path)
    matrix_IDs = {};
    for group_ID = group_IDs.'
        path_to_group = [root_path, '/', group_ID{1}, '/private/'];
        mfiles = dir([path_to_group, '*.m']);
        for mfile = mfiles.'
            % Find which .m files are matrix-generating files.
            mfile_contents = fileread([path_to_group, mfile.name]);
            if (contains(mfile_contents, 'properties = {') || ...
                contains(mfile_contents, 'properties= {') || ...
                contains(mfile_contents, 'properties ={') || ...
                contains(mfile_contents, 'properties={') ...
               )
                matrix_IDs = [
                    matrix_IDs; 
                    [group_ID{1}, '/', extractBefore(mfile.name, '.m')]
                    ];  %#ok<AGROW>
            end
        end
        
        % Read matrix IDs that are placed in properties.m files and
        % add them if they are not in yet from the M-files.
        format_check = @(x) size(x,2)==2;
        filename = 'am_properties';  % without '.m'
        if isfile([path_to_group, filename '.m'])
            handle = str2func(['anymatrix_', group_ID{1}]);
            P = handle(filename);
            if ~format_check(P)
                warning( ['File ''%s.m'' of group ''%s'' cannot be interpreted, '...
                          'and thus is skipped.\n'], filename, group_ID{1} );
            else
                moreIDs = strcat(group_ID{1}, '/', P(:,1));
                idx_wildcard = contains( moreIDs, '*' );
                moreIDs(idx_wildcard) = [];
                matrix_IDs = [matrix_IDs;
                              moreIDs(~ismember(moreIDs, matrix_IDs))];  %#ok<AGROW>
            end
        end
    end
end

% Get properties of a specified array of matrices in a cell array of
% cell arrays, arranged in the same order as matrix_IDs.
function properties = scan_properties(matrix_IDs, root_path)
    % List of built-in anymatrix groups.
    properties = {};
    for matrix_ID = matrix_IDs.'
        p = get_properties(matrix_ID{1}, root_path);
        if iscell(p)
            if isempty(p)
                p = struct;
                % do nothing
            elseif size(p,2) == 1
                p = sanitize_property( p );
                p = cell2struct( repmat( {1}, [numel(p) 1] ) , p(:,1) );
            else
                warning(['Format of properties for matrix ''%s'' is wrong, '...
                        'and thus skipped.'],  matrix_ID{1} );
                continue;
            end
        elseif isstruct(p)
            % do nothing
        end
        properties = [properties; p];  %#ok<AGROW>
    end

    % Add property 'built-in' for the built-in matrices.
    for i = 1:numel(matrix_IDs)
       if any(startsWith(matrix_IDs{i}, built_in_groups()))
           properties{i}.built_in = true;  %#ok<AGROW>
       end
    end
end

function [pm,im] = scan_prop_map(group_IDs, root_path)
    pm = prop_map();
    im = inv_prop_map();

    % Read prop-map that are placed in am_prop_map.m
    format_check = @(x) iscell(x) && size(x,2)==2;
    filename = 'am_prop_map';  % without '.m'
    for group_ID = group_IDs.'
        path_to_group = [root_path, '/', group_ID{1}, '/private/'];
        if isfile([path_to_group filename '.m'])
            handle = str2func(['anymatrix_', group_ID{1}]);
            pm_am = handle(filename);
            if ~format_check(pm_am)
                warning( ['File ''%s.m'' of group ''%s'' cannot be interpreted, ' ...
                          'and thus is skipped.\n'], filename, group_ID{1} );
            else
                pm = [pm; pm_am];  %#ok<AGROW>
            end
        end
    end
    pm = unique_pm( pm );
    pm = sanitize_property( pm );

    % Read prop-map that are placed in am_inv_prop_map.m
    format_check = @(x) iscell(x) && size(x,2)==2;
    filename = 'am_inv_prop_map';  % without '.m'
    for group_ID = group_IDs.'
        path_to_group = [root_path, '/', group_ID{1}, '/private/'];
        if isfile([path_to_group filename '.m'])
            handle = str2func(['anymatrix_', group_ID{1}]);
            im_am = handle(filename);
            if ~format_check(im_am)
                warning( ['File ''%s.m'' of group ''%s'' cannot be interpreted,' ...
                          'and thus is skipped.\n'], filename, group_ID{1} );
            else
                im = [im; im_am];  %#ok<AGROW>
            end
        end
    end
    im = unique_pm( im );
    im = sanitize_property( im );
end

function pm = unique_pm( pm )
%%
    str = cell(size(pm,1),1);
    for i = 1:size(pm,1)
        str{i} = [pm{i,:}];
        str{i} = [str{i}{:}];
    end
    [~,idx] = unique(str);
    pm = pm(idx,:);
end

function properties = add_implied_properties(properties, pm, im)
%%
    for i = 1:numel(properties)
        for j = 1:size(im,1)
            if ~isfield(properties{i}, im{j,1})
                add = true;
                for f = im{j,2}
                    if isfield(properties{i},f{1}) && ~properties{i}.(f{1})
                       add = false;
                       break 
                    end
                end
                if add
                    properties{i}.(im{j,1}) = true;
                end
            end
        end

        j = 1;
        while j <= size(pm,1)
            % Find parent properties of any of the properties already
            % in the list and add them if they are not in yet.
            if ~isfield(properties{i},pm{j,1})
                add = false;
                for f = pm{j,2}
                    if isfield(properties{i},f{1}) && properties{i}.(f{1})
                        add = true;
                    end
                end
                if add
                    properties{i}.(pm{j,1}) = true;
                    j = 1;
                end
            end
            j = j+1;
        end
    end
end

function supported_properties = scan_supported_properties(group_IDs, root_path)
    supported_properties = prop_list();

    % Read properities that are placed in am_prop_list.m
    format_check = @(x) iscell(x) && size(x,2)==1;
    filename = 'am_prop_list';  % without '.m'
    for group_ID = group_IDs.'
        path_to_group = [root_path, '/', group_ID{1}, '/private/'];
        if isfile([path_to_group, filename '.m'])
            handle = str2func(['anymatrix_', group_ID{1}]);
            pl_am = handle(filename);
            if ~format_check(pl_am)
                warning( ['File ''%s.m'' of group ''%s'' cannot be interpreted,' ...
                          'and thus is skipped.\n'], filename, group_ID{1} );
            else
                supported_properties = [supported_properties; pl_am];  %#ok<AGROW>
            end
        end
    end
    supported_properties = unique(supported_properties);
    supported_properties = sanitize_property(supported_properties);
end

function check_properties( matrix_IDs, properties, supported_properties )
    % Check if all the properties can be recognized.
    for i=1:numel(matrix_IDs)
        p = fieldnames(properties{i});
        for bad_prop = p(~ismember(p, supported_properties))
            if ~isempty(bad_prop)
                warning('Property ''%s'' in ''%s'' is not recognized.', ...
                    bad_prop{1}, matrix_IDs{i});
            end
        end
    end
end

%%

% Check if a folder in anymatrix root directory is a group folder.
% Group directories have one private/ directory and one file named
% anymatrix_<dir_name>.m where <dir_name> is the directory name.
function out = is_group_dir(directory, root_path)
    % Check dir is not current or previous directories '.' and '..',
    % and check dir has two files additionally to '.' and '..'.
    if (any(strcmp(directory, {'.', '..'})) || ...
        numel(dir([root_path '/' directory])) ~= 4 ...
       )
        out = false;
    else
        % Check dir has a 'private' directory and a file
        % anymatrix_<dir_name>.
        out = ~isempty(dir([root_path '/' directory '/private/'])) && ...
              ~isempty(dir([root_path '/' directory '/anymatrix_' directory '.m']));
    end
end

% Fetch the properties of a specified matrix.
function P = get_properties(matrix_ID, root_path)
    slashloc = find(matrix_ID == '/');
    group_name = matrix_ID(1:slashloc-1);
    path_to_group = [root_path, '/', group_name, '/private/'];
    matrix_name = matrix_ID(slashloc+1:numel(matrix_ID));
    handle = str2func(['anymatrix_' group_name]);
    P = {};
    % Get properties from the M-file of the matrix.
    mfile_path = [path_to_group matrix_name '.m'];
    if isfile(mfile_path)
        mfile_contents = fileread(mfile_path);
        if regexp( mfile_contents, '^\s*function.*properties.*=', 'once' )
            noutputs = nargout([path_to_group matrix_name]);
            temp = {};  % get last output of function
            [temp{1:noutputs-1},P] = handle(matrix_name);  %#ok<NASGU>
        end
        P = P.';
    end
    

    % Get other properties from the entry in the am_properties.m file.
    format_check = @(x) size(x,2)==2;
    filename = 'am_properties';  % without '.m'
    if isfile([path_to_group filename '.m'])
        am_properties = handle(filename);
        if ~format_check(am_properties)
           warning( ['File ''%s.m'' in ''%s'' cannot be interpreted, '...
                     'and thus is skipped.\n'], ...
                    filename, path_to_group );
        else
            find_idx = ~cellfun('isempty', ...
                                regexp(matrix_name, ...
                                       strcat('^', ...
                                              regexptranslate('wildcard', ...
                                                              am_properties(:, 1)), ...
                                              '$' ), ...
                                       'once' ) );
            P = [P; [am_properties{find_idx,2}]'];
        end
    end
end

function p = sanitize_property( p )
    if size(p, 2) == 2
        for i = 1:size(p, 1)
            assert(iscell(p{i,2}), 'Format of map wrong.');
            p{i,1} = sanitize_property_worker( p{i,1} );
            for j = 1:numel(p{i,2})
                p{i,2}{j} = sanitize_property_worker( p{i,2}{j} );
            end
        end
        p{i,2} = unique(p{i,2});
    else
        for i = 1:numel(p)
            p{i,1} = sanitize_property_worker( p{i,1} );
        end
        p = unique( p );
    end
end

function p = sanitize_property_worker( p )    
    p = lower(p);
    p = strtrim(p);
    p(p == '-') = '_';
    p(p == ' ') = '_';
end

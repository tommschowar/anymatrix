% Top level function for scanning the files.
function [set_IDs, group_IDs, matrix_IDs, properties] = scan_filesystem( supported_properties, root_path, rescan )
    persistent set_IDs_
    persistent group_IDs_
    persistent matrix_IDs_
    persistent properties_

    if nargin <= 2 || isempty( rescan )
        rescan = false;
    end

    if isempty(set_IDs_) || rescan
        set_IDs_ = scan_sets(root_path);
        group_IDs_ = scan_groups(root_path);
        matrix_IDs_ = scan_matrices(group_IDs_, root_path);
        properties_ = scan_properties(matrix_IDs_, supported_properties, root_path);

        disp('Anymatrix scanning done.');
    end

    set_IDs = set_IDs_;
    group_IDs = group_IDs_;
    matrix_IDs = matrix_IDs_;
    properties = properties_;
end

% Scan the sets folder and obtain the set IDs.
function set_IDs = scan_sets( root_path )
    set_IDs = {dir(strcat(root_path, '/sets/*.txt')).name};
    
    % Remove '.txt' extensions from the IDs.
    for k = 1:length(set_IDs)
        dotloc = find(set_IDs{k} == '.');
        set_IDs{k} = set_IDs{k}(1:dotloc(1)-1);
    end
    set_IDs = set_IDs.';
end

% Scan the root folder and obtain the group IDs.
function IDs = scan_groups( root_path )
    contents = dir(root_path);
    IDs = {};
    for k = 1:length(contents)
        if contents(k).isdir && is_group_dir(contents(k).name, root_path)
            IDs{end+1} = contents(k).name;  %#ok<AGROW>
            addpath(strcat(root_path, '/', contents(k).name));
        end
    end
    IDs = IDs.';
end

% Scan the group folders and obtain the matrix IDs.
function matrix_IDs = scan_matrices(groups, root_path)
    matrix_IDs = {};
    for group = groups.'
        path_to_group = [root_path, '/', group{1}, '/private/'];
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
                    [group{1}, '/', extractBefore(mfile.name, '.m')]
                    ];  %#ok<AGROW>
            end
        end
        
        % Read matrix IDs that are placed in properties.m files and
        % add them if they are not in yet from the M-files.
        if isfile(strcat(path_to_group, 'am_properties.m'))
            handle = str2func(strcat('anymatrix_', group{1}));
            P = handle('am_properties');
            moreIDs = strcat(group{1}, '/', P(:,1));
            matrix_IDs = [matrix_IDs; moreIDs(~ismember(moreIDs, matrix_IDs))];  %#ok<AGROW>
        end
    end
end

% Get properties of a specified array of matrices in a cell array of
% cell arrays, arranged in the same order as matrix_IDs.
function properties = scan_properties(matrix_IDs, supported_properties, root_path)
    % List of built-in anymatrix groups.
    built_in_groups = {
         'contest'
         'core'
         'gallery'
         'hadamard'
         'matlab'
         'nessie'
         'regtools'
         'set'
         };

    properties = {};
    for matrix_ID = matrix_IDs.'
        [current_properties, temp] = get_properties(matrix_ID{1}, root_path);
        if size(current_properties, 2) > 1
            current_properties = current_properties';
        end
        properties = [properties; {current_properties}];  %#ok<AGROW>
    end

    % Add property 'built-in' for the built-in matrices.
    for i = 1:length(matrix_IDs)
       if any(startsWith(matrix_IDs{i}, built_in_groups))
           properties{i} = [properties{i}; 'built-in'];  %#ok<AGROW>
       end
    end

    % Add parent properties if not specified.
    M = prop_map();
    I = inv_prop_map();
    for i = 1:length(properties)
        for j = 1:length(I)
            % Find properties that can be added due to absence of some
            % other properties.
            if ~any(ismember(strrep(lower(I{j, 2}),'-', ' '), ...
                    strrep(lower(properties{i}), '-', ' '))) && ...
                    ~ismember(strrep(lower(I{j, 1}), '-', ' '), ...
                    strrep(lower(properties{i}), '-', ' '))
                properties{i} = [properties{i}; I{j, 1}];  %#ok<AGROW>
            end
        end
        j = 1;
        while j <= length(M)
            % Find parent properties of any of the properties already
            % in the list and add them if they are not in yet.
            if any(ismember(strrep(lower(properties{i}), '-', ' '), ...
                            strrep(lower(M{j, 2}), '-', ' '))) && ...
                ~ismember(strrep(lower(M{j, 1}), '-', ' '), ...
                          strrep(lower(properties{i}), '-', ' '))
                properties{i} = [properties{i}; M{j, 1}];  %#ok<AGROW>
                j=1;
            end
            j = j+1;
        end
    end

    % Check if all the properties can be recognized.
    for i=1:length(matrix_IDs)
        for bad_prop = ...
                properties{i}(~ismember(strrep(lower(properties{i}), '-', ' '), ...
                               strrep(lower(supported_properties), ...
                               '-', ' ')))
            if ~isempty(bad_prop)
                warning('Property %s in %s is not recognized.', ...
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
            (length(dir(strcat(root_path, '/', directory)))) ~= 4 ...
       )
        out = false;
    else
        % Check dir has a 'private' directory and a file
        % anymatrix_<dir_name>.
        out = ~(isempty(dir(strcat(root_path, '/', directory, ...
                                   '/private/'))) || ...
                isempty(dir(strcat(root_path, '/', directory, ...
                                   '/anymatrix_', directory, '.m'))));
    end
end

% Fetch the properties of a specified matrix.
function [P, temp] = get_properties(matrix_ID, root_path)
    slashloc = find(matrix_ID == '/');
    group_name = matrix_ID(1:slashloc-1);
    path_to_group = [root_path, '/', group_name, '/private/'];
    matrix_name = matrix_ID(slashloc+1:length(matrix_ID));
    handle = str2func(strcat('anymatrix_', group_name));
    P = {};
    % Get properties from the M-file of the matrix.
    mfile_path = strcat(path_to_group, matrix_name, '.m');
    if isfile(mfile_path)
        mfile_contents = fileread(mfile_path);
        if (contains(mfile_contents, 'properties = {') || ...
            contains(mfile_contents, 'properties= {') || ...
            contains(mfile_contents, 'properties ={') || ...
            contains(mfile_contents, 'properties={') ...
           )
            noutputs = nargout(strcat(path_to_group, matrix_name));
            temp = {};
            [temp{1:noutputs-1},P] = handle(matrix_name);
        end
    end
    % Get other properties from the entry in the properties.m file.
    if isfile(strcat(path_to_group, 'am_properties.m'))
        temp = handle('am_properties');
        if ismember(matrix_name, temp(:, 1))
            temp = temp{strcmp(matrix_name, temp(:, 1)), 2};
            P = [P, temp(~ismember(temp, P))];
        end
    end
    P = P.';
end

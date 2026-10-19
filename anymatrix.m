function varargout = anymatrix(varargin)
%ANYMATRIX  Interface for accessing the Anymatrix collections.
%   ANYMATRIX is a user interface for the Anymatrix matrix collection.
%   It provides commands to list matrices, groups and sets, search for
%   matrices by properties, and obtain the matrices by their IDs.
%
%   The interface comes with built-in groups of matrices, but users can
%   develop their own groups and make them available to other users.
%
%   The built-in collection contains 7 groups:
%
%       contest  - the CONTEST test matrix toolbox of random matrices
%                  from networks.
%       core     - miscellaneous matrices.
%       gallery  - matrices from the MATLAB gallery.
%       hadamard - a large collection of (complex) Hadamard matrices.
%       matlab   - other MATLAB matrices (not in gallery).
%       nessie   - matrices from real-life networks.
%       regtools - matrices from regularization problems.
%
%   Anymatrix accepts the following commands. All arguments are character
%   vectors or strings, except ones defined by the matrix M-files which
%   might take various types of arguments.
%
%   help anymatrix - display this information.
%   ANYMATRIX('all') - return all matrix IDs in the collection.
%       The call ANYMATRIX('groups','*') does the same
%   ANYMATRIX('contents', group_name) - displays Contents.m of the group
%       with a specified name group_name.
%   G = ANYMATRIX('groups') - return the available groups.
%   M = ANYMATRIX('groups', group_name) - return matrix IDs that belong
%       to the group with a specified name group_name.
%   ANYMATRIX('groups', group_name, repository) - clone or update
%       an anymatrix group stored in the specified repository.
%   ANYMATRIX('help', matrix_id) - list the help for a specified
%       matrix (anymatrix(matrix_id, 'help') also accepted).
%   M = ANYMATRIX('lookfor', pattern) - returns a list of matrix IDs
%       whose help comments contain the specified string/char pattern.
%   ANYMATRIX('properties') - show the list of recognized properties.
%   ANYMATRIX('properties', matrix_id) - list the properties of a
%       specified matrix (anymatrix(matrix_id, 'properties') also
%       accepted).
%   M = ANYMATRIX('properties', properties) - list matrices having
%       the specified properties.
%   M = ANYMATRIX('root_path') - returns the root path of anymatrix
%   ANYMATRIX('scan') - force a scan of the file system.
%   S = ANYMATRIX('sets') - return the available sets.
%   [s, mat1, ..., matK] = ANYMATRIX('sets', set_name) - return matrix IDs
%       in S and generate matrices in a specified set.
%   ANYMATRIX('test') - run tests of all groups, where available.
%   ANYMATRIX('test', group_name) - run tests of the specified group, if
%       available.
%   [out1, ..., outK] = ANYMATRIX(matrix_id, in1, ..., inN) - get the
%       matrix with a specified matrix id and parameters (if any) in1 to
%       inN. Some matrices supply multiple output arguments.
%
%   Shorthand commands with one or more of the starting letters are also
%   accepted, for example 'c', 'cont', 'g', 'gr', 'h', 'l', 'p', 'prop',
%   'sc', 'se', 't'.
%
%   Anymatrix supports logical queries to search for matrices by
%   properties. In the command anymatrix('properties', '[properties]'), the
%   list of properties is a single character vector containing properties
%   that have to be separated by an "and" or an "or" and can be preceded by
%   a "not". Brackets can also be included to specify precedence.
%
%   Anymatrix holds the information about the underlying database of
%   matrices in the persistent variables that are initialized by scanning
%   the data on the first call to any command. To force an update to these
%   variables use anymatrix('scan').
%
%   Documentation:
%   Nicholas J. Higham and Mantas Mikaitis, Anymatrix: An Extendable MATLAB
%   Matrix Collection, User's Guide, MIMS EPrint 2021.15, Manchester
%   Institute for Mathematical Sciences, The University of Manchester,
%   UK, October 2021.

%   References and acknowledgments.
% 
%   The CONTEST toolbox is included with permission from
%   Alan Taylor and Desmond J. Higham.  CONTEST: A controllable test matrix
%   toolbox for MATLAB. ACM Trans. Math. Software, 35(4):26:1-26:17, 2009.
%   https://doi.org/10.1145/1462173.1462175
%
%   The Hadamard group is reproduced with permission from
%   N. J. A. Sloane, A Library of Hadamard Matrices,
%   http://neilsloane.com/hadamard/. "Anything free comes with no guarantee".
%
%   The NESSIE collection is included with permission from
%   https://outreach.mathstat.strath.ac.uk/outreach/nessie/nessie_transport.html
%   Alan Taylor and Desmond J. Higham, NESSIE: Network Example Source
%   Supporting Innovative Experimentation, in Ernesto Estrada, Maria
%   Fox, Desmond J. Higham and Gian-Luca Oppo, eds, Network Science:
%   Complexity in Nature and Technology, pp. 85-106, Springer, 2010.
%   https://doi.org/10.1007/978-1-84996-396-1_5
%
%   The regtools group is included with permission from the
%   Regulariation Tools toolbox at https://www.imm.dtu.dk/~pcha/Regutools/
%   P. C. Hansen Regularization Tools: A Matlab package for analysis and
%   solution of discrete ill-posed problems.  Numer. Algorithms 6(1), 1--35
%   (1994).  https://doi.org/10.1007/BF02149761
%   P. C. Hansen: Regularization Tools version 4.0 for Matlab 7.3.
%   Numer. Algorithms 46(2), 189--194 (2007).
%   https://doi.org/10.1007/s11075-007-9136-9

% Changelog:    2026-09-29,     tommsch,        Refactored
%                                               Multiply properties can be given as multiple arguments
%                                               Behaviour change: matrices of a set are returned as a cell array in the second return argument
%                                               New option 'root_path'

    root_path = fileparts([mfilename('fullpath'), '.m']);

    add_to_path(root_path);

    [set_IDs, group_IDs, matrix_IDs, properties, supported_properties] = ...
        scan_filesystem( root_path );
    
    [command, args] = parse_input( varargin{:} );

    capture_some_common_errors()

    % Execute the specified command.
    if isempty( command )
        fprintf( ['Type ``help anymatrix`` or ``anymatrix xyz```'...
                  'to get help on anymatrix or topic ''xyz''.\n'] );

    elseif startsWith('all', command) && numel(args) == 0
        varargout{1} = matrix_IDs;

    elseif startsWith('all', command)
        error('Anymatrix command was not recognized.');

    elseif startsWith('root_path', command) && numel(args) == 0
        varargout{1} = root_path;

    elseif startsWith('root_path', command)
        error('Anymatrix command was not recognized.');

    elseif startsWith('contents', command) && numel(args) == 1  %#ok<ISCL>
        show_contents(group_IDs, root_path, args{:});

    elseif startsWith('contents', command)
        error('Anymatrix command was not recognized.');

    elseif startsWith('groups', command) && numel(args) == 2
        update_git_group(root_path, args{:});

    elseif startsWith('groups', command) && isempty( args{1} )
        assert(numel(args) == 0, ...
               'Anymatrix command was not recognized (too many inputs).');
        varargout{1} = group_IDs;

    elseif startsWith('groups', command) && numel(args) == 1  %#ok<ISCL>
        varargout{1} = read_groups( group_IDs, matrix_IDs, args{:});

    elseif startsWith('groups', command)
        error('Anymatrix command was not recognized.');

    elseif startsWith('help', command)
        do_help(matrix_IDs, args{:})

    elseif startsWith('lookfor', command)
        varargout{1} = lookfor_term(matrix_IDs, root_path, args{:});

    % we check 'properties' before 'path',
    % so that 'p' becomes an abbreviation for 'properties'
    elseif startsWith('properties', command)
        varargout{1} = do_properties(matrix_IDs, properties, ...
                                     supported_properties, args{:});

    elseif startsWith('path', command)
        varargout{1} = do_path(root_path, args{:});

    elseif startsWith('scan', command) && numel(args) == 0
        scan_filesystem(root_path, true);

    elseif startsWith('scan', command)
        error('Anymatrix command was not recognized.');

    elseif startsWith('sets', command) && numel(args) == 0
        varargout{1} = set_IDs;

    elseif startsWith('sets', command)
        [varargout{1:2}] = do_sets(set_IDs, matrix_IDs, root_path, args{:});

    elseif startsWith('test', command)
        do_test(group_IDs, root_path, args{:})

    else
        [varargout{1:nargout}] = generate_matrix(command, matrix_IDs, args{:});

    end

end

%%
function add_to_path(root_path)
    % Add anymatrix/sets and anymatrix/testing to the search path.
    persistent added
    if isempty(added)
        added = true;
        addpath(root_path);
        addpath([root_path '/sets']);
        addpath([root_path '/testing']);
        fprintf(['Anymatrix installed. ' ...
                 'Type `savepath` to make the installation permament.\n']);
    end
end

function str = do_path(root_path, arg)
    slashloc = find(arg == '/');
    group_name = arg(1:slashloc-1);
    matrix_name = arg(slashloc+1:end);
    str = [fullfile(root_path, group_name, 'private', matrix_name) '.m'];
end

function do_help( matrix_IDs, varargin )
    if numel( varargin ) == 0
        help anymatrix;
    elseif numel( varargin ) == 1 %#ok<ISCL>
        show_matrix_help(varargin{1}, matrix_IDs);
    else
        error('Anymatrix command was not recognized.');
    end
end

function out = do_properties(matrix_IDs, properties, ...
                             supported_properties, varargin)
    if isempty(varargin)
        [~, I] = sort(supported_properties);
        out = supported_properties(I);
    elseif is_matrixID(varargin{1})
        assert(ismember(varargin{1}, matrix_IDs), ...
               'Specified matrix ID not found.');
        out = properties{strcmp(matrix_IDs, varargin{1})};
    elseif varargin{1}(1) == '/' && ...
           ischar( find_matrixID(varargin{1}, matrix_IDs, 0 ) )
        matrix_ID = find_matrixID(varargin{1}, matrix_IDs);
        out = properties{strcmp(matrix_IDs, matrix_ID)};
    else
        out = search_by_properties(matrix_IDs, properties, ...
                                   supported_properties, varargin(1:end));
    end
end

function [S, matrices] = do_sets(set_IDs, matrix_IDs, root_path, ...
                                 set)  %#ok<INUSD>
    assert(ismember(set, set_IDs), ...
           'ID of the specified set was not found.');
    S = readcell( [root_path '/sets/' set '.txt'], ...
                  'Delimiter',':', 'CommentStyle','%', ...
                  'Whitespace', ' \n');
    % Generate matrices using parameters specified in the set.
    matrices = cell( 1, numel(S) );
    for idx = 1:size(S,1)
        if ismissing(S{idx, 2})
            str = ['generate_matrix(''' S{idx,1} ''', matrix_IDs)'];
            matrices{idx} = eval(str);
        else
            str = ['generate_matrix(''' S{idx,1} ''', matrix_IDs,' ...
                   num2str(S{idx,2}) ')'];
            try
                matrices{idx} = eval(str);
            catch me
                fprintf('Could not evaluate: %s -- %s\n', S{idx,1}, S{idx,2});
                matrices{idx} = [];
            end
        end
    end
end

function do_test(group_IDs, root_path, group_ID)
    assert(ismember(group_ID, group_IDs), ...
           'The specified group ID was not found.');
    if isempty( group_ID )
        for id = group_IDs.'
            run_group_tests(id{1}, root_path);
        end
    else
        run_group_tests(group_ID, root_path);
    end
end


%%

function [command, args] = parse_input( varargin )
    command = [];
    if numel(varargin) == 0
        return;
    end

    varargin = string_to_char( varargin{:} );
    if numel(varargin) >= 2 && ischar(varargin{2}) && ...
       any(startsWith({ ...
                'properties', ...
                'groups', 'sets', 'all', 'scan', 'help', 'test', ...
                'lookfor', 'contents'}, varargin{2})) && ...
       ~any(startsWith({ ...
                'properties', ...
                'groups', 'sets', 'all', 'scan', 'help', 'test', ...
                'lookfor', 'contents'}, varargin{1}))
        [varargin{2},varargin{1}] = deal(varargin{1},varargin{2});
    end

    command = varargin{1};
    command = strrep(command, '-', '_');
    
    % if numel( varargin ) >= 2
    %     arg = varargin{2};
        % % Allow use of hyphens instead of underscores, but replace here.
        % if ischar(arg) && ~any(startsWith({'lookfor', 'sets'}, command))
        %     arg = strrep(arg, '-', '_');
        % end
    % end
    args = varargin(2:end);
end

function varargin = string_to_char( varargin )
    for i = 1:numel(varargin)
        if isstring(varargin{i})
            varargin{i} = char(varargin{i});
        end
    end
end

% Capture some common errors in the arguments.
function capture_some_common_errors()
    % Check that MATLAB 2020b or higher is present.
    assert(~verLessThan('matlab','9.9'), ...
           'MATLAB 2020b or newer is required.');  %#ok<VERLESSMATLAB>
end

% Search for matrices that have properties, according to a specified
% logical expression, and return their IDs.
function IDs = search_by_properties(matrix_IDs, properties, ...
                                    supported_properties, expressions)
    supported_properties = shrink_property(supported_properties);
    expression = expressions{1};
    if numel(expressions) > 1
        if any(strcmp(strtrim(expressions{1}),{'and','or','&','|'}))
            expressions = [expressions(2:end);
                           repmat({[' ' expressions{1} ' ']}, ...
                                  1, numel(expressions)-1)];
            expressions = reshape( expressions, 1, [] );
            expression = [expressions{1:end-1}];
        elseif ~any(strcmp(expressions,'and')) && ...
               ~any(strcmp(expressions,'or')) && ...
               ~any(strcmp(expressions,'&')) && ...
               ~any(strcmp(expressions,'|'))
            for i = 2:numel( expressions )
                expression = [expression ' and ' expressions{i}];  %#ok<AGROW>
            end
        else
            expressions = [expressions(1:end);
                           repmat({' '}, 1, numel(expressions))];
            expression = [expressions{1:end-1}];
        end
    end
    IDs = {};
    expression = lower( expression );
    expression(expression == '-') = '_';
    % Replace 'and', 'or', and 'not' by corresponding MATLAB symbols.
    expression = regexprep(expression, '\s+and\s+', ' & ', 'ignorecase');
    expression = regexprep(expression, '\s+or\s+', ' | ', 'ignorecase');
    expression = regexprep(expression, '\s+not\s+', ' ~', 'ignorecase');
    expression = regexprep(expression, '\(not\s+', '(~', 'ignorecase');
    rest = regexprep(expression, '[A-Za-z0-9_-]|(?<=[A-Za-z0-9_-])[/\\]', '');
    assert( all(ismember(rest, [char([9 10]) '|&~() '])), ...
            ['Given property string contains characters'...
             'which could not be parsed: ''%s'''], rest );
    if startsWith( expression, 'not ' )
        expression = expression(4:end);
        expression(1) = '~';
    end
    % Assume properties are made up letters, can include a hyphen
    % or a white space character, and there is no case sensitivity.
    property_pat = '[A-Za-z][A-Za-z0-9\s_-]*';
    [idx_props_start, idx_props_end] = regexp( expression, property_pat );
    for idx = fliplr( [idx_props_start; idx_props_end] )
        p = shrink_property(expression(idx(1):idx(2)));
        expression = [ expression(1:idx(1)-1) p expression(idx(2)+1:end)];
    end
    [idx_props_start, idx_props_end] = regexp(expression, property_pat );
    ind = 1;
    new_expression = '';
    for idx = [idx_props_start; idx_props_end]
        p = expression(idx(1):idx(2));
        if ~ismember(p, supported_properties)
            fprintf( 2, 'A given property is not supported: ''%s''.\n', p );
        end
        mod_prop = ['(isfield(mp, ''' p ''') && all(mp.' p '))'];
        trunc_exp = expression(ind:end);
        % Find where the property is in the expression.
        prop_index = strfind(trunc_exp, p);
        % Take anything before the property and append the modified
        % version of the property.
        new_expression = [new_expression, ...
                          trunc_exp(1:prop_index(1)-1), ...
                          mod_prop];  %#ok<AGROW>
        % Move the index after the property that was replaced.
        ind = ind + prop_index(1) + numel(p) - 1;
    end
    new_expression = [new_expression, expression(ind:end)];

    % Find matrices whose properties satisfy the specified logical expression.
    k = 0;
    for matrix_properties = properties.'
        mp = shrink_property(matrix_properties{1});  %#ok<NASGU>
        k = k + 1;
        % Test if the expression is true for this matrix and add it's ID.
        if eval(new_expression)
            IDs = [IDs; matrix_IDs{k}];  %#ok<AGROW>
        end
    end
end

% Generate a specified matrix with the given parameters, if any.
function varargout = generate_matrix(matrix_ID, matrix_IDs, varargin)
    [~, group_name, matrix_name] = find_matrixID( matrix_ID, matrix_IDs );
    handle = str2func(['anymatrix_', group_name]);
    if ~isempty(varargin)
        [varargout{1:max(1,nargout)}] = handle(matrix_name, varargin{:});
    else
        [varargout{1:max(1,nargout)}] = handle(matrix_name);
    end
end

% Display help info of a specified matrix.
function show_matrix_help(matrix_ID, matrix_IDs)
    [matrix_ID, group_name, matrix_name] = find_matrixID( matrix_ID, ...
                                                          matrix_IDs );
    if strcmp('gallery', group_name)
        help(['private/', matrix_name]);
    elseif strcmp('matlab', group_name)
        help(matrix_name);
    else
        help(replace(matrix_ID, '/', '/private/'));
    end
end

% Look for a pattern inside all matrix help comments in the collection.
function found_IDs = lookfor_term(matrix_IDs, root_path, term)
    assert(~isempty(term), ...
           'Anymatrix command was not recognized (too less inputs).');
    found_IDs = {};
    for ID_cell = matrix_IDs.'
        matrix_ID = ID_cell{1};
        slashloc = find(matrix_ID == '/');
        group_name = matrix_ID(1:slashloc-1);
        matrix_name = matrix_ID(slashloc+1:end);
        path_to_mat = [root_path '/' group_name '/private/' matrix_name];
        if strcmp('gallery', group_name)
            H = help(['private/' matrix_name]);
        elseif strcmp('matlab', group_name)
            H = help(matrix_name);
        else
            H = help(path_to_mat);
        end
        if contains(H, term, 'IgnoreCase', true)
            found_IDs = [found_IDs; matrix_ID];  %#ok<AGROW>
            fprintf( '!' )
        else
            fprintf( '.' )
        end
    end
    fprintf( '\n' )
end

% Display info in the Contents.m of a specified group.
function show_contents(group_IDs, root_path, group_ID)
    assert(ismember(group_ID, group_IDs), ...
           'The specified group ID was not found.');
    assert(isfile([root_path '/' group_ID '/private/Contents.m']), ...
           'No Contents.m exists for that group.');
    type([root_path '/' group_ID '/private/Contents.m'])
end

function g = read_groups(group_IDs, matrix_IDs, group_ID)
    if strcmp(group_ID,'*')
        g = matrix_IDs;
    else
        assert(ismember(group_ID, group_IDs), ...
               'The specified group ID was not found.');
        g = matrix_IDs(contains(matrix_IDs, [group_ID '/']));
    end
end


% Run a testsuite of a particular group.
function run_group_tests(group_ID, root_path)
    handle = str2func(['anymatrix_' group_ID]);
    test_func = 'test_run';
    if isfile([root_path '/' group_ID '/private/' test_func '.m'])
        handle(test_func);
    else
        fprintf('Group %s does not contain any tests. \n', group_ID);
    end
end

function ret = is_matrixID(str)
    matrix_ID_pat = '^[A-Za-z][A-Za-z0-9_-]*/[A-Za-z][A-Za-z0-9_-]*$';
    ret = ~isempty( regexp( str, matrix_ID_pat, 'once' ) );
end

function [matrix_ID, group_name, matrix_name] = find_matrixID( matrix_ID, matrix_IDs, do_error )
    group_name = '';
    matrix_name = '';
    if nargin <= 2
        do_error = 1;
    end
    slashloc = find(matrix_ID == '/', 1);
    if ~isempty(slashloc)  && ~isequal(slashloc,1)
        return
    end
    idx = contains(matrix_IDs, matrix_ID);
    switch nnz(idx)
        case 0
            str = 'Specified matrix ID was not found.';
            if do_error
                error(str);
            else
                matrix_ID = [];
            end
        case 1
            matrix_ID = matrix_IDs{idx};
            if do_error
                fprintf(['Group name of matrix-ID is not given. '...
                         'I did select: ''%s''\n'], matrix_ID );
            end
        otherwise
            str = ['Specified matrix ID is ambigous.'...
                   'Add the group name to the matrix-ID.'];
            if do_error
                error(str);
            else
                matrix_ID = matrix_IDs{idx};
            end
    end

    slashloc = find(matrix_ID == '/');
    group_name = matrix_ID(1:slashloc-1);
    matrix_name = matrix_ID(slashloc+1:end);
end


%#ok<*MCHLP>
%#ok<*MCCD>

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
    
    [arg, command, varargin] = parse_input( varargin{:} );

    capture_some_common_errors()

    % Execute the specified command.
    if isempty( command )
        fprintf( 'Type ``help anymatrix`` or ``anymatrix xyz``` to get help on anymatrix or topic ''xyz''.\n' );
    elseif startsWith('all', command)
        varargout{1} = matrix_IDs;

    elseif startsWith('root_path', command)
        assert(numel(varargin) == 0, ...
               'Anymatrix command was not recognized (too many inputs).' );
        varargout{1} = root_path;

    elseif startsWith('contents', command)
        assert(numel(varargin) == 2, ...
               'Anymatrix command was not recognized (too many inputs).' );
        assert(ismember(arg, group_IDs), ...
               'The specified group ID was not found.');
        show_contents(arg, root_path);

    elseif startsWith('groups', command) && numel(varargin) == 3
        update_git_group(arg, varargin{3}, root_path);

    elseif startsWith('groups', command) && isempty( arg )
        assert(numel(varargin) == 0, ...
               'Anymatrix command was not recognized (too many inputs).' );
        varargout{1} = group_IDs;

    elseif startsWith('groups', command) && numel(varargin) == 2
        assert(~isempty(arg), ...
               'Anymatrix command was not recognized (too less inputs).' );
        assert(ismember(arg, group_IDs), ...
               'The specified group ID was not found.');
        varargout{1} = matrix_IDs(contains(matrix_IDs, [arg, '/']));

    elseif startsWith('help', command)
        if isempty( arg )
            help anymatrix
        else
            do_help(arg, matrix_IDs)
        end

    elseif startsWith('lookfor', command)
        assert(~isempty(arg), ...
               'Anymatrix command was not recognized (too less inputs).' );
        varargout{1} = lookfor_term(arg, matrix_IDs, root_path);

    % we check 'properties' before 'path',
    % so that 'p' becomes an abbreviation for 'properties'
    elseif startsWith('properties', command)
        varargout{1} = do_properties(matrix_IDs, properties, ...
                                     supported_properties, arg, varargin{:} );

    elseif startsWith('path', command)
        varargout{1} = do_path(arg, root_path);

    elseif startsWith('scan', command)
        scan_filesystem(root_path, true);

    elseif startsWith('sets', command) && isempty(arg)
        varargout{1} = set_IDs;

    elseif startsWith('sets', command)
        assert(ismember(arg, set_IDs), ...
               'ID of the specified set was not found.');
        [varargout{1:2}] = do_sets(root_path, arg);

    elseif startsWith('test', command)
        assert(ismember(arg, group_IDs), ...
               'The specified group ID was not found.');
        do_test(group_IDs, arg, root_path)

    else
        [varargout{1:nargout}] = generate_matrix(command, matrix_IDs, ...
                                                 varargin{2:end});

    end

end

%%
function add_to_path(root_path)
    % Add anymatrix/sets and anymatrix/testing to the search path.
    persistent added
    if isempty(added)
        added = true;
        addpath(root_path);
        addpath([root_path, '/sets']);
        addpath([root_path, '/testing']);
        fprintf( 'Anymatrix installed. Type `savepath` to make the installation permament.\n' );
    end
end

function str = do_path(arg, root_path)
    slashloc = find(arg == '/');
    group_name = arg(1:slashloc-1);
    matrix_name = arg(slashloc+1:end);
    str = [fullfile(root_path, group_name, 'private', matrix_name) '.m'];
end

function do_help( arg, matrix_IDs )
    if isempty( arg )
        help anymatrix;
    else
        show_matrix_help(arg, matrix_IDs);
    end
end

function out = do_properties(matrix_IDs, properties, ...
                             supported_properties, arg, varargin )
    if isempty(arg)
        [~, I] = sort(supported_properties);
        out = supported_properties(I);
    elseif is_matrixID(arg)
        assert(ismember(arg, matrix_IDs), 'Specified matrix ID not found.');
        [~, I] = sort(properties{strcmp(matrix_IDs, arg)});
        out = properties{strcmp(matrix_IDs, arg)}(I);
    else
        out = search_by_properties(matrix_IDs, properties, ...
                                   supported_properties, varargin(2:end));
    end
end

function [S, matrices] = do_sets(root_path, arg)
    S = readcell( [root_path '/sets/' arg '.txt'], ...
                  'Delimiter',':', 'CommentStyle','%', ...
                  'Whitespace', ' \n');
    m_idx = 2;
    matrices = {};
    % Generate matrices using parameters specified in the set.
    for index = 1:size(S,1)
        if ismissing(S{index, 2})
            matrices{m_idx} = eval(['generate_matrix(''' ...
                S{index, 1} ''')']);  %#ok<AGROW>
        else
            matrices{m_idx} = eval(['generate_matrix(''', ...
                S{index, 1}, ''',', num2str(S{index, 2}), ')']);  %#ok<AGROW>
        end
        m_idx = m_idx + 1;
    end
end

function do_test(group_IDs, arg, root_path)
    if isempty( arg )
        for group_id = group_IDs.'
            run_group_tests(group_id{1}, root_path);
        end
    else
        run_group_tests(arg, root_path);
    end
end


%%

function [arg, command, varargin] = parse_input( varargin )
    arg = [];
    command = [];
    if numel(varargin) == 0
        return;
    end

    varargin = string_to_char( varargin{:} );
    assert(ischar(varargin{1}), 'Anymatrix command was not recognized');
    command = varargin{1};
    if numel( varargin ) >= 2
        arg = varargin{2};
        if ischar(varargin{2}) && any(startsWith({ ...
                'properties', ...
                'groups', 'sets', 'all', 'scan', 'help', 'test', ...
                'lookfor', 'contents'}, varargin{2}))
            command = varargin{2};
            arg = varargin{1};
        end
        % Allow use of hyphens instead of underscores, but replace here.
        if ischar(arg) && ~any(startsWith({'properties', 'lookfor', ...
                                           'sets'}, command))
            arg = strrep(arg, '-', '_');
        end
    end
    % Hyphens -> underscores in matrix IDs.
    command = strrep(command, '-', '_');
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
    expression = expressions{1};
    for i = 2:numel( expressions )
        expression = [expression ' and ' expressions{i}];  %#ok<AGROW>
    end
    IDs = {};
    expression = lower( expression );
    expression(expression == '_') = '-';
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
    ind = 1;
    new_expression = '';
    for idx = [idx_props_start; idx_props_end]
        p = strtrim(expression(idx(1):idx(2)));
        if ~ismember(p, supported_properties)
            fprintf( 2, 'A given property is not supported: ''%s''.\n', p );
        end
        mod_prop = ['ismember(''' strrep(p, '-', ' ') ''', ' ...
                                 'strrep(matrix_properties{1}, '...
                                         '''-'', '...
                                         ''' '')' ...
                             ')'
                   ];
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
        k = k + 1;
        % Test if the expression is true for this matrix and add it's ID.
        if eval(new_expression)
            IDs = [IDs; matrix_IDs{k}];  %#ok<AGROW>
        end
    end
end

% Generate a specified matrix with the given parameters, if any.
function varargout = generate_matrix(matrix_ID, matrix_IDs, varargin)
    matrix_ID = find_matrixID( matrix_ID, matrix_IDs );
    slashloc = find(matrix_ID == '/');    
    group_name = matrix_ID(1:slashloc-1);
    matrix_name = matrix_ID(slashloc+1:end);
    handle = str2func(['anymatrix_', group_name]);
    if ~isempty(varargin)
        [varargout{1:max(1,nargout)}] = handle(matrix_name, varargin{:});
    else
        [varargout{1:max(1,nargout)}] = handle(matrix_name);
    end
end

% Display help info of a specified matrix.
function show_matrix_help(matrix_ID, matrix_IDs)
    matrix_ID = find_matrixID( matrix_ID, matrix_IDs );
    slashloc = find(matrix_ID == '/');
    group_name = matrix_ID(1:slashloc-1);
    matrix_name = matrix_ID(slashloc+1:end);
    if strcmp('gallery', group_name)
        help(['private/', matrix_name]);
    elseif strcmp('matlab', group_name)
        help(matrix_name);
    else
        help(replace(matrix_ID, '/', '/private/'));
    end
end

% Look for a pattern inside all matrix help comments in the collection.
function found_IDs = lookfor_term(term, matrix_IDs, root_path)
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
function show_contents(group_ID, root_path)
    assert(isfile([root_path '/' group_ID '/private/Contents.m']), ...
           'No Contents.m exists for that group.');
    type([root_path '/' group_ID '/private/Contents.m'])
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

function ret = is_matrixID( str )
    matrix_ID_pat = '^[A-Za-z][A-Za-z0-9_-]*/[A-Za-z][A-Za-z0-9_-]*$';
    ret = ~isempty( regexp( str, matrix_ID_pat, 'once' ) );
end

function matrix_ID = find_matrixID( matrix_ID, matrix_IDs )
    slashloc = find(matrix_ID == '/', 1);
    if ~isempty(slashloc)
        return
    end
    idx = contains(matrix_IDs, matrix_ID);
    switch nnz(idx)
        case 0
            error('Specified matrix ID was not found.');
        case 1
            matrix_ID = matrix_IDs{idx};
            fprintf(['Group name of matrix-ID is not given. '...
                     'I did select: ''%s''\n'], matrix_ID );
        otherwise
            error(['Specified matrix ID is ambigous.'...
                    'Add the group name to the matrix-ID.']);
    end
end

%#ok<*MCHLP>
%#ok<*MCCD>


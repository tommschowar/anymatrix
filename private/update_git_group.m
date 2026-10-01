% Create or update a specified git group.

% Changelog:    tommsch,    2026-10-01,     .gitignore file is generated on cloning
%                                           anymatrix_[group_ID] file is copied out of repo instead of moved
function update_git_group(group_ID, repo_ID, root_path)
    group_folder = [root_path '/' group_ID '/'];
    if (~isfolder(group_folder) || ...
        numel(dir(group_folder)) == 2 ...
       )
        clone_it(repo_ID, group_ID, group_folder);
    else
        update_it(group_folder);
    end
    scan_filesystem(root_path, true);
end

function clone_it(repo_ID, group_ID, group_folder)
    if (count(repo_ID, '/') > 1 || ...
        contains(repo_ID, ':') || ...
        contains(repo_ID, '@') ...
       )
        status = system([
            'git clone "' repo_ID '" "' group_folder 'private"'], '-echo');
    else
        status = system([ ...
            'git clone "https://github.com/' repo_ID ...
            '.git" "' group_folder 'private"'], ...
            '-echo');
    end
    if status == 0
        disp('Anymatrix remote group cloned.');
        run_setup_function([group_folder 'private/']);
    else
        rmdir(group_folder, 's');
        return
    end

    % Create a bridge file to the private/ dir of the group.
    if (isfile([...
            group_folder 'private/anymatrix_' group_ID '.m']) ...
       )
        copyfile( ...  % do not move the file, since we must not change the git repository
            [group_folder 'private/anymatrix_' group_ID '.m'], ...
            [group_folder 'anymatrix_' group_ID '.m'] ...
                );
    else
        fid1 = fopen([group_folder ...
                        'anymatrix_' ...
                        group_ID ...
                        '.m'], 'w');
        if fid1 ~= -1
            close_fid1 = onCleanup( @() fclose(fid1) );
            temp = ['function varargout = anymatrix_' ...
                          group_ID ...
                          '(matrix_name, varargin)\n' ...
                          'handle = str2func(matrix_name);\n' ...
                          '[varargout{1:nargout}]' ...
                          '= handle(varargin{1:nargin-1});\n end'];
            fprintf(fid1, temp);
        else
            warning('Could not generate file: ''anymatrix_%s.m''\n', group_ID);
        end
    end

    %create .gitignore file
    fid2 = fopen([group_folder '.gitignore'], 'w');
    if fid2 ~= -1
        close_fid2 = onCleanup( @() fclose(fid2) );
        fprintf( fid2, ['*' newline] );
    else
        warning('Could not generate file: ''.gitignore''\n');
    end

end

function update_it(group_folder)
    if ~isfolder([group_folder 'private/.git'])
        error('Something broke in the folder %s\n. I am not able to fix this by myself.', group_folder );
    else
        [exit_code, output] = system('git pull', '-echo');  %#ok<ASGLU>
        repository_changed = ~strcmp(output, ...
                                     ['Already up-to-date.' newline]);
        if repository_changed
            run_update_function([group_folder 'private/']);
        end
    end
end


%%

% Run function if present.
function run_function_if_present(new_folder, function_name)
    current_folder = cd(new_folder);
    if exist([function_name '.m'], 'file')
        fprintf('Running function %s()...', function_name);
        feval(function_name);
        fprintf('done.\n');
    end
    cd(current_folder);
end

% Try to run function setup() if current group has one.
function run_setup_function(group_private_folder)
    run_function_if_present(group_private_folder, 'setup');
end

% Try to run function update() if current group has one.
function run_update_function(group_private_folder)
    run_function_if_present(group_private_folder, 'update');
end

%#ok<*MCMFL>
%#ok<*MCCD>

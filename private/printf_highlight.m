function printf_highlight(str, term)
%HIGHLIGHTTERM Print a string, showing every occurrence of a term in red.
%   highlightTerm(str, term) prints str to the command window. Each
%   occurrence of term is printed in red (case-sensitive).
%
%   Example:
%       printf_highlight('The cat sat on the mat. The end.', 'The')

    % Start/end indices of all (non-overlapping) matches
    startIdx = strfind(str, term);
    n = numel(term);

    pos = 1;
    for k = 1:numel(startIdx)
        s = startIdx(k);
        if s < pos   % skip overlapping matches
            continue
        end
        % Plain text before the match
        fprintf('%s', str(pos:s-1));
        % Red match; style '[1,0,0]' sets an RGB colour for the text
        fprintf(2, '%s', str(s:s+n-1));
        pos = s + n;
    end

    % Remaining text after the last match
    fprintf('%s\n', str(pos:end));
end

function [ arg ] = str2numt( arg );
% wrapper for str2num
% only calls function, when argument is of type char or string
    if( ischar(arg) || isstring(arg) );
        arg = str2num( arg ); end;  %#ok<ST2NM>
end

function dummy; end  %#ok<DEFNU>  % Generates an error, if the 'end' of a function is missing.
%#ok<*NOSEL,*NOSEMI,*ALIGN>

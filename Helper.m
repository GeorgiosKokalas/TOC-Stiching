% function name: Helper
% Purpose: Directs to all the Helper functions in the program
% Called by: Multiple functions
% Inputs:
%   - varargin:     all the inputs of the experiment
% Outputs:
%   - output:       the output of the function called

function output = Helper(varargin)
    if length(varargin) < 1
        disp('No helper function specified. Returning...');
        return
    end

    switch varargin{1}
        case 'IsProperName'
            output = IsProperName(varargin{2});
            return;
        case 'FileNameAppend'
            output = FilenameAppend(varargin{2}, varargin{3});
            return;
        otherwise
            disp("Helper function name not recognized. Returning...");
            return;
    end
end


% function name: IsProperName
% Purpose: Checks to see if the name given is a proper filename (without the extension)  
% Called by:
%   - NEV_StichAcrossSpace
%   - NSX_StichAcrossSpace
% Inputs:
%   - input:        the string of characters that make up the filename  
% Outputs:
%   - result:       Boolean/Logic of whether or not the name is proper 
function result = IsProperName(input)
    result = isstring(input) && isscalar(input);
    result = result || (ischar(input) && isvector (input));
    result = result && ~contains(input, '.');
end


% Function name: FilenameAppend
% Role insert a file in a file collection based on its chronological relevance 
% Called by:
%   - GetFileNames
% Input:
%   - collection    the chronological collection of files
%   - filename      the name of the file to be inserted
% Output:
%   - collection    updated with the filename inserted
function collection = FilenameAppend(collection, filename)
    filename_str = string(filename);
    filename_char = char(filename);
    
    % Represents the chronological order of the files selected
    chrono_idx = 0;
    
    % Each chronological entry uses the filename (minus the NSP identifier and file extension as its signature 
    % Find if the current file's signature uses the signature of any of the chronological entries.
    % No signiature means a new entry. 
    for col_idx=1:length(collection)
        comparison = strcmp( filename_char( 1:(end-10) ), ...
            collection(col_idx).signature );
        if comparison
            chrono_idx = col_idx;
        end
    end
    
    % If new entry, make a new entry 
    % Else put the file in its entry
    if chrono_idx < 1
        collection = [collection, ...
            struct('signature', string( filename_char( 1:(end-10) ) ),...     % (1:end-10) ignores the _NSP-*.ns* section
            'files', filename_str )];
    else
        collection(chrono_idx).files = [collection(chrono_idx).files,...
            filename_str];
    end

end




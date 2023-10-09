% function name: GetFileNames
% Purpose: To gather the filenames of all relevant files
% Called by: TaskSticher_MAIN()
% Inputs:
%   - comment:      the comment that identifies our experiment
% Outputs:
%   - nsx_files:    a list of all the nsx filenames we will use
%   - nev_files:    a list of all the nev filenames we will use
%   - mode:         an identifier for the type of filestructure we are looking at 

% Assumed naming structure:
% EMU-001_PacMan_run-01_NSP-2.ns5
% \___________________/\____/\__/
%           1             2    3
% 1: Main name - used as chronological signature (assumed: EMU-001, EMU-002 etc.)   
% 2: NSP identifier - used to identify which NSP this file is from
% 3: extension (ext) - used to identify the sampling frequency

function [nsx_files, nev_files, mode] = GetFileNames(comment)
    
    nev_files = [];
    nsx_files = [];
    mode = struct('NSPs', 0, 'NSX_modes', [], 'Error', {});
    
    directory = pwd;
    filenames = dir;


    %% Filter out all nevs from the rest of the files
    all_nevs = [];
    for file_idx=1:length(filenames)
        if strcmp(filenames(file_idx).name((end-3):end), '.nev')                        % Checks the extension
            all_nevs = [all_nevs, string(filenames(file_idx).name)];
        end
    end
    
    % Assuming that the files are named chronologically, they can be sorted as such  
    sort(all_nevs);
 
    %% Go through the NEVs to see which ones are relevant
    for nev_idx=1:length(all_nevs)
        % Examine the NEVs using the custom function
        nev_struct = openNEVCustom( append(directory, '/', all_nevs(nev_idx)) );
        if strcmp(nev_struct.Comments, comment)
            %% How to handle the relevant NEV
            % Determine if the NEV is supposed to have a parallel pair
            nev_files = Helper('FileNameAppend', nev_files, all_nevs(nev_idx));

            %% How to handle the relevant NSXs from the NEV
            % Grab the needed NSxs
            derived_nsx = dir(append( all_nevs(file_idx).name(1:(end-4)), '.ns*' ));        % Replaces the .nev with a .ns*
            for nsx_idx=1:derived_nsx
                cur_nsx = char(derived_nsx(nsx_idx).name);

                % Find under which extension to place the file
                extension_idx = 0;
                for nsx_idx2 = 1:length(nsx_files)
                    if strcmp(nsx_files(nsx_idx2).extension_type, cur_nsx( (end-3):end ))       % (end-3:end) -> .ns3 or .ns5 etc.
                        extension_idx = nsx_idx2;
                    end
                end
                
                % If there is no extension category for this kind of extension, make one  
                if extension_idx < 1
                    nsx_files = [nsx_files, stuct('extension_type', cur_nsx( (end-3):end ), ...       % (end-3:end) -> .ns3 or .ns5 etc.
                        'ext_contents', [])];

                    nsx_files(end).ext_contents = ...
                        Helper('FileNameAppend', nsx_files(end).ext_contents, cur_nsx);                    
                else
                    nsx_files(extension_idx).ext_contents = ...
                        Helper('FileNameAppend', nsx_files(extension_idx).ext_contents, cur_nsx);  
                end              
            end
        end
    end
    clear all_nevs;

    %% Verify that parsing and categorization has been done successfully
    % Each error category increments per error instance spotted
            %% See if all NEVs have been successfully parsed
    % Give mode the proper amount of relevant NSPs
    mode.NSPs = length(nev_files(1).files);         % Uses first instance as base of judgement  
    mode.NSX_modes = zeros(mode.NSPs, 5);           % col = NSPs, row = possible sampling rates (ns1, 2, 3, 4 or 5)  
    mode.Error = [mode.Error, 0]; 

    % Check if all NEV signatures represent the same amount of NSPs
    % Otherwise, add an Error
    for nev_idx = 2:length(nev_files)
        if length(nev_files(nev_idx).files) ~= mode.NSPs
            mode.Error{end} = mode.Error{end} + 1;
        end
    end
    clear nev_idx;

            %% See if all NSXs have been successfully parsed
    % Check to see that we have the same chronology across all files
    % Each extension should have the same amount of chronological timestamps as each other and the NEV files
    mode.Error = [mode.Error, 0, zeros(length(nsx_files), 1)];
    for ext_idx = 1:length(nsx_files)
        % Check if NEV and NSX extension match
        if length(nsx_files(ext_idx).ext_contents) ~= length(nev_files)
            mode.Error{end-1} = mode.Error{end-1} + 1;
        end
        
        % Check if NSX extension matches with every other NSX extension
        for ext_idx2 = 1:length(nsx_files)
            if length(nsx_files(ext_idx).ext_contents) ~= length(nsx_files(ext_idx2).ext_contents)
                mode.Error{end}(ext_idx) = mode.Error{end}(ext_idx) + 1;            % each .ns* extension has its own error tracking  
            end
        end
    end
    clear ext_idx ext_idx2;


    % Check that the NEVs and the NSPs supposedly represent the correct amount of NSPs  
    % Also give us which type of file is used per NSP
    mode.Error = [mode.Error, zeros(length(nsx_files)), 1];
    for ext_idx = 1:length(nsx_files)

        % Check that each NSX extension is consistent with its NSPs 
        nsp_count = length(nsx_files(ext_idx).ext_contents(1).files);
        for ext_idx2 = 2:length(nsx_files(ext_idx).ext_contents)
            if length(nsx_files(ext_idx).ext_contents(ext_idx2).files) ~= nsp_count
                mode.Error{end-1}(ext_idx) = mode.Error{end-1}(ext_idx) + 1;
            end
        end
        clear ext_idx2;
        
        % Which NSP uses which sampling rates
        for ext_idx2 = 1:nsp_count
            curr_file = nsx_files(ext_idx).ext_contents(1).files(ext_idx2);
            curr_nsp = curr_file(end-4);
            curr_ext = curr_file(end);

            curr_nsp_n = str2double(curr_nsp);
            curr_ext_n = str2double(curr_ext);
            mode.NSX_modes(curr_nsp_n, curr_ext_n) = curr_ext_n; 
        end
        clear ext_idx2 curr_ext curr_nsp curr_ext_n curr_nsp_n curr_file;
  
        if length(nsx_files(ext_idx).ext_contents(1).files) == mode.NSPs
            mode.Error{end} = 0; 
        end
    end
    clear ext_idx

end

% Helper function - DEPRECATED see Helper instead
% Role insert a file in a file collection based on its chronological relevance 
% Input:
%   - collection    the chronological collection of files
%   - filename      the name of the file to be inserted
% Output:
%   - collection    updated with the filename inserted
% function collection = add_to_collection(collection, filename)
%     filename_str = string(filename);
%     filename_char = char(filename);
% 
%     % Represents the chronological order of the files selected
%     chrono_idx = 0;
% 
%     % Each chronological entry uses the filename (minus the NSP identifier and file extension as its signature 
%     % Find if the current file's signature uses the signature of any of the chronological entries.
%     % No signiature means a new entry. 
%     for col_idx=1:length(collection)
%         comparison = strcmp( filename_char( 1:(end-10) ), ...
%             collection(col_idx).signature );
%         if comparison
%             chrono_idx = col_idx;
%         end
%     end
% 
%     % If new entry, make a new entry 
%     % Else put the file in its entry
%     if chrono_idx < 1
%         collection = [collection, ...
%             struct('signature', string( filename_char( 1:(end-10) ) ),...     % (1:end-10) ignores the _NSP-*.ns* section
%             'files', filename_str )];
%     else
%         collection(chrono_idx).files = [collection(chrono_idx).files,...
%             filename_str];
%     end
% 
% end


%%  Dumped code
% nsx_files(extension_idx).contents = ...
%     add_to_collection(nsx_files(end).contents, cur_nsx);

% Replaces

% put_in_idx = 0;
%
% for nsx_idx3=1:length(nsx_files(end).contents)
%     comparison = strcmp( cur_nsx( 1:(end-10) ), ...
%         nsx_files(end).contents(nsx_idx3).signiature );
%     if comparison
%         put_in_idx = nsx_idx3;
%     end
% end
%
% if put_in_idx < 1
%     nsx_files(end).contents = [nsx_files(end).contents, ...
%         struct('signiature', nev_filename, 'files', [string(cur_nsx)] )];
% else
%     nsx_files(end).contents(put_in_idx).files =...
%         [nsx_files(end).contents(put_in_idx).files,...
%         string(cur_nsx)];
% end

%----------------------

% nsx_files(extension_idx).contents = ...
%     add_to_collection(nsx_files(extension_idx).contents, cur_nsx);

% Replaces
                   
% put_in_idx = 0;
%
% for nsx_idx3=1:length(nsx_files(extension_idx).contents)
%     comparison = strcmp( cur_nsx( 1:(end-10) ), ...
%         nsx_files(extension_idx).contents(nsx_idx3).signiature );
%     if comparison
%         put_in_idx = nsx_idx3;
%     end
% end
%
% if put_in_idx < 1
%     nsx_files(extension_idx).contents = [nsx_files(extension_idx).contents, ...
%         struct('signiature', nev_filename, 'files', [string(cur_nsx)] )];
% else
%     nsx_files(extension_idx).contents(put_in_idx).files =...
%         [nsx_files(extension_idx).contents(put_in_idx).files,...
%         string(cur_nsx)];
% end

%----------------------

% nev_files = add_to_collection(nev_files, all_nevs(nev_idx));

% Replaces
            
% char_filename = char(all_nevs(nev_idx));
% nev_filename = string(char_filename( 1:(end-10) ));
% 
% 
% put_in_idx = 0;
% for nev_idx2 = 1:length(nev_files)
%     if strcmp(nev_files(nev_idx2).signiature, nev_filename)
%         put_in_idx = nev_idx2;
%     end
% end
% 
% % If there is no parallel pair for the NEV, make a new entry for it
% % Otherwise put it in its parallel entry
% if put_in_idx < 1
%     nev_files = [nev_files, struct('signiature', nev_filename, ...
%         'files', [all_nevs(nev_idx)] )];
% else
%     nev_files(put_in_idx).files = [nev_files(put_in_idx).files,  all_nevs(nev_idx)];
% end

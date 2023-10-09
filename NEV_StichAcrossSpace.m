% function name: NEV_StichAcrossSpace
% Purpose: To chunk all NEV recordings from different NSPs that are supposed to be run 
%   in parallel to one another.
% Called by: TaskSticher_MAIN 
% Inputs:
%   - NEVs: vector that holds all the NEV stuctures to be stiched together 
%       (Could have put them individually, but this offers flexibility at
%       little extra development complexity)
%   - Filename: (optional) a string to specify what the name of this structure should be  
%   - Filepath: (optional) a string to specify where the structure is supposed to be located  
% Outputs:
%   - merged_nev: the NEV structure with all the data of the other ones.

function merged_nev = NEV_StichAcrossSpace (NEVs, Filename, Filepath)
    %% Perform preliminary checks
    % If we only have one NEV, there is no need to run this function
    if ~isvector(NEVs) || nargin < 1
        disp("NEV_StichAcrossSpace: There isn't enough NEV Data to stich together.")
        return;
    elseif length(NEVs) == 1
        merged_nev = NEVs(1);
        return;
    end

    % Check if we got a proper custom filename
    has_custom_filename = nargin >= 2 && Helper("IsProperName", Filename);

    % Check if we can use the custom filepath
    has_custom_filepath = nargin >= 3 && exist(Filepath, 'dir');
    
    
    %% Merge the NEVs
    % Use the first of the NEVs as the base for our output
    merged_nev = NEVs(1);

    % Loop through each subsequent NEV and add it to the merged structure.
    for nev_idx=2:length(NEVs)
        merged_nev.ElectrodesInfo = [merged_nev.ElectrodesInfo; NEVs(nev_idx).ElectrodesInfo];

        merged_nev.Data.Comment.Text = [merged_nev.Data.Comment.Text; NEVs(nev_idx).Data.Comment.Text];

        merged_nev.MetaTags.Comment = [merged_nev.MetaTags.Comment; NEVs(nev_idx).MetaTags.Comment];
        merged_nev.MetaTags.ChannelID = [ merged_nev.MetaTags.ChannelID,  NEVs(nev_idx).MetaTags.ChannelID];
    end
    
    % Make any changes from customization
    if has_custom_filepath
        merged_nev.MetaTags.FilePath = Filepath;
    end
    clear has_custom_filepath;

    if has_custom_filename
        merged_nev.MetaTags.Filename = Filename;
    else
        nev_name = char(merged_nev.MetaTags.Filename);
        nspless_name = nev_name(1:end-10);
        merged_nev.MetaTags.Filename = append(nspless_name, '_StSp');
        clear nev_name nspless_name;
    end
    clear has_custom_filename;
end
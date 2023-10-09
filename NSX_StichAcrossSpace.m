% function name: NSX_StichAcrossSpace
% Purpose: To chunk all NSX recordings from different NSPs that are supposed to be run 
%   in parallel to one another.
% Called by: TaskSticher_MAIN
% Inputs:
%   - NSXs: vector that holds all the NSX stuctures to be stiched together 
%       (Could have put them individually, but this offers flexibility at
%       little extra development complexity
%   - Filename: a string to specify what the name of this structure should be  
%   - Filepath: a string to specify where the structure is supposed to be located  
% Outputs:
%   - mergedNSx: the NSX structure with all the data of the other ones.

function merged_nsx = NSX_StichAcrossSpace (NSXs, Filename, Filepath)
    
    %% Prepare for the merging process.
    % establishing some checks based on the number of arguments given. 
    has_custom_filename = true;
    has_custom_filepath = true;

    if nargin < 1
        disp('No NSX vector provided. Aborting');
        return;
    elseif ~isvector(NSXs) 
        disp ('NSX structures are meant to be provided inside a vector. Aborting');
        return;
    elseif length(NSXs) < 2
        disp ( 'Not enough NSXs provided. Aborting,');
        return;
    end

    if nargin < 2 || ~Helper("IsProperName", Filename)
        has_custom_filename = false;   
    end
    
    if nargin < 3 || ~exist(Filepath, 'dir')
        has_custom_filepath = false;
    end
    
    % Create a stiching target. 
    merged_nsx = NSXs(1);


    % Make sure the files are compatible for space stiching  
    for nsx_idx=nsx_count:-1:2
        is_compatible = strcmp(merged_nsx.MetaTags.FileExt, NSXs(nsx_idx).MetaTags.FileExt) && ...
            merged_nsx.MetaTags.DataPoints == NSXs(nsx_idx).MetaTags.DataPoints && ...
            merged_nsx.MetaTags.Timestamp == NSXs(nsx_idx).MetaTags.Timestamp;

        if ~is_compatible
            NSXs(nsx_idx) = [];
        end
    end
    
    
    %% Begin the Merging process.
    % Make all appends
    for nsx_idx=2:length(NSXs)
        merged_nsx.MetaTags.ChannelID = [merged_nsx.MetaTags.ChannelID; NSXs(nsx_idx).MetaTags.ChannelID];
        merged_nsx.Data = [merged_nsx.Data; NSXs(nsx_idx).Data];
        merged_nsx.ElectrodesInfo = [merged_nsx.ElectrodesInfo; NSXs(nsx_idx).ElectrodesInfo];
    end
    
    % Make other changes
    if has_custom_filepath
        merged_nsx.MetaTags.FilePath = Filepath;
    end

    if has_custom_filename
        merged_nsx.MetaTags.Filename = Filename;
    else
        merged_nsx.MetaTags.Filename = append(merged_nsx.MetaTags.Filename, '_StSp');
    end

end
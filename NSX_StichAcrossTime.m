% function name: NSX_StichAcrossTime
% Purpose: To chunk all NSX recordings in chronological order
% Called by: TaskSticher_MAIN 
% Inputs:
%   - NSXs: vector that holds all the NSX stuctures to be stiched together 
%       (Could have put them individually, but this offers flexibility at
%       little extra development complexity
% Outputs:
%   - merged_nsx: the NSX structure with all the data of the other ones.

function merged_nsx = NSX_StichAcrossTime(NSXs)
    %% Do some preliminary checks
    if ~isvector(NSXs) || nargin < 1
        return;
    elseif length(NEVs) == 1
        merged_nsx = NSXs(1);
        return;
    end

    %% Chronologically stich the files
    merged_nsx = NSXs(1);
    for nsx_idx=2:length(NSXs)
        merged_nsx.Data = [merged_nsx.Data, NSXs(nsx_idx).Data];

        merged_nsx.MetaTags.DataPoints = merged_nsx.MetaTags.DataPoints + NSXs(nsx_idx).MetaTags.DataPoints;
        merged_nsx.MetaTags.DataDurationSec = merged_nsx.MetaTags.DataDurationSec + NSX(nsx_idx).MetaTags.DataDurationSec;
        merged_nsx.MetaTags.DataPointsSec = merged_nsx.MetaTags.DataPointsSec + NSX(nsx_idx).MetaTags.DataPointsSec;
    end

end


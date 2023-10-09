% function name: NEV_StichAcrossTime
% Purpose: To chunk all NEV recordings in chronological order
% Called by:TaskSticher_MAIN 
% Inputs:
%   - NEVs: vector that holds all the NEV stuctures to be stiched together 
%       (Could have put them individually, but this offers flexibility at
%       little extra development complexity
% Outputs:
%   - merged_nev: the NEV structure with all the data of the other ones.

function merged_nev = NEV_StichAcrossTime(NEVs)
    %% Do some preliminary checks
    if ~isvector(NEVs) || nargin < 1
        return;
    elseif length(NEVs) == 1
        merged_nev = NEVs(1);
        return;
    end

    %% Merge the NEVs
    merged_nev = NEVs(1);

    for nev_idx=2:length(NEVs)
        merged_nev.MetaTags.DataDuration = merged_nev.MetaTags.DataDuration + NEVs(nev_idx).MetaTags.DataDuration;
        
        merged_nev.Data.Spikes.Electrode      = [merged_nev.Data.Spikes.Electrode, NEVs(nev_idx).Data.Spikes.Electrode];
        merged_nev.Data.Spikes.TimeStamp      = [merged_nev.Data.Spikes.TimeStamp, NEVs(nev_idx).Data.Spikes.TimeStamp];
        merged_nev.Data.Spikes.Unit           = [merged_nev.Data.Spikes.Unit, NEVs(nev_idx).Data.Spikes.Unit];
        merged_nev.Data.Spikes.Waveform       = [merged_nev.Data.Spikes.Waveform, NEVs(nev_idx).Data.Spikes.Waveform];
        merged_nev.Data.Comments.TimeStamp    = [merged_nev.Data.Comments.TimeStamp, NEVs(nev_idx).Data.Comments.TimeStamp];
        merged_nev.Data.Comments.TimeStampSec = [merged_nev.Data.Comments.TimeStampSec, NEVs(nev_idx).Data.Comments.TimeStampSec];
        merged_nev.Data.Comments.CharSet      = [merged_nev.Data.Comments.CharSet, NEVs(nev_idx).Data.Comments.CharSet];
        merged_nev.Data.Comments.Color        = [merged_nev.Data.Comments.Color, NEVs(nev_idx).Data.Comments.Color];
        merged_nev.Data.Comments.Text         = [merged_nev.Data.Comments.Text; NEVs(nev_idx).Data.Comments.Text];
        if ~isempty(NEVs(nev_idx).Data.Tracking)
            for idx = 1:size(trackingFieldNames, 1)
                merged_nev.Data.Tracking.(trackingFieldNames{idx}).TimeStamp = [merged_nev.Data.Tracking.(trackingFieldNames{idx}).TimeStamp, NEVs(nev_idx).Data.Tracking.(trackingFieldNames{idx}).TimeStamp];
                merged_nev.Data.Tracking.(trackingFieldNames{idx}).TimeStampSec = [merged_nev.Data.Tracking.(trackingFieldNames{idx}).TimeStampSec, NEVs(nev_idx).Data.Tracking.(trackingFieldNames{idx}).TimeStampSec];
                merged_nev.Data.Tracking.(trackingFieldNames{idx}).ParentID = [merged_nev.Data.Tracking.(trackingFieldNames{idx}).ParentID, NEVs(nev_idx).Data.Tracking.(trackingFieldNames{idx}).ParentID];
                merged_nev.Data.Tracking.(trackingFieldNames{idx}).NodeCount = [merged_nev.Data.Tracking.(trackingFieldNames{idx}).NodeCount, NEVs(nev_idx).Data.Tracking.(trackingFieldNames{idx}).NodeCount];
                merged_nev.Data.Tracking.(trackingFieldNames{idx}).MarkerCount = [merged_nev.Data.Tracking.(trackingFieldNames{idx}).MarkerCount, NEVs(nev_idx).Data.Tracking.(trackingFieldNames{idx}).MarkerCount];
                merged_nev.Data.Tracking.(trackingFieldNames{idx}).MarkerCoordinates = [merged_nev.Data.Tracking.(trackingFieldNames{idx}).MarkerCoordinates NEVs(nev_idx).Data.Tracking.(trackingFieldNames{idx}).MarkerCoordinates];
            end
        end
    end
end


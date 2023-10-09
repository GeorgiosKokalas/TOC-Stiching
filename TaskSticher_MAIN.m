function [merged_nev_struct, merged_nsx_structs] = TaskSticher_MAIN(comment, ns_dir)
    
    %% Make some preliminary checks
    if nargin < 1
        disp("Cannot identify the files without the comment");
        return;
    end
    
    if nargin < 2
        ns_dir = '.';
    end

    %% Go to the correct spot
    cd(ns_dir);
    ns_dir = pwd;

    %% Obtain the NSXs and NEVs we will be working with
    [nsx_files, nev_files, mode] = GetFileNames(comment);
        
    
    %% Append all the NEVs first.
    nev_structs = [];
    for nev_idx = 1:length(nev_files)
        parallel_nevs = [];
        for nev_idx2 =1:length(nev_files(nev_idx).files)
            parallel_nevs = [parallel_nevs, ...
                openNEV(append(ns_dir, '/', nev_files(nex_idx).files(nev_idx2)), 'nosave')];
        end
        nev_structs = [nev_structs, NEV_StichAcrossSpace(parallel_nevs)];
        clear parallel_nevs;
    end
    
    merged_nev_struct = NEV_StichAcrossTime(nev_structs);
    
    %% Work on the NSXs
    merged_nsx_structs = [];

    % Work on each level of resolution separately
    for ext_idx=1:length(nsx_files)
        if length(nsx_files(ext_idx).ext_contents) < 2
            continue;
        end

        % First combine the first 2 timestamps together
        start_merge_ingr = [];
        for idx = 1:2
            sp_st_1 = [];           %space stiched 1st

             % Combine each of the 2 timestamps across space
            for nsx_idx=1:length(nsx_files(ext_idx).ext_contents(idx).files)
                sp_st_1 = [sp_st_1, ...
                    openNEV(append(ns_dir,'/',nsx_files(ext_idx).ext_contents(idx).files(nsx_idx)), 'nosave')];
            end
            start_merge_ingr = [start_merge_ingr, NSX_StichAcrossSpace(app1_sp)];
        end
        % merge product will be holding each iteration of the merged NSXs
        merge_product = NSX_StichAcrossTime(start_merge_ingr);
        clear start_merge_ingr sp_st_1 idx nsx_idx;
        
        % Work on the rest of the NSXs
        for nsx_idx=3:length(nsx_files(ext_idx).ext_contents)
            sp_st_ingr = [];  % 

            % Combine each new timestamp across space first
            for nsx_idx2=1:length(nsx_files(ext_idx).ext_contents(nsx_idx).files)
                sp_st_ingr = [sp_st_ingr, ...
                    openNEV(append(ns_dir,'/',nsx_files(ext_idx).ext_contents(nsx_idx).files(nsx_idx2)), 'nosave')];
            end
            sp_st_timestamp = NSX_StichAcrossSpace(sp_st_ingr);
            clear sp_st_ingr;

            merge_product = NSX_StichAcrossTime([merge_product, sp_st_timestamp]);
            clear stp_st_timestamp;
        end

        merged_nsx_structs = [merged_nsx_structs, merge_product];
        clear merge_product;
    end    
    
end


function [coding_params, param_dict] = get_coding_params()
    %%% HOGHOF
    coding_params.hoghof = {};
    coding_param = struct;
    coding_param.enc_type = 'hardbow';
    coding_param.codebook_size = 4000;
    codebook_file = '/net/per610a/export/das11f/plsang/trecvidmed/feature/codebook/idensetraj.hoghof/codebook.kmeans.4000.204.mat';
    load(codebook_file);
    coding_param.codebook = codebook;
    kdtree_file = '/net/per610a/export/das11f/plsang/trecvidmed/feature/codebook/idensetraj.hoghof/codebook.kmeans.4000.204.kdtree.mat';
    load(kdtree_file);
    coding_param.kdtree = kdtree;
    coding_params.hoghof{end+1} = coding_param;
    
    coding_param = struct;
    coding_param.enc_type = 'softbow';
    coding_param.codebook_size = 4000;
    codebook_file = '/net/per610a/export/das11f/plsang/trecvidmed/feature/codebook/idensetraj.hoghof/codebook.kmeans.4000.204.mat';
    load(codebook_file);
    coding_param.codebook = codebook;
    kdtree_file = '/net/per610a/export/das11f/plsang/trecvidmed/feature/codebook/idensetraj.hoghof/codebook.kmeans.4000.204.kdtree.mat';
    load(kdtree_file);
    coding_param.kdtree = kdtree;
    coding_params.hoghof{end+1} = coding_param;
    
    coding_param = struct;
    coding_param.enc_type = 'fisher';
    coding_param.codebook_size = 256;
    coding_param.dimred = 128;
    codebook_file = '/net/per610a/export/das11f/plsang/trecvidmed/feature/codebook/idensetraj.hoghof/codebook.gmm.256.128.mat';
    load(codebook_file);
    coding_param.codebook = codebook;
    lowproj_file = '/net/per610a/export/das11f/plsang/trecvidmed/feature/codebook/idensetraj.hoghof/lowproj.128.204.mat';
    load(lowproj_file);
    coding_param.low_proj =  low_proj;
    coding_params.hoghof{end+1} = coding_param;
    
    coding_param = struct;
    coding_param.enc_type = 'fisher';
    coding_param.codebook_size = 256;
    coding_param.dimred = 64;
    codebook_file = '/net/per610a/export/das11f/plsang/trecvidmed/feature/codebook/idensetraj.hoghof/codebook.gmm.256.64.mat';
    load(codebook_file);
    coding_param.codebook = codebook;
    lowproj_file = '/net/per610a/export/das11f/plsang/trecvidmed/feature/codebook/idensetraj.hoghof/lowproj.64.204.mat';
    load(lowproj_file);
    coding_param.low_proj =  low_proj;
    coding_params.hoghof{end+1} = coding_param;
    
    %%% MBH
    coding_params.mbh = {};
    coding_param = struct;
    coding_param.enc_type = 'hardbow';
    coding_param.codebook_size = 4000;
    codebook_file = '/net/per610a/export/das11f/plsang/trecvidmed/feature/codebook/idensetraj.mbh/codebook.kmeans.4000.192.mat';
    load(codebook_file);
    coding_param.codebook = codebook;
    kdtree_file = '/net/per610a/export/das11f/plsang/trecvidmed/feature/codebook/idensetraj.mbh/codebook.kmeans.4000.192.kdtree.mat';
    load(kdtree_file);
    coding_param.kdtree = kdtree;
    coding_params.mbh{end+1} = coding_param;
    
    coding_param = struct;
    coding_param.enc_type = 'softbow';
    coding_param.codebook_size = 4000;
    codebook_file = '/net/per610a/export/das11f/plsang/trecvidmed/feature/codebook/idensetraj.mbh/codebook.kmeans.4000.192.mat';
    load(codebook_file);
    coding_param.codebook = codebook;
    kdtree_file = '/net/per610a/export/das11f/plsang/trecvidmed/feature/codebook/idensetraj.mbh/codebook.kmeans.4000.192.kdtree.mat';
    load(kdtree_file);
    coding_param.kdtree = kdtree;
    coding_params.mbh{end+1} = coding_param;
    
    coding_param = struct;
    coding_param.enc_type = 'fisher';
    coding_param.codebook_size = 256;
    coding_param.dimred = 128;
    codebook_file = '/net/per610a/export/das11f/plsang/trecvidmed/feature/codebook/idensetraj.mbh/codebook.gmm.256.128.mat';
    load(codebook_file);
    coding_param.codebook = codebook;
    lowproj_file = '/net/per610a/export/das11f/plsang/trecvidmed/feature/codebook/idensetraj.mbh/lowproj.128.192.mat';
    load(lowproj_file);
    coding_param.low_proj =  low_proj;
    coding_params.mbh{end+1} = coding_param;
    
    coding_param = struct;
    coding_param.enc_type = 'fisher';
    coding_param.codebook_size = 256;
    coding_param.dimred = 64;
    codebook_file = '/net/per610a/export/das11f/plsang/trecvidmed/feature/codebook/idensetraj.mbh/codebook.gmm.256.64.mat';
    load(codebook_file);
    coding_param.codebook = codebook;
    lowproj_file = '/net/per610a/export/das11f/plsang/trecvidmed/feature/codebook/idensetraj.mbh/lowproj.64.192.mat';
    load(lowproj_file);
    coding_param.low_proj =  low_proj;
    coding_params.mbh{end+1} = coding_param;
    
    %%% post processing, add output dimension & stats_dimnesion (for fisher vector)
    [coding_params, param_dict] = post_process(coding_params);
end

function [coding_params, param_dict] = post_process(coding_params)
    descs = fieldnames(coding_params);
    param_dict = struct;
    for ii=1:length(descs),
        desc = descs{ii};
        for jj=1:length(coding_params.(desc)),
            coding_param = coding_params.(desc){jj};
            if strcmp(coding_param.enc_type, 'fisher') == 1,
                coding_params.(desc){jj}.output_dim = 2*coding_param.codebook_size*coding_param.dimred;
                coding_params.(desc){jj}.stats_dim = 1 + coding_param.codebook_size*(2*coding_param.dimred + 1);
                coding_params.(desc){jj}.feature_pat = sprintf('idensetraj.%s.%s.cb%d.pca%d', desc, coding_param.enc_type, coding_param.codebook_size, coding_param.dimred);
            else
                coding_params.(desc){jj}.output_dim = coding_param.codebook_size;
                coding_params.(desc){jj}.feature_pat = sprintf('idensetraj.%s.%s.cb%d', desc, coding_param.enc_type, coding_param.codebook_size);
            end
            
            if strcmp(desc, 'hoghof'),
                coding_params.(desc){jj}.desc_dim = 204;
                coding_params.(desc){jj}.start_idx = 1;
                coding_params.(desc){jj}.end_idx = 204;
            elseif strcmp(desc, 'mbh'),
                coding_params.(desc){jj}.desc_dim = 192;
                coding_params.(desc){jj}.start_idx = 205;
                coding_params.(desc){jj}.end_idx = 396;
            end
            
            key = strrep(coding_params.(desc){jj}.feature_pat, '.', '');
            param_dict.(key) = coding_param;
        end
    end
end


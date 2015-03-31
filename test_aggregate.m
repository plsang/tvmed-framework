function test_aggregate(video_id)
    set_env;
    
    %seg_file = '/net/per610a/export/das11f/plsang/trecvidmed/feature/med.pooling/idensetraj.hoghof.fisher.cb256.pca128/LDC2011E41/MED11EvaluationData/video/MED11TEST/HVC256384.mat';
    fisher_params = struct;
    fisher_params.grad_weights = false;		% "soft" BOW
    fisher_params.grad_means = true;		% 1st order
    fisher_params.grad_variances = true;	% 2nd order
    fisher_params.alpha = single(1.0);		% power normalization (set to 1 to disable)
    fisher_params.pnorm = single(0.0);		% norm regularisation (set to 0 to disable)
    
    fprintf('Loading metadata...\n');
	medmd_file = '/net/per610a/export/das11f/plsang/trecvidmed14/metadata/medmd_2014_devel_ps.mat';
	
	load(medmd_file, 'MEDMD'); 
	metadata = MEDMD.lookup;
    
    coding_params = get_coding_params();
    
    descs = fieldnames(coding_params);
    
    fea_dir = '/net/per610a/export/das11f/plsang/trecvidmed/feature';
    
    for ii=1:length(descs),
        desc = descs{ii};
        for jj=1:length(coding_params.(desc)),
            seg_output_file = sprintf('%s/%s/%s/%s/%s.mat', fea_dir, 'med.pooling', coding_params.(desc){jj}.feature_pat, fileparts(metadata.(video_id)), video_id);
            video_output_file = sprintf('%s/%s/%s/%s/%s.mat', fea_dir, 'med.pooling.video', coding_params.(desc){jj}.feature_pat, fileparts(metadata.(video_id)), video_id);
            code1 = load(video_output_file);
            code1 = code1.code;
            enc_param = coding_params.(desc){jj};
            if strcmp(enc_param.enc_type, 'fisher') == 1,
                stats_output_file = sprintf('%s/%s/%s/%s/%s.stats.mat', fea_dir, 'med.pooling', coding_params.(desc){jj}.feature_pat, fileparts(metadata.(video_id)), video_id);
                stats = load(stats_output_file);    
                stats = sum(stats.code, 2);
                cpp_handle = mexFisherEncodeHelperSP('init', enc_param.codebook, fisher_params);
                code2 = mexFisherEncodeHelperSP('getfkstats', cpp_handle, stats);
            else
                code2 = load(seg_output_file);    
                code2 = sum(code2.code, 2);
            end
            diff = abs(code1-code2);
            fprintf(' --%s: sum diff = %f, mean diff = %f \n', coding_params.(desc){jj}.feature_pat, sum(diff), mean(diff));
        end
    end
    
end

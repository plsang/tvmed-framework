%% calculating bg kernel
function calker_cal_bg_kernel(proj_name, exp_name, ker)

	bg_ker_path = sprintf('%s/kernels/%s/%s.background.mat', ker.calker_exp_dir, ker.dev_pat, ker.devname);
    
    if ~exist(bg_ker_path),
        fprintf('\tLoading background feats ... \n', ker.feat) ;	
        bg_feats = calker_load_feature(proj_name, exp_name, ker, 'bg');
        
        fprintf('\tCalculating background kernel ... \n', ker.feat) ;	
        %kernel = calcKernel(ker, feats);
        bg_kernel = bg_feats'*bg_feats;
        
        fprintf('\tSaving kernel ''%s''.\n', bg_ker_path) ;
        ssave(bg_ker_path, 'bg_kernel', 'bg_feats', '-v7.3');
    else
        fprintf('Skipped calculating kernel [%s]...\n', bg_ker_path);
    end		

end

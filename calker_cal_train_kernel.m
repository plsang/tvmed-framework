
function calker_cal_train_kernel(proj_name, exp_name, ker, event_id)

	feature_ext = ker.feat;

	kerPath = sprintf('%s/kernels/%s/%s', ker.calker_exp_dir, ker.dev_pat, ker.devname);
	
	scaleParamsPath = sprintf('%s/kernels/%s/%s.mat', ker.calker_exp_dir, ker.dev_pat, ker.scaleparamsName);

	[dev_hists, sel_feat] = calker_load_traindata(proj_name, exp_name, ker);
		
		if ker.feature_scale == 1,	
			fprintf('Feature scaling...\n');	
			[dev_hists, scale_params] = calker_feature_scale(dev_hists);	
			save(scaleParamsPath, 'scale_params');		
		end
		
		fprintf('\tSaving devel features for kernel %s ... \n', feature_ext) ;
		save(devHistPath, 'dev_hists', '-v7.3');
		save(selLabelPath, 'sel_feat');
		
	end
    
    heu_kerPath = sprintf('%s.heuristic.mat', kerPath);
    if ~exist(heu_kerPath),
        fprintf('\tCalculating devel kernel %s with heuristic gamma ... \n', feature_ext) ;	
        ker = calcKernel(ker, dev_hists);
        
        fprintf('\tSaving kernel ''%s''.\n', heu_kerPath) ;
        par_save( heu_kerPath, ker );
    else
        fprintf('Skipped calculating kernel [%s]...\n', heu_kerPath);
    end		

end

function par_save( output_file, ker )
	ssave(output_file, '-STRUCT', 'ker', '-v7.3');
end

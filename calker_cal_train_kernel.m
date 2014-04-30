
function calker_cal_train_kernel(proj_name, exp_name, ker)

	feature_ext = ker.feat;
	
	fprintf('Loading meta file \n');
	
	database = load(ker.prms.meta_file, 'database');
	database = database.database;
	
	if isempty(database)
		error('Empty metadata file!!\n');
	end
	
	calker_exp_dir = sprintf('%s/%s/experiments/%s-calker/%s%s', ker.proj_dir, proj_name, exp_name, ker.feat, ker.suffix);

	kerPath = sprintf('%s/kernels/%s/%s/%s-%s', calker_exp_dir, ker.dev_pat, ker.devname, ker.prms.eventkit, ker.prms.rtype);

	devHistPath = sprintf('%s/kernels/%s/%s.mat', calker_exp_dir, ker.dev_pat, ker.histName);
	selLabelPath = sprintf('%s/kernels/%s/%s.sel.mat', calker_exp_dir, ker.dev_pat, ker.histName);
	
	scaleParamsPath = sprintf('%s/kernels/%s/%s.mat', calker_exp_dir, ker.dev_pat, ker.scaleparamsName);
	
	log2g_list = ker.startG:ker.stepG:ker.endG;
	numLog2g = length(log2g_list);

	fprintf('\tLoading devel features for kernel %s ... \n', feature_ext) ;
	if exist(devHistPath),
		load(devHistPath);
		load(selLabelPath);
	else
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

	ker.sel_feat =  database.sel_idx & sel_feat;
	
	if ker.cross,
		parfor jj = 1:numLog2g,
			cv_ker = ker;
			log2g = log2g_list(jj);
			gamma = 2^log2g;	
			cv_ker.mu = gamma;
			cv_kerPath = sprintf('%s.gamma%s.mat', kerPath, num2str(gamma));
			
			if ~exist(cv_kerPath),
				fprintf('\tCalculating devel kernel %s with gamma = %f... \n', feature_ext, gamma) ;	
				cv_ker = calcKernel(cv_ker, dev_hists);
				
				fprintf('\tSaving kernel ''%s''.\n', cv_kerPath) ;
				par_save( cv_kerPath, cv_ker );
			else
				fprintf('Skipped calculating kernel [%s]...\n', cv_kerPath);
			end			
		end
	else
		heu_kerPath = sprintf('%s.heuristic.mat', kerPath);
		if ~exist(heu_kerPath),
			
			%ker = calcKernel(ker, dev_hists);
			distancePath = sprintf('%s/kernels/%s/%s.distance.mat', calker_exp_dir, ker.dev_pat, ker.devname);
			if exist(distancePath),
				fprintf('\tLoading distance matrix for feature [%s] ... \n', feature_ext) ;	
				load(distancePath, 'distmatrix');
			else
				fprintf('\tCalculating distance matrix for feature [%s] ... \n', feature_ext) ;	
				distmatrix = vl_alldist2(dev_hists, 'chi2') ;
				fprintf('\tSaving distance matrix for feature [%s] ... \n', feature_ext) ;	
				save(distancePath, 'distmatrix', '-v7.3');
			end
			%ker = calker_cal_kernel(ker, dev_hists);
			fprintf('\tCalculating devel kernel %s with heuristic gamma ... \n', feature_ext) ;	
			sel_matrix = distmatrix(ker.sel_feat, ker.sel_feat);	
			mu     = 1 ./ mean(sel_matrix(:)) ;
			ker.mu = mu;
			ker.matrix = exp(- mu * distmatrix) ;
			
			fprintf('\tSaving kernel ''%s''.\n', heu_kerPath) ;
			par_save( heu_kerPath, ker );
		else
			fprintf('Skipped calculating kernel [%s]...\n', heu_kerPath);
		end		
	end

end

function par_save( output_file, ker )
	ssave(output_file, '-STRUCT', 'ker', '-v7.3');
end

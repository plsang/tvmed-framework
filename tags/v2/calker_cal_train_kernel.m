
function calker_cal_kernel(proj_name, exp_name, ker)

	feature_ext = ker.feat;

	calker_exp_dir = sprintf('/net/per900a/raid0/plsang/%s/experiments/%s-calker/%s', proj_name, exp_name, ker.feat);

	kerPath = sprintf('%s/kernels/%s', calker_exp_dir, ker.devname);

	devHistPath = sprintf('%s/kernels/%s.mat', calker_exp_dir, ker.histName);

	log2g_list = ker.startG:ker.stepG:ker.endG;
	numLog2g = length(log2g_list);

	fprintf('\tLoading devel features for kernel %s ... \n', feature_ext) ;
	if exist(devHistPath),
		load(devHistPath);
	else
		dev_hists = calker_load_traindata(proj_name, exp_name, ker);
		fprintf('Scaling data...\n');
		dev_hists = scaledata(dev_hists, 0, 1);
		fprintf('Saving data...\n');
		save(devHistPath, 'dev_hists', '-v7.3');
	end

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
			fprintf('\tCalculating devel kernel %s with heuristic gamma ... \n', feature_ext) ;	
			ker = calcKernel(ker, dev_hists);
			
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

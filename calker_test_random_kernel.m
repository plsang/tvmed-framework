function calker_test_random_kernel(proj_name, exp_name, ker)


    % loading labels
    calker_exp_dir = sprintf('%s/%s/experiments/%s-calker/%s%s', ker.proj_dir, proj_name, exp_name, ker.feat, ker.suffix);

	calker_common_exp_dir = sprintf('%s/%s/experiments/%s-calker/common/%s', ker.proj_dir, proj_name, exp_name, ker.feat);

	fprintf('Loading test meta file \n');
	
	load(ker.prms.test_meta_file, 'database');
	
	if isempty(database)
		error('Empty metadata file!!\n');
	end
	
    n_event = length(database.event_names);
	events = database.event_ids;
	
	n_clip = size(database.clip_names, 2);	%% Update Sep 6, 2013
    fprintf('Number test clips: %d\n', n_clip);

    num_part = ceil(n_clip/ker.chunk_size);
    cols = fix(linspace(1, n_clip + 1, num_part+1));
		
	rr = ker.randnum;
	
	%scorePath = sprintf('%s/r-scores/%d/%s/%s.r%d.scores.mat', calker_exp_dir, ker.randim, ker.test_pat, ker.name, rr);
	scorePath = sprintf('%s/r-scores/%s/%s-%s/n%05d/r%03d/%s.%s.scores.mat', calker_exp_dir, ker.test_pat, ker.prms.eventkit, ker.prms.rtype, ker.randim, rr, ker.name, ker.type);
	
	if checkFile(scorePath), 
		fprintf('Skipped testing %s \n', scorePath);
		continue;
	end
	
	models = struct;
	scores = struct;
	
	for jj = 1:n_event,
		event_name = events{jj};
		
		%modelPath = sprintf('%s/models/%s.%s.%s.model.mat', calker_exp_dir, event_name, ker.name, ker.type);
		%modelPath = sprintf('%s/r-models/%d/%s.%s.%s.model.%d.mat', calker_exp_dir, ker.randim, event_name, ker.name, ker.type, rr);
		%modelPath = sprintf('%s/r-models/%d/%s-%s/%s.%s.%s.model.%d.mat', calker_exp_dir, ker.randim, ker.prms.eventkit, ker.prms.rtype, event_name, ker.name, ker.type, rr);
		modelPath = sprintf('%s/r-models/%s-%s/n%05d/r%03d/%s.%s.%s.model.mat', calker_exp_dir, ker.prms.eventkit, ker.prms.rtype, ker.randim, rr, event_name, ker.name, ker.type);
		
		if ~checkFile(modelPath),
			error('Model not found %s \n', modelPath);			
		end
		
		fprintf('Loading model ''%s''...\n', event_name);
		models.(event_name) = load(modelPath);
		tmp_scores{jj} = cell(num_part, 1);
		scores.(event_name) = [];
	end
	
		%load test partition
	for kk = 1:num_part,
		
		fprintf('-- [%d/%d] -- Testing...\n', kk, num_part);
		
		sel = [cols(kk):cols(kk+1)-1];
		part_name = sprintf('%s_%d_%d', ker.testname, cols(kk), cols(kk+1)-1);
		%kerPath = sprintf('%s/kernels/%s/%s.%s.mat', calker_exp_dir, ker.test_pat, part_name, ker.type);
		%kerPath = sprintf('%s/r-kernels/%s/%d/%s.%s.r%d.mat', calker_exp_dir, ker.test_pat, ker.randim, part_name, ker.type, rr);
		%distPath = sprintf('%s/r-kernels/%s/%d/%s.%s.r%d.mat', calker_exp_dir, ker.test_pat, ker.randim, part_name, ker.type, rr);
		distPath = sprintf('%s/r-kernels/%s/n%05d/r%03d/%s.%s.mat', calker_exp_dir, ker.test_pat, ker.randim, rr, part_name, ker.type);
		
		fprintf('Loading distance matrix %s ...\n', distPath); 
		testDist_ = load(distPath) ;
		testDist = testDist_.testDist;
		
		% fprintf('Loading kernel %s ...\n', kerPath); 
		% kernels_ = load(kerPath) ;
		% base = kernels_.matrix;
		%info = whos('base') ;
		%fprintf('\tKernel matrices size %.2f GB\n', info.bytes / 1024^3) ;
		
		% Nt = # test
		% N  = # train
		% [N, Nt] = size(base) ;

		parfor jj = 1:n_event,
			event_name = events{jj};
			
			%test_base = base(models.(event_name).train_idx, :);
			test_base = exp(- models.(event_name).gamma * testDist(models.(event_name).train_idx, :)) ;
			
			[N, Nt] = size(test_base); % Nt = # test ; % N  = # train
			
			%only test at svind
			%test_base = base(models.(event_name).svind,:);
			%sub_scores = models.(event_name).alphay' * test_base + models.(event_name).b;
			
			%[y, acc, dec] = svmpredict(zeros(Nt, 1), [(1:Nt)' base'], models.(event_name).libsvm_cl, '-b 1') ;		
			[y, acc, dec] = svmpredict(zeros(Nt, 1), [(1:Nt)' test_base'], models.(event_name).libsvm_cl, '-b 1 -q') ;		
			sub_scores = dec(:, 1)';
			
			tmp_scores{jj}{kk} = sub_scores;
		end
		
		%clear base;
	end
	
	for jj = 1:n_event,
		event_name = events{jj};
		scores.(event_name) = cat(2, tmp_scores{jj}{:});
	end
		
	%saving scores
	fprintf('\tSaving scores ''%s''.\n', scorePath) ;
	
	output_score_dir = fileparts(scorePath);
	if ~exist(output_score_dir, 'file'),
		mkdir(output_score_dir);
	end
	
	ssave(scorePath, '-STRUCT', 'scores') ;
	
end
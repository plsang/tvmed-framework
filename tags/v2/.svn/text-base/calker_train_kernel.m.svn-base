function calker_train_kernel(proj_name, exp_name, ker, events)

    test_on_train = 1;
	
	calker_exp_dir = sprintf('/net/per900a/raid0/plsang/%s/experiments/%s-calker/%s', proj_name, exp_name, ker.feat);

    traindb_file = fullfile(calker_exp_dir, 'metadata', 'traindb.mat');
	
    load(traindb_file, 'traindb');

    % event names
 
    n_event = length(events);

    all_labels = zeros(n_event, length(traindb.label));

    for ii = 1:length(traindb.label),
        for jj = 1:n_event,
            if traindb.label(ii) == jj,
                all_labels(jj, ii) = 1;
            else
                all_labels(jj, ii) = -1;
            end
        end
    end

    kerPath = sprintf('%s/kernels/%s', calker_exp_dir, ker.devname);
	
	for jj = 1:n_event,
		event_name = events{jj};
	
        modelPath = sprintf('%s/models/%s.%s.model.mat', calker_exp_dir, event_name, ker.name);
		
		if checkFile(modelPath),
			fprintf('Skipped training %s \n', modelPath);
			continue;
		end
		
		fprintf('Training event ''%s''...\n', event_name);	
		
		labels = double(all_labels(jj,:));
		posWeight = ceil(length(find(labels == -1))/length(find(labels == 1)));
		
		log2g_list = ker.startG:ker.stepG:ker.endG;
		numLog2g = length(log2g_list);
		
		if ker.cross,
			svm = cell(numLog2g, 1);
			maxacc = cell(numLog2g, 1);
			
			parfor jj = 1:numLog2g,
				cv_ker = ker;
				log2g = log2g_list(jj);
				gamma = 2^log2g;	
				
				cv_kerPath = sprintf('%s.gamma%s.mat', kerPath, num2str(gamma));
				fprintf('Loading kernel %s ...\n', cv_kerPath); 
				kernels_ = load(cv_kerPath) ;
				base = kernels_.matrix;

				fprintf('SVM learning with predefined kernel matrix...\n');
				[svm_, maxacc_] = calker_svmkernellearn(base, labels,   ...
								   'type', 'C',        ...
								   ...%'C', 10,            ...
								   'verbosity', 0,     ...
								   ...%'rbf', 1,           ...
								   'crossvalidation', 5, ...
								   'weights', [+1 posWeight ; -1 1]') ;
				fprintf(' cur acc = %f, at gamma = %f...\n', maxacc_, gamma);
				
				svm{jj} = svm_;
				maxacc{jj} = maxacc_;
				
			end
			
			maxacc = cat(1, maxacc{:});
			[~, max_idx] = 	max(maxacc);
			svm = svm{max_idx};
			gamma = 2^log2g_list(max_idx);
			fprintf(' best acc = %f, at gamma = %f...\n', maxacc(max_idx), gamma);
			
		else
			heu_kerPath = sprintf('%s.heuristic.mat', kerPath);
			fprintf('Loading kernel %s ...\n', heu_kerPath); 
			kernels_ = load(heu_kerPath) ;
			base = kernels_.matrix;
			
			fprintf('SVM learning with predefined kernel matrix...\n');
			svm = calker_svmkernellearn(base, labels,   ...
							   'type', 'C',        ...
							   ...%'C', 10,            ...
							   'verbosity', 0,     ...
							   ...%'rbf', 1,           ...
							   'crossvalidation', 5, ...
							   'weights', [+1 posWeight ; -1 1]') ;
							   
			gamma = kernels_.mu;
			clear kernels_;
		end
		

		svm = svmflip(svm, labels);

		svm.gamma = gamma;
		
		% test it on train
		if test_on_train,		
			if ker.cross,		
				cv_kerPath = sprintf('%s.gamma%s.mat', kerPath, num2str(gamma));
			else
				cv_kerPath = sprintf('%s.heuristic.mat', kerPath);
			end
			
			fprintf('Loading kernel %s ...\n', cv_kerPath); 
			kernels_ = load(cv_kerPath) ;
			base = kernels_.matrix;
			
			scores = svm.alphay' * base(svm.svind, :) + svm.b ;
			errs = scores .* labels < 0 ;
			err  = mean(errs) ;
			selPos = find(labels > 0) ;
			selNeg = find(labels < 0) ;
			werr = sum(errs(selPos)) * posWeight + sum(errs(selNeg)) ;
			werr = werr / (length(selPos) * posWeight + length(selNeg)) ;
			fprintf('\tSVM training error: %.2f%% (weighed: %.2f%%).\n', ...
			  err*100, werr*100) ;
			  
			% save model
			fprintf('\tNumber of support vectors: %d\n', length(svm.svind)) ;
			clear kernels_;
		end
		
		fprintf('\tSaving model ''%s''.\n', modelPath) ;
		ssave(modelPath, '-STRUCT', 'svm') ;	

	end
	

	
end
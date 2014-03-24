function calker_train_kernel(proj_name, exp_name, ker, events)

    
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

    kerPath = sprintf('%s/kernels/%s.mat', calker_exp_dir, ker.devname);
	
	if ~exist(kerPath, 'file'), 
		error('Kernel does not exist %s \n', kerPath);
	end;
	
	fprintf('Loading kernel %s ...\n', kerPath); 
	kernels_ = load(kerPath) ;
	base = kernels_.matrix;

	%base = base';

	info = whos('base') ;
	fprintf('\tKernel matrices size %.2f GB\n', info.bytes / 1024^3) ;

	%label?

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

		tic
		fprintf('SVM learning with predefined kernel matrix...\n');
		svm = svmkernellearn(base, labels,   ...
						   'type', 'C',        ...
						   'C', 10,            ...
						   'verbosity', 1,     ...
                           ...%'rbf', 1,           ...
						   'crossvalidation', 5, ...
						   'weights', [+1 posWeight ; -1 1]') ;
		toc

		svm = svmflip(svm, labels) ;

		% test it on train
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

		fprintf('\tSaving model ''%s''.\n', modelPath) ;
		ssave(modelPath, '-STRUCT', 'svm') ;
	end
	
	clear kernels_;
	
end
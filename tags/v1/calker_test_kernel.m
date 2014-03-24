function calker_test_kernel(proj_name, exp_name, ker, events)


    % loading labels
    calker_exp_dir = sprintf('/net/per900a/raid0/plsang/%s/experiments/%s-calker/%s', proj_name, exp_name, ker.feat);

	db_file = fullfile(calker_exp_dir, 'metadata', 'database_test.mat');

    load(db_file, 'database');


    n_event = length(events);

    all_labels = zeros(n_event, length(database.label));

    for ii = 1:length(database.label),
        for jj = 1:n_event,
            if database.label(ii) == jj,
                all_labels(jj, ii) = 1;
            else
                all_labels(jj, ii) = -1;
            end
        end
    end


    % number test kf
    n_test_kf = size(all_labels, 2);
    fprintf('Number test kf %d\n', n_test_kf);

    num_part = ceil(n_test_kf/10000);
    cols = fix(linspace(1, n_test_kf + 1, num_part+1));
	
	scorePath = sprintf('%s/scores/%s.scores.mat', calker_exp_dir, ker.name);
	
	%if checkFile(scorePath), 
	%	error('Skipped testing %s \n', scorePath);
	%end;
	
	for jj = 1:n_event,
		event_name = events{jj};
		
		modelPath = sprintf('%s/models/%s.%s.model.mat', calker_exp_dir, event_name, ker.name);
        
		if ~checkFile(modelPath),
			error('Model not found %s \n', modelPath);			
		end
		
		fprintf('Loading model ''%s''...\n', event_name);
		models.(event_name) = load(modelPath);
		scores.(event_name) = [];
	end
	
	%load test partition
	for kk = 1:num_part,
		sel = [cols(kk):cols(kk+1)-1];
        part_name = sprintf('%s_%d_%d', ker.testname, cols(kk), cols(kk+1)-1);
		kerPath = sprintf('%s/kernels/%s.mat', calker_exp_dir, part_name);
		
		fprintf('Loading kernel %s ...\n', kerPath); 
		kernels_ = load(kerPath) ;
		base = kernels_.matrix;
		info = whos('base') ;
		fprintf('\tKernel matrices size %.2f GB\n', info.bytes / 1024^3) ;
		
		for jj = 1:n_event,
			event_name = events{jj};
			fprintf('Testing model model ''%s''...\n', event_name);
			%only test at svind
			test_base = base(models.(event_name).svind,:);
			sub_scores = models.(event_name).alphay' * test_base + models.(event_name).b;
			scores.(event_name) = [scores.(event_name) sub_scores];
		end
		
		clear base;
	end
	
	%saving scores
	fprintf('\tSaving scores ''%s''.\n', scorePath) ;
	ssave(scorePath, '-STRUCT', 'scores') ;

end
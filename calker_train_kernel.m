function ker = calker_train_kernel(proj_name, exp_name, ker)

    fprintf('Loading background feature...\n');
    bg_feats = calker_load_feature(proj_name, exp_name, ker, 'bg');

    labels_ = cell(length(ker.event_ids), 1);
    train_feats = cell(length(ker.event_ids), 1);
    
    for ii=1:length(ker.event_ids),
        event_id = ker.event_ids{ii};
        fprintf('Loading event feature [%s]...\n', event_id);
        [train_feats{ii}, labels_{ii}] = calker_load_feature(proj_name, exp_name, ker, event_id);
    end
    
    train_feats = cat(2, train_feats{:});
    train_feats = [train_feats, bg_feats];
    
    labels = zeros(length(ker.event_ids), size(train_feats, 2));
    start_idx = 1;
    bg_start_idx = size(train_feats, 2) - size(bg_feats, 2)+1;
    
    for ii=1:length(ker.event_ids),
        end_idx = start_idx + length(labels_{ii}) - 1;
        labels(ii, start_idx:end_idx) = labels_{ii};
        labels(ii, bg_start_idx:end) = -ones(1, size(bg_feats, 2));
        
        if ker.strictova == 1,
            labels(ii, 1:start_idx-1) = -1;
            labels(ii, end_idx+1:bg_start_idx-1) = -1;
        end
        
        start_idx = start_idx + length(labels_{ii});
    end
        
    fprintf('\tCalculating %s kernel %s ... \n', ker.type, ker.feat) ;	
    
    if strcmp(ker.type, 'linear'),
		train_kernel = train_feats'*train_feats;
	elseif strcmp(ker.type, 'echi2'),
		%train_kernel = cal
		matrix = vl_alldist2(train_feats, 'chi2');
		mu     = 1 ./ mean(matrix(:)) ;
		train_kernel = exp(- mu * matrix) ;
		
		ker.mu = mu;
		clear matrix;
	else
		error('unknown ker type');
	end
    
    for kk = 1:length(ker.event_ids),
    
		event_id = ker.event_ids{kk};
        
        modelPath = sprintf('%s/models/%s-%s/%s.%s.%s.model.mat', ker.calker_exp_dir, ker.prms.eventkit, ker.prms.rtype, event_id, ker.name, ker.type);
		
		if checkFile(modelPath),
			fprintf('Skipped training %s \n', modelPath);
			continue;
		end
		
		fprintf('Training event ''%s''...\n', event_id);	
		
		labels_kk = labels(kk, :);
		
		train_idx = labels_kk ~= 0;
		labels_kk = labels_kk(train_idx);
		
		posWeight = ceil(length(find(labels_kk == -1))/length(find(labels_kk == 1)));
		
        base = train_kernel(train_idx, train_idx);	% selected features
        
        fprintf('SVM learning with predefined kernel matrix...\n');
    
        if ker.cross,
            model = calker_svmkernellearn(base, labels_kk,   ...
                               'type', 'C',        ...
                               ...%'C', 10,            ...
                               'verbosity', 0,     ...
                               ...%'rbf', 1,           ...
                               'crossvalidation', ker.cross, ...
                               'weights', [+1 posWeight ; -1 1]') ;
        else
            model = calker_svmkernellearn(base, labels_kk,   ...
                               'type', 'C',        ...
                               'C', 10,            ...
                               'verbosity', 0,     ...
                               ...%'rbf', 1,           ...
                               ...%'crossvalidation', ker.cross, ...
                               'weights', [+1 posWeight ; -1 1]') ;
        end
        
		model = svmflip(model, labels_kk);
		
		model.train_idx = train_idx;
		
        fprintf('\tSaving model ''%s''.\n', modelPath) ;
		par_save( modelPath, model );	

	end
	
end

function par_save( modelPath, model )
	ssave(modelPath, 'model') ;
end


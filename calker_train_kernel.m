function calker_train_kernel(proj_name, exp_name, ker)

    test_on_train = 0;
    
    fprintf('Loading background feature...\n');
    bg_feats = calker_load_feature(proj_name, exp_name, ker, 'bg');
    
    for ii=1:length(ker.event_ids),
     
        event_id = ker.event_ids{ii};
        
        modelPath = sprintf('%s/models/%s-%s/%s.%s.%s.model.mat', ker.calker_exp_dir, ker.prms.eventkit, ker.prms.rtype, event_id, ker.name, ker.type);
        
        if checkFile(modelPath),
            fprintf('Skipped training %s \n', modelPath);
            continue;
        end
    
        fprintf('Loading event feature [%s]...\n', event_id);
        [feats, labels] = calker_load_feature(proj_name, exp_name, ker, event_id);
        
        %fprintf('Calculating event kernel [%s]...\n', event_id);
        
        feats = [feats, bg_feats];
        labels = [labels, -ones(1, size(bg_feats, 2))];
        
        fprintf('Training event ''%s''...\n', event_id);	
        
        posWeight = ceil(length(find(labels == -1))/length(find(labels == 1)));
        svm_opts = sprintf('-w1 %g -w-1 1', posWeight);
        
        %% using liblinear
        if strcmp(ker.svmtool, 'liblinear'),
            if ker.cross,
                svm_opts_cv = sprintf('%s -v %d', svm_opts, ker.cross);
                c = cross_val(labels', sparse(feats), svm_opts_cv);
                svm_opts = sprintf('%s -c %g', svm_opts, c);
            end
            
            fprintf('%s \n', svm_opts);
            model = train(labels', sparse(feats), svm_opts, 'col');
        elseif strcmp(ker.svmtool, 'libsvm'),
            svm_opts = sprintf('%s -t 0', svm_opts);
            fprintf('%s \n', svm_opts);
            model = svmtrain(cast(labels', 'double'), cast(feats', 'double'), svm_opts); 
        else
            error('Unknown svm tool \n');
        end
        
        fprintf('\tSaving model ''%s''.\n', modelPath) ;
        ssave( modelPath, 'model' );	
        
    end
	
end

function C = cross_val(labels, feats, svm_opts),
    %% do cross validation
    val_range_idx = [-2:+5];
    val_range = arrayfun(@(x) 2^x, val_range_idx);
    
    for t = 1:length(val_range)
        %fprintf('liblinear: setting C to %g\n', val_range(t)) ;
        svm_opts_ = [svm_opts sprintf(' -c %g -q', val_range(t))] ;                           
        res = train(labels, feats, svm_opts_, 'col') ;
        fprintf(' + cv: svm opts ''%s'', acc = %g\n', svm_opts_, res) ;
        acc_range(t) = res;
    end
    
    % best C
    [maxacc, best] = max(acc_range);
    sel = find(acc_range == maxacc);
    [~, median_idx] = min(abs(sel - median(sel)));		% get the median value
    pick = sel(median_idx);
    val = val_range(pick);
    C = val;
    fprintf('--- Selected values: maxacc = %f, pick = %d, C = %g \n', maxacc, pick, C);        
end



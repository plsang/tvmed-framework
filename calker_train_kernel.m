function calker_train_kernel(proj_name, exp_name, ker)

    test_on_train = 0;
    
    fprintf('Loading background feature...\n');
    bg_feats = calker_load_feature(proj_name, exp_name, ker, 'bg');
    
    for ii=1:length(ker.event_ids),
     
        event_id = ker.event_ids{ii};
        
        modelPath = sprintf('%s/models/%s-%s/%s.%s.%s.model.mat', ker.calker_exp_dir, ker.prms.eventkit, ker.prms.rtype, event_id, ker.name, ker.type);
        
        if checkFile(modelPath),
            fprintf('Skipped training %s \n', modelPath);
            return;
        end
    
        fprintf('Loading event feature [%s]...\n', event_id);
        [feats, labels] = calker_load_feature(proj_name, exp_name, ker, event_id);
        
        %fprintf('Calculating event kernel [%s]...\n', event_id);
        
        feats = [feats, bg_feats];
        labels = [labels, -ones(1, size(bg_feats, 2))];
        
        fprintf('Training event ''%s''...\n', event_id);	
        
        C = 1;
        posWeight = ceil(length(find(labels == -1))/length(find(labels == 1)));
        svm_opts = sprintf('c %g -w1 %g -w-1 1', C, posWeight);
        
        %% using liblinear
        model = train(labels', sparse(feats), svm_opts, 'col');
        %% using libsvm
        
        %% using pre-computed kernel technique
        
        % svm = calker_svmkernellearn(train_kernel, labels,   ...
                           % 'type', 'C',        ...
                           % ...%'C', 10,            ...
                           % 'verbosity', 0,     ...
                           % ...%'rbf', 1,           ...
                           % 'crossvalidation', 5, ...
                           % 'weights', [+1 posWeight ; -1 1]') ;

        %svm = svmflip(svm, labels);
        
        fprintf('\tSaving model ''%s''.\n', modelPath) ;
        ssave( modelPath, 'model' );	
        
    end
	
end



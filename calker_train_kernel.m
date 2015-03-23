function calker_train_kernel(proj_name, exp_name, ker, event_id)

    test_on_train = 0;
	
    kerPath = sprintf('%s/kernels/%s/%s', ker.calker_exp_dir, ker.dev_pat, ker.devname);

    modelPath = sprintf('%s/models/%s-%s/%s.%s.%s.model.mat', ker.calker_exp_dir, ker.prms.eventkit, ker.prms.rtype, event_id, ker.name, ker.type);
    
    if checkFile(modelPath),
        fprintf('Skipped training %s \n', modelPath);
        return;
    end
    
    event_ker_path = sprintf('%s/kernels/%s-%s/%s/%s.%s.mat', ker.calker_exp_dir, ker.prms.eventkit, ker.prms.rtype, ker.dev_pat, ker.devname, event_id);
    
    %if ~exist(event_ker_path, 'file'),
    
    fprintf('Loading event feature [%s]...\n', event_id);
    [feats, labels] = calker_load_feature(proj_name, exp_name, ker, event_id);
    
    fprintf('Loading background feature...\n');
    bg_feats = calker_load_feature(proj_name, exp_name, ker, 'bg');
    
    %fprintf('Calculating event kernel [%s]...\n', event_id);
    
    feats = [feats, bg_feats];
    labels = [labels, -ones(1, size(bg_feats, 2))];
        
    %    fprintf('Saving event kernel & labels [%s]...\n', event_id);
    %    ssave(event_ker_path, 'train_kernel', 'labels', '-v7.3');
    
    fprintf('Training event ''%s''...\n', event_id);	
    
    %posWeight = ceil(length(find(labels == -1))/length(find(labels == 1)));
    
    %fprintf('SVM learning with predefined kernel matrix...\n');

    %% using liblinear
    model = train(labels', sparse(feats), '-c 1', 'col');
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



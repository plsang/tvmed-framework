function calker_test_kernel(proj_name, exp_name, ker)
    
    fprintf('Loading test features [%s]...\n', ker.test_pat);
    feats = calker_load_feature(proj_name, exp_name, ker, ker.test_pat, 'test');
    num_feat = size(feats, 2);
    
    for ii=1:length(ker.event_ids),
     
        event_id = ker.event_ids{ii};

    	scorePath = sprintf('%s/scores/%s/%s-%s/%s.%s.%s.scores.mat', ker.calker_exp_dir, ker.test_pat, ker.prms.eventkit, ker.prms.rtype, event_id, ker.name, ker.type);
        
        if exist(scorePath, 'file'),
            fprintf('File already exist. Skipped!\n');
        else

            modelPath = sprintf('%s/models/%s-%s/%s.%s.%s.model.mat', ker.calker_exp_dir, ker.prms.eventkit, ker.prms.rtype, event_id, ker.name, ker.type);
            
            if ~checkFile(modelPath),
                error('Model not found %s \n', modelPath);			
            end
            
            fprintf('Loading model ''%s''...\n', event_id);
            load(modelPath);
            
            [~, ~, score] = predict(zeros(num_feat, 1), sparse(feats), model, '', 'col');
                
            %saving scores
            fprintf('\tSaving scores ''%s''.\n', scorePath) ;
            ssave(scorePath, 'score') ;
        end
	
    end
    
end
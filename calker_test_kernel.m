function calker_test_kernel(proj_name, exp_name, ker, event_id)

	fprintf('Loading test meta file \n');
	
    %num_part = ceil(n_clip/ker.chunk_size);
    %cols = fix(linspace(1, n_clip + 1, num_part+1));
	
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
	
        fprintf('Loading feature [%s]...\n', ker.test_pat);
        feats = calker_load_feature(proj_name, exp_name, ker, ker.test_pat, 'test');
        num_feat = size(feats, 2);
        
        [~, ~, score] = predict(zeros(num_feat, 1), sparse(feats), model, '', 'col');
			
		%saving scores
		fprintf('\tSaving scores ''%s''.\n', scorePath) ;
		ssave(scorePath, 'score') ;
	end
	
end
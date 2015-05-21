function calker_test_kernel(proj_name, exp_name, ker)

    switch ker.test_pat,
        case 'kindred14'
            n_clip = length(ker.MEDMD.RefTest.KINDREDTEST.clips);
        case 'medtest14'
            n_clip = length(ker.MEDMD.RefTest.MEDTEST.clips);
        case 'med2012'
            n_clip = length(ker.MEDMD.RefTest.CVPR14Test.clips); 
        otherwise
            error('unknown video pat!!!\n');
    end
    	
	scoreSumPath = sprintf('%s/scores/%s/%s-%s/%s.%s.sum.scores.mat', ker.calker_exp_dir, ker.test_pat, ker.prms.eventkit, ker.prms.rtype, ker.name, ker.type);
	
	scoreMaxPath = sprintf('%s/scores/%s/%s-%s/%s.%s.max.scores.mat', ker.calker_exp_dir, ker.test_pat, ker.prms.eventkit, ker.prms.rtype, ker.name, ker.type);
    
	if exist(scoreSumPath, 'file') &&  exist(scoreMaxPath, 'file'),
		fprintf('File already exist!!\n');
        return;
	end
        
    models = struct;
    scores_sum = struct;
	scores_max = struct;
    
    num_part = n_clip;  %% test at each video
    
    for jj = 1:length(ker.event_ids),
        event_id = ker.event_ids{jj};
        
        modelPath = sprintf('%s/models/%s-%s/%s.%s.%s.model.mat', ker.calker_exp_dir, ker.prms.eventkit, ker.prms.rtype, event_id, ker.name, ker.type);
        
        if ~checkFile(modelPath),
            error('Model not found %s \n', modelPath);			
        end
        
        fprintf('Loading model ''%s''...\n', event_id);
        models.(event_id) = load(modelPath, 'model');
        tmp_scores_sum{jj} = cell(num_part, 1);
		tmp_scores_max{jj} = cell(num_part, 1);
        scores_sum.(event_id) = [];
		scores_max.(event_id) = [];
    end
    
    %% loading devel hists
    fprintf('Loading training features...\n');
    %bg_feats = calker_load_feature_segment(proj_name, exp_name, ker, 'bg');
    train_feats = cell(length(ker.event_ids), 1);
    for ii=1:length(ker.event_ids),
        event_id = ker.event_ids{ii};
        train_feats{ii} = calker_load_feature_segment(proj_name, exp_name, ker, event_id);
    end
	
	train_feats = cat(1, train_feats{:});  %% 3878 x 1
    train_feats = cat(2, train_feats{:});
	
    %train_feats = [train_feats, bg_feats];
    
    cols = fix(linspace(1, n_clip + 1, num_part+1));
    
    for kk = 1:num_part,
        
        fprintf('-- [%d/%d] -- Testing...\n', kk, num_part);
        
        test_feats = calker_load_feature_segment(proj_name, exp_name, ker, ker.test_pat, 'test', cols(kk), cols(kk+1)-1);
		test_feats = cat(2, test_feats{:});
        
        for jj = 1:length(ker.event_ids),
        
            event_id = ker.event_ids{jj};
            
            %test_base = train_feats(:, models.(event_id).model.train_idx)'*test_feats;
            %[N, Nt] = size(test_base); % Nt = # test ; % N  = # train
            %[y, acc, dec] = svmpredict(zeros(Nt, 1), [(1:Nt)' test_base'], models.(event_id).model.libsvm_cl, '-b 1 -q') ;		
            %sub_scores = dec(:, 1)';
			
			
            %only test at svind
			train_feats_ = train_feats(:, models.(event_id).model.train_idx);
            test_base = train_feats_(:, models.(event_id).model.svind)'*test_feats;
            sub_scores = models.(event_id).model.alphay' * test_base + models.(event_id).model.b;
            
			
			tmp_scores_sum{jj}{kk} = mean(sub_scores); % select max score
			tmp_scores_max{jj}{kk} = max(sub_scores); % select max score
			
        end
        
        clear test_feats;
    end
    
    clear train_feats;
    
    for jj = 1:length(ker.event_ids),
        event_id = ker.event_ids{jj};
        scores_sum.(event_id) = cat(2, tmp_scores_sum{jj}{:});
		scores_max.(event_id) = cat(2, tmp_scores_max{jj}{:});
    end
        
    %saving scores
	
    fprintf('\tSaving scores ''%s''.\n', scoreSumPath) ;
	scores = scores_sum;
    ssave(scoreSumPath, 'scores') ;
	
	scores = scores_max;
	fprintf('\tSaving scores ''%s''.\n', scoreMaxPath) ;
    ssave(scoreMaxPath, 'scores') ;
	
end
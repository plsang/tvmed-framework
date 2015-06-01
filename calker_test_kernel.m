function calker_test_kernel(proj_name, exp_name, ker)

    switch ker.test_pat,
        case 'kindred14'
            n_clip = length(ker.MEDMD.RefTest.KINDREDTEST.clips);
        case 'medtest14'
            n_clip = length(ker.MEDMD.RefTest.MEDTEST.clips);
        case 'med2012'
            n_clip = length(ker.MEDMD.RefTest.CVPR14Test.clips); 
		case 'med11test'
            n_clip = length(ker.MEDMD.RefTest.MED11TEST.clips); 	
        otherwise
            error('unknown video pat!!!\n');
    end
    	
	scorePath = sprintf('%s/scores/%s/%s-%s/%s.%s.scores.mat', ker.calker_exp_dir, ker.test_pat, ker.prms.eventkit, ker.prms.rtype, ker.name, ker.type);
    
	if exist(scorePath, 'file'),
		fprintf('File already exist!!\n');
        return;
	end
        
    models = struct;
    scores = struct;
    
    num_part = ceil(n_clip/ker.chunk_size);
    
    for jj = 1:length(ker.event_ids),
        event_id = ker.event_ids{jj};
        
        modelPath = sprintf('%s/models/%s-%s/%s.%s.%s.model.mat', ker.calker_exp_dir, ker.prms.eventkit, ker.prms.rtype, event_id, ker.name, ker.type);
        
        if ~checkFile(modelPath),
            error('Model not found %s \n', modelPath);			
        end
        
        fprintf('Loading model ''%s''...\n', event_id);
        models.(event_id) = load(modelPath, 'model');
        tmp_scores{jj} = cell(num_part, 1);
        scores.(event_id) = [];
    end
    
    %% loading devel hists
    fprintf('Loading training features...\n');
    bg_feats = calker_load_feature(proj_name, exp_name, ker, 'bg');
    train_feats = cell(length(ker.event_ids), 1);
    for ii=1:length(ker.event_ids),
        event_id = ker.event_ids{ii};
        train_feats{ii} = calker_load_feature(proj_name, exp_name, ker, event_id);
    end
    train_feats = cat(2, train_feats{:});
    train_feats = [train_feats, bg_feats];
    
    cols = fix(linspace(1, n_clip + 1, num_part+1));
    
    for kk = 1:num_part,
        
        fprintf('-- [%d/%d] -- Testing...\n', kk, num_part);
        
        test_feats = calker_load_feature(proj_name, exp_name, ker, ker.test_pat, 'test', cols(kk), cols(kk+1)-1);
		
		if strcmp(ker.type, 'linear'),
			base = train_feats'*test_feats;
		elseif strcmp(ker.type, 'echi2'),
			%train_kernel = cal
			matrix = vl_alldist2(train_feats, test_feats, 'chi2');
			base = exp(- ker.mu * matrix);
			clear matrix;
		else
			error('unknown ker type');
		end
        
        parfor jj = 1:length(ker.event_ids),
        
            event_id = ker.event_ids{jj};
            
            test_base = base(models.(event_id).model.train_idx, :);
            
            [N, Nt] = size(test_base); % Nt = # test ; % N  = # train
            
            %only test at svind
            %test_base = base(models.(event_id).svind,:);
            %sub_scores = models.(event_id).alphay' * test_base + models.(event_id).b;
            
            [y, acc, dec] = svmpredict(zeros(Nt, 1), [(1:Nt)' test_base'], models.(event_id).model.libsvm_cl, '-b 1 -q') ;		
            sub_scores = dec(:, 1)';
            
            tmp_scores{jj}{kk} = sub_scores;
        end
        
        clear base test_feats;
    end
    
    clear train_feats;
    
    for jj = 1:length(ker.event_ids),
        event_id = ker.event_ids{jj};
        scores.(event_id) = cat(2, tmp_scores{jj}{:});
    end
        
    %saving scores
    fprintf('\tSaving scores ''%s''.\n', scorePath) ;
    ssave(scorePath, 'scores') ;
	
end
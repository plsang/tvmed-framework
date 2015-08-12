function calker_test_zeroshot(proj_name, exp_name, ker)

    if ~strcmp(ker.feat_raw, 'placeshybrid.full'),
        error('unsupported feature for zeroshot detection');
    end
    
    sim_file = '/net/per610a/export/das11f/plsang/trecvidmed15/metadata/event_concept_place1183.mat';
    fprintf('Loading similarity file  <%s>...\n', sim_file);
    sims = load(sim_file, 'scores');
    sims = sims.scores(:, ker.start_event:ker.end_event);
    sims = l2_norm_matrix(sims);
    
    switch ker.test_pat,
        case 'kindred14'
            n_clip = length(ker.MEDMD.RefTest.KINDREDTEST.clips);
        case 'medtest14'
            n_clip = length(ker.MEDMD.RefTest.MEDTEST.clips);
        case 'med2012'
            n_clip = length(ker.MEDMD.RefTest.CVPR14Test.clips); 
		case 'med11test'
            n_clip = length(ker.MEDMD.RefTest.MED11TEST.clips); 	
        case 'eval15full'
			n_clip = length(ker.EVALMD.UnrefTest.MED15EvalFull.clips);            
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
        tmp_scores{jj} = cell(num_part, 1);
        scores.(event_id) = [];
    end
     
    cols = fix(linspace(1, n_clip + 1, num_part+1));
    
    for kk = 1:num_part,
        
        fprintf('-- [%d/%d] -- Testing...\n', kk, num_part);
        
        test_feats = calker_load_feature(proj_name, exp_name, ker, ker.test_pat, 'test', cols(kk), cols(kk+1)-1);
		
        for jj = 1:length(ker.event_ids),
            
            v1 = sims(:, jj);
            
            %sub_scores = zeros(1, size(test_feats, 2));
            %for ii = 1:size(test_feats, 2),
            %    v2 = test_feats(:, ii);
            %    sub_scores(ii) = v1'*v2;  %% if v1 and v2 are l2-normed
            %end
            
            tmp_scores{jj}{kk} = v1'*test_feats;
        end
        
        clear test_feats;
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

function cosim = cosine_similarity(v1, v2)
    %"compute cosine similarity of v1 to v2: (v1 dot v2)/{||v1||*||v2||)"
    sumxx = 0;
    sumxy = 0;
    sumyy = 0;
    
    for ii = 1:length(v1),
        x = v1(ii); 
        y = v2(ii);
        sumxx = sumxx + x*x;
        sumyy = sumyy + y*y;
        sumxy = sumxy + x*y;
    end
    
    cosim = sumxy/sqrt(sumxx*sumyy);
end


function X = l2_norm_matrix(X),
    for ii=1:size(X, 2),
        if any(X(:,ii) ~= 0), 
            X(:,ii) = X(:,ii) / norm(X(:,ii), 2);
        end
    end
end    
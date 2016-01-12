function calker_cal_rank(proj_name, exp_name, ker)
	
	test_db_file = sprintf('database_%s.mat', ker.test_pat);
	
	calker_common_exp_dir = sprintf('%s/%s/experiments/%s-calker/common/%s', ker.proj_dir, proj_name, exp_name, ker.feat);
	
    scorePath = sprintf('%s/scores/%s/%s-%s/%s.%s.scores.mat', ker.calker_exp_dir, ker.test_pat, ker.prms.eventkit, ker.prms.rtype, ker.name, ker.type);
	scoreDir = fileparts(scorePath);
	
	if ~checkFile(scorePath), 
		error('File not found!! %s \n', scorePath);
		return;
	end
	
	load(scorePath);
	
	n_event = length(ker.event_ids);
	events = ker.event_ids;
	
	fprintf('Ranking for feature %s...\n', ker.name);
	
	switch ker.test_pat,
        case 'kindred14'
            clips = ker.MEDMD.RefTest.KINDREDTEST.clips;
        case 'medtest14'
            clips = ker.MEDMD.RefTest.MEDTEST.clips;
        case 'med2012'
            clips = ker.MEDMD.RefTest.CVPR14Test.clips; 
		case 'med11test'
            clips = ker.MEDMD.RefTest.MED11TEST.clips; 	
        case 'eval15full'
			clips = ker.EVALMD.UnrefTest.MED15EvalFull.clips;            
        case 'medtest13lj'
            clips = ker.MEDMD.RefTest.MEDTEST2.clips;
        case 'medtest14lj'
            clips = ker.MEDMD.RefTest.MEDTEST2.clips;      
        otherwise
            error('unknown video pat!!!\n');
    end
    
	for jj = 1:n_event,
		event_name = events{jj};
		
		
		this_scores = scores.(event_name);
		
		fprintf('-- [%d] Ranking for event [%s]...\n', jj, event_name);
		
		[sorted_scores, sorted_idx] = sort(this_scores, 'descend');
		
		rankFile = sprintf('%s/%s.%s.%s.rank', scoreDir, event_name, ker.name, ker.type);
		
		fh = fopen(rankFile, 'w');
		for kk=1:length(sorted_scores),
			rank_idx = sorted_idx(kk);
			fprintf(fh, '%s %f\n', clips{rank_idx}, sorted_scores(kk));
		end
		
		fclose(fh);
	end	
	
end
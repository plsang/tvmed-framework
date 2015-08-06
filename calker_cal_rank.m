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
	
	
	for jj = 1:n_event,
		event_name = events{jj};
		
		
		this_scores = scores.(event_name);
		
		fprintf('-- [%d] Ranking for event [%s]...\n', jj, event_name);
		
		[sorted_scores, sorted_idx] = sort(this_scores, 'descend');
		
		rankFile = sprintf('%s/%s.%s.rank', scoreDir, event_name, ker.name);
		
		fh = fopen(rankFile, 'w');
		for kk=1:length(sorted_scores),
			rank_idx = sorted_idx(kk);
			fprintf(fh, '%s %f\n', ker.MEDMD.UnrefTest.MED15EvalFull.clips{rank_idx}, sorted_scores(kk));
		end
		
		fclose(fh);
	end	
	
end
function calker_cal_rank(proj_name, exp_name, ker, events)
	
	calker_exp_dir = sprintf('%s/%s/experiments/%s/%s%s', ker.proj_dir, proj_name, exp_name, ker.feat, ker.suffix);
	
	calker_common_exp_dir = sprintf('%s/%s/experiments/%s/common/%s', ker.proj_dir, proj_name, exp_name, ker.feat);
	
	db_file = fullfile(calker_common_exp_dir, ['database_' ker.test_pat '.mat']);
	if ~exist(db_file, 'file'),
		db_file = sprintf('%s/%s/experiments/%s/common/%s', ker.proj_dir, proj_name, exp_name, ['database_' ker.test_pat '.mat']);
	end

	fprintf('Loading database [%s]...\n', db_file);
	load(db_file, 'database');
	
	scoreDir =  sprintf('%s/scores/%s', calker_exp_dir, ker.test_pat);
	scorePath = sprintf('%s/scores/%s/%s.%s.cross%d.scores.mat', calker_exp_dir, ker.test_pat, ker.name, ker.type, ker.cross);
    
	if ~checkFile(scorePath), 
		warning('File not found!! %s \n', scorePath);
		return;
	end
	
	
	scores = load(scorePath);
	
	n_event = length(events);
	
	fprintf('Ranking for feature %s...\n', ker.name);
	
	run_name = sprintf('mediaeval-vsd2013-shot.%s.R1', ker.name);
	
	for jj = 1:n_event,
		event_name = events{jj};
		
		
		this_scores = scores.(event_name);
		
		fprintf('-- [%d] Ranking for event [%s]...\n', jj, event_name);
		
		[sorted_scores, sorted_idx] = sort(this_scores, 'descend');
		
		rankFile = sprintf('%s/%s.rank', scoreDir, event_name);
		
		eventScoreDir = sprintf('%s/%s', scoreDir, event_name);
		
		mkdir(eventScoreDir);
		
		scoreFile = sprintf('%s/VSD13_19_001.res', eventScoreDir);
		fh = fopen(scoreFile, 'w');
		for kk=1:length(this_scores),
			fprintf(fh, '%s #$# %f\n', database.cname{kk}, this_scores(kk));
		end
		
		fclose(fh);
		
		fh = fopen(rankFile, 'w');
		for kk=1:length(sorted_scores),
			rank_idx = sorted_idx(kk);
			fprintf(fh, '0 0 %s %d %f %s\n', database.cname{rank_idx}, kk, sorted_scores(kk), run_name);
		end
		
		fclose(fh);
	end	
	
end
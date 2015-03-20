function calker_cal_threshhold(proj_name, exp_name, ker, videolevel)
	
	%videolevel: 1 (default): video-based approach, 0: segment-based approach
	
	if ~exist('videolevel', 'var'),
		videolevel = 1;
	end
	
	calker_exp_dir = sprintf('%s/%s/experiments/%s-calker/%s%s', ker.proj_dir, proj_name, exp_name, ker.feat, ker.suffix);
	
	calker_common_exp_dir = sprintf('%s/%s/experiments/%s-calker/common/%s', ker.proj_dir, proj_name, exp_name, ker.feat);
	
	fprintf('Loading ref meta file \n');
	
	load(ker.prms.test_meta_file, 'database');
	
	if isempty(database)
		error('Empty metadata file!!\n');
	end
	
	% event names
	n_event = length(database.event_ids);
	events = database.event_ids;
	
	fprintf('Scoring for feature %s...\n', ker.name);

	
	scorePath = sprintf('%s/scores/%s/%s-%s/%s.%s.scores.mat', calker_exp_dir, ker.test_pat, ker.prms.eventkit, ker.prms.rtype, ker.name, ker.type);
    
	if ~checkFile(scorePath), 
		error('File not found!! %s \n', scorePath);
	end
	scores = load(scorePath);

	
	
	%output_dir='/net/per610a/export/das11f/plsang/trecvidmed14/ioserver/submissions/ES';
	output_dir='/net/per610a/export/das11f/plsang/trecvidmed14/ioserver/submissions_adhoc/ES';
	
	for jj = 1:n_event,
		event_name = events{jj};
		this_scores = scores.(event_name);
		
		f_threshold_csv = sprintf('%s/%s/%s.threshold.csv', output_dir, ker.prms.eventkit, event_name);
		
		fprintf('Thresholding for event [%s]...\n', event_name);
		
		[sorted_scores, idx] = sort(this_scores, 'descend');
		%gt_idx = find(database.label == jj);
		gt_idx = find(ismember(database.clip_names, database.ref.(event_name)));
		
		rank_idx = arrayfun(@(x)find(idx == x), gt_idx);
		
		sorted_idx = sort(rank_idx);	
		
		threshhold = mean(sorted_scores(sorted_idx));
		rank = round(mean(sorted_idx));
		
		fh = fopen(f_threshold_csv, 'w');
		fprintf(fh, 'EventID,QueryType,PRF,DetectionThresholdScore,DetectionThresholdRank\n');
		fprintf(fh, '%s,SQ,noPRF,%.6f,%d', event_name, threshhold, rank);
		
		fclose(fh);
		%map.(event_name) = ap;
	end	

end
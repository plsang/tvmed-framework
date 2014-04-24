function calker_cal_random_map(proj_name, exp_name, ker, videolevel)
	
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
	n_event = length(database.event_names);
	events = database.event_ids;
	
	fprintf('Scoring for feature %s...\n', ker.name);

	for rr = ker.numrand,
	
		%scorePath = sprintf('%s/r-scores/%d/%s/%s.r%d.scores.mat', calker_exp_dir, ker.randim, ker.test_pat, ker.name, rr);
		scorePath = sprintf('%s/r-scores/%d/%s/%s-%s/%s.%s.r%d.scores.mat', calker_exp_dir, ker.randim, ker.test_pat, ker.prms.eventkit, ker.prms.rtype, ker.name, ker.type, rr);
		
		mapPath = sprintf('%s/r-scores/%d/%s/%s-%s/%s.%s.r%d.map.csv', calker_exp_dir, ker.randim, ker.test_pat, ker.prms.eventkit, ker.prms.rtype, ker.name, ker.type, rr);
		
		if ~checkFile(scorePath), 
			error('File not found!! %s \n', scorePath);
		end
		scores = load(scorePath);
				
		m_ap = zeros(1, n_event);
			
		for jj = 1:n_event,
			event_name = events{jj};
			this_scores = scores.(event_name);
			
			fprintf('Scoring for event [%s]...\n', event_name);
			
			[~, idx] = sort(this_scores, 'descend');
			gt_idx = find(database.label == jj);
			
			rank_idx = arrayfun(@(x)find(idx == x), gt_idx);
			
			sorted_idx = sort(rank_idx);	
			ap = 0;
			for kk = 1:length(sorted_idx), 
				ap = ap + kk/sorted_idx(kk);
			end
			ap = ap/length(sorted_idx);
			m_ap(jj) = ap;
			%map.(event_name) = ap;
		end	
		
		m_ap
		mean(m_ap)	
		%save(mapPath, 'map');
		
		fh = fopen(mapPath, 'w');
		for jj = 1:n_event,	
			event_name = events{jj};
			fprintf(fh, '%s\t%f\n', event_name, m_ap(jj));
		end
		fprintf(fh, '%s\t%f\n', 'all', mean(m_ap));
		fclose(fh);
	end
end
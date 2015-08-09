function calker_cal_map(proj_name, exp_name, ker, events)
	
	calker_exp_dir = sprintf('%s/%s/experiments/%s/%s%s', ker.proj_dir, proj_name, exp_name, ker.feat, ker.suffix);
	
	calker_common_exp_dir = sprintf('%s/%s/experiments/%s/common/%s', ker.proj_dir, proj_name, exp_name, ker.feat);
	
	test_db_file = sprintf('database_%s.mat', ker.test_pat);
	
	gt_file = fullfile(calker_common_exp_dir, test_db_file);
	
	if ~exist(gt_file, 'file'),
		warning('File not found! [%s] USING COMMON DIR GROUNDTRUTH!!!', gt_file);
		calker_common_exp_dir = sprintf('%s/%s/experiments/%s/common', ker.proj_dir, proj_name, exp_name);
		gt_file = fullfile(calker_common_exp_dir, test_db_file);
	end
	
	fprintf('Loading database [%s]...\n', test_db_file);
    database = load(gt_file, 'database');
	database = database.database;
	
	

	% event names
	n_event = length(events);
	
	fprintf('Scoring for feature %s...\n', ker.name);

	
	scorePath = sprintf('%s/scores/%s/%s.scores.mat', calker_exp_dir, ker.test_pat, ker.name);
    
	mapPath = sprintf('%s/scores/%s/%s.map.csv', calker_exp_dir, ker.test_pat, ker.name);
    
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
        gt_idx = find(database.labels.(event_name) == 1);
        
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
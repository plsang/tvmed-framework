function calker_cal_map(proj_name, exp_name, ker)
	
	% event names
	switch ker.test_pat,
        case 'kindred14'
            clips = ker.MEDMD.RefTest.KINDREDTEST.clips;
            gt_ref = ker.MEDMD.RefTest.KINDREDTEST.ref;
        case 'medtest14'
            clips = ker.MEDMD.RefTest.MEDTEST.clips;
            gt_ref = ker.MEDMD.RefTest.MEDTEST.ref;
        case 'med2012'
            clips = ker.MEDMD.RefTest.CVPR14Test.clips;
            gt_ref = ker.MEDMD.RefTest.CVPR14Test.ref;
        otherwise
            error('unknown test video pat!!!\n');
    end
    
	
	fprintf('Scoring for feature %s...\n', ker.name);
	scorePath = sprintf('%s/scores/%s/%s-%s/%s.%s.%s.scores.mat', ker.calker_exp_dir, ker.test_pat, ker.prms.eventkit, ker.prms.rtype, ker.name, ker.type, ker.testagg);
    mapPath = sprintf('%s/scores/%s/%s-%s/%s.%s.%s.map.csv', ker.calker_exp_dir, ker.test_pat, ker.prms.eventkit, ker.prms.rtype, ker.name, ker.type, ker.testagg);
    
	if ~checkFile(scorePath), 
		error('File not found!! %s \n', scorePath);
	end
	scores = load(scorePath, 'scores');
			
	m_ap = zeros(1, length(ker.event_ids));
    
    for jj = 1:length(ker.event_ids),
        event_id = ker.event_ids{jj};
        this_scores = scores.scores.(event_id);
        
        fprintf('Scoring for event [%s]...\n', event_id);
        
        [sorted_scores, idx] = sort(this_scores, 'descend');
        gt_idx = find(ismember(clips, gt_ref.(event_id)));
        
        rank_idx = arrayfun(@(x)find(idx == x), gt_idx);
        
        sorted_idx = sort(rank_idx);	
        ap = 0;
        for kk = 1:length(sorted_idx), 
            ap = ap + kk/sorted_idx(kk);
        end
        ap = ap/length(sorted_idx);
        m_ap(jj) = ap;
    end	

	m_ap
	mean(m_ap)	
	
	fh = fopen(mapPath, 'w');
	for jj = 1:length(ker.event_ids),	
		event_id = ker.event_ids{jj};
		fprintf(fh, '%s\t%f\n', event_id, m_ap(jj));
	end
    
	fprintf(fh, '%s\t%f\n', 'all', mean(m_ap));
	fclose(fh);
end
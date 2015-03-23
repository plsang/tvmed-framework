function calker_cal_map(proj_name, exp_name, ker, event_id)
	
	fprintf('Scoring for feature %s...\n', ker.name);
    
	scorePath = sprintf('%s/scores/%s/%s-%s/%s.%s.%s.scores.mat', ker.calker_exp_dir, ker.test_pat, ker.prms.eventkit, ker.prms.rtype, event_id, ker.name, ker.type);
	mapPath = sprintf('%s/scores/%s/%s-%s/%s.%s.%s.map.csv', ker.calker_exp_dir, ker.test_pat, ker.prms.eventkit, ker.prms.rtype, event_id, ker.name, ker.type);
    
	if ~checkFile(scorePath), 
		error('File not found!! %s \n', scorePath);
	end
    
	load(scorePath);
			
    [sorted_score, idx] = sort(score, 'descend');
    %gt_idx = find(database.label == jj);
    switch ker.test_pat,
        case 'kindred14'
            clips = ker.MEDMD.RefTest.KINDREDTEST.clips;
            gt_clips = ker.MEDMD.RefTest.KINDREDTEST.ref.(event_id);
        case 'medtest14'
            clips = ker.MEDMD.RefTest.MEDTEST.clips;
            gt_clips = ker.MEDMD.RefTest.MEDTEST.ref.(event_id);
        otherwise
            error('unknown test video pat!!!\n');
    end
        
    gt_idx = find(ismember(clips, gt_clips));
    
    rank_idx = arrayfun(@(x)find(idx == x), gt_idx);
    
    sorted_idx = sort(rank_idx);	
    ap = 0;
    for kk = 1:length(sorted_idx), 
        ap = ap + kk/sorted_idx(kk);
    end
    ap = ap/length(sorted_idx);
	fprintf('AP = %.3f \n', ap);
    
end
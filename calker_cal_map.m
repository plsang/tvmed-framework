function calker_cal_map(proj_name, exp_name, ker)
	
	fprintf('Scoring for feature %s...\n', ker.name);
    
    switch ker.test_pat,
        case 'kindred14'
            clips = ker.MEDMD.RefTest.KINDREDTEST.clips;
            gt_ref = ker.MEDMD.RefTest.KINDREDTEST.ref;
        case 'medtest14'
            clips = ker.MEDMD.RefTest.MEDTEST.clips;
            gt_ref = ker.MEDMD.RefTest.MEDTEST.ref;
        otherwise
            error('unknown test video pat!!!\n');
    end
    
    mapPath = sprintf('%s/scores/%s/%s-%s/%s.%s.map.csv', ker.calker_exp_dir, ker.test_pat, ker.prms.eventkit, ker.prms.rtype, ker.name, ker.type);    
    fh = fopen(mapPath, 'w');
    
    m_ap = zeros(1, length(ker.event_ids));
    
    for ii=1:length(ker.event_ids),
     
        event_id = ker.event_ids{ii};
        
        scorePath = sprintf('%s/scores/%s/%s-%s/%s.%s.%s.scores.mat', ker.calker_exp_dir, ker.test_pat, ker.prms.eventkit, ker.prms.rtype, event_id, ker.name, ker.type);
        
        if ~checkFile(scorePath), 
            error('File not found!! %s \n', scorePath);
        end
        
        load(scorePath);
                
        [sorted_score, idx] = sort(score, 'descend');
        
        gt_idx = find(ismember(clips, gt_ref.(event_id)));
        
        rank_idx = arrayfun(@(x)find(idx == x), gt_idx);
        
        sorted_idx = sort(rank_idx);	
        ap = 0;
        for kk = 1:length(sorted_idx), 
            ap = ap + kk/sorted_idx(kk);
        end
        ap = ap/length(sorted_idx);
        fprintf('AP = %.4f \n', ap);
        m_ap(ii) = ap;
        
        fprintf(fh, '%s\t%f\n', event_id, ap);
        
    end
    fprintf('%.4f ', m_ap, mean(m_ap));
    fprintf(fh, '%s\t%f\n', 'mAP', mean(m_ap));
	fclose(fh);
end
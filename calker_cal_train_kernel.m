
function calker_cal_train_kernel(proj_name, exp_name, ker)

	kerPath = sprintf('%s/kernels/%s/%s.%s.mat', ker.calker_exp_dir, ker.dev_pat, ker.devname, ker.type);
	
	if ~exist(kerPath),
		
        fprintf('Loading background feature...\n');
        bg_feats = calker_load_feature(proj_name, exp_name, ker, 'bg');
    
        labels_ = cell(length(ker.event_ids), 1);
        train_feats = cell(length(ker.event_ids), 1);
        
        for ii=1:length(ker.event_ids),
            event_id = ker.event_ids{ii};
            fprintf('Loading event feature [%s]...\n', event_id);
            [train_feats{ii}, labels_{ii}] = calker_load_feature(proj_name, exp_name, ker, event_id);
        end
        
        train_feats = cat(2, train_feats{:});
        train_feats = [train_feats, bg_feats];
        
        labels = zeros(length(ker.event_ids), size(train_feats, 2));
        start_idx = 1;
        bg_start_idx = size(train_feats, 2) - size(bg_feats, 2)+1;
        
        for ii=1:length(ker.event_ids),
            end_idx = start_idx + length(labels_{ii}) - 1;
            labels(ii, start_idx:end_idx) = labels_{ii};
            labels(ii, bg_start_idx:end) = -ones(1, size(bg_feats, 2));
            start_idx = start_idx + length(labels_{ii});    
        end
            
		fprintf('\tCalculating linear kernel %s ... \n', ker.feat) ;	
        pre_train_kernel = train_feats'*train_feats;
        
        fprintf('\tSaving pre-computed kernel & labels ''%s''.\n', kerPath) ;
        ssave( kerPath, 'pre_train_kernel', 'labels', '-v7.3' );
    end

end


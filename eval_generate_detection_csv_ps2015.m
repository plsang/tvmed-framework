function eval_generate_detection_csv_ps2015(run_name, ek_set)
	
    proj_dir = '/net/per610a/export/das11f/plsang';
    proj_name = 'trecvidmed15';
    exp_name = 'niimed2015';
    suffix = '--v1.3-r1';
    testset = 'eval15full';
    miss_type = 'RN';
    
    
	f_trial_index = '/net/per610a/export/das11f/plsang/trecvidmed15/metadata/MED15-InputFIles-20150730/MED15-EvalFull-PS-TrialIndex.csv';
	
	fh = fopen(f_trial_index);
	trial_indexes = textscan(fh, '%s %s %s', 'delimiter', ',');
	fclose(fh);
	
	trial_ids = trial_indexes{1}(2:end);
	video_num_ids = trial_indexes{2}(2:end);
	event_ids = trial_indexes{3}(2:end);
    
	videoScorePath = sprintf('%s/%s/experiments/%s/%s.%s/scores/%s/%s-%s/%s.mixed.scores.mat', ...
        proj_dir, proj_name, exp_name, run_name, suffix, testset, ek_set, miss_type, run_name);
	
	load(videoScorePath);
	
    events  = fieldnames(scores);
    
	f_detection_csv = sprintf('%s/%s/experiments/%s/%s.%s/scores/%s/%s-%s/%s.detection.csv', ...
        proj_dir, proj_name, exp_name, run_name, suffix, testset, ek_set, miss_type, run_name);
		
	if exist(f_detection_csv, 'file'),
		fprintf('File already exist! skipped!\n');
		return;
	end
	
    testmd_file = '/net/per610a/export/das11f/plsang/trecvidmed/metadata/med15/med15_eval.mat';
    fprintf('Loading test metadata <%s>...\n', testmd_file);
    load(testmd_file, 'MEDMD'); 
    
    fprintf('Creating ranking meta...\n');
    rank = struct; 
    for ii = 1:length(events),
        event_id = events{ii};
        fprintf('%s ', event_id);
        
        this_scores = scores.(event_id);
        
        [sorted_scores, sorted_idx] = sort(this_scores, 'descend');
        
        for kk=1:length(sorted_scores),
            rank_idx = sorted_idx(kk);
            clip_id = MEDMD.UnrefTest.MED15EvalFull.clips{rank_idx};
            rank.(event_id).(clip_id) = kk;
        end
        
    end
    
    fprintf('Saving detection scores...\n');
    fh = fopen(f_detection_csv, 'w');
    fprintf(fh, '"TrialID","Rank"\n');
    
    for jj=1:length(trial_ids),
        if ~mod(jj, 1000),
            fprintf('%d ', jj);
        end
        event_id = strrep(event_ids{jj}, '"', '');
        
        video_num_id = strrep(video_num_ids{jj}, '"', '');
        
        clip_id = ['HVC', video_num_id];
                        
        fprintf(fh, '%s,"%d"\n', trial_ids{jj}, rank.(event_id).(clip_id));
    end	
    
    fprintf('Done...\n');
    fclose(fh);
    
end
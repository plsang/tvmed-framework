function eval_generate_detection_csv_ah2015()
	

	f_trial_index = '/net/per610a/export/das11f/plsang/trecvidmed15/metadata/MED15-InputFIles-20150728/MED15-EvalFull-AH-TrialIndex.csv';
	
	fh = fopen(f_trial_index);
	trial_indexes = textscan(fh, '%s %s %s', 'delimiter', ',');
	fclose(fh);
	
	trial_ids = trial_indexes{1}(2:end);
	video_num_ids = trial_indexes{2}(2:end);
	event_ids = trial_indexes{3}(2:end);
    
	videoScorePath = '/net/per610a/export/das11f/plsang/trecvidmed15/experiments/niimed2015/fusion.sift.mfcc.hoghof.mbh.fc6.fc7.full.l2.--v1.3-ah-r1/scores/eval15full/EK10Ex-RN/fusion.sift.mfcc.hoghof.mbh.fc6.fc7.full.l2.linear.scores.mat';
	
	load(videoScorePath);
	
    events  = fieldnames(scores);
    
	
	f_detection_csv = '/net/per610a/export/das11f/plsang/trecvidmed15/experiments/niimed2015/fusion.sift.mfcc.hoghof.mbh.fc6.fc7.full.l2.--v1.3-ah-r1/scores/eval15full/EK10Ex-RN/fusion.sift.mfcc.hoghof.mbh.fc6.fc7.full.l2.linear.detection.csv';
		
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
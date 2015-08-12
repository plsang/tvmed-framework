function hitachi_convert_format()
    
    input_file = '/net/per610a/export/das11f/plsang/trecvidmed15/experiments/niimed2015/hitachi.audio.l2.--v1.3-r1/scores/eval15full/EK10Ex-RN/detection_scores_prespecified_zeros.csv';
    fh = fopen(input_file, 'r');
    infos = textscan(fh, '%s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f', 'Delimiter', ',');
    fclose(fh);
    
    output_file = '/net/per610a/export/das11f/plsang/trecvidmed15/experiments/niimed2015/hitachi.audio.l2.--v1.3-r1/scores/eval15full/EK10Ex-RN/hitachi.audio.l2.mixed.scores.mat';
    
    testmd_file = '/net/per610a/export/das11f/plsang/trecvidmed/metadata/med15/med15_eval.mat';
    fprintf('Loading test metadata <%s>...\n', testmd_file);
    load(testmd_file, 'MEDMD'); 
    
    event_ids = arrayfun(@(x) sprintf('E%03d', x), [21:40], 'UniformOutput', false);
    
    clips = MEDMD.UnrefTest.MED15EvalFull.clips;

    scores = struct;    
    for ee = 1:length(event_ids),
        event_id = event_ids{ee};
        
        fprintf('%s ', event_id);
        
        scores.(event_id) = infos{ee+1}';
        
        %%% generating ranking files
        rank_file = sprintf('/net/per610a/export/das11f/plsang/trecvidmed15/experiments/niimed2015/hitachi.audio.l2.--v1.3-r1/scores/eval15full/EK10Ex-RN/%s.hitachi.audio.l2.mixed.rank', event_id);
        fh = fopen(rank_file, 'w');
        
        [sorted_scores, sorted_idx] = sort(scores.(event_id), 'descend');
        for kk=1:length(sorted_scores),
			rank_idx = sorted_idx(kk);
            video_id = ['HVC', infos{1}{rank_idx}];
            if ~strcmp(video_id, clips{rank_idx}),
                error('video id not identical <%s><%s>', video_id, clips{rank_idx});
            end
			fprintf(fh, '%s %f\n', clips{rank_idx}, sorted_scores(kk));
		end
        fclose(fh);
    end
    
    save(output_file, 'scores');
    
end

function idensetraj_encode_gamma( exp_name, pat_list, seg_length, start_seg, end_seg )
    
    % pat_list == 'ek100ps14 ek10ps14 bg kindred14 medtest14 --count'
    % seg_length: length of segment, in seconds, if seg_length is large enough, it become video-based
    
    %% special switch
    %% --count: count number of videos, and total duration of videos will be processed (then stop)
    %% --nolog: turn off logging
    %% --check: print videos that have not been processed
    %% --rmsmall: remove small files (possibly contains NaN)
	
    % setting
    set_env;
    % exp_name = 'med.pooling';
        
    if isempty(strfind(pat_list, '--nolog')),
       	configs = set_global_config();
        logfile = sprintf('%s/%s.log', configs.logdir, mfilename);
        msg = sprintf('Start running %s(%s, %d, %d)', mfilename, exp_name, start_seg, end_seg);
        logmsg(logfile, msg);
        change_perm(logfile);
        tic;
    end
	
    video_dir = '/net/per610a/export/das11f/plsang/dataset/MED/LDCDIST-RSZ';
	fea_dir = '/net/per610a/export/das11f/plsang/trecvidmed/feature';
	
	fprintf('Loading metadata...\n');
	medmd_file = '/net/per610a/export/das11f/plsang/trecvidmed14/metadata/medmd_2014_devel_ps.mat';
	
	load(medmd_file, 'MEDMD'); 
	metadata = MEDMD.lookup;
	
    supported_pat_list = {'ek100ps14', 'ek10ps14', 'bg', 'kindred14', 'medtest14'};
    
    clips = []; 
    durations = [];
    for supported_pat = supported_pat_list,
        if ~isempty(strfind(pat_list, supported_pat{:})),
            switch supported_pat{:},
                case 'bg'
                    clips_ = MEDMD.EventBG.default.clips;
                    durations_ = MEDMD.EventBG.default.durations;
                case 'kindred14'
                    clips_ = MEDMD.RefTest.KINDREDTEST.clips;
                    durations_ = MEDMD.RefTest.KINDREDTEST.durations;
                case 'medtest14'
                    clips_ = MEDMD.RefTest.MEDTEST.clips;
                    durations_ = MEDMD.RefTest.MEDTEST.durations;
                case 'ek100ps14'
                    clips_ = MEDMD.EventKit.EK100Ex.clips;
                    durations_ = MEDMD.EventKit.EK100Ex.durations;
                    %% only select e20-e40
                    sel_idx = zeros(1, length(clips_));
                    for ii=21:40,
                        event_id = sprintf('E%03d', ii);
                        sel_idx = sel_idx | ismember(clips_, MEDMD.EventKit.EK100Ex.judge.(event_id).positive);
                        sel_idx = sel_idx | ismember(clips_, MEDMD.EventKit.EK100Ex.judge.(event_id).miss);
                    end
                    clips_ = clips_(sel_idx);
                    durations_ = durations_(sel_idx);
                case 'ek10ps14'
                    clips_ = MEDMD.EventKit.EK100Ex.clips;
                    durations_ = MEDMD.EventKit.EK100Ex.durations;
                    %% only select e20-e40
                    sel_idx = zeros(1, length(clips_));
                    for ii=21:40,
                        event_id = sprintf('E%03d', ii);
                        sel_idx = sel_idx | ismember(clips_, MEDMD.EventKit.EK10Ex.judge.(event_id).positive);
                        sel_idx = sel_idx | ismember(clips_, MEDMD.EventKit.EK10Ex.judge.(event_id).miss);
                    end
                    clips_ = clips_(sel_idx);
                    durations_ = durations_(sel_idx);
            end
            
            clips = [clips, clips_];
            durations = [durations, durations_];
            
            %[clips, unique_idx] = unique(clips);
            %durations = durations(unique_idx);
        end
    end
    
    if ~isempty(strfind(pat_list, '--count')),
        fprintf('Total clips: %d \n', length(clips));
        fprintf('Total durations: %.3f hours \n', sum(durations)/3600 );
        return;
    end
    
    [durations, sorted_idx] = sort(durations, 'descend');
    clips = clips(sorted_idx);
	
    coding_params = get_coding_params();
    descs = fieldnames(coding_params);
    
    if start_seg < 1,
        start_seg = 1;
    end
    
    if end_seg > length(clips),
        end_seg = length(clips);
    end
    
    for ss = start_seg:end_seg,
	
		video_id = clips{ss};
        
		if ~isfield(metadata, video_id) && isempty(strfind(pat_list, '--nolog')),
			msg = sprintf('Unknown location of video <%s>\n', video_id);
			logmsg(logfile, msg);
			continue;
		end
		
		video_file = fullfile(video_dir, metadata.(video_id));
        
        bool_run = 0;
        for ii=1:length(descs),
            desc = descs{ii};
            for jj=1:length(coding_params.(desc)),
                output_file = sprintf('%s/%s/%s/%s/%s.mat', fea_dir, exp_name, coding_params.(desc){jj}.feature_pat, fileparts(metadata.(video_id)), video_id);
                if ~exist(output_file, 'file'),
                    bool_run = 1;
                    break;
                end
            end
        end
        
        if bool_run == 0, continue; end
        
   		fprintf(' [%d --> %d --> %d] Extracting & Encoding for [%s], durations %d s...\n', start_seg, ss, end_seg, video_id, durations(ss));
        
        fps = MEDMD.info.(video_id).fps;
        duration = MEDMD.info.(video_id).duration;
        num_seg = ceil(duration/seg_length);
        max_frame = ceil(duration*fps);
        
        codes = struct;
        for ii=1:length(descs),
            desc = descs{ii};
            codes.(desc) = cell(length(coding_params.(desc)), 1);
            for jj=1:length(coding_params.(desc)),
                enc_param = coding_params.(desc){jj};
                if strcmp(enc_param.enc_type, 'fisher') == 1,
                    codes.(desc){jj} = single(zeros(enc_param.output_dim + enc_param.stats_dim, num_seg));
                else
                    codes.(desc){jj} = single(zeros(enc_param.output_dim, num_seg));
                end
            end
        end
        
        for ff=1:num_seg,
            start_frame = ceil((ff-1)*seg_length*fps) + 1;
            if ff == 1, %% first segment
                start_frame = 0;
            else
                start_frame = start_frame - 15; %% seg_length is 15
            end
            
            end_frame = ceil(ff*seg_length*fps);
            if end_frame > max_frame,
                end_frame = max_frame;
            end
            
            codes_ = idensetraj_extract_and_encode(video_file, start_frame, end_frame, coding_params);
            
            for ii=1:length(descs),
                desc = descs{ii};
                for jj=1:length(codes.(desc)),
                    codes.(desc){jj}(:, ff) = codes_.(desc){jj};
                end
            end
            
            clear codes_;
        end
        
        %%% save at video level
        for ii=1:length(descs),
            desc = descs{ii};
            for jj=1:length(coding_params.(desc)),
                output_file = sprintf('%s/%s/%s/%s/%s.mat', fea_dir, exp_name, coding_params.(desc){jj}.feature_pat, fileparts(metadata.(video_id)), video_id);
                enc_param = coding_params.(desc){jj};
                if strcmp(enc_param.enc_type, 'fisher') == 1,
                    sge_save(output_file, codes.(desc){jj}(1:enc_param.output_dim, :));
                    stats_file = sprintf('%s/%s/%s/%s/%s.stats.mat', fea_dir, exp_name, coding_params.(desc){jj}.feature_pat, fileparts(metadata.(video_id)), video_id);
                    sge_save(stats_file, codes.(desc){jj}(enc_param.output_dim+1:end, :));
                else
                    sge_save(output_file, codes.(desc){jj});
                end
            end
        end
        
		clear codes;

    end
    
    if isempty(strfind(pat_list, '--nolog')),
        elapsed = toc;
        elapsed_str = datestr(datenum(0,0,0,0,0,elapsed),'HH:MM:SS');
        msg = sprintf('Finish running %s(%s, %d, %d). Elapsed time: %s', mfilename, exp_name, start_seg, end_seg, elapsed_str);
        logmsg(logfile, msg);
    end
    
	quit;
end


function idensetraj_encode( exp_name, pat_list, start_video, end_video )
    
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
        msg = sprintf('Start running %s(%s, %d, %d)', mfilename, exp_name, start_video, end_video);
        logmsg(logfile, msg);
        change_perm(logfile);
        tic;
    end
	
    video_dir = '/net/per610a/export/das11f/plsang/dataset/MED/LDCDIST-RSZ';
	fea_dir = '/net/per610a/export/das11f/plsang/trecvidmed15/feature';
	
    if ~isempty(strfind(pat_list, '12')),
        %% MED 2012
        medmd_file = '/net/per610a/export/das11f/plsang/trecvidmed/metadata/med12/medmd_2012.mat';   
    elseif ~isempty(strfind(pat_list, 'med11')),
		%% MED 2011
		medmd_file = '/net/per610a/export/das11f/plsang/trecvidmed/metadata/med11/medmd_2011.mat';
    elseif ~isempty(strfind(pat_list, 'med15eval')),
		%% MED 2015
		medmd_file = '/net/per610a/export/das11f/plsang/trecvidmed/metadata/med15/med15_eval.mat';
	else
        %% MED 2014
        medmd_file = '/net/per610a/export/das11f/plsang/trecvidmed14/metadata/medmd_2014_devel_ps.mat';
    end
	fprintf('Loading metadata...\n');
	load(medmd_file, 'MEDMD'); 
	
    supported_pat_list = {'ek100ps14', 'ek10ps14', 'bg', 'kindred14', 'medtest14', ...
        'train12', 'test12', 'train14', 'med11ek', 'med11devt', 'med11test', 'med15eval'};
    
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
                case 'train12'
                    clips_ = MEDMD.Train.clips;
                    durations_ = MEDMD.Train.durations;
                
                case 'test12'
                    clips_ = MEDMD.Test.clips;
                    durations_ = MEDMD.Test.durations;
                    
                case 'train14'
                    clips_ = MEDMD.videos;
                    durations_ = zeros(1, length(clips_));
                    for ii=1:length(clips_),
                        clip_id = clips_{ii};
                        if isfield(MEDMD.info, clip_id),
                            durations_(ii) = MEDMD.info.(clip_id).duration;
                        end
                    end
                case 'med11ek'
                    clips_ = MEDMD.EventKit.EK130Ex.clips;
                    durations_ = MEDMD.EventKit.EK130Ex.durations;
				
				case 'med11devt'
					clips_ =  MEDMD.RefTest.MED11DEVT.clips;
					durations_ = MEDMD.RefTest.MED11DEVT.durations;
					
				case 'med11test'
					clips_ =  MEDMD.RefTest.MED11TEST.clips;
					durations_ = MEDMD.RefTest.MED11TEST.durations;
                    
                case 'med15eval'
                    clips_ =  MEDMD.UnrefTest.MED15EvalFull.clips;
					durations_ = MEDMD.UnrefTest.MED15EvalFull.durations;
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
    
    if start_video < 1,
        start_video = 1;
    end
    
    if end_video > length(clips),
        end_video = length(clips);
    end
    
    clear clips_ durations_ durations;
    info = MEDMD.info;
    clear MEDMD;
    
    for ss = start_video:end_video,
	
		video_id = clips{ss};
        
		if ~isfield(info, video_id) && isempty(strfind(pat_list, '--nolog')),
			msg = sprintf('Unknown location of video <%s>\n', video_id);
			logmsg(logfile, msg);
			continue;
		end
		
		video_file = fullfile(video_dir, info.(video_id).loc);
        
        bool_run = 0;
        for ii=1:length(descs),
            desc = descs{ii};
            for jj=1:length(coding_params.(desc)),
                output_file = sprintf('%s/%s/%s/%s/%s.mat', fea_dir, exp_name, coding_params.(desc){jj}.feature_pat, fileparts(info.(video_id).loc), video_id);
                output_file_info = dir(output_file);
                if ~exist(output_file, 'file') || output_file_info.bytes < 2000,
                    bool_run = 1;
                    break;
                end
            end
        end
        
        if bool_run == 0, 
            fprintf('Video <%s> already processed \n', video_file);
            continue; 
        end
        
   		fprintf(' [%d --> %d --> %d] Extracting & Encoding for [%s], durations %f s...\n', start_video, ss, end_video, video_id, info.(video_id).duration);
        
        codes = struct;
        for ii=1:length(descs),
            desc = descs{ii};
            codes.(desc) = cell(length(coding_params.(desc)), 1);
        end
		
		codes_ = idensetraj_extract_and_encode(video_file, coding_params);
		
		for ii=1:length(descs),
			desc = descs{ii};
			for jj=1:length(codes.(desc)),
				codes.(desc){jj} = codes_.(desc){jj};
			end
		end
        
		clear codes_;
		
        %%% save at video level
        for ii=1:length(descs),
            desc = descs{ii};
            for jj=1:length(coding_params.(desc)),
                output_file = sprintf('%s/%s/%s/%s/%s.mat', fea_dir, exp_name, coding_params.(desc){jj}.feature_pat, fileparts(info.(video_id).loc), video_id);
                sge_save(output_file, codes.(desc){jj});
            end
        end
        
		clear codes;

    end
    
    if isempty(strfind(pat_list, '--nolog')),
        elapsed = toc;
        elapsed_str = datestr(datenum(0,0,0,0,0,elapsed),'HH:MM:SS');
        msg = sprintf('Finish running %s(%s, %d, %d). Elapsed time: %s', mfilename, exp_name, start_video, end_video, elapsed_str);
        logmsg(logfile, msg);
    end
    
	quit;
end


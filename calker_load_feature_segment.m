
function [feats, labels, num_inst] = calker_load_feature_segment(proj_name, exp_name, ker, video_pat, mode, start_clip, end_clip)

    %% video_pat: bg, kindred14, medtest14, or an event id
    %% mode: train (missing feature will be removed), other modes (test): missing features will be all-zero vectors
    if ~exist('mode', 'var'),  mode = 'train'; end;
    
	configs = set_global_config();
	logfile = sprintf('%s/%s.log', configs.logdir, mfilename);
	msg = sprintf('Start running %s(%s, %s, %s)', mfilename, proj_name, exp_name);
	logmsg(logfile, msg);
	change_perm(logfile);
	tic;
    
    clips = []; 
   
    
    if (any(ismember(ker.MEDMD.EventKit.(ker.prms.eventkit).eventids, video_pat))), 
        if strcmp(ker.prms.rtype, 'NR'),
            clips = [ker.MEDMD.EventKit.(ker.prms.eventkit).judge.(video_pat).positive];
        else
            clips = [ker.MEDMD.EventKit.(ker.prms.eventkit).judge.(video_pat).positive, ker.MEDMD.EventKit.(ker.prms.eventkit).judge.(video_pat).miss];
        end
        
    else
        switch video_pat,
            case 'bg'
                if isfield(ker.MEDMD, 'EventBG'),
                    clips = ker.MEDMD.EventBG.default.clips;
                end
            case 'kindred14'
                clips = ker.MEDMD.RefTest.KINDREDTEST.clips;
            case 'medtest14'
                clips = ker.MEDMD.RefTest.MEDTEST.clips;
            case 'med2012'
                clips = ker.MEDMD.RefTest.CVPR14Test.clips;    
			case 'med11test'
				clips = ker.MEDMD.RefTest.MED11TEST.clips;    
            otherwise
                error('unknown video pat!!!\n');
        end
    end
    
    if ~exist('start_clip', 'var'), start_clip = 1; end;
    if ~exist('end_clip', 'var'), end_clip = length(clips); end;
    
    feats = cell(end_clip - start_clip + 1, 1);
	num_inst = ones(end_clip - start_clip + 1, 1);
	labels = cell(end_clip - start_clip + 1, 1);
	
    selected_label = zeros(1, end_clip - start_clip + 1);

    for ii = 1:end_clip - start_clip + 1, %
        
		feats{ii} = zeros(ker.num_dim, 1);
		
        clip_name = clips{ii + start_clip - 1};
        
		if ~isfield(ker.MEDMD.info, clip_name), continue; end;				
		
		if strcmp(ker.seg_type, 'video'),
			segment_path = sprintf('%s/%s/feature/%s/%s/%s/%s.mat',...
							ker.proj_dir, proj_name, exp_name, ker.feat_raw, fileparts(ker.MEDMD.info.(clip_name).loc), clip_name);
							
			if ~exist(segment_path),
				msg = sprintf('File [%s] does not exist!\n', segment_path);
				fprintf(msg);
				logmsg(logfile, msg);
				continue;
			end
			
			load(segment_path, 'code');
		
		else
			segment_path = sprintf('%s/%s/feature/%s/%s/%s/%s.stats.mat',...
                    ker.proj_dir, proj_name, exp_name, ker.feat_raw, fileparts(ker.MEDMD.info.(clip_name).loc), clip_name);
            
			stats = load(segment_path, 'code'); 
			%% load from med.pooling.seg4
			total_unit_seg = size(stats.code, 2);	
			
			if ker.overlapping == 0, % non overlapping
				idxs = 1:ker.num_agg:total_unit_seg;
			else % overlapping, default 50%
				idxs = 1:(ker.num_agg/2):total_unit_seg; 
			end
			
			code = zeros(feat_dim, length(idxs));
			remove_last_seg = 0;
			for jj=1:length(idxs),
				start_idx = idxs(jj);
				end_idx = start_idx + num_agg - 1;
				if end_idx > total_unit_seg, end_idx = total_unit_seg; end;
				stat_ = stats.code(:, start_idx:end_idx);
				
				if any(any(isnan(stat_), 1)),
					stat_ = stat_(:, ~any(isnan(stat_), 1));
				end
				
				if isempty(stat_) && end_idx == total_unit_seg,
					remove_last_seg = 1;
					break;
				end
				
				stat_ = sum(stat_, 2);
                
                cpp_handle = mexFisherEncodeHelperSP('init', ker.codebook, ker.fisher_params);
                code_ = mexFisherEncodeHelperSP('getfkstats', cpp_handle, stat_);
                mexFisherEncodeHelperSP('clear', cpp_handle);
                
                %% power normalization
                code_ = sign(code_) .* sqrt(abs(code_));    
                %clear stats;
				
				code(:, jj) = code_;
				clear code_;
			end
			
			if remove_last_seg,
				fprintf('Last seg of video <%s> contains NaN. Removing...\n', feat_pat);
				code(:, end) = [];
			end
		end
        
		if ~isempty(find(any(isnan(code), 1))),
			fprintf('Warning: File <%s> contains NaN\n', segment_path);
			code = code(:, ~any(isnan(code), 1));
		end
		
		%% remove all zoro colums
		if any(~any(code)),
			fprintf('Warning: File <%s> contains all zeros column\n', segment_path);
			code = code(:, any(code));
		end
                
        % event video contains all zeros --> skip, keep backgroud video
        if isempty(code),
            fprintf('Feature empty [%s]. Skipped !!\n', segment_path);
            msg = sprintf('Feature empty [%s]', segment_path);
            logmsg(logfile, msg);
            continue;
        end
        
        feats{ii} = code;
		num_inst(ii) = size(code, 2);
		
		if (any(ismember(ker.MEDMD.EventKit.(ker.prms.eventkit).eventids, video_pat))), 
			labels{ii} = ones(1, size(code, 2));
		end
        selected_label(ii) = 1;
        
    end

    if strcmp(mode, 'train'),
        sel_feat = selected_label ~= 0;
        
        feats = feats(sel_feat);
        labels = labels(sel_feat);
		
		%feats =  cat(2, feats{:});
		%labels =  cat(2, feats{:});
    end
    
	elapsed = toc;
	elapsed_str = datestr(datenum(0,0,0,0,0,elapsed),'HH:MM:SS');
	msg = sprintf('Finish running %s(%s, %s, %s). Elapsed time: %s', mfilename, proj_name, exp_name, elapsed_str);
	logmsg(logfile, msg);
	
end
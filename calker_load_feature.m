
function [feats, labels] = calker_load_feature(proj_name, exp_name, ker, video_pat, mode, start_clip, end_clip)

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
    labels = []; %% only in case of event videos
    
    if (any(ismember(ker.MEDMD.EventKit.(ker.prms.eventkit).eventids, video_pat))), 
        if strcmp(ker.prms.rtype, 'NR'),
            clips = [ker.MEDMD.EventKit.(ker.prms.eventkit).judge.(video_pat).positive];
            labels = ones(1, length(clips));
        else
            clips = [ker.MEDMD.EventKit.(ker.prms.eventkit).judge.(video_pat).positive, ker.MEDMD.EventKit.(ker.prms.eventkit).judge.(video_pat).miss];
            if strcmp(ker.prms.rtype, 'RP')
                labels = ones(1, length(clips));
            elseif strcmp(ker.prms.rtype, 'RN')
                labels = [ones(1, length(ker.MEDMD.EventKit.(ker.prms.eventkit).judge.(video_pat).positive)), -ones(1, length(ker.MEDMD.EventKit.(ker.prms.eventkit).judge.(video_pat).miss))];
            else
                error('unknown how to use missed videos!!!\n');
            end
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
            case 'eval15full'
				clips = ker.EVALMD.UnrefTest.MED15EvalFull.clips;        
            otherwise
                error('unknown video pat!!!\n');
        end
    end
    
    if ~exist('start_clip', 'var'), start_clip = 1; end;
    if ~exist('end_clip', 'var'), end_clip = length(clips); end;
    
    feats = zeros(ker.num_dim, end_clip - start_clip + 1);
    selected_label = zeros(1, end_clip - start_clip + 1);

    if strcmp(video_pat, 'eval15full'),
        info = ker.EVALMD.info;
    else
        info = ker.MEDMD.info;
    end
    
    parfor ii = 1:end_clip - start_clip + 1, %
        
        clip_name = clips{ii + start_clip - 1};
                                
		if ~isfield(info, clip_name), continue; end;
		
        segment_path = sprintf('%s/%s/feature/%s/%s/%s/%s.mat',...
                        ker.proj_dir, proj_name, exp_name, ker.feat_raw, fileparts(info.(clip_name).loc), clip_name);
                        
        if ~exist(segment_path),
            msg = sprintf('File [%s] does not exist!\n', segment_path);
            fprintf(msg);
            logmsg(logfile, msg);
            continue;
        end
        
        if strcmp(ker.seg_type, 'video'),  %% video-based
            code = load(segment_path, 'code');
            code = code.code;
            
			if ker.pn > 0,
				%% currently alpha = 0.5
				%% todo: support other alpha values
				code = sign(code) .* sqrt(abs(code));    
			end
			
            if ker.pntest > 0 && strcmp(video_pat, 'eval15full'),
				%% only for hoghof, mbh on eval15
				code = sign(code) .* sqrt(abs(code));    
			end
            
            % if strcmp(ker.idt_desc, 'hoghof'),
                % code = code(1:65536);
            % elseif strcmp(ker.idt_desc, 'mbh'),
                % code = code(65537:end);
            % end
        elseif strcmp(ker.seg_type, 'keyframe'),  %% video-based
            code = load(segment_path, 'code');
            code = code.code;
            
            code = mean(code, 2);
            
            if ker.pn > 0,
				%% currently alpha = 0.5
				%% todo: support other alpha values
				code = sign(code) .* sqrt(abs(code));    
			end
            
        else %% segment-based
            if strcmp(ker.enc_type, 'fisher'),
                stats_path = sprintf('%s/%s/feature/%s/%s/%s/%s.stats.mat',...
                    ker.proj_dir, proj_name, exp_name, ker.feat_raw, fileparts(info.(clip_name).loc), clip_name);
                stats = load(stats_path, 'code'); 

                if any(any(isnan(stats.code), 1)),
                    fprintf('Warning: File <%s> contains NaN\n', stats_path);
                    stats.code = stats.code(:, ~any(isnan(stats.code), 1));
                end
                
                stats = sum(stats.code, 2);
                
                cpp_handle = mexFisherEncodeHelperSP('init', ker.codebook, ker.fisher_params);
                code = mexFisherEncodeHelperSP('getfkstats', cpp_handle, stats);
                mexFisherEncodeHelperSP('clear', cpp_handle);
                
                %% power normalization
                code = sign(code) .* sqrt(abs(code));    
                %clear stats;
                
            else %bow
                codes = load(segment_path, 'code');
                if ~isempty(find(any(isnan(codes.code), 1))),
                    fprintf('Warning: File <%s> contains NaN\n', segment_path);
                    codes.code = codes.code(:, ~any(isnan(codes.code), 1));
                end
                code = sum(codes.code, 2);
                %clear codes;
            end
        end
        
        if size(code, 1) ~= ker.num_dim,
            fprintf('Dimension mismatch [%d-%d-%s]. Skipped !!\n', size(code, 1), ker.num_dim, segment_path);
            continue;
        end
        
        if any(isnan(code)),
            fprintf('Feature contains NaN [%s]. Skipped !!\n', segment_path);
            msg = sprintf('Feature contains NaN [%s]', segment_path);
            logmsg(logfile, msg);
            continue;
        end
        
        % event video contains all zeros --> skip, keep backgroud video
        if all(code == 0),
            fprintf('Feature contains all zeros [%s]. Skipped !!\n', segment_path);
            msg = sprintf('Feature contains all zeros [%s]', segment_path);
            logmsg(logfile, msg);
            continue;
        end
        
        if ~all(code == 0),
            if strcmp(ker.feat_norm, 'l1'),
                code = code / norm(code, 1);
            elseif strcmp(ker.feat_norm, 'l2'),
                code = code / norm(code, 2);
            else
                %error('unknown norm!\n');
            end
        end
        
        feats(:, ii) =  code;
        selected_label(ii) = 1;
        
    end

    if strcmp(mode, 'train'),
        sel_feat = selected_label ~= 0;
        
        feats = feats(:, sel_feat);
        
        if ~isempty(labels),
            labels = labels(sel_feat);
        end 
    end
    
	elapsed = toc;
	elapsed_str = datestr(datenum(0,0,0,0,0,elapsed),'HH:MM:SS');
	msg = sprintf('Finish running %s(%s, %s, %s). Elapsed time: %s', mfilename, proj_name, exp_name, elapsed_str);
	logmsg(logfile, msg);
	
end
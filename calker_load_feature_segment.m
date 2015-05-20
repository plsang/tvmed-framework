
function [feats, labels] = calker_load_feature_segment(proj_name, exp_name, ker, video_pat, mode, start_clip, end_clip)

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
            otherwise
                error('unknown video pat!!!\n');
        end
    end
    
    if ~exist('start_clip', 'var'), start_clip = 1; end;
    if ~exist('end_clip', 'var'), end_clip = length(clips); end;
    
    feats = cell(end_clip - start_clip + 1, 1);
	labels = cell(end_clip - start_clip + 1, 1);
	
    selected_label = zeros(1, end_clip - start_clip + 1);

    for ii = 1:end_clip - start_clip + 1, %
        
        clip_name = clips{ii + start_clip - 1};
                                
        segment_path = sprintf('%s/%s/feature/%s/%s/%s/%s.mat',...
                        ker.proj_dir, proj_name, exp_name, ker.feat_raw, fileparts(ker.MEDMD.info.(clip_name).loc), clip_name);
                        
        if ~exist(segment_path),
            msg = sprintf('File [%s] does not exist!\n', segment_path);
            fprintf(msg);
            logmsg(logfile, msg);
            continue;
        end
        
        
		load(segment_path, 'code');
        
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
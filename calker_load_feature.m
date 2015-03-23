
function [feats, labels] = calker_load_feature(proj_name, exp_name, ker, video_pat, mode)

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
    
    if (any(ismember(ker.MEDMD.EventKit.EK10Ex.eventids, video_pat))), 
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
                clips = ker.MEDMD.EventBG.default.clips;
            case 'kindred14'
                clips = ker.MEDMD.RefTest.KINDREDTEST.clips;
            case 'medtest14'
                clips = ker.MEDMD.RefTest.MEDTEST.clips;
            otherwise
                error('unknown video pat!!!\n');
        end
    end
    
    feats = zeros(ker.num_dim, length(clips));
    selected_label = zeros(1, length(clips));

    for ii = 1:length(clips), %
        
        clip_name = clips{ii};
                                
        segment_path = sprintf('%s/%s/feature/%s/%s/%s/%s.mat',...
                        ker.proj_dir, proj_name, exp_name, ker.feat_raw, fileparts(ker.MEDMD.lookup.(clip_name)), clip_name);
                        
        if ~exist(segment_path),
            msg = sprintf('File [%s] does not exist!\n', segment_path);
            fprintf(msg);
            logmsg(logfile, msg);
            continue;
        end
        
        code = load(segment_path, 'code');
        code = code.code;
        
        if strcmp(ker.idt_desc, 'hoghof'),
            code = code(1:65536);
        elseif strcmp(ker.idt_desc, 'mbh'),
            code = code(65537:end);
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
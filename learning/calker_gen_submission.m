function calker_gen_submission(task, fuse_list, runid, ext, use_threshold)
    %%% task: vsd, affect
    %%% fuse_list = 'mfcc_fc7'
    %%% test_pat = 'kindred14', 'eval15full';
    set_env;
    
    fprintf('loading video list in the testset...\n');
    proj_dir = '/net/per920a/export/das14a/satoh-lab/plsang';
    proj_name = 'vsd2015';
    test_pat = 'testset';
    videos = vsd_load_shots_2015( proj_dir, proj_name, test_pat);
    
    output_dir = '/net/per920a/export/das14a/satoh-lab/plsang/vsd2015/submission';
    
    if strcmp(task, 'vsd')
        fprintf('Searching for optimal threshold...\n');
        t = late_fusion_('violence', fuse_list, 'test', 'dev_val');
        
        fprintf('Late fusion on testset...\n');
        scores = late_fusion_('violence', fuse_list);
        
        pred = double(scores.violence >= t.violence);
        
        fprintf('Generating submission...\n');
        
        if ext == 1,
            output_file = sprintf('%s/me15am_NII-UIT_violence_%d_ext.txt', output_dir, runid);
        else
            output_file = sprintf('%s/me15am_NII-UIT_violence_%d.txt', output_dir, runid);
        end
        
        fh = fopen(output_file, 'w');
        for ii = 1:length(videos),
            video_id = videos{ii}(1:end-4);
            if pred(ii) == 1,
                fprintf(fh, '%s %f t\n', video_id, scores.violence(ii));
            else
                fprintf(fh, '%s %f f\n', video_id, scores.violence(ii));
            end
        end
        fclose(fh);
        
    elseif strcmp(task, 'affect')
        
        fprintf('[Valence] Searching for optimal threshold...\n');
        valence_t = late_fusion_('valence', fuse_list, 'test', 'dev_val');
        
        fprintf('[Valence] Late fusion on testset...\n');
        valence_scores = late_fusion_('valence', fuse_list);
        
        valence_combined_scores = [valence_scores.negative; valence_scores.neutral; valence_scores.positive];
        valence_combined_thresholds = [valence_t.negative; valence_t.neutral; valence_t.positive];
        fprintf('[Valence] Combining scores...\n');
        
        if use_threshold == 1,
            valence_final_decs = combine_scores(valence_combined_scores, valence_combined_thresholds);
        else
            valence_final_decs = combine_scores(valence_combined_scores);
        end
        
        fprintf('[Arousal] Searching for optimal threshold...\n');
        arousal_t = late_fusion_('arousal', fuse_list, 'test', 'dev_val');
        
        fprintf('[Arousal] Late fusion on testset...\n');
        arousal_scores = late_fusion_('arousal', fuse_list);
        
        arousal_combined_scores = [arousal_scores.passive; arousal_scores.neutral; arousal_scores.active];
        arousal_combined_thresholds = [arousal_t.passive; arousal_t.neutral; arousal_t.active];
        fprintf('[Arousal] Combining scores...\n');
        
        if use_threshold == 1,
            arousal_final_decs = combine_scores(arousal_combined_scores, arousal_combined_thresholds);
        else
            arousal_final_decs = combine_scores(arousal_combined_scores);
        end
        
        fprintf('Generating submission...\n');
        
        if ext == 1,
            output_file = sprintf('%s/me15am_NII-UIT_affect_%d_ext.txt', output_dir, runid);
        else
            output_file = sprintf('%s/me15am_NII-UIT_affect_%d.txt', output_dir, runid);
        end
        
        fh = fopen(output_file, 'w');
        for ii = 1:length(videos),
            video_id = videos{ii}(1:end-4);
            fprintf(fh, '%s %d %d\n', video_id, valence_final_decs(ii), arousal_final_decs(ii));
        end
        fclose(fh);
        
    else
        error('unknown task <%s>\n ', task);
    end
    
    %late_fusion_(exp_name, fuse_list);
	
    %calker_cal_rank(proj_name, exp_name, ker);
	%calker_cal_threshhold(proj_name, exp_name, ker);
end

function final_decs = combine_scores(scores, thresholds)
    %%% scores 3xN, thresholds: 3x1
    
    if ~exist('thresholds', 'var'),
        %% simply choose the max results
        num_video = size(scores, 2);
        final_decs = zeros(1, num_video);
        
        for ii = 1:num_video,
            
            [~, max_idx] = max(scores(:, ii));
            
            final_decs(ii) = max_idx - 2;
                
        end
    else
        %% using the learnt thresholds
        decs = bsxfun(@ge, scores, thresholds);
        
        num_video = size(scores, 2);
        final_decs = zeros(1, num_video);
        
        for ii = 1:num_video,
            dec = decs(:, ii);
            if sum(dec) ~= 1,
                %[~, max_idx] = max(scores(:, ii));
                
                rel = (scores(:, ii) - thresholds)./thresholds;
                [~, max_idx] = max(rel);
                
            else
                [~, max_idx] = max(dec);
            end
            
            final_decs(ii) = max_idx - 2;
                
        end
    end    
end

function [out] = late_fusion_(exp_name, fuse_list, varargin)
    
    %%%out: 
   
    test_pat = 'testset';
    proj_name = 'vsd2015';
    feat_norm = 'l2';
	suffix = '';
	
    for k=1:2:length(varargin),

        opt = lower(varargin{k});
        arg = varargin{k+1} ;
        
        switch opt
            case 'suffix'
                suffix = arg ;
            case 'dim'
                feat_dim = arg;
            case 'ek'
                eventkit = arg;	
            case 'miss'
                miss_type = arg;	
            case 'test'
                test_pat = arg;	
            case 's'
                start_event = arg;
            case 'e'
                end_event = arg;
            otherwise
                error(sprintf('Option ''%s'' unknown.', opt)) ;
        end  
    end


	ker.proj_dir = '/net/per920a/export/das14a/satoh-lab/plsang';
	
	addpath('/net/per900a/raid0/plsang/tools/kaori-secode-calker/support');
	addpath('/net/per900a/raid0/plsang/tools/libsvm-3.17/matlab');
	addpath('/net/per900a/raid0/plsang/tools/vlfeat-0.9.16/toolbox');
    
    switch exp_name,
        case 'arousal'
            event_ids = {'active', 'neutral', 'passive'};
        case 'valence'
            event_ids = {'negative', 'neutral', 'positive'};
        case 'violence'
            event_ids = {'violence'};
        otherwise
            error('unknown experiment name');
    end

    
	ker_names = struct;
    
	ker_names.('sift') = 'covdet.hessian.sift.cb256.fc.pca';
	ker_names.('mfcc') = 'mfcc.rastamat.cb256.fc';
    ker_names.('hoghof') = 'idensetraj.hoghof.fisher.cb256.pca128';
    ker_names.('mbh') = 'idensetraj.mbh.fisher.cb256.pca128';
    
    ker_names.('tfis') = 'covdet.hessian.sift.cb256.fc.pca.dev2014';
	ker_names.('ccfm') = 'mfcc.rastamat.cb256.fc.dev2014';
    ker_names.('fohgoh') = 'idensetraj.hoghof.fisher.cb256.pca128.dev2014';
    ker_names.('hbm') = 'idensetraj.mbh.fisher.cb256.pca128.dev2014';
    
    ker_names.('phfc6') = 'placeshybrid.fc6';
    ker_names.('phfc7') = 'placeshybrid.fc7';
    ker_names.('phfull') = 'placeshybrid.full';
    
    ker_names.('vdfc6') = 'verydeep.fc6.l16';
    ker_names.('vdfc7') = 'verydeep.fc7.l16';
    ker_names.('vdfull') = 'verydeep.full.l16';

    %%%    
	ker_types.('sift') = 'kl2';
	ker_types.('mfcc') = 'kl2';
    ker_types.('hoghof') = 'kl2';
    ker_types.('mbh') = 'kl2';
    
    ker_types.('tfis') = 'kl2';
	ker_types.('ccfm') = 'kl2';
    ker_types.('fohgoh') = 'kl2';
    ker_types.('hbm') = 'kl2';
    
    ker_types.('phfc6') = 'echi2';
    ker_types.('phfc7') = 'echi2';
    ker_types.('phfull') = 'echi2';
    
    ker_types.('vdfc6') = 'echi2';
    ker_types.('vdfc7') = 'echi2';
    ker_types.('vdfull') = 'echi2';
    %%%
    
	calker_exp_dir = sprintf('%s/%s/experiments/%s', ker.proj_dir, proj_name, exp_name);
	
	ker_ids = fieldnames(ker_names);
    
    fused_ids = {};
    for ii=1:length(ker_ids),
        ker_id = ker_ids{ii};
        if ~isempty(strfind(fuse_list, ker_id)),
            fused_ids = [fused_ids, ker_id];
        end
    end
    
	fusion_name = 'fusion';
	for ii=1:length(fused_ids),
		fusion_name = sprintf('%s.%s', fusion_name, fused_ids{ii});
	end
	
    fusion_name = sprintf('%s.%s', fusion_name, feat_norm);
    
    output_file = sprintf('%s/%s%s/scores/%s/%s.%s.cross%d.scores.mat', calker_exp_dir, fusion_name, suffix, test_pat, fusion_name, 'kl2', 0);
	
	if 1, %~exist(output_file, 'file'),
	
		output_dir = fileparts(output_file);
		if ~exist(output_dir, 'file'),
			mkdir(output_dir);
		end
		
		fused_scores = struct;
		for ii=1:length(event_ids),
			event_name = event_ids{ii};
			fprintf('Fusing for event [%s]...\n', event_name);
			for jj = 1:length(fused_ids),
				ker_name = ker_names.(fused_ids{jj});
                ker_type = ker_types.(fused_ids{jj});
                
				fprintf(' -- [%d/%d] kernel [%s]...\n', jj, length(fused_ids), ker_name);
				
				%scorePath = sprintf('%s/%s.%s.%s/scores/%s/%s-%s/%s.%s.%s.scores.mat', calker_exp_dir, ker_name, feat_norm, suffix, test_pat, ek_set, miss_type, ker_name, feat_norm, ker_type);
				scorePath = sprintf('%s/%s.%s%s/scores/%s/%s.%s.%s.cross%d.scores.mat', calker_exp_dir, ker_name, feat_norm, suffix, test_pat, ker_name, feat_norm, ker_type, 1);
                
				if ~exist(scorePath, 'file');
					error('File not found! [%s]', scorePath);
				end
				
				scores = load(scorePath);
				if isfield(fused_scores, event_name),			
					fused_scores.(event_name) = [fused_scores.(event_name); scores.(event_name)];
				else
					fused_scores.(event_name) = scores.(event_name);
				end
			end
            
			fused_scores.(event_name) = mean(fused_scores.(event_name)); %scores: 1 x number of videos
		end
		
		scores = fused_scores;
		%save(output_file, 'scores');
        ssave(output_file, '-STRUCT', 'scores') ;
		
	end
        
	if ~strcmp(test_pat, 'dev_val'),
        out = scores;
    else
        ker.feat = fusion_name;
        ker.name = fusion_name;
        ker.suffix = suffix;
        ker.test_pat = test_pat;
        ker.type = 'kl2';  
        ker.cross = 0;
        
        ker.event_ids = event_ids;
        ker.calker_exp_dir = sprintf('%s/%s/experiments/%s/%s.%s', ker.proj_dir, proj_name, exp_name, ker.feat, suffix);
        calker_cal_map(proj_name, exp_name, ker, event_ids);
        
        test_db_file = sprintf('database_%s.mat', test_pat);
        calker_common_exp_dir = sprintf('%s/%s/experiments/%s/common', ker.proj_dir, proj_name, exp_name);
		gt_file = fullfile(calker_common_exp_dir, test_db_file);
        
        fprintf('Loading database [%s]...\n', test_db_file);
        load(gt_file, 'database');
        
    
        %% tuning threshold
        thresholds = [0:0.01:1];
        for ii=1:length(event_ids),
                    
            event_name = event_ids{ii};
            this_scores = scores.(event_name);
            this_scores = this_scores';
            
            label = database.labels.(event_name);
            label = label';
            
            max_f1 = 0;
            max_t = 0;
            for t = thresholds,
                pred = double(this_scores >= t);
                pred(pred == 0) = -1;
                eval = calker_cal_measure(label, pred);
                
                if max_f1 <= eval(6),
                    max_t  = t;
                    max_f1 = eval(6);
                end
                
                %%fprintf('(%f, %f) ', t, eval(6));
            end 
            
            out.(event_name) = max_t;
            fprintf('\n *** optimal: (%f, %f) \n ', max_t, max_f1);
        end
    end
end
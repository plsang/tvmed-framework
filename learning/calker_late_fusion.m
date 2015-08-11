function calker_late_fusion(exp_name, fuse_list, varargin)
    %%% fuse_list = 'mfcc_fc7'
    %%% test_pat = 'kindred14', 'eval15full';
    
    set_env;
    
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
	
	if ~exist(output_file, 'file'),
	
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
        
	if strcmp(test_pat, 'dev_val'),
        ker.feat = fusion_name;
        ker.name = fusion_name;
        ker.suffix = suffix;
        ker.test_pat = test_pat;
        ker.type = 'kl2';  
        ker.cross = 0;
        
        ker.event_ids = event_ids;
        ker.calker_exp_dir = sprintf('%s/%s/experiments/%s/%s.%s', ker.proj_dir, proj_name, exp_name, ker.feat, suffix);
        calker_cal_rank(proj_name, exp_name, ker, event_ids);
        calker_cal_map(proj_name, exp_name, ker, event_ids);
    end
	
    %calker_cal_rank(proj_name, exp_name, ker);
	%calker_cal_threshhold(proj_name, exp_name, ker);
end


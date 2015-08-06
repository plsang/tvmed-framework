function calker_late_fusion(fuse_list, varargin)
    %%% fuse_list = 'mfcc_fc7'
    %%% test_pat = 'kindred14', 'eval15full';
    
    
    test_pat = 'kindred14';
    start_event = 21;
    end_event = 40;
    
    proj_name = 'trecvidmed15';
	exp_name = 'niimed2015';
    ek_set = 'EK10Ex';
    miss_type = 'RN';
    ker_type = 'linear';
    feat_norm = 'l2';
	suffix = '--v1.3-r1';
	
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


	ker.proj_dir = '/net/per610a/export/das11f/plsang';
	
	addpath('/net/per900a/raid0/plsang/tools/kaori-secode-calker/support');
	addpath('/net/per900a/raid0/plsang/tools/libsvm-3.17/matlab');
	addpath('/net/per900a/raid0/plsang/tools/vlfeat-0.9.16/toolbox');
    
    event_ids = arrayfun(@(x) sprintf('E%03d', x), [start_event:end_event], 'UniformOutput', false);
    
	ker_names = struct;
	ker_names.('sift') = 'covdet.hessian.sift.cb256.fc.pca';
	ker_names.('mfcc') = 'mfcc.rastamat.cb256.fc';
    ker_names.('hoghof') = 'idensetraj.hoghof.fisher.cb256.pca';
    ker_names.('mbh') = 'idensetraj.mbh.fisher.cb256.pca';
    ker_names.('fc6') = 'placeshybrid.fc6';
    ker_names.('fc7') = 'placeshybrid.fc7';
    ker_names.('full') = 'placeshybrid.full';
				
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
    
	output_file = sprintf('%s/%s.%s/scores/%s/%s-%s/%s.%s.scores.mat', calker_exp_dir, fusion_name, suffix, test_pat, ek_set, miss_type, fusion_name, ker_type);
	
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
				fprintf(' -- [%d/%d] kernel [%s]...\n', jj, length(fused_ids), ker_name);
				
				scorePath = sprintf('%s/%s.%s.%s/scores/%s/%s-%s/%s.%s.%s.scores.mat', calker_exp_dir, ker_name, feat_norm, suffix, test_pat, ek_set, miss_type, ker_name, feat_norm, ker_type);
					
				if ~exist(scorePath, 'file');
					error('File not found! [%s]', scorePath);
				end
				
				load(scorePath, 'scores');
				if isfield(fused_scores, event_name),			
					fused_scores.(event_name) = [fused_scores.(event_name); scores.(event_name)];
				else
					fused_scores.(event_name) = scores.(event_name);
				end
			end
            
			fused_scores.(event_name) = mean(fused_scores.(event_name)); %scores: 1 x number of videos
		end
		
		scores = fused_scores;
		save(output_file, 'scores');
		
	end
	
    ker.feat = fusion_name;
    ker.name = fusion_name;
    ker.suffix = suffix;
    ker.test_pat = test_pat;
    ker.type = ker_type;
    
    ker.prms.tvprefix = 'TVMED14';
    ker.prms.eventkit = ek_set;
    ker.prms.rtype = miss_type;
    
    
    
    ker.event_ids = event_ids;
    ker.calker_exp_dir = sprintf('%s/%s/experiments/%s/%s.%s', ker.proj_dir, proj_name, exp_name, ker.feat, suffix);
        
	if ~strcmp(test_pat, 'eval15full'),
    
        medmd_file = '/net/per610a/export/das11f/plsang/trecvidmed14/metadata/medmd_2014_devel_ps.mat';
        fprintf('Loading metadata <%s>...\n', medmd_file);
        load(medmd_file, 'MEDMD'); 
        ker.MEDMD = MEDMD;
    
        fprintf('Calculating MAP...\n');
        calker_cal_map(proj_name, exp_name, ker);
    else
        medmd_file = '/net/per610a/export/das11f/plsang/trecvidmed/metadata/med15/med15_eval.mat';
        fprintf('Loading metadata <%s>...\n', medmd_file);
        load(medmd_file, 'MEDMD'); 
        ker.MEDMD = MEDMD;
    end
	
    calker_cal_rank(proj_name, exp_name, ker);
	%calker_cal_threshhold(proj_name, exp_name, ker);
end
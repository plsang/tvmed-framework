function calker_late_fusion(fuse_list)
    %%% fuse_list = 'mfcc_fc7'
    
    proj_name = 'trecvidmed15';
	exp_name = 'niimed2015';
    ek_set = 'EK10Ex';
    miss_type = 'RN';
    ker_type = 'linear';
    test_pat = 'kindred14';
    feat_norm = 'l2';
	
	if ~exist('suffix', 'var'),
		suffix = '--v1.3-r1';
		%suffix = '--tvmed13-v1.1.3-ah';
	end
	
	ker.proj_dir = '/net/per610a/export/das11f/plsang';
	
	addpath('/net/per900a/raid0/plsang/tools/kaori-secode-calker/support');
	addpath('/net/per900a/raid0/plsang/tools/libsvm-3.17/matlab');
	addpath('/net/per900a/raid0/plsang/tools/vlfeat-0.9.16/toolbox');

	event_list = '/net/per610a/export/das11f/plsang/trecvidmed14/metadata/common/trecvidmed14.events.ps.lst';
	%event_list = '/net/per610a/export/das11f/plsang/trecvidmed14/metadata/common/trecvidmed14.events.ah.lst';
	
	fh = fopen(event_list, 'r');
	infos = textscan(fh, '%s %s', 'delimiter', ' >.< ', 'MultipleDelimsAsOne', 1);
	fclose(fh);
	events = infos{1};
			
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
		for ii=1:length(events),
			event_name = events{ii};
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
	%ker.prms.test_meta_file = sprintf('%s/%s/metadata/%s-REFTEST-%s/database.mat', ker.proj_dir, proj_name, ker.prms.tvprefix, upper(test_pat));
    medmd_file = '/net/per610a/export/das11f/plsang/trecvidmed14/metadata/medmd_2014_devel_ps.mat';
    fprintf('Loading metadata <%s>...\n', medmd_file);
    load(medmd_file, 'MEDMD'); 
    ker.MEDMD = MEDMD;
	
    ker.event_ids = arrayfun(@(x) sprintf('E%03d', x), [21:40], 'UniformOutput', false);
    
    ker.calker_exp_dir = sprintf('%s/%s/experiments/%s/%s.%s', ker.proj_dir, proj_name, exp_name, ker.feat, suffix);
    
	fprintf('Calculating MAP...\n');
	calker_cal_map(proj_name, exp_name, ker);
	%calker_cal_rank(proj_name, exp_name, ker);
	%calker_cal_threshhold(proj_name, exp_name, ker);
end
function calker_late_fusion2(proj_name, exp_name, fuse_list, output_run, varargin)
    %%% fuse_list = 'mfcc_fc7'
    %%% test_pat = 'kindred14', 'eval15full';
    
    
    test_pat = 'medtest13lj';
    ek_set = 'EK10Ex';
    miss_type = 'RN';
    ker_type = 'mixed';
    feat_norm = 'l2';
	metadb = 'med2013lj';
	
    for k=1:2:length(varargin),

        opt = lower(varargin{k});
        arg = varargin{k+1} ;
        
        switch opt
            case 'metadb'
                metadb = arg ;
            case 'dim'
                feat_dim = arg;
            case 'ek'
                ek_set = arg;	
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
    
    %event_ids = arrayfun(@(x) sprintf('E%03d', x), [start_event:end_event], 'UniformOutput', false);
    
    %% hard code for med 2013 
    if strcmp(test_pat, 'medtest13lj'),
        event_ids = [arrayfun(@(x) sprintf('E%03d', x), [6:15], 'UniformOutput', false), ...
                    arrayfun(@(x) sprintf('E%03d', x), [21:30], 'UniformOutput', false)]
    elseif strcmp(test_pat, 'medtest14lj'),
        event_ids = arrayfun(@(x) sprintf('E%03d', x), [21:40], 'UniformOutput', false);
    else    
        error('Unknown test pat');
    end
	calker_exp_dir = sprintf('%s/%s/experiments/%s', ker.proj_dir, proj_name, exp_name);
	
    %fused_runs = strsplit(fuse_list, '_');
    fused_runs = regexp(fuse_list, '_', 'split');
    fused_runs
    
	output_file = sprintf('%s/%s/scores/%s/%s-%s/%s.%s.scores.mat', ...
        calker_exp_dir, output_run, test_pat, ek_set, miss_type, output_run, ker_type);
	
	if ~exist(output_file, 'file'),
	
		output_dir = fileparts(output_file);
		if ~exist(output_dir, 'file'),
			mkdir(output_dir);
		end
		
		fused_scores = struct;
		for ii=1:length(event_ids),
			event_name = event_ids{ii};
			fprintf('Fusing for event [%s]...\n', event_name);
			for jj = 1:length(fused_runs),
                fused_run = fused_runs{jj};
				fprintf(' -- [%d/%d] kernel [%s]...\n', jj, length(fused_runs), fused_run);
				
                scorePattern = sprintf('%s/%s/scores/%s/%s-%s/*.scores.mat', ...
                    calker_exp_dir, fused_run, test_pat, ek_set, miss_type);
                    
				scorePaths = dir(scorePattern);
				
				if length(scorePaths) == 0;
					error('Score file not found! [pattern: %s]', scorePattern);
                elseif length(scorePaths) > 1;
                    error('Too many score files! [pattern: %s]', scorePattern);
                else
                    scorePath = sprintf('%s/%s/scores/%s/%s-%s/%s', ...
                        calker_exp_dir, fused_run, test_pat, ek_set, miss_type, scorePaths(1).name);
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
	
    ker.feat = output_run;
    ker.name = output_run;
    ker.test_pat = test_pat;
    ker.type = ker_type;
    
    ker.prms.tvprefix = 'TVMED14';
    ker.prms.eventkit = ek_set;
    ker.prms.rtype = miss_type;
    ker.metadb = metadb;
    
    
    ker.event_ids = event_ids;
    ker.calker_exp_dir = sprintf('%s/%s/experiments/%s/%s', ker.proj_dir, proj_name, exp_name, ker.feat);
        
        
    if strcmp(ker.metadb, 'med2014'),
        medmd_file = '/net/per610a/export/das11f/plsang/trecvidmed14/metadata/medmd_2014_devel_ps.mat';
    elseif strcmp(ker.metadb, 'med2012'),
        medmd_file = '/net/per610a/export/das11f/plsang/trecvidmed/metadata/med12/medmd_2012_upgraded.mat';
    elseif strcmp(ker.metadb, 'med2011'),
        medmd_file = '/net/per610a/export/das11f/plsang/trecvidmed/metadata/med11/medmd_2011.mat';
    elseif strcmp(ker.metadb, 'med2015ah'),
        medmd_file = '/net/per610a/export/das11f/plsang/trecvidmed/metadata/med15/med15_ah.mat';    
    elseif strcmp(ker.metadb, 'med2013lj'),
        medmd_file = '/net/per610a/export/das11f/plsang/trecvidmed/metadata/med13/medmd_2013_lujiang.mat';        
    elseif strcmp(ker.metadb, 'med2014lj'),
        medmd_file = '/net/per610a/export/das11f/plsang/trecvidmed/metadata/med14/medmd_2014_lujiang.mat';        
    else
        error('unknown metadb <%s>\n', ker.metadb);
    end
    
    fprintf('Loading metadata <%s>...\n', medmd_file);
    load(medmd_file, 'MEDMD'); 

    ker.MEDMD = MEDMD;

    fprintf('Calculating MAP...\n');
    calker_cal_map(proj_name, exp_name, ker);
    calker_cal_rank(proj_name, exp_name, ker);
	%calker_cal_threshhold(proj_name, exp_name, ker);
    
    quit;
end
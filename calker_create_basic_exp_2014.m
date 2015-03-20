function calker_create_basic_exp_2014()
	calker_create_basic_exp_train_();
	calker_create_basic_exp_test_();
end

function calker_create_basic_exp_train_()
	
	meta_dir = '/net/per610a/export/das11f/plsang/trecvidmed13/metadata';
	meta_file = fullfile(meta_dir, 'medmd_2014_devel.mat');
	
	fprintf('Loading metadata file...\n');
	load(meta_file, 'MEDMD');
	
	%% setting for MED 2013,
	%% Pre-specified tasks: 20 events E021-E030 & E031-E040
	
	fprintf('Generating for TVMED14-PS...\n');
	exp_prefix = 'TVMED14-PS';
	event_nums = [21:40];
	calker_create_basic_exp_train_set(MEDMD, exp_prefix, event_nums, meta_dir, 'PS');

	%% setting for MED 2013,
	%% Ad-hoc tasks: 
	
	%fprintf('Generating for TVMED14-AH...\n');
	%exp_prefix = 'TVMED14-AH';
	%event_nums = [41:50];
	%calker_create_basic_exp_train_set(MEDMD, exp_prefix, event_nums, meta_dir, 'AH');
end

function calker_create_basic_exp_train_set(MEDMD, exp_prefix, event_nums, meta_dir, event_type)

	event_ids = arrayfun(@(x) sprintf('E%03d', x), event_nums, 'UniformOutput', false);
	
	if strcmp(event_type, 'PS'),
		event_kits = {'EK10Ex', 'EK100Ex'};
	elseif strcmp(event_type, 'AH'),
		event_kits = {'EK10Ex', 'EK100Ex'};
	end
	
	%% 3 ways to use miss (related) videos
	related_examples = {'RP', 'RN', 'NR'}; % RP: Related as Positive, RN: Related as Negative, NR: No Related 
	
	% universal database (specific for event types)
	database = struct;
	event_clip_names = {};
	
	for ii = 1:length(event_kits),
		event_kit = event_kits{ii};
		
		for jj = 1:length(event_ids),
			event_id = event_ids{jj};
			event_clip_names = [event_clip_names, MEDMD.EventKit.(event_kit).judge.(event_id).positive]; 
			event_clip_names = [event_clip_names, MEDMD.EventKit.(event_kit).judge.(event_id).miss]; 
		end
	
	end
	
	event_clip_names = unique(event_clip_names);
		
	bg_clip_names = unique(MEDMD.EventBG.default.clips);
		
	clip_names = [event_clip_names, bg_clip_names];
		
	clip_names = unique(clip_names);
	clip_idxs = [1:length(clip_names)];
	
	%train_labels = repmat(init_labels, length(event_ids), 1);
	
	database.clip_names = clip_names;
	database.clip_idxs = clip_idxs;
	database.num_clip = length(clip_names);
	database.event_ids = event_ids;
	database.event_names = MEDMD.EventKit.(event_kit).eventnames(find(ismember(MEDMD.EventKit.(event_kit).eventids, event_ids)));
	
	train_labels = zeros(length(event_ids), length(clip_names));
	
	for ii = 1:length(event_kits),
		event_kit = event_kits{ii};
		exp_name = [exp_prefix, '-', event_kit];
		
		event_clip_names = {};
		
		for jj = 1:length(event_ids),
			event_id = event_ids{jj};
			event_clip_names = [event_clip_names, MEDMD.EventKit.(event_kit).judge.(event_id).positive]; 
			event_clip_names = [event_clip_names, MEDMD.EventKit.(event_kit).judge.(event_id).miss]; 
		end
		
		event_clip_names = unique(event_clip_names);
		
		bg_clip_names = unique(MEDMD.EventBG.default.clips);
		
		clip_names = [event_clip_names, bg_clip_names];
		
		clip_names = unique(clip_names);
		
		database.sel_idx = ismember(database.clip_names, clip_names);
		
		for kk = 1:length(related_examples),
			r_example = related_examples{kk};
			%r_train_labels = train_labels(:, database.sel_idx);
			
			r_exp_name = [exp_name, '-', r_example];
			output_dir = sprintf('%s/%s', meta_dir, r_exp_name);
			if ~exist(output_dir, 'file'), mkdir(output_dir); end;
			
			output_file = sprintf('%s/database.mat', output_dir);
			if exist(output_file, 'file'), fprintf('File %s already exist!\n', output_file); continue; end;
			
			r_train_labels = train_labels;
			
			for jj = 1:length(event_ids),
				
				r_train_labels(jj, database.sel_idx) = -1;
				
				event_id = event_ids{jj};
				event_pos_clips = MEDMD.EventKit.(event_kit).judge.(event_id).positive;
				event_miss_clips = MEDMD.EventKit.(event_kit).judge.(event_id).miss;
				
				%event_pos_idx = find(ismember(clip_names, event_pos_clips));
				event_pos_idx = ismember(database.clip_names, event_pos_clips);
				r_train_labels(jj, event_pos_idx) = 1;
				
				event_miss_idx = ismember(database.clip_names, event_miss_clips);
				
				switch r_example,
					case 'RP' 
						r_train_labels(jj, event_miss_idx) = 1;
					case 'RN' 
						r_train_labels(jj, event_miss_idx) = -1;
					case 'NR' 
						r_train_labels(jj, event_miss_idx) = 0;
					otherwise 
						error('Unknow related example type!');
				end
				
			end

			database.train_labels = r_train_labels;
			save(output_file, 'database');			
		end
	end
	
end

function calker_create_basic_exp_test_()
	meta_dir = '/net/per610a/export/das11f/plsang/trecvidmed13/metadata';
	
	exp_prefix = 'TVMED14-REFTEST';	
	meta_file = fullfile(meta_dir, 'medmd_2014_devel.mat');
	
	fprintf('Loading metadata file...');
	load(meta_file, 'MEDMD');
	test_sets = fieldnames(MEDMD.RefTest);
	
	for ii = 1:length(test_sets),
		test_set = test_sets{ii};
		exp_name = [exp_prefix, '-', test_set];
		output_dir = sprintf('%s/%s', meta_dir, exp_name);
		if ~exist(output_dir, 'file'), mkdir(output_dir); end;
		output_file = sprintf('%s/database.mat', output_dir);
		if exist(output_file, 'file'), fprintf('File %s already exist!\n', output_file); continue; end;
		database.clip_names = MEDMD.RefTest.(test_set).clips;
		database.clip_idxs = [1:length(database.clip_names)];
		database.num_clip = length(database.clip_names);
		database.event_ids = MEDMD.RefTest.(test_set).eventids;
		database.event_names = MEDMD.RefTest.(test_set).eventnames;
		database.ref = MEDMD.RefTest.(test_set).ref;
		save(output_file, 'database');			
	end
	
	exp_prefix = 'TVMED14-UNREFTEST';
	meta_file = fullfile(meta_dir, 'medmd_2014_test.mat');
	load(meta_file, 'MEDMD');
	test_sets = fieldnames(MEDMD.UnrefTest);
	for ii = 1:length(test_sets),
		test_set = test_sets{ii};
		exp_name = [exp_prefix, '-', test_set];
		output_dir = sprintf('%s/%s', meta_dir, exp_name);
		if ~exist(output_dir, 'file'), mkdir(output_dir); end;
		output_file = sprintf('%s/database.mat', output_dir);
		if exist(output_file, 'file'), fprintf('File %s already exist!\n', output_file); continue; end;
		database.clip_names = MEDMD.UnrefTest.(test_set).clips;
		database.clip_idxs = [1:length(database.clip_names)];
		database.num_clip = length(database.clip_names);
		database.event_ids = MEDMD.UnrefTest.(test_set).eventids;
		database.event_names = MEDMD.UnrefTest.(test_set).eventnames;
		save(output_file, 'database');			
	end
end

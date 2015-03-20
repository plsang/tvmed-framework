function calker_create_basic_exp_2014_ah()
	%calker_create_basic_exp_train_();
	%calker_create_basic_exp_test_();
	calker_create_basic_exp_val_();
end

% for thresholding
function calker_create_basic_exp_val_()
	meta_dir = '/net/per610a/export/das11f/plsang/trecvidmed14/metadata';
	meta_file = fullfile(meta_dir, 'medmd_2014_devel_ah.mat');
	
	fprintf('Loading metadata file...\n');
	load(meta_file, 'MEDMD');
	
	fprintf('Generating for TVMED14-AH...\n');
	exp_prefix = 'TVMED14-AH';
	event_nums = [41:50];
	
	event_kits = {'EK10Ex', 'EK100Ex'};
	
	event_ids = arrayfun(@(x) sprintf('E%03d', x), event_nums, 'UniformOutput', false);
	
	max_positive = 20;
	
	input_database = '/net/per610a/export/das11f/plsang/trecvidmed14/metadata/TVMED14-AH-EK100Ex-RN/database.mat';
	load(input_database);
	output_database = '/net/per610a/export/das11f/plsang/trecvidmed14/metadata/TVMED14-AH-EK80Ex-RN/database.mat';
	
	ref = struct;
	ref_clips = {};
	for jj = 1:length(event_ids),
		event_id = event_ids{jj};
		ek10_pos = MEDMD.EventKit.EK10Ex.judge.(event_id).positive; 
		ek100_pos = MEDMD.EventKit.EK100Ex.judge.(event_id).positive;
		
		ek10_pos_idx = find(ismember(database.clip_names, ek10_pos));
		ek100_pos_idx = find(ismember(database.clip_names, ek100_pos));
		
		remaining_pos_idx = setdiff(ek100_pos_idx, ek10_pos_idx);
		
		rand_index = randperm(length(remaining_pos_idx));
		
		selected_index = rand_index(1:max_positive);
		remaining_pos_test_idx = remaining_pos_idx(selected_index);
		remaining_pos_train_idx = setdiff(remaining_pos_idx, remaining_pos_test_idx);
		
		database.train_labels(jj, remaining_pos_test_idx) = 0;
		ref.(event_id) = database.clip_names(remaining_pos_test_idx);
		ref_clips = [ref_clips, ref.(event_id)];
	end	
	save(output_database, 'database');
	
	
	input_database = '/net/per610a/export/das11f/plsang/trecvidmed14/metadata/TVMED14-REFTEST-KINDREDTEST/database.mat';
	load(input_database);
	output_database = '/net/per610a/export/das11f/plsang/trecvidmed14/metadata/TVMED14-REFTEST-KINDREDTESTAH/database.mat';
	
	old_ref_clips = {};
	for ii = 1:length(database.event_ids),
		event_id = database.event_ids{ii};
		old_ref_clips = [old_ref_clips, database.ref.(event_id)];
	end
	old_ref_clips_idx = find(ismember(database.clip_names, old_ref_clips));
	background_clips_idx = setdiff(1:length(database.clip_names), old_ref_clips_idx);
	background_clips = database.clip_names(background_clips_idx);
	
	database.clip_names = [ref_clips, background_clips];
	database.clip_idxs = [1:length(database.clip_names)];
	database.num_clip = length(database.clip_names);
	database.event_ids = event_ids;
	database.ref = ref;
	
	save(output_database, 'database');
	
	input_database = '/net/per610a/export/das11f/plsang/trecvidmed14/metadata/TVMED14-REFTEST-MEDTEST/database.mat';
	load(input_database);
	output_database = '/net/per610a/export/das11f/plsang/trecvidmed14/metadata/TVMED14-REFTEST-MEDTESTAH/database.mat';
	
	old_ref_clips = {};
	for ii = 1:length(database.event_ids),
		event_id = database.event_ids{ii};
		old_ref_clips = [old_ref_clips, database.ref.(event_id)];
	end
	old_ref_clips_idx = find(ismember(database.clip_names, old_ref_clips));
	background_clips_idx = setdiff(1:length(database.clip_names), old_ref_clips_idx);
	background_clips = database.clip_names(background_clips_idx);
	
	database.clip_names = [ref_clips, background_clips];
	database.clip_idxs = [1:length(database.clip_names)];
	database.num_clip = length(database.clip_names);
	database.event_ids = event_ids;
	database.ref = ref;
	
	save(output_database, 'database');
	
end

function calker_create_basic_exp_train_()
	
	meta_dir = '/net/per610a/export/das11f/plsang/trecvidmed14/metadata';
	meta_file = fullfile(meta_dir, 'medmd_2014_devel_ah.mat');
	
	fprintf('Loading metadata file...\n');
	load(meta_file, 'MEDMD');
	
	%% setting for MED 2013,
	%% Pre-specified tasks: 20 events E021-E030 & E031-E040
	
	fprintf('Generating for TVMED14-AH...\n');
	exp_prefix = 'TVMED14-AH';
	event_nums = [41:50];
	calker_create_basic_exp_train_set(MEDMD, exp_prefix, event_nums, meta_dir, 'AH');

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
	%database.event_names = MEDMD.EventKit.(event_kit).eventnames(find(ismember(MEDMD.EventKit.(event_kit).eventids, event_ids)));
	
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
				
				%r_train_labels(jj, database.sel_idx) = -1;
				r_train_labels(jj, database.sel_idx) = 0;
				
				event_id = event_ids{jj};
				event_pos_clips = MEDMD.EventKit.(event_kit).judge.(event_id).positive;
				event_miss_clips = MEDMD.EventKit.(event_kit).judge.(event_id).miss;
				
				%event_pos_idx = find(ismember(clip_names, event_pos_clips));
				event_pos_idx = ismember(database.clip_names, event_pos_clips);
				r_train_labels(jj, event_pos_idx) = 1;
				
				event_miss_idx = ismember(database.clip_names, event_miss_clips);
				
				bg_clip_idx = ismember(database.clip_names, bg_clip_names);
				r_train_labels(jj, bg_clip_idx) = -1;
				
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
	meta_dir = '/net/per610a/export/das11f/plsang/trecvidmed14/metadata';
	
	exp_prefix = 'TVMED14-UNREFTEST';
	meta_file = fullfile(meta_dir, 'medmd_2014_test_ah.mat');
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
		%database.event_names = MEDMD.UnrefTest.(test_set).eventnames;
		save(output_file, 'database');			
	end
end

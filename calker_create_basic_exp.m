function calker_create_basic_exp()
	calker_create_basic_exp_train_();
	calker_create_basic_exp_test_();
end

function calker_create_basic_exp_train_()
	
	meta_dir = '/net/per610a/export/das11f/plsang/trecvidmed13/metadata/';
	meta_file = fullfile(meta_dir, 'medmd.mat');
	
	fprintf('Loading metadata file...');
	load(meta_file, 'MEDMD');
	
	event_kits = {'EK10Ex', 'EK100Ex', 'EK130Ex'};
	
	%% setting for MED 2013,
	%% Pre-specified tasks: 20 events E006-E015 & E021-E030
	
	exp_prefix = 'TVMED13-PS';
	event_nums = [6:15, 21:30];
	event_ids = arrayfun(@(x) sprintf('E%03d', x), event_nums, 'UniformOutput', false);
	
	%% 3 ways to use miss (related) videos
	related_examples = {'RP', 'RN', 'NR'}; % RP: Related as Positive, RN: Related as Negative, NR: No Related 
	
	for ii = 1:length(event_kits),
		event_kit = event_kits{ii};
		MEDMD.EventKit.(event_kit); 
		
		exp_name = [exp_prefix, '-', event_kit];
		
		% as positive
		database = struct;
		
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
		clip_idxs = [1:length(clip_names)];
		
		init_labels = -ones(length(clip_names), 1);
		
		train_labels = repmat(init_labels, 1, length(event_ids));
		
		database.clip_names = clip_names;
		database.clip_idxs = clip_idxs;
		database.num_clip = length(clip_names);
		database.event_ids = event_ids;
		database.event_names = MEDMD.EventKit.(event_kit).eventnames(find(ismember(MEDMD.EventKit.(event_kit).eventids, event_ids)));
		
		for kk = 1:length(related_examples),
			r_example = related_examples{kk};
			r_train_labels = train_labels;
			
			r_exp_name = [exp_name, '-', r_example];
			output_dir = sprintf('%s/%s', meta_dir, r_exp_name);
			if ~exist(output_dir, 'file'), mkdir(output_dir); end;
			
			output_file = sprintf('%s/database_devel.mat', output_dir);
			if exist(output_file, 'file'), fprintf('File %s already exist!\n', output_file); continue; end;
			
			for jj = 1:length(event_ids),
				event_id = event_ids{jj};
				event_pos_clips = MEDMD.EventKit.(event_kit).judge.(event_id).positive;
				event_miss_clips = MEDMD.EventKit.(event_kit).judge.(event_id).miss;
				
				event_pos_idx = find(ismember(clip_names, event_pos_clips));
				r_train_labels(event_pos_idx, jj) = 1;
				
				event_miss_idx = find(ismember(clip_names, event_miss_clips));
				
				switch r_example,
					case 'RP' 
						r_train_labels(event_miss_idx, jj) = 1;
					case 'RN' 
						r_train_labels(event_miss_idx, jj) = -1;
					case 'NR' 
						r_train_labels(event_miss_idx, jj) = 0;
					otherwise 
						error('Unknow related example type!');
				end
				
				database.train_labels = r_train_labels;
			end

			save(output_file, 'database');			
		end
	end
	
	%% setting for MED 2013,
	%% Ad-hoc tasks: 
end


function calker_create_basic_exp_test_()
	meta_dir = '/net/per610a/export/das11f/plsang/trecvidmed13/metadata/';
	meta_file = fullfile(meta_dir, 'medmd.mat');
	
	fprintf('Loading metadata file...');
	load(meta_file, 'MEDMD');
		
	exp_prefix = 'TVMED13-PS-TEST';
	event_nums = [6:15, 21:30];
	event_ids = arrayfun(@(x) sprintf('E%03d', x), event_nums, 'UniformOutput', false);
    event_names = MEDMD.EventKit.(event_kit).eventnames(find(ismember(MEDMD.EventKit.(event_kit).eventids, event_ids)));
	
	MEDMD.RefTest 	
end

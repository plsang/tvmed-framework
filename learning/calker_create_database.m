function calker_create_database(ker, pat_name, task)

calker_exp_dir = sprintf('%s/%s/experiments/%s/%s%s', ker.proj_dir, ker.proj_name, ker.exp_name, ker.feat, ker.suffix);
calker_common_exp_dir = sprintf('%s/%s/experiments/%s/common/%s', ker.proj_dir, ker.proj_name, ker.exp_name, ker.feat);
if ~exist(calker_common_exp_dir, 'file'),
	mkdir(calker_common_exp_dir);
end

skip_exist = 0;
	
db_file = fullfile(calker_common_exp_dir, ['database_' pat_name '.mat']);
if skip_exist && exist(db_file, 'file'),
	fprintf('File [%s] already exist! skip!\n', db_file);
	return;
end

fprintf('creating the database...\n');

database = struct;


database.cname = {}; % name of each video
database.labels = struct;
database.path = {}; % contain the pathes for each image of each class
database.video = []; % video index for each segment


shots = vsd_load_shots_2015( ker.proj_dir, ker.proj_name, pat_name);
        
for ii = 1:length(shots),
    shot_id = shots{ii};
    
    fprintf('Processing [%d/%d] videos...\n', ii, length(shots));
    database.cname{end+1} = shot_id(1:end-4);        

    if strcmp(ker.mode, 'submit'),
        c_path = sprintf('%s/%s/feature/%s/%s/%s.mat',...
            ker.proj_dir, ker.proj_name, ker.feat_raw, pat_name, shot_id(1:end-4));                  
    elseif strcmp(ker.mode, 'tune'),
        c_path = sprintf('%s/%s/feature/%s/%s/%s.mat',...
            ker.proj_dir, ker.proj_name, ker.feat_raw, 'devset', shot_id(1:end-4));                  
    end
    
    database.path{end+1} = c_path;

end


database.num_shot = length(database.cname);

%% no annotation dir for this pat_name, means this is a test patition	
if ~isempty(strfind(pat_name, 'dev')),
    ann_dir = sprintf('%s/%s/annotations/%s', ...
			ker.proj_dir, ker.proj_name, 'devset');
			
	for jj = 1:length(ker.events),
		event = ker.events{jj};
		
		%label = -1*ones(1, length(shots));
		label = -ones(1, length(database.cname));
		
        if strcmp(task, 'violence'),
            pos_ann_file = sprintf('%s/%s', ann_dir, task); 	% label 1
        else
            pos_ann_file = sprintf('%s/%s_%s', ann_dir, task, event); 	% label 1
        end    
		
		pos_shots = load_shot_ann(pos_ann_file);
		
        pos_idx = find(ismember(database.cname, pos_shots));
        
		label(pos_idx) = 1;
		
		database.labels.(event) = label;
	end	
end

	disp('done!');
	save(db_file, 'database');
	clear database;
		
end

function pos_shots = load_shot_ann(ann_file)
	fh = fopen(ann_file, 'r');
	
	infos = textscan(fh, '%s');
	
	pos_shots = infos{1};
	
	fclose(fh);
end


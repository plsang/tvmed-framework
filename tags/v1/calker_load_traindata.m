
function hists = calker_load_traindata(proj_name, exp_name, ker)

%%Update change parameter to ker
% load database

calker_exp_dir = sprintf('/net/per900a/raid0/plsang/%s/experiments/%s-calker/%s', proj_name, exp_name, ker.feat);

db_file = fullfile(calker_exp_dir, 'metadata', 'database_devel.mat');
load(db_file, 'database');

traindb_file = fullfile(calker_exp_dir, 'metadata', 'traindb.mat');
load(traindb_file, 'traindb');

hists = zeros(ker.num_dim, size(database.label, 1));
listPtr = 1;

if isempty(traindb)
    error('Empty training db!!\n');
end

for ii = 1:length(traindb.video), %
    video = traindb.video{ii};
	
    
	%skip non-seletecd videos
	if ~isfield(traindb.sel, video), continue; end;
	
    vid_idx = find(ismember(database.cname, video));
    if isempty(vid_idx)
        error('Video not found!');
    end
    
    %ft_files = database.path(database.video == vid_idx);
    %hists_ = [];
    %for ft_file = ft_files,
    %    load(ft_file{:}, 'code'); 
    %    hists_ = [hists_ code];
    %end
	
	sel = traindb.sel.(video);
	
    ft_file = database.path{vid_idx};
	if ~exist(ft_file),
		warning('File [%s] does not exist!\n', ft_file);
		hists_ = rand(ker.num_dim, length(sel));
	end
    hists_ = load_feature(ft_file);
    
    
    %% Feb 13th, important update: remove features containing NaN
    %% c.f. HVC4727, last 8 segments in 60s experiments
	
	%% update Jun 21, 2013: set random value to NaN to reserve number of segment
    %% sel = sel(:, ~any(isnan(hists_)));
	hists_(isnan(hists_)) = rand();
    
    curEnd = listPtr + length(sel) - 1;
	if size(hists_, 2) < length(sel),
		hists(:, listPtr:curEnd) = rand(ker.num_dim, length(sel));
	else
		hists(:, listPtr:curEnd) = hists_(:, sel);
	end
    
    fprintf('[%d] Video %s - %d features loaded (%d new features added)!\n', ii, video, listPtr, length(sel));
    listPtr = listPtr + length(sel); 
end

if listPtr < size(traindb.label, 1),
    hists(:, listPtr:end) = []; 
end

end



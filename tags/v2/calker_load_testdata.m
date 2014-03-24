
function hists = calker_load_testdata(proj_name, exp_name, ker)

%%Update change parameter to ker
% load database
calker_exp_dir = sprintf('/net/per900a/raid0/plsang/%s/experiments/%s-calker/%s', proj_name, exp_name, ker.feat);

db_file = fullfile(calker_exp_dir, 'metadata', 'database_test.mat');
load(db_file, 'database');

hists = zeros(ker.num_dim, size(database.label, 1));
listPtr = 1;

if isempty(database)
    error('Empty db!!\n');
end

for ii = 1:length(database.cname), %
    video = database.cname{ii};
    
    ft_file = database.path{ii};
	if ~exist(ft_file),
		warning('File [%s] does not exist!\n', ft_file);
		hists_ = rand(ker.num_dim, 1);
	end
    hists_ = load_feature(ft_file);
    
    %removing NaN features
    %hists_ = hists_(:, ~any(isnan(hists_)));
	
	%% update Jun 21, 2013: set random value to NaN to reserve number of segment
	hists_(isnan(hists_)) = rand();
    if isempty(hists_),
		hists_ = rand(ker.num_dim, 1);
	end
    curEnd = listPtr + size(hists_, 2) - 1;
    hists(:, listPtr:curEnd) = hists_(:, :);
    
    fprintf('[%d] Video %s - %d features loaded (%d new features added)!\n', ii, video, listPtr, size(hists_, 2));
    listPtr = listPtr + size(hists_, 2); 
end

if listPtr < size(database.label, 1),
    hists(:, listPtr:end) = []; 
end

end



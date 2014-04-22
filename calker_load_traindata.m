
function [hists, sel_feat] = calker_load_traindata(proj_name, exp_name, ker)

%%Update change parameter to ker
% load database

calker_exp_dir = sprintf('%s/%s/experiments/%s-calker/%s%s', ker.proj_dir, proj_name, exp_name, ker.feat, ker.suffix);

fprintf('Loading meta file \n');
database = load(ker.prms.meta_file, 'database');
database = database.database;

if isempty(database)
    error('Empty metadata file!!\n');
end

hists = zeros(ker.num_dim, size(database.train_labels, 1));

selected_label = zeros(1, size(database.train_labels, 1));

parfor ii = 1:size(database.train_labels, 1), %
	
	clip_name = database.clip_names{ii};
	
	segment_path = sprintf('%s/%s/feature/%s/%s/%s/%s/%s.mat',...
						ker.proj_dir, proj_name, ker.prms.seg_name, ker.feat_raw, ker.prms.train_fea_pat, clip_name, clip_name);   
						
	if ~exist(segment_path),
		warning('File [%s] does not exist!\n', segment_path);
		continue;
	end
	
	code = load(segment_path, 'code');
	code = code.code;
	
	if size(code, 1) ~= ker.num_dim,
		warning('Dimension mismatch [%d-%d-%s]. Skipped !!\n', size(code, 1), ker.num_dim, segment_path);
		size(code)
		continue;
	end
	
	if any(isnan(code)),
		warning('Feature contains NaN [%s]. Skipped !!\n', segment_path);
		msg = sprintf('Feature contains NaN [%s]', segment_path);
		log(msg);
		continue;
	end
	
	% event video contains all zeros --> skip, keep backgroud video
	if all(code == 0),
		warning('Feature contains all zeros [%s]. Skipped !!\n', segment_path);
		msg = sprintf('Feature contains all zeros [%s]', segment_path);
		log(msg);
		continue;
	end
	
	if ~all(code == 0),
		if strcmp(ker.feat_norm, 'l1'),
			code = code / norm(code, 1);
		elseif strcmp(ker.feat_norm, 'l2'),
			code = code / norm(code, 2);
		else
			error('unknown norm!\n');
		end
    end
	
	hists(:, ii) =  code;
	selected_label(ii) = 1;
	
end

sel_feat = selected_label ~= 0;
hists = hists(:, sel_feat);

%fprintf('Updating traindb ...\n');
%save(traindb_file, 'traindb');

end

function log (msg)
    logfile = [mfilename('fullpath'), '.log'];
    fh = fopen(logfile, 'a+');
    fprintf(fh, [msg, '\n']);
	fclose(fh);
end

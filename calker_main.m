function calker_main(proj_name, exp_name, feature_ext, varargin)

set_env;

feat_dim = 2^16;
ker_type = 'linear';
cross = 0;
open_pool = 0;
suffix = '';
test_pat = 'kindred14';
eventkit = 'EK100Ex';
miss_type = 'RN'; % RN: Related example as Negative, RP: Related example as Positive, NR: No related example
tvtask = 'PS';
desc = 'hoghof';
start_event = 21;
end_event = 40;

for k=1:2:length(varargin),

	opt = lower(varargin{k});
	arg = varargin{k+1} ;
  
	switch opt
		case 'cross'
			cross = arg;
		case 'pool' ;
			open_pool = arg ;
		case 'cv' ;
			cv = arg ;
		case 'ker' ;
			ker_type = arg ;
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
		case 'task'
			tvtask = arg;
		case 'desc'
			desc = arg;
        case 's'
            start_event = arg;
        case 'e'
            end_event = arg;
    
		otherwise
			error(sprintf('Option ''%s'' unknown.', opt)) ;
	end  
end

ker = calker_build_kerdb(feature_ext, ker_type, feat_dim, cross, suffix);

ker.prms.tvprefix = 'TVMED14';
ker.prms.tvtask = upper(tvtask);
ker.prms.eventkit = eventkit; % 'EK130Ex';
ker.prms.rtype = miss_type;	% RN: Related example as Negative, RP: Related example as Positive, NR: No related example 
ker.prms.train_fea_pat = 'devel';	% train pat name where local features are stored
ker.prms.test_fea_pat = 'devel';	% train pat name where local features are stored

ker.idt_desc = desc;

ker.dev_pat = 'dev';
ker.test_pat = test_pat;

calker_exp_dir = sprintf('%s/%s/experiments/%s-calker/%s%s', ker.proj_dir, proj_name, exp_name, ker.feat, ker.suffix);
ker.log_dir = fullfile(calker_exp_dir, 'log');
ker.calker_exp_dir = sprintf('%s/%s/experiments/%s/%s-%s', ker.proj_dir, proj_name, exp_name, ker.feat, ker.suffix);
ker.event_ids = arrayfun(@(x) sprintf('E%03d', x), [start_event:end_event], 'UniformOutput', false);

fprintf('Loading metadata...\n');
medmd_file = '/net/per610a/export/das11f/plsang/trecvidmed14/metadata/medmd_2014_devel_ps.mat';
load(medmd_file, 'MEDMD'); 
ker.MEDMD = MEDMD;

%open pool
%if matlabpool('size') == 0 && open_pool > 0, matlabpool(open_pool); end;
calker_cal_train_kernel(proj_name, exp_name, ker);
calker_train_kernel(proj_name, exp_name, ker);
calker_test_kernel(proj_name, exp_name, ker);
calker_cal_map(proj_name, exp_name, ker);
%end
%calker_cal_rank(proj_name, exp_name, ker);

%close pool
%if matlabpool('size') > 0, matlabpool close; end;

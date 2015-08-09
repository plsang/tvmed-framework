function calker_main(exp_name, feature_ext, varargin)

%% exp_name: arousal, valence, violence

addpath('/net/per610a/export/das11f/plsang/codes/kaori-secode-vsd');
set_env;

feat_dim = 4000;
ker_type = 'kl2';
cross = 0;
open_pool = 0;
mode = 'submit';
suffix = '';

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
        case 'mode'
            mode = arg;
		otherwise
			error(sprintf('Option ''%s'' unknown.', opt)) ;
	end  
end


switch exp_name,
    case 'arousal'
        events = {'active', 'neutral', 'passive'};
    case 'valence'
        events = {'negative', 'neutral', 'positive'};
    case 'violence'
        events = {'violence'};
    otherwise
        error('unknown experiment name');
end

ker = calker_build_kerdb(feature_ext, ker_type, feat_dim, cross, suffix);

ker.events = events;
ker.mode = mode;

if strcmp(ker.mode, 'submit'),
    ker.dev_pat = 'devset';
    ker.test_pat = 'testset';
elseif strcmp(mode, 'tune'),
    ker.dev_pat = 'dev_train';
    ker.test_pat = 'dev_val';
else
    error('unknown mode <%s> \n', mode);
end





ker.proj_dir = '/net/per920a/export/das14a/satoh-lab/plsang';
ker.proj_name = 'vsd2015';
ker.exp_name = exp_name;

calker_exp_dir = sprintf('%s/%s/experiments/%s/%s%s', ker.proj_dir, ker.proj_name, ker.exp_name, ker.feat, ker.suffix);
ker.log_dir = fullfile(calker_exp_dir, 'log');
 
%if ~exist(calker_exp_dir, 'file'),
mkdir(calker_exp_dir);
mkdir(fullfile(calker_exp_dir, 'metadata'));
mkdir(fullfile(calker_exp_dir, 'kernels'));
mkdir(fullfile(calker_exp_dir, 'kernels', ker.dev_pat));
mkdir(fullfile(calker_exp_dir, 'kernels', ker.test_pat));
mkdir(fullfile(calker_exp_dir, 'scores'));
mkdir(fullfile(calker_exp_dir, 'scores', ker.test_pat));
mkdir(fullfile(calker_exp_dir, 'models'));
mkdir(fullfile(calker_exp_dir, 'log'));
%end

calker_create_database(ker, ker.dev_pat, exp_name);
calker_create_database(ker, ker.test_pat, exp_name);

%open pool
if matlabpool('size') == 0 && open_pool > 0, matlabpool(open_pool); end;
calker_cal_train_kernel(ker.proj_name, ker.exp_name, ker);
calker_train_kernel(ker.proj_name, ker.exp_name, ker, events);

calker_cal_test_kernel(ker.proj_name, ker.exp_name, ker);
calker_test_kernel(ker.proj_name, ker.exp_name, ker, events);
calker_cal_rank(ker.proj_name, ker.exp_name, ker, events);

if strcmp(mode, 'tune'),
    calker_cal_map(ker.proj_name, ker.exp_name, ker, events);
end

%close pool
if matlabpool('size') > 0, matlabpool close; end;



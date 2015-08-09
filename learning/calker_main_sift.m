function calker_main_sift(proj_name, feature_ext, start_event, end_event, varargin)

addpath('/net/per610a/export/das11f/plsang/codes/kaori-secode-vsd');
set_env;

prms.proj_dir = '/net/per610a/export/das11f/plsang';
prms.proj_name = proj_name;
prms.org_root_dir = '/net/per610a/export/das11f/ledduy';
prms.org_proj_name = 'mediaeval-vsd-2014';
prms.seg_name = 'keyframe-5';
prms.exp_name = 'mediaeval-vsd-2014.devel2013-new';
%prms.exp_name = 'mediaeval-vsd-2014.devel2014-new';

feat_dim = 4000;
ker_type = 'kl2';
cross = 0;
open_pool = 0;
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
		otherwise
			error(sprintf('Option ''%s'' unknown.', opt)) ;
	end  
end

concept_file = sprintf('%s/%s/annotation/%s/%s/%s.Concepts.lst', ...
	prms.org_root_dir, prms.org_proj_name, prms.seg_name, prms.exp_name, prms.exp_name);

%events = {'objviolentscenes', 'subjviolentscenes'};
%events = {'explosion', 'gunshot', 'scream'};
events = vsd_load_concept_list(concept_file);
events = events(start_event:end_event);

ker = calker_build_kerdb(feature_ext, ker_type, feat_dim, cross, suffix);

ker.events = events;
ker.dev_pat_list = {'devel2011', 'test2011'};
ker.dev_pat = 'devel2013-new';
ker.test_pat_list = {'test2013'};
ker.test_pat = 'test2013-new';
%ker.dev_pat_list = {'devel2011', 'test2011', 'test2012', 'test2013'};
%ker.dev_pat = 'devel2014-new';
%ker.test_pat_list = {'test2014'};
%ker.test_pat = 'test2014-new';

calker_exp_dir = sprintf('%s/%s/experiments/%s-calker/%s%s', ker.proj_dir, prms.proj_name, prms.exp_name, ker.feat, ker.suffix);
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

calker_create_database(prms, ker, ker.dev_pat_list, ker.dev_pat);
calker_create_database(prms, ker, ker.test_pat_list, ker.test_pat);
%calker_create_traindb(prms.proj_name, prms.exp_name, ker);

%open pool
if matlabpool('size') == 0 && open_pool > 0, matlabpool(open_pool); end;
calker_cal_train_kernel(prms.proj_name, prms.exp_name, ker);
calker_train_kernel(prms.proj_name, prms.exp_name, ker, events);

calker_cal_test_kernel(prms.proj_name, prms.exp_name, ker);
calker_test_kernel(prms.proj_name, prms.exp_name, ker, events);
calker_cal_rank(prms.proj_name, prms.exp_name, ker, events);
%calker_cal_map(proj_name, exp_name, ker, events);

%close pool
if matlabpool('size') > 0, matlabpool close; end;



function calker_main(proj_name, exp_id, feature_ext, suffix, test_pat, feat_dim, ker_type, cross, open_pool)

addpath('/net/per900a/raid0/plsang/tools/kaori-secode-calker-v6/support');
addpath('/net/per900a/raid0/plsang/tools/libsvm-3.17/matlab');
addpath('/net/per900a/raid0/plsang/tools/vlfeat-0.9.16/toolbox');

% run vl_setup with no prefix
% vl_setup('noprefix');
vl_setup;

exp_name = [proj_name, '-', exp_id];
seg_name = ['segment-', exp_id];

if ~exist('suffix', 'var'),
	suffix = '--calker-v7.1';
end

if ~exist('feat_dim', 'var'),
	feat_dim = 4000;
end

if ~exist('ker_type', 'var'),
	ker_type = 'echi2';
end

if ~exist('cross', 'var'),
	cross = 0;
end

if ~exist('open_pool', 'var'),
	open_pool = 0;
end

if ~exist('test_pat', 'var'),
	test_pat = 'kindredtest';
end

if isempty(strfind(suffix, '-v7')),
	error('**** Suffix does not contain v7 !!!!!\n');
end

ker = calker_build_kerdb(feature_ext, ker_type, feat_dim, cross, suffix);

ker.prms.tvprefix = 'TVMED13';
ker.prms.tvtask = 'PS';
ker.prms.eventkit = 'EK10Ex';
ker.prms.rtype = 'NR';	% RN: Related example as Negative, RP: Related example as Positive, NR: No related example 
ker.prms.train_fea_pat = 'devel';	% train pat name where local features are stored
ker.prms.test_fea_pat = 'devel';	% train pat name where local features are stored

ker.prms.meta_file = sprintf('%s/%s/metadata/%s-%s-%s-%s/database.mat', ker.proj_dir, proj_name, ker.prms.tvprefix, ker.prms.tvtask, ker.prms.eventkit, ker.prms.rtype);
ker.prms.seg_name = seg_name;

%ker.event_set = 'EK130';	% EK10, EK100
ker.dev_pat = 'dev';
ker.test_pat = test_pat;
ker.prms.ref_meta_file = sprintf('%s/%s/metadata/%s-%s-REFTEST/%s.mat', ker.proj_dir, proj_name, ker.prms.tvprefix, ker.prms.tvtask, upper(test_pat));

calker_exp_dir = sprintf('%s/%s/experiments/%s-calker/%s%s', ker.proj_dir, proj_name, exp_name, ker.feat, ker.suffix);
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

videolevel = strcmp('100000', exp_id);

%calker_create_database(proj_name, exp_name, seg_name, ker);
%calker_create_traindb(proj_name, exp_name, ker);

%open pool
if matlabpool('size') == 0 && open_pool > 0, matlabpool(open_pool); end;
calker_cal_train_kernel(proj_name, exp_name, ker);
calker_train_kernel(proj_name, exp_name, ker);
calker_cal_test_kernel(proj_name, exp_name, ker);
calker_test_kernel(proj_name, exp_name, ker);
calker_cal_map(proj_name, exp_name, ker, videolevel);

%calker_val_kernel(proj_name, exp_name, ker, events);
%calker_val_map(proj_name, exp_name, ker, events, videolevel);


%close pool
if matlabpool('size') > 0, matlabpool close; end;

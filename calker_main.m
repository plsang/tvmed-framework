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
desc = '';  % default is null, be careful because it will influence the feature index in the calker_load_feature function
start_event = 21;
end_event = 40;
enc_type = 'fisher';
seg_type = 'video'; %% video-based, segment-based
cbfile = '';
metadb='med2014';
testdb='';
maxneg=Inf;
config_str = '';
pn = 0;
pntest = 0; %% power norm on test data only (already pn on train)
strictova = 0;

runtrain = 1;
runtest = 1;
runmap = 1;
runrank = 1;
preload = 0;
randdep = 0; %% where to use random dependency 
selfile = ''; %% file that contains selected indexes (of a dependency type)

for k=1:2:length(varargin),

	opt = lower(varargin{k});
	arg = varargin{k+1} ;

	if ~strcmp(opt, 'cbfile'),
		if strcmp(config_str, ''),
			config_str = sprintf('%s.%s', opt, num2str(arg));
		else
			config_str = sprintf('%s_%s.%s', config_str, opt, num2str(arg));
		end
	end
	
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
        case 'enctype'
			enc_type = arg;
        case 'segtype'
			seg_type = arg;
        case 'cbfile'
			cbfile = arg;    
        case 'metadb'
            metadb = arg;
        case 'testdb'
            testdb = arg;
        case 'maxneg'
            maxneg = arg;    
        case 's'
            start_event = arg;
        case 'e'
            end_event = arg;
		case 'pn'
			pn = arg;
        case 'pntest'
			pntest = arg;    
        case 'strictova'
			strictova = arg;        
        case 'runtrain'
			runtrain = arg;        
        case 'runtest'
			runtest = arg;        
        case 'runmap'
			runmap = arg;        
        case 'runrank'
			runrank = arg;            
        case 'preload'
            preload = arg;
        case 'randdep'
            randdep = arg;    
        case 'selfile'
            selfile = arg;
		otherwise
			error(sprintf('Option ''%s'' unknown.', opt)) ;
	end  
end

ker = calker_build_kerdb(feature_ext, ker_type, feat_dim, cross, suffix);

ker.prms.tvprefix = 'TVMED14';
ker.prms.tvtask = upper(tvtask);
ker.prms.eventkit = eventkit; % 'EK130Ex';
ker.prms.rtype = miss_type;	% RN: Related example as Negative, RP: Related example as Positive, NR: No related example 

ker.idt_desc = desc;
ker.test_pat = test_pat;
ker.seg_type = seg_type;
ker.enc_type = enc_type;
ker.metadb = metadb;
ker.testdb = testdb;
ker.maxneg = maxneg;
ker.pn = pn;
ker.pntest = pntest;
ker.strictova = strictova;
ker.start_event = start_event;
ker.end_event = end_event;
ker.preload = preload;
ker.randdep = randdep;
ker.selfile = selfile;

fisher_params = struct;
fisher_params.grad_weights = false;		% "soft" BOW
fisher_params.grad_means = true;		% 1st order
fisher_params.grad_variances = true;	% 2nd order
fisher_params.alpha = single(1.0);		% power normalization (set to 1 to disable)
fisher_params.pnorm = single(0.0);		% norm regularisation (set to 0 to disable)

ker.fisher_params = fisher_params;
if exist(cbfile, 'file'),
    load(cbfile);
    ker.codebook = codebook;    
else    
    [~, param_dict] = get_coding_params();
    feat_key = strrep(feature_ext, '.', '');
    if isfield(param_dict, feat_key),
        ker.codebook = param_dict.(feat_key).codebook;
    end 
end

if isempty(suffix),
    ker.calker_exp_dir = sprintf('%s/%s/experiments/%s/%s.%s', ker.proj_dir, proj_name, exp_name, ker.feat, ker.type);
else
    ker.calker_exp_dir = sprintf('%s/%s/experiments/%s/%s.%s.%s', ker.proj_dir, proj_name, exp_name, ker.feat, ker.type, suffix);
end

ker.log_dir = fullfile(ker.calker_exp_dir, 'log');

if strcmp(ker.metadb, 'med2014'),
    medmd_file = '/net/per610a/export/das11f/plsang/trecvidmed14/metadata/medmd_2014_devel_ps.mat';
elseif strcmp(ker.metadb, 'med2012'),
    medmd_file = '/net/per610a/export/das11f/plsang/trecvidmed/metadata/med12/medmd_2012_upgraded.mat';
elseif strcmp(ker.metadb, 'med2011'),
	medmd_file = '/net/per610a/export/das11f/plsang/trecvidmed/metadata/med11/medmd_2011.mat';
elseif strcmp(ker.metadb, 'med2015ah'),
	medmd_file = '/net/per610a/export/das11f/plsang/trecvidmed/metadata/med15/med15_ah.mat';    
elseif strcmp(ker.metadb, 'med2013lj'),
	medmd_file = '/net/per610a/export/das11f/plsang/trecvidmed/metadata/med13/medmd_2013_lujiang.mat';        
elseif strcmp(ker.metadb, 'med2014lj'),
	medmd_file = '/net/per610a/export/das11f/plsang/trecvidmed/metadata/med14/medmd_2014_lujiang.mat';        
else
    error('unknown metadb <%s>\n', ker.metadb);
end

fprintf('Loading metadata <%s>...\n', medmd_file);
load(medmd_file, 'MEDMD'); 
ker.MEDMD = MEDMD;

if isfield(MEDMD.RefTest, 'KINDREDTEST'),
    ker.event_ids = MEDMD.RefTest.KINDREDTEST.eventids;
else
    ker.event_ids = arrayfun(@(x) sprintf('E%03d', x), [start_event:end_event], 'UniformOutput', false);
end
    
%open pool
if matlabpool('size') == 0 && open_pool > 0, matlabpool(open_pool); end;
%calker_cal_train_kernel(proj_name, exp_name, ker);

if preload ~= 0,
    pl_file = sprintf('%s/%s/feature/%s/%s.h5', ker.proj_dir, proj_name, 'mydeps', ker.feat_raw);
    fprintf('loading feature from file <%s>...\n', pl_file);
    ker.feats = calker_load_h5_feature(pl_file, preload, ker.num_dim, ker.randdep, ker.selfile);
end

if runtrain == 1,
    if strcmp(ker.metadb, 'med2012') || strcmp(ker.metadb, 'med2011'),
        ker = calker_train_kernel_ova(proj_name, exp_name, ker);
    else
        ker = calker_train_kernel(proj_name, exp_name, ker);
    end
end

if strcmp(ker.test_pat, 'eval15full'),
    testmd_file = '/net/per610a/export/das11f/plsang/trecvidmed/metadata/med15/med15_eval.mat';
    fprintf('Loading test metadata <%s>...\n', testmd_file);
    load(testmd_file, 'MEDMD'); 
    ker.EVALMD = MEDMD;
end

if runtest == 1,
    if ~strcmp(eventkit, 'EK0Ex'),
        calker_test_kernel(proj_name, exp_name, ker);
    else
        calker_test_zeroshot(proj_name, exp_name, ker);
    end
end

if runmap == 1,
    if isempty(strfind(ker.test_pat, 'eval')),
        calker_cal_map(proj_name, exp_name, ker);
    end
end

if runrank == 1,
    calker_cal_rank(proj_name, exp_name, ker);
end

%close pool
if matlabpool('size') > 0, matlabpool close; end;

quit;

function calker_check_feature(proj_name, exp_name, feature_ext, varargin)

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
video_pat = 'EK10Ex';

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
		case 'video_pat'
            video_pat = arg;
            
		otherwise
			error(sprintf('Option ''%s'' unknown.', opt)) ;
	end  
end

ker = calker_build_kerdb(feature_ext, ker_type, feat_dim, cross, suffix);
ker.idt_desc = desc;
ker.test_pat = test_pat;
ker.seg_type = seg_type;
ker.enc_type = enc_type;
ker.metadb = metadb;
ker.testdb = testdb;
ker.maxneg = maxneg;
ker.start_event = start_event;
ker.end_event = end_event;


if isempty(suffix),
    ker.calker_exp_dir = sprintf('%s/%s/experiments/%s/%s.%s', ker.proj_dir, proj_name, exp_name, ker.feat, ker.type);
else
    ker.calker_exp_dir = sprintf('%s/%s/experiments/%s/%s.%s.%s', ker.proj_dir, proj_name, exp_name, ker.feat, ker.type, suffix);
end

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

switch video_pat,
    case 'ek'
        clips = unique([MEDMD.EventKit.EK100Ex.clips, MEDMD.EventKit.EK10Ex.clips]);
    case 'bg'
        if isfield(ker.MEDMD, 'EventBG'),
            clips = ker.MEDMD.EventBG.default.clips;
        end
    case 'kindred14'
        clips = ker.MEDMD.RefTest.KINDREDTEST.clips;
    case 'medtest14'
        clips = ker.MEDMD.RefTest.MEDTEST.clips;
    case 'med2012'
        clips = ker.MEDMD.RefTest.CVPR14Test.clips;    
    case 'med11test'
        clips = ker.MEDMD.RefTest.MED11TEST.clips;    
    case 'eval15full'
        clips = ker.EVALMD.UnrefTest.MED15EvalFull.clips;        
    case 'medtest13lj'
        clips = ker.MEDMD.RefTest.MEDTEST2.clips;
    case 'medtest14lj'
        clips = ker.MEDMD.RefTest.MEDTEST2.clips;    
    otherwise
        error('unknown video pat!!!\n');
end

count = 0;        
for ii = 1:length(clips), %

    clip_name = clips{ii};
    
    if ~isfield(ker.MEDMD.info, clip_name), 
        msg = sprintf('Video info [%s] does not exist!\n', clip_name);
        fprintf(msg);
        continue;
    end
    
    segment_path = sprintf('%s/%s/feature/%s/%s/%s/%s.mat',...
                            ker.proj_dir, proj_name, exp_name, ker.feat_raw, fileparts(ker.MEDMD.info.(clip_name).loc), clip_name);
                            
    if ~exist(segment_path),
        msg = sprintf('File [%s] does not exist!\n', segment_path);
        fprintf(msg);
        count = count + 1;
    end
    
end

fprintf('total non-exist: %d \n', count);
function copy_hoghofmbh
    in_dir = '/net/per610a/export/das11f/plsang/trecvidmed13/feature/video-bg/idensetraj.hoghofmbh.cb256.fc.pca';
    
    hoghof_out_dir = '/net/per610a/export/das11f/plsang/trecvidmed15/feature/niimed2015/idensetraj.hoghof.fisher.cb256.pca';
    mbh_out_dir = '/net/per610a/export/das11f/plsang/trecvidmed15/feature/niimed2015/idensetraj.mbh.fisher.cb256.pca';
    
    %idensetraj.hoghof.fisher.cb256.pca128
    %idensetraj.mbh.fisher.cb256.pca128
    %medmd_file = '/net/per610a/export/das11f/plsang/trecvidmed/metadata/med13/medmd_2013_lujiang.mat';   
    medmd_file = '/net/per610a/export/das11f/plsang/trecvidmed/metadata/med14/medmd_2014_lujiang.mat';   
    fprintf('Loading metadata <%s>...\n', medmd_file);
    MEDMD = load(medmd_file, 'MEDMD'); 
    MEDMD = MEDMD.MEDMD;
    
    clips = [MEDMD.EventKit.EK100Ex.clips, MEDMD.EventKit.EK10Ex.clips, MEDMD.EventBG.default.clips, ...
        MEDMD.RefTest.KINDREDTEST.clips, MEDMD.RefTest.MEDTEST.clips];
    
    clips = unique(clips);
    
    fprintf('total: %d clips \n', length(clips));
    
    for ii=1:length(clips),
        
        if ~mod(ii, 10), 
            fprintf('%d ', ii);
        end
        
        video_id = clips{ii};
        if ~isfield(MEDMD.info, video_id),
            fprintf('could not look up for video <%s> \n', video_id);
            continue;
        end
        
        ldc_pat = MEDMD.info.(video_id).loc;
        
        out_hoghof_file = sprintf('%s/%s.mat', hoghof_out_dir, ldc_pat(1:end-4));
        out_mbh_file = sprintf('%s/%s.mat', mbh_out_dir, ldc_pat(1:end-4));
        
        if exist(out_hoghof_file, 'file') && exist(out_mbh_file, 'file'),
            continue;
        end
        
        in_file = sprintf('%s/%s.mat', in_dir, ldc_pat(1:end-4));
        if ~exist(in_file, 'file'),
            warning('File <%s> not exist', in_file);
            continue;
        end
        
        code_hoghofmbh = load(in_file, 'code');
        code_hoghof = code_hoghofmbh.code(1:65536);
        code_mbh = code_hoghofmbh.code(65537:end);
        
        save_code(out_hoghof_file, code_hoghof);
        save_code(out_mbh_file, code_mbh);
    end
    
end


%_from_med2015_ah
function copy_hoghofmbh_med15_ah
    in_dir = '/net/per610a/export/das11f/plsang/trecvidmed13/feature/video-bg/idensetraj.hoghofmbh.cb256.fc.pca';
    
    hoghof_out_dir = '/net/per610a/export/das11f/plsang/trecvidmed15/feature/niimed2015/idensetraj.hoghof.fisher.cb256.pca';
    mbh_out_dir = '/net/per610a/export/das11f/plsang/trecvidmed15/feature/niimed2015/idensetraj.mbh.fisher.cb256.pca';
    
    %idensetraj.hoghof.fisher.cb256.pca128
    %idensetraj.mbh.fisher.cb256.pca128
    medmd_file = '/net/per610a/export/das11f/plsang/trecvidmed/metadata/med15/med15_ah.mat';   
    fprintf('Loading metadata <%s>...\n', medmd_file);
    MEDMD = load(medmd_file, 'MEDMD'); 
    MEDMD = MEDMD.MEDMD;
    
    clips = [MEDMD.EventKit.EK10Ex.clips];
    
    fprintf('total: %d clips \n', length(clips));
    
    for ii=1:length(clips),
        
        if ~mod(ii, 10), 
            fprintf('%d ', ii);
        end
        
        video_id = clips{ii};
        ldc_pat = MEDMD.info.(video_id).loc;
        in_file = sprintf('%s/%s.mat', in_dir, ldc_pat(1:end-4));
        if ~exist(in_file, 'file'),
            warning('File <%s> not exist', in_file);
            continue;
        end
        
        code_hoghofmbh = load(in_file, 'code');
        code_hoghof = code_hoghofmbh.code(1:65536);
        code_mbh = code_hoghofmbh.code(65537:end);
        
        out_hoghof_file = sprintf('%s/%s.mat', hoghof_out_dir, ldc_pat(1:end-4));
        out_mbh_file = sprintf('%s/%s.mat', mbh_out_dir, ldc_pat(1:end-4));
        
        save_code(out_hoghof_file, code_hoghof);
        save_code(out_mbh_file, code_mbh);
    end
    
end

   

function copy_hoghofmbh_from_med2014_ek10
    in_dir = '/net/per610a/export/das11f/plsang/trecvidmed13/feature/video-bg/idensetraj.hoghofmbh.cb256.fc.pca';
    
    hoghof_out_dir = '/net/per610a/export/das11f/plsang/trecvidmed15/feature/niimed2015/idensetraj.hoghof.fisher.cb256.pca';
    mbh_out_dir = '/net/per610a/export/das11f/plsang/trecvidmed15/feature/niimed2015/idensetraj.mbh.fisher.cb256.pca';
    
    %idensetraj.hoghof.fisher.cb256.pca128
    %idensetraj.mbh.fisher.cb256.pca128
    medmd_file = '/net/per610a/export/das11f/plsang/trecvidmed14/metadata/medmd_2014_devel_ps.mat';
    fprintf('Loading metadata <%s>...\n', medmd_file);
    MEDMD = load(medmd_file, 'MEDMD'); 
    MEDMD = MEDMD.MEDMD;
    
    clips = [MEDMD.EventKit.EK10Ex.clips, MEDMD.EventBG.default.clips, MEDMD.RefTest.KINDREDTEST.clips];
    
    fprintf('total: %d clips \n', length(clips));
    
    parfor ii=1:length(clips),
        
        if ~mod(ii, 1000), 
            fprintf('%d ', ii);
        end
        
        video_id = clips{ii};
        ldc_pat = MEDMD.info.(video_id).loc;
        in_file = sprintf('%s/%s.mat', in_dir, ldc_pat(1:end-4));
        if ~exist(in_file, 'file'),
            warning('File <%s> not exist', in_file);
            continue;
        end
        
        code_hoghofmbh = load(in_file, 'code');
        code_hoghof = code_hoghofmbh.code(1:65536);
        code_mbh = code_hoghofmbh.code(65537:end);
        
        out_hoghof_file = sprintf('%s/%s.mat', hoghof_out_dir, ldc_pat(1:end-4));
        out_mbh_file = sprintf('%s/%s.mat', mbh_out_dir, ldc_pat(1:end-4));
        
        save_code(out_hoghof_file, code_hoghof);
        save_code(out_mbh_file, code_mbh);
    end
    
end

function save_code(out_file, code)
    output_dir = fileparts(out_file);
    if ~exist(output_dir, 'file'),
        mkdir(output_dir);
    end
    save(out_file, 'code');
end

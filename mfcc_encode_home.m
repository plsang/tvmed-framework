function mfcc_encode_home( partition, start_seg, end_seg )
%ENCODE Summary of this function goes here
%   Detailed explanation goes here
%% kf_dir_name: name of keyframe folder, e.g. keyframe-60 for segment length of 60s   

	set_env;
    
	algo = 'rastamat';
	
	codebook_gmm_size = 256;
	
	feat_dim = 39;
	
	video_dir = '/net/per920a/export/das14a/satoh-lab/plsang/vsd2015/data-rsz';
	fea_dir = '/net/per920a/export/das14a/satoh-lab/plsang/vsd2015/feature';
	
    root_meta = '/net/per920a/export/das14a/satoh-lab/plsang/vsd2015/metadata';
    
    meta_file = sprintf('%s/%s.txt', root_meta, partition);
    fh = fopen(meta_file, 'r');
    clips = textscan(fh, '%s');
    clips = clips{1};
    fclose(fh);

    
	feature_ext_fc = sprintf('mfcc.%s.cb%d.fc', algo, codebook_gmm_size);
	
	output_dir_fc = sprintf('%s/%s/%s', fea_dir, feature_ext_fc, partition);
    if ~exist(output_dir_fc, 'file'),
        mkdir(output_dir_fc);
    end

	feat_pat = sprintf('mfcc.%s', algo);
	
    codebook_gmm_file = '/net/per610a/export/das11f/plsang/vsd2014/feature/bow.codebook.devel/mfcc.rastamat/data/codebook.gmm.256.39.mat';
    codebook_gmm_ = load(codebook_gmm_file, 'codebook');
    codebook_gmm = codebook_gmm_.codebook;
	
	if ~exist('start_seg', 'var') || start_seg < 1,
        start_seg = 1;
    end
    
    if ~exist('end_seg', 'var') || end_seg > length(clips),
        end_seg = length(clips);
    end
	
    for ii = start_seg:end_seg,
        
		video_id = clips{ii};
		
		video_file = fullfile(video_dir, partition, video_id);
		
		output_fc_file = sprintf('%s/%s.mat', output_dir_fc, video_id(1:end-4));
		
		if exist(output_fc_file, 'file') ,
            fprintf('File [%s] already exist. Skipped!!\n', output_fc_file);
            continue;
        end
        
        fprintf(' [%d --> %d --> %d] Extracting features & Encoding for [%s]...\n', start_seg, ii, end_seg, video_id);
        
		feat = mfcc_extract_features(video_file, algo);
		
		if isempty(feat),
			continue;
		else			    
			code = fc_encode(feat, codebook_gmm, []);	
		end
        
		save(output_fc_file, 'code'); 
		
    end
	
	
	quit;
end


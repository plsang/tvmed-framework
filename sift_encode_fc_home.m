function sift_encode_fc_home( partition, start_seg, end_seg )
%ENCODE Summary of this function goes here
%   Detailed explanation goes here
%% kf_dir_name: name of keyframe folder, e.g. keyframe-60 for segment length of 60s   

	% update: Jun 25th, SPM suported
    % setting
    set_env;
	
    % encoding type
    sift_algo = 'covdet';
    param = 'hessian';
    enc_type = 'fc';
	
	if ~exist('codebook_size', 'var'),
		codebook_size = 256;
	end
    
	if ~exist('spm', 'var'),
		spm = 0;
	end
	
	default_dim = 128;
	if ~exist('dimred', 'var'),
		dimred = 80;
	end
	
    fea_dir = '/net/per920a/export/das14a/satoh-lab/plsang/vsd2015/feature';
	
    root_meta = '/net/per920a/export/das14a/satoh-lab/plsang/vsd2015/metadata';
    
	feat_pat = sprintf('%s.%s.sift', sift_algo, num2str(param));
	feature_ext = sprintf('%s.cb%d.%s', feat_pat, codebook_size, enc_type);
	
	
	if dimred < default_dim,,
		feature_ext = sprintf('%s.pca', feature_ext);
	end
	
	output_dir = sprintf('%s/%s/%s', fea_dir, feature_ext, partition);
    if ~exist(output_dir, 'file'),
		mkdir(output_dir);
		change_perm(output_dir);
    end
    
    codebook_file = '/net/per610a/export/das11f/plsang/vsd2014/feature/bow.codebook.devel/covdet.hessian.sift/data/codebook.gmm.256.80.mat';
		
	fprintf('Loading codebook [%s]...\n', codebook_file);
    codebook_ = load(codebook_file, 'codebook');
    codebook = codebook_.codebook;
 
 	low_proj = [];
	if dimred < default_dim,
		lowproj_file = '/net/per610a/export/das11f/plsang/vsd2014/feature/bow.codebook.devel/covdet.hessian.sift/data/lowproj.80.128.mat';
			
		fprintf('Loading low projection matrix [%s]...\n', lowproj_file);
		low_proj_ = load(lowproj_file, 'low_proj');
		low_proj = low_proj_.low_proj;
	end
    
    meta_file = sprintf('%s/%s.txt', root_meta, partition);
    fh = fopen(meta_file, 'r');
    clips = textscan(fh, '%s');
    clips = clips{1};
    fclose(fh);

    
    if ~exist('start_seg', 'var') || start_seg < 1,
        start_seg = 1;
    end
    
    if ~exist('end_seg', 'var') || end_seg > length(clips),
        end_seg = length(clips);
    end
	
    kf_dir = '/net/per920a/export/das14a/satoh-lab/plsang/vsd2015/keyframes';
	
    for ii = start_seg:end_seg,
        video_id = clips{ii};                 
        
		output_file = sprintf('%s/%s.mat', output_dir, video_id(1:end-4));
		
        if exist(output_file, 'file'),
            fprintf('File [%s] already exist. Skipped!!\n', output_file);
            continue;
        end
        
		video_kf_dir = fullfile(kf_dir, partition, video_id(1:end-4));
		
		if ~exist(video_kf_dir, 'file'),
			fprintf('Kf dir does not exist <%s>\n', video_kf_dir);
			continue;
		end
		
		kfs = dir([video_kf_dir, '/*.jpg']);
       
		%% update Jul 5, 2013: support segment-based
		
		fprintf(' [%d --> %d --> %d] Extracting & encoding for [%s - %d kfs]...\n', start_seg, ii, end_seg, video_id, length(kfs));
        
		code = cell(length(kfs), 1);
		
		for jj = 1:length(kfs),
			if ~mod(jj, 100),
				fprintf('%d ', jj);
			end
			img_name = kfs(jj).name;
			img_path = fullfile(video_kf_dir, img_name);
			
			[~, descrs] = sift_extract_features( img_path, sift_algo, param );
            
            % if more than 50% of points are empty --> possibley empty image
            if isempty(descrs) || sum(all(descrs == 0, 1)) > 0.5*size(descrs, 2),
                %warning('Maybe blank image...[%s]. Skipped!\n', img_name);
                continue;
            end
			
			code_ = sift_do_encoding(enc_type, descrs, codebook, [], low_proj);
			code{jj} = code_;	
			
			clear descrs, code_;
		end 
        
		code = cat(2, code{:});
		code = mean(code, 2);
		
		% apply power normalization again
		code = sign(code) .* sqrt(abs(code));
		
        save(output_file, 'code'); % MATLAB don't allow to save inside parfor loop             
		%change_perm(output_file);
       
		clear code;
    end
    
    %quit;

end
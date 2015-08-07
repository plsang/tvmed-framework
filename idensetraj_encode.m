function idensetraj_encode( partition, start_video, end_video )
    
    % setting
    set_env;
    % exp_name = 'med.pooling';
        
    video_dir = '/net/per920a/export/das14a/satoh-lab/plsang/vsd2015/data-rsz';
	fea_dir = '/net/per920a/export/das14a/satoh-lab/plsang/vsd2015/feature';
	
    root_meta = '/net/per920a/export/das14a/satoh-lab/plsang/vsd2015/metadata';
    
    meta_file = sprintf('%s/%s.txt', root_meta, partition);
    fh = fopen(meta_file, 'r');
    clips = textscan(fh, '%s');
    clips = clips{1};
    fclose(fh);
    
    coding_params = get_coding_params();
    descs = fieldnames(coding_params);
    
    if start_video < 1,
        start_video = 1;
    end
    
    if end_video > length(clips),
        end_video = length(clips);
    end
    
    for ss = start_video:end_video,
	
		video_id = clips{ss};
		
		video_file = fullfile(video_dir, partition, video_id);
        
        bool_run = 0;
        for ii=1:length(descs),
            desc = descs{ii};
            for jj=1:length(coding_params.(desc)),
                output_file = sprintf('%s/%s/%s/%s.mat', fea_dir, coding_params.(desc){jj}.feature_pat, partition, video_id(1:end-4));
                output_file_info = dir(output_file);
                if ~exist(output_file, 'file') || output_file_info.bytes < 2000,
                    bool_run = 1;
                    break;
                end
            end
        end
        
        if bool_run == 0, 
            fprintf('Video <%s> already processed \n', video_file);
            continue; 
        end
        
   		fprintf(' [%d --> %d --> %d] Extracting & Encoding for [%s]...\n', start_video, ss, end_video, video_id);
        
        codes = struct;
        for ii=1:length(descs),
            desc = descs{ii};
            codes.(desc) = cell(length(coding_params.(desc)), 1);
        end
		
		codes_ = idensetraj_extract_and_encode(video_file, coding_params);
		
		for ii=1:length(descs),
			desc = descs{ii};
			for jj=1:length(codes.(desc)),
				codes.(desc){jj} = codes_.(desc){jj};
			end
		end
        
		clear codes_;
		
        %%% save at video level
        for ii=1:length(descs),
            desc = descs{ii};
            for jj=1:length(coding_params.(desc)),
                output_file = sprintf('%s/%s/%s/%s.mat', fea_dir, coding_params.(desc){jj}.feature_pat, partition, video_id(1:end-4));
                sge_save(output_file, codes.(desc){jj});
            end
        end
        
		clear codes;

    end
    
	quit;
end


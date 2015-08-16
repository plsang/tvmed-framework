function codes = idensetraj_extract_and_encode( video_file, start_frame, end_frame, coding_params )

    idensetraj = 'LD_PRELOAD=/net/per610a/export/das11f/plsang/usr/lib64/libstdc++.so.6 /net/per610a/export/das11f/plsang/codes/opensource/improved_trajectory_release/release/DenseTrackStab_HOGHOFMBH';
    
    cmd = [idensetraj, ' ', video_file, ' -S ', num2str(start_frame), ' -E ', num2str(end_frame)];

    % open pipe 
    p = popenr(cmd);

    if p < 0
		error(['Error running popenr(', cmd,')']);
    end
	
	full_dim = 396;		
    BLOCK_SIZE = 30000;                          % initial capacity (& increment size)
    X = zeros(full_dim, BLOCK_SIZE, 'single');
   
    listPtr = 1;
    
    fisher_params = struct;
    fisher_params.grad_weights = false;		% "soft" BOW
    fisher_params.grad_means = true;		% 1st order
    fisher_params.grad_variances = true;	% 2nd order
    fisher_params.alpha = single(1.0);		% power normalization (set to 1 to disable)
    fisher_params.pnorm = single(0.0);		% norm regularisation (set to 0 to disable)
    
    %%% initialization
    descs = fieldnames(coding_params);
    
    for ii=1:length(descs),
        desc = descs{ii};
        codes.(desc) = cell(length(coding_params.(desc)), 1);
        
        for jj=1:length(coding_params.(desc)),
            enc_param = coding_params.(desc){jj};
            
            if strcmp(enc_param.enc_type, 'fisher') == 1,
                codes.(desc){jj} = zeros(enc_param.output_dim + enc_param.stats_dim, 1, 'single');
                coding_params.(desc){jj}.fisher_handle = mexFisherEncodeHelperSP('init', enc_param.codebook, fisher_params); 
            else
                codes.(desc){jj} = zeros(enc_param.output_dim, 1, 'single');
            end
        end
    end
    
    while true,

        % Get the next chunk of data from the process
        Y = popenr(p, full_dim, 'float');

        if isempty(Y), break; end;

        if length(Y) ~= full_dim,
            continue;                                    
        end

        X(:, listPtr) = Y;
        listPtr = listPtr + 1;  

        if listPtr > BLOCK_SIZE,
            %%% HOGHOF
            
            for ii=1:length(descs),
                desc = descs{ii};
                
                s_idx = coding_params.(desc){1}.start_idx;
                e_idx = coding_params.(desc){1}.end_idx;
                
                for jj=1:length(coding_params.(desc)),
                    enc_param = coding_params.(desc){jj};
                    
                    switch enc_param.enc_type,
                        case 'hardbow'
                            code_ = vq_encode(X(s_idx:e_idx, :), enc_param.codebook, enc_param.kdtree);
                            codes.(desc){jj} = codes.(desc){jj} + sum(code_, 2);
                        case 'softbow'
                            code_ = kcb_encode(X(s_idx:e_idx, :), enc_param.codebook, enc_param.kdtree);
                            codes.(desc){jj} = codes.(desc){jj} + sum(code_, 2);
                        case 'fisher'
                            mexFisherEncodeHelperSP('accumulate', enc_param.fisher_handle, enc_param.low_proj * X(s_idx:e_idx, :));
                    end
                end
            end
            
            listPtr = 1;
            X(:,:) = 0;
        end
    
    end

    if (listPtr > 1)
        
        X(:, listPtr:end) = [];   % remove unused slots
        
        for ii=1:length(descs),
            desc = descs{ii};
            
            s_idx = coding_params.(desc){1}.start_idx;
            e_idx = coding_params.(desc){1}.end_idx;
            
            for jj=1:length(coding_params.(desc)),
                enc_param = coding_params.(desc){jj};
                
                switch enc_param.enc_type,
                    case 'hardbow'
                        code_ = vq_encode(X(s_idx:e_idx, :), enc_param.codebook, enc_param.kdtree);
                        codes.(desc){jj} = codes.(desc){jj} + sum(code_, 2);
                    case 'softbow'
                        code_ = kcb_encode(X(s_idx:e_idx, :), enc_param.codebook, enc_param.kdtree);
                        codes.(desc){jj} = codes.(desc){jj} + sum(code_, 2);
                    case 'fisher'
                        mexFisherEncodeHelperSP('accumulate', enc_param.fisher_handle, enc_param.low_proj * X(s_idx:e_idx, :));
                end
            end
        end
            
    end
    
    clear X;
    
    for ii=1:length(descs),
        desc = descs{ii};
        
        for jj=1:length(coding_params.(desc)),
            enc_param = coding_params.(desc){jj};
            
            if strcmp(enc_param.enc_type, 'fisher') == 1,
                [code_, stats_] = mexFisherEncodeHelperSP('getfk', enc_param.fisher_handle);
                codes.(desc){jj} = [code_; stats_];
                mexFisherEncodeHelperSP('clear', enc_param.fisher_handle); 
                
                clear code_ stats_;
            end
        end
    end
    
    % Close pipe
    popenr(p, -1);

end

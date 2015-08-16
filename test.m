function test
    %set_env;
    
    addpath('/net/per610a/export/das11f/plsang/students/ntrang/gmm-fisher/matlab');
    addpath('/net/per610a/export/das11f/plsang/codes/common');
    addpath('/net/per610a/export/das11f/plsang/codes/common/med');
    addpath('/net/per610a/export/das11f/plsang/codes/common/enceval-toolkit-1.1');
    addpath('/net/per610a/export/das11f/plsang/codes/common/popen/popen_dt');
    addpath('/net/per610a/export/das11f/plsang/codes/common/gmm-fisher/matlab');

    fisher_params = struct;
    fisher_params.grad_weights = false;		% "soft" BOW
    fisher_params.grad_means = true;		% 1st order
    fisher_params.grad_variances = true;	% 2nd order
    fisher_params.alpha = single(1.0);		% power normalization (set to 1 to disable)
    fisher_params.pnorm = single(0.0);		% norm regularisation (set to 0 to disable)
    
    
    coding_param.enc_type = 'fisher';
    coding_param.codebook_size = 256;
    coding_param.dimred = 128;
    %codebook_file = '/net/per610a/export/das11f/plsang/trecvidmed/feature/codebook/idensetraj.hoghof/codebook.gmm.256.128.mat';
    codebook_file = '/net/per610a/export/das11f/plsang/students/ntrang/codebook.gmm.256.128.mat';
    load(codebook_file);
    coding_param.codebook = codebook;
    lowproj_file = '/net/per610a/export/das11f/plsang/students/ntrang/lowproj.128.204.mat';
    load(lowproj_file);
    coding_param.low_proj =  low_proj;

    cpp_handle = mexFisherEncodeHelperSP('init', coding_param.codebook, fisher_params);
    
    %filename = '/net/per610a/export/das11f/plsang/codes/opensource/improved_trajectory_release/test_sequences/person01_boxing_d1_uncomp.avi';
    filename = '/net/per610a/export/das11f/plsang/codes/tvmed-framework-v2.0/BIG_FISH_climb_stairs_f_nm_np1_fr_med_1.avi';
    
    bin = 'LD_PRELOAD=/net/per900a/raid0/plsang/usr.local/lib/libstdc++.so /net/per610a/export/das11f/plsang/codes/opensource/improved_trajectory_release/release/DenseTrackStab_HOGHOFMBH';

    cmd = sprintf('%s %s', bin, filename);

    p = popenr(cmd);

    if p < 0
      error(['Error running popenr(', cmd,')']);
    end

    
    while true,

        % Get the next chunk of data from the process
        Y = popenr(p, 396, 'float');

        if isempty(Y), break; end;
        
        X = Y(1:204, :);
        
        [code, stats] = mexFisherEncodeHelperSP('encodestats', cpp_handle, low_proj*X);
        
        [code_new, stats_new] = mexFisherEncodeHelperSP_new('encodestats', cpp_handle, low_proj*X);
        
        fprintf('non-zero code: %d.  non-zero stats: %d.  max stats_0: %f.  sumdiff: %f \n', length(find(code > 0)), length(find(stats > 0)), max(stats(2:257)), sum(code-code_new));
        
        
        
        % if length(find(code > 0)) > 256,
            % fprintf('num dim: %d - number of non-zero entries: %d \n', length(code), length(find(code > 0)));
        % end
        
    end

    
    % Close pipe
    popenr(p, -1);
    
    %x = rand(204, 10000);
    %mexFisherEncodeHelperSP('accumulate', cpp_handle, low_proj*x);
    %code = mexFisherEncodeHelperSP('getfk', cpp_handle);
    
    %% hai dong tren co the duoc viet gon bang mot dong nhu sau:
    % for ii=1:size(x, 2),
        % code = mexFisherEncodeHelperSP('encodestats', cpp_handle, low_proj*x(:,ii));
        % if length(find(code > 0)) > 256,
            % fprintf('num dim: %d - number of non-zero entries: %d \n', length(code), length(find(code > 0)));
        % end
    % end
end

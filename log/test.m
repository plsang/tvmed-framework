stats = load('HVC234953.stats.mat', 'code'); 

if any(any(isnan(stats.code), 1)),
	stats.code = stats.code(:, ~any(isnan(stats.code), 1));
end

stats = sum(stats.code, 2);
load('/net/per610a/export/das11f/plsang/trecvidmed/feature/codebook/idensetraj.hoghof/codebook.gmm.256.128.mat');
fisher_params = struct;
fisher_params.grad_weights = false;		% "soft" BOW
fisher_params.grad_means = true;		% 1st order
fisher_params.grad_variances = true;	% 2nd order
fisher_params.alpha = single(1.0);		% power normalization (set to 1 to disable)
fisher_params.pnorm = single(0.0);		% norm regularisation (set to 0 to disable)
				
cpp_handle = mexFisherEncodeHelperSP('init', codebook, fisher_params);
code = mexFisherEncodeHelperSP('getfkstats', cpp_handle, stats);
mexFisherEncodeHelperSP('clear', cpp_handle);



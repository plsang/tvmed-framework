function runme_imagenet_1k()
	proj_name = 'trecvidmed13';
	exp_id = 'att-v2.2';
	
	stem_feature_ext = 'covdet.hessian.sift.cb256.pca80.fisher.att.M1000.N100';
	
	for randnum = 1:10,
		feature_ext = sprintf('%s.R%d', stem_feature_ext, randnum)
		calker_main(proj_name, exp_id, feature_ext, 'ek', 'EK10Ex', 'pool', 5);
	end

	for randnum = 1:10,
		feature_ext = sprintf('%s.R%d', stem_feature_ext, randnum)
		calker_main(proj_name, exp_id, feature_ext, 'ek', 'EK10Ex', 'test', 'medtest', 'pool', 5);
	end
	
	quit;
	% for randim = randims,
		% calker_random_main(proj_name, exp_id, feature_ext, randim, 'ek', 'EK100Ex', 'pool', 5);
	% end
	
	% for randim = randims,
		% calker_random_main(proj_name, exp_id, feature_ext, randim, 'ek', 'EK130Ex', 'pool', 5);
	% end
	
	
	
	% for randim = randims,
		% calker_random_main(proj_name, exp_id, feature_ext, randim, 'ek', 'EK100Ex', 'pool', 5, 'test', 'medtest');
	% end
	
	% for randim = randims,
		% calker_random_main(proj_name, exp_id, feature_ext, randim, 'ek', 'EK130Ex', 'pool', 5, 'test', 'medtest');
	% end
end
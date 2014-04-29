function runme(feature_ext)
	proj_name = 'trecvidmed13';
	exp_id = 'att';
	
	randims = [100, 200, 500, 1000, 2000, 5000, 10000, 20000];
	
	for randim = randims,
		calker_random_main(proj_name, exp_id, feature_ext, randim, 'ek', 'EK10Ex', 'pool', 5);
	end
	
	for randim = randims,
		calker_random_main(proj_name, exp_id, feature_ext, randim, 'ek', 'EK10Ex', 'pool', 5, 'test', 'medtest');
	end
end
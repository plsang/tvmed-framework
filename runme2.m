function runme2(feature_ext, ss)
	proj_name = 'trecvidmed13';
	exp_id = 'att-v2.2';
	
	%randims = [100, 200, 500, 1000, 2000, 5000, 10000, 20000];
	randims = [2000, 5000, 10000, 20000];
	
	numrand = 20;
	
	for randnum = ss:numrand
		for randim = randims,
			calker_random_main2(proj_name, exp_id, feature_ext, randim, 'ek', 'EK10Ex', 'rn', randnum);
		end
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
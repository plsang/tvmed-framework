function eval_generate_detection_csv()
	feature_list = {
		'fusion.mbh_fc.sift_fc_pca.mfcc_fc';
		};
	
	for ii = 1:length(feature_list),
		feature_name = feature_list{ii};
		fprintf('Gen detection csv for feature [%s] ...\n', feature_name);
		eval_generate_detection_csv_(feature_name);
	end
			
end

function eval_generate_detection_csv_(feature_name)
	
	proj_dir = '/net/per610a/export/das11f/plsang';
	proj_name = 'trecvidmed14';
	exp_name = 'trecvidmed14-video-bg-calker';
	suffix = '--tvmed13-v1.1.3-ah';
	
	% eval_generate_detection_csv('trecvidmed11', 'trecvidmed11-100000', 'densetrajectory.mbh.Soft-4000-VL2.MBH.trecvidmed11.devel.kcb', 'l2')
	
	addpath('/net/per900a/raid0/plsang/tools/kaori-secode-calker-v7.1/support');
	
	calker_exp_dir = sprintf('%s/%s/experiments/%s/%s%s', proj_dir, proj_name, exp_name, feature_name, suffix);
	
	ker.test_pat = 'evalfull';
	ker.eventkit = 'EK100Ex';
	ker.rtype = 'RN'; % RN: R
	ker.type = 'kl2';

	fprintf('Loading test meta file \n');
	tvprefix = 'TVMED14';
	test_meta_file = sprintf('%s/%s/metadata/%s-REFTEST-%s/database.mat', proj_dir, proj_name, tvprefix, upper(ker.test_pat));
	database = load(test_meta_file, 'database');
	database = database.database;
	
	scorePath = sprintf('%s/scores/%s/%s-%s/%s.%s.scores.mat', calker_exp_dir, ker.test_pat, ker.eventkit, ker.rtype, feature_name, ker.type);
	
	fprintf('Loading scores...\n');
	scores = load(scorePath);
	events  = fieldnames(scores);
	
	%output_dir='/net/per610a/export/das11f/plsang/trecvidmed14/ioserver/submissions/ES';
	output_dir='/net/per610a/export/das11f/plsang/trecvidmed14/ioserver/submissions_adhoc/ES';
	
	for ii = 1:length(events),
		event_name = events{ii};
		fprintf('for event: %s...\n', event_name);
		
		f_detection_csv = sprintf('%s/%s/%s.detection.csv', output_dir, ker.eventkit, event_name);
		fh = fopen(f_detection_csv, 'w');
		fprintf(fh, 'EventID,QueryType,PRF,VideoID,Score,Rank\n');
		
		this_scores = scores.(event_name);
		
		fprintf('-- [%d] Generating for event [%s]...\n', ii, event_name);
		
		[sorted_scores, sorted_idx] = sort(this_scores, 'descend');
		
		for kk=1:length(sorted_scores),
			rank_idx = sorted_idx(kk);
			clip_name = database.clip_names{rank_idx};
			if isempty(strfind(clip_name, 'HVC')),
				error('Unknown video');
			end
			clip_id = clip_name(4:end);
			fprintf(fh, '%s,SQ,noPRF,%s,%.6f,%d\n', event_name, clip_id, sorted_scores(kk),kk);
		end
		
		fclose(fh);
	end
	

end
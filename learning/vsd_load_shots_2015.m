function [ shots ] = vsd_load_shots_2015( proj_dir, proj_name, sz_pat)
    %%% shot_type: arousal, valence, violence
	ann_file = sprintf('%s/%s/metadata/%s.txt', proj_dir, proj_name, sz_pat);
    fh = fopen(ann_file, 'r');
    shots = textscan(fh, '%s');
    shots = shots{1};
    fclose(fh);
end


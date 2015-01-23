function med_prepare_metadata
    med_prepare_metadata_2014
end

function med_prepare_metadata_2014
    medmd_file = '/net/per610a/export/das11f/plsang/trecvidmed14/metadata/medmd_2014_devel_ps.mat'
    
    fprintf('Loading [%s]\n', medmd_file);
    load(medmd_file);
    
    fprintf('Gen Event-bg list...');
    output_file = sprintf('/net/per610a/export/das11f/plsang/trecvidmed/metadata/med14/%s', 'eventbg_list.txt');
    
    med_gen_video_list(MEDMD.EventBG.default, MEDMD.lookup, output_file);
    
end

% those meta list file is used in deep learning codes
% param: meta is a struct with following fields
    % clips: {1x4992 cell}
    % durations: [1x4992 double]
    % eventids: {1x30 cell}
    % eventnames: {1x30 cell}
    % judge: [1x1 struct]

function med_gen_video_list(meta, lookup, output_file),
    fh = fopen(output_file, 'w');
    
    for ii=1:length(meta.clips),
        video_id = meta.clips{ii};
        fprintf(fh, '%s %s\n', video_id, lookup.(video_id));
    end
    
    fclose(fh);
end
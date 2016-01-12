function maps = calker_load_h5_feature(input_file, set, top_k)
    % input_file = '/net/per920a/export/das14a/satoh-lab/plsang/trecvidmed/feature/mydeps/vgg16l.fc8.h5';
    
    % top_k: top frequent dependencies
    
    fprintf('Reading index...\n');
    index = hdf5read(input_file, 'index');
    
    fprintf('Reading %s...\n', set);
    data = hdf5read(input_file, set);
    
    if(length(index) ~= size(data, 2)),
        error(' dimension mismatch ');
    end
    
    if ~exist('top_k', 'var'),
        top_k = size(data, 1);
    end
    
    maps = {};
    
    for ii =1:length(index),
        video_id = index(ii).Data;
        maps.(video_id) = data(1:top_k,ii);
    end
    
end

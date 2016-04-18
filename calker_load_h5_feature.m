function maps = calker_load_h5_feature(input_file, set, top_k, randdep, selfile, vidpre, startind)
    % input_file = '/net/per920a/export/das14a/satoh-lab/plsang/trecvidmed/feature/mydeps/vgg16l.fc8.h5';
    
    % top_k: top frequent dependencies
    
    %%% change random at different session
    stream = RandStream('mt19937ar','Seed',sum(100*clock));
    RandStream.setDefaultStream(stream);

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
    
    if ~exist('randdep', 'var'),
        randdep = 0;
    end
    
    if ~exist('selfile', 'var'),
        selfile = '';
    end
    
    if ~exist('vidpre', 'var'),
        vidpre = '';
    end
    
    if ~exist('startind', 'var'),
        startind = 1;
    end
    
    if isempty(selfile),
        if top_k ~= size(data, 1) && randdep ~= 0,
            fprintf('*** Selecting randomly %d out of %d dependencies...\n', top_k, size(data, 1));
            rand_idx = randperm(size(data, 1));
            sel_idx = rand_idx(1:top_k);
        else
            sel_idx = startind:startind+top_k-1;
        end    
        
        sel_idx = sel_idx';
    else
        meta_dir = '/net/per610a/export/das11f/plsang/trecvidmed/metadata/depsv4';
        meta_file = fullfile(meta_dir, [selfile, '.txt']);
        if ~exist(meta_file, 'file'),
            error('File %s not found \n', meta_file);
        end
        
        fh = fopen(meta_file, 'r');
        infos = textscan(fh, '%d ');
        fclose(fh);
        
        sel_idx = infos{1};
        fprintf('Num of sel index: %d \n', length(sel_idx));
    end
    % convert to row vector
    maps = {};
    dbstop if error
    for ii =1:length(index),
        if ~strcmp(vidpre, ''),
            video_id = sprintf('%s%06d', vidpre, index(ii));
	else
            video_id = index(ii).Data;
        end
        maps.(video_id) = data(sel_idx,ii);
        if mod(ii,1000) == 0,
            fprintf('%d/%d read...\n', ii, length(index));
        end
    end
    
end

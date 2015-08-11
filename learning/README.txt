%% tuning

%%% arousal
calker_main('arousal', 'idensetraj.hoghof.fisher.cb256.pca128', 'dim', 2^16,  'mode', 'tune')
calker_main('arousal', 'idensetraj.mbh.fisher.cb256.pca128', 'dim', 2^16, 'mode', 'tune')
calker_main('arousal', 'covdet.hessian.sift.cb256.fc.pca', 'dim', 40960,  'mode', 'tune')
calker_main('arousal', 'mfcc.rastamat.cb256.fc', 'dim', 19968, 'mode', 'tune')

calker_main('arousal', 'placeshybrid.fc6', 'dim', 4096, 'segtype', 'keyframe', 'ker', 'echi2', 'mode', 'tune')
calker_main('arousal', 'placeshybrid.fc7', 'dim', 4096, 'segtype', 'keyframe', 'ker', 'echi2', 'mode', 'tune')
calker_main('arousal', 'placeshybrid.full', 'dim', 1183, 'segtype', 'keyframe', 'ker', 'echi2', 'mode', 'tune')

calker_main('arousal', 'verydeep.fc6.l16', 'dim', 4096, 'segtype', 'keyframe', 'ker', 'echi2', 'mode', 'tune')
calker_main('arousal', 'verydeep.fc7.l16', 'dim', 4096, 'segtype', 'keyframe', 'ker', 'echi2', 'mode', 'tune')
calker_main('arousal', 'verydeep.full.l16', 'dim', 1000, 'segtype', 'keyframe', 'ker', 'echi2', 'mode', 'tune')


%%% valence
calker_main('valence', 'idensetraj.hoghof.fisher.cb256.pca128', 'dim', 2^16,  'mode', 'tune')
calker_main('valence', 'idensetraj.mbh.fisher.cb256.pca128', 'dim', 2^16, 'mode', 'tune')
calker_main('valence', 'covdet.hessian.sift.cb256.fc.pca', 'dim', 40960,  'mode', 'tune')
calker_main('valence', 'mfcc.rastamat.cb256.fc', 'dim', 19968, 'mode', 'tune')

calker_main('valence', 'placeshybrid.fc6', 'dim', 4096, 'segtype', 'keyframe', 'ker', 'echi2', 'mode', 'tune')
calker_main('valence', 'placeshybrid.fc7', 'dim', 4096, 'segtype', 'keyframe', 'ker', 'echi2', 'mode', 'tune')
calker_main('valence', 'placeshybrid.full', 'dim', 1183, 'segtype', 'keyframe', 'ker', 'echi2', 'mode', 'tune')

calker_main('valence', 'verydeep.fc6.l16', 'dim', 4096, 'segtype', 'keyframe', 'ker', 'echi2', 'mode', 'tune')
calker_main('valence', 'verydeep.fc7.l16', 'dim', 4096, 'segtype', 'keyframe', 'ker', 'echi2', 'mode', 'tune')
calker_main('valence', 'verydeep.full.l16', 'dim', 1000, 'segtype', 'keyframe', 'ker', 'echi2', 'mode', 'tune')


%% end tuning


'dev2014'
calker_main('violence', 'idensetraj.hoghof.fisher.cb256.pca128', 'dim', 2^16, 'mode', 'tune', 'dev2014', 1, 'desc', 'hoghof', 'suffix', '--dev2014'); calker_main('violence', 'idensetraj.hoghof.fisher.cb256.pca128', 'dim', 2^16, 'dev2014', 1, 'desc', 'hoghof', 'suffix', '--dev2014')

calker_main('violence', 'idensetraj.mbh.fisher.cb256.pca128', 'dim', 2^16, 'mode', 'tune', 'dev2014', 1, 'desc', 'mbh', 'suffix', '--dev2014'); calker_main('violence', 'idensetraj.mbh.fisher.cb256.pca128', 'dim', 2^16, 'dev2014', 1, 'desc', 'mbh', 'suffix', '--dev2014')

calker_main('violence', 'covdet.hessian.sift.cb256.fc.pca', 'dim', 40960, 'mode', 'tune', 'dev2014', 1, 'suffix', '--dev2014'); calker_main('violence', 'covdet.hessian.sift.cb256.fc.pca', 'dim', 40960, 'dev2014', 1, 'suffix', '--dev2014')
calker_main('violence', 'mfcc.rastamat.cb256.fc', 'dim', 19968, 'mode', 'tune', 'dev2014', 1, 'suffix', '--dev2014'); calker_main('violence', 'mfcc.rastamat.cb256.fc', 'dim', 19968, 'dev2014', 1, 'suffix', '--dev2014')

%%% test on vsd2015
calker_main('violence', 'idensetraj.hoghof.fisher.cb256.pca128', 'dim', 2^16, 'cross', 1)
calker_main('violence', 'idensetraj.mbh.fisher.cb256.pca128', 'dim', 2^16, 'cross', 1)
calker_main('violence', 'covdet.hessian.sift.cb256.fc.pca', 'dim', 40960, 'cross', 1)
calker_main('violence', 'mfcc.rastamat.cb256.fc', 'dim', 19968, 'cross', 1)

calker_main('violence', 'placeshybrid.fc6', 'dim', 4096, 'segtype', 'keyframe', 'ker', 'echi2', 'cross', 1)
calker_main('violence', 'placeshybrid.fc7', 'dim', 4096, 'segtype', 'keyframe', 'ker', 'echi2', 'cross', 1)
calker_main('violence', 'placeshybrid.full', 'dim', 1183, 'segtype', 'keyframe', 'ker', 'echi2', 'cross', 1)

calker_main('violence', 'verydeep.fc6.l16', 'dim', 4096, 'segtype', 'keyframe', 'ker', 'echi2', 'cross', 1)
calker_main('violence', 'verydeep.fc7.l16', 'dim', 4096, 'segtype', 'keyframe', 'ker', 'echi2', 'cross', 1)
calker_main('violence', 'verydeep.full.l16', 'dim', 1000, 'segtype', 'keyframe', 'ker', 'echi2', 'cross', 1)

%%% arousal
calker_main('arousal', 'idensetraj.hoghof.fisher.cb256.pca128', 'dim', 2^16, 'cross', 1)
calker_main('arousal', 'idensetraj.mbh.fisher.cb256.pca128', 'dim', 2^16, 'cross', 1)
calker_main('arousal', 'covdet.hessian.sift.cb256.fc.pca', 'dim', 40960, 'cross', 1)
calker_main('arousal', 'mfcc.rastamat.cb256.fc', 'dim', 19968, 'cross', 1)

calker_main('arousal', 'placeshybrid.fc6', 'dim', 4096, 'segtype', 'keyframe', 'ker', 'echi2', 'cross', 1)
calker_main('arousal', 'placeshybrid.fc7', 'dim', 4096, 'segtype', 'keyframe', 'ker', 'echi2', 'cross', 1)
calker_main('arousal', 'placeshybrid.full', 'dim', 1183, 'segtype', 'keyframe', 'ker', 'echi2', 'cross', 1)

calker_main('arousal', 'verydeep.fc6.l16', 'dim', 4096, 'segtype', 'keyframe', 'ker', 'echi2', 'cross', 1)
calker_main('arousal', 'verydeep.fc7.l16', 'dim', 4096, 'segtype', 'keyframe', 'ker', 'echi2', 'cross', 1)
calker_main('arousal', 'verydeep.full.l16', 'dim', 1000, 'segtype', 'keyframe', 'ker', 'echi2', 'cross', 1)


%%% valence
calker_main('valence', 'idensetraj.hoghof.fisher.cb256.pca128', 'dim', 2^16, 'cross', 1)
calker_main('valence', 'idensetraj.mbh.fisher.cb256.pca128', 'dim', 2^16, 'cross', 1)
calker_main('valence', 'covdet.hessian.sift.cb256.fc.pca', 'dim', 40960, 'cross', 1)
calker_main('valence', 'mfcc.rastamat.cb256.fc', 'dim', 19968, 'cross', 1)

calker_main('valence', 'placeshybrid.fc6', 'dim', 4096, 'segtype', 'keyframe', 'ker', 'echi2', 'cross', 1)
calker_main('valence', 'placeshybrid.fc7', 'dim', 4096, 'segtype', 'keyframe', 'ker', 'echi2', 'cross', 1)
calker_main('valence', 'placeshybrid.full', 'dim', 1183, 'segtype', 'keyframe', 'ker', 'echi2', 'cross', 1)

calker_main('valence', 'verydeep.fc6.l16', 'dim', 4096, 'segtype', 'keyframe', 'ker', 'echi2', 'cross', 1)
calker_main('valence', 'verydeep.fc7.l16', 'dim', 4096, 'segtype', 'keyframe', 'ker', 'echi2', 'cross', 1)
calker_main('valence', 'verydeep.full.l16', 'dim', 1000, 'segtype', 'keyframe', 'ker', 'echi2', 'cross', 1)
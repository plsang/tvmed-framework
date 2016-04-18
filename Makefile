all: fc6fc7 numdeps randeps deptypes

fc6fc7:
	matlab -nodisplay -r "calker_main('trecvidmed', 'mydeps', 'vgg16l-mydepsv4.fc6-conv', 'dim', 4096, 'ek', 'EK100Ex', 'metadb', 'med2013lj', 'preload', 'fc6-conv', 'test', 'medtest13lj', 'cross', 0, 'ker', 'echi2', 'suffix', 'echi2')"

	matlab -nodisplay -r "calker_main('trecvidmed', 'mydeps', 'vgg16l-mydepsv4.fc7-conv', 'dim', 4096, 'ek', 'EK100Ex', 'metadb', 'med2013lj', 'preload', 'fc7-conv', 'test', 'medtest13lj', 'cross', 0, 'ker', 'echi2', 'suffix', 'echi2')"

	matlab -nodisplay -r "calker_main('trecvidmed', 'mydeps', 'vgg16l-mydepsv4.fc6-conv', 'dim', 4096, 'ek', 'EK10Ex', 'metadb', 'med2013lj', 'preload', 'fc6-conv', 'test', 'medtest13lj', 'cross', 0, 'ker', 'echi2', 'suffix', 'echi2')"

	matlab -nodisplay -r "calker_main('trecvidmed', 'mydeps', 'vgg16l-mydepsv4.fc7-conv', 'dim', 4096, 'ek', 'EK10Ex', 'metadb', 'med2013lj', 'preload', 'fc7-conv', 'test', 'medtest13lj', 'cross', 0, 'ker', 'echi2', 'suffix', 'echi2')"

numdeps:
	matlab -nodisplay -r "calker_main('trecvidmed', 'mydeps', 'vgg16l-mydepsv4.fc8-conv-sigmoid', 'ek', 'EK100Ex', 'metadb', 'med2013lj', 'preload', 'fc8-conv-sigmoid', 'test', 'medtest13lj', 'cross', 0, 'ker', 'echi2', 'dim', 10, 'suffix', 'nd10')"
	matlab -nodisplay -r "calker_main('trecvidmed', 'mydeps', 'vgg16l-mydepsv4.fc8-conv-sigmoid', 'ek', 'EK100Ex', 'metadb', 'med2013lj', 'preload', 'fc8-conv-sigmoid', 'test', 'medtest13lj', 'cross', 0, 'ker', 'echi2', 'dim', 20, 'suffix', 'nd20')"
	matlab -nodisplay -r "calker_main('trecvidmed', 'mydeps', 'vgg16l-mydepsv4.fc8-conv-sigmoid', 'ek', 'EK100Ex', 'metadb', 'med2013lj', 'preload', 'fc8-conv-sigmoid', 'test', 'medtest13lj', 'cross', 0, 'ker', 'echi2', 'dim', 30, 'suffix', 'nd30')"
	matlab -nodisplay -r "calker_main('trecvidmed', 'mydeps', 'vgg16l-mydepsv4.fc8-conv-sigmoid', 'ek', 'EK100Ex', 'metadb', 'med2013lj', 'preload', 'fc8-conv-sigmoid', 'test', 'medtest13lj', 'cross', 0, 'ker', 'echi2', 'dim', 40, 'suffix', 'nd40')"
	matlab -nodisplay -r "calker_main('trecvidmed', 'mydeps', 'vgg16l-mydepsv4.fc8-conv-sigmoid', 'ek', 'EK100Ex', 'metadb', 'med2013lj', 'preload', 'fc8-conv-sigmoid', 'test', 'medtest13lj', 'cross', 0, 'ker', 'echi2', 'dim', 50, 'suffix', 'nd50')"
	matlab -nodisplay -r "calker_main('trecvidmed', 'mydeps', 'vgg16l-mydepsv4.fc8-conv-sigmoid', 'ek', 'EK100Ex', 'metadb', 'med2013lj', 'preload', 'fc8-conv-sigmoid', 'test', 'medtest13lj', 'cross', 0, 'ker', 'echi2', 'dim', 100, 'suffix', 'nd100')"
	matlab -nodisplay -r "calker_main('trecvidmed', 'mydeps', 'vgg16l-mydepsv4.fc8-conv-sigmoid', 'ek', 'EK100Ex', 'metadb', 'med2013lj', 'preload', 'fc8-conv-sigmoid', 'test', 'medtest13lj', 'cross', 0, 'ker', 'echi2', 'dim', 500, 'suffix', 'nd500')"
	matlab -nodisplay -r "calker_main('trecvidmed', 'mydeps', 'vgg16l-mydepsv4.fc8-conv-sigmoid', 'ek', 'EK100Ex', 'metadb', 'med2013lj', 'preload', 'fc8-conv-sigmoid', 'test', 'medtest13lj', 'cross', 0, 'ker', 'echi2', 'dim', 1000, 'suffix', 'nd1000')"
	matlab -nodisplay -r "calker_main('trecvidmed', 'mydeps', 'vgg16l-mydepsv4.fc8-conv-sigmoid', 'ek', 'EK100Ex', 'metadb', 'med2013lj', 'preload', 'fc8-conv-sigmoid', 'test', 'medtest13lj', 'cross', 0, 'ker', 'echi2', 'dim', 5000, 'suffix', 'nd5000')"
	matlab -nodisplay -r "calker_main('trecvidmed', 'mydeps', 'vgg16l-mydepsv4.fc8-conv-sigmoid', 'ek', 'EK100Ex', 'metadb', 'med2013lj', 'preload', 'fc8-conv-sigmoid', 'test', 'medtest13lj', 'cross', 0, 'ker', 'echi2', 'dim', 10000, 'suffix', 'nd10000')"
	matlab -nodisplay -r "calker_main('trecvidmed', 'mydeps', 'vgg16l-mydepsv4.fc8-conv-sigmoid', 'ek', 'EK100Ex', 'metadb', 'med2013lj', 'preload', 'fc8-conv-sigmoid', 'test', 'medtest13lj', 'cross', 0, 'ker', 'echi2', 'dim', 15000, 'suffix', 'nd15000')"
	matlab -nodisplay -r "calker_main('trecvidmed', 'mydeps', 'vgg16l-mydepsv4.fc8-conv-sigmoid', 'ek', 'EK100Ex', 'metadb', 'med2013lj', 'preload', 'fc8-conv-sigmoid', 'test', 'medtest13lj', 'cross', 0, 'ker', 'echi2', 'dim', 20000, 'suffix', 'nd20000')"
	
randeps:
	matlab -nodisplay -r "calker_main('trecvidmed', 'mydeps', 'vgg16l-mydepsv4.fc8-conv-sigmoid', 'ek', 'EK100Ex', 'metadb', 'med2013lj', 'preload', 'fc8-conv-sigmoid', 'test', 'medtest13lj', 'cross', 0, 'ker', 'echi2', 'dim', 1000, 'suffix', 'nd1000.rand1', 'randdep', 1)"
	matlab -nodisplay -r "calker_main('trecvidmed', 'mydeps', 'vgg16l-mydepsv4.fc8-conv-sigmoid', 'ek', 'EK100Ex', 'metadb', 'med2013lj', 'preload', 'fc8-conv-sigmoid', 'test', 'medtest13lj', 'cross', 0, 'ker', 'echi2', 'dim', 1000, 'suffix', 'nd1000.rand2', 'randdep', 1)"
	matlab -nodisplay -r "calker_main('trecvidmed', 'mydeps', 'vgg16l-mydepsv4.fc8-conv-sigmoid', 'ek', 'EK100Ex', 'metadb', 'med2013lj', 'preload', 'fc8-conv-sigmoid', 'test', 'medtest13lj', 'cross', 0, 'ker', 'echi2', 'dim', 1000, 'suffix', 'nd1000.rand3', 'randdep', 1)"
	matlab -nodisplay -r "calker_main('trecvidmed', 'mydeps', 'vgg16l-mydepsv4.fc8-conv-sigmoid', 'ek', 'EK100Ex', 'metadb', 'med2013lj', 'preload', 'fc8-conv-sigmoid', 'test', 'medtest13lj', 'cross', 0, 'ker', 'echi2', 'dim', 1000, 'suffix', 'nd1000.rand4', 'randdep', 1)"
	matlab -nodisplay -r "calker_main('trecvidmed', 'mydeps', 'vgg16l-mydepsv4.fc8-conv-sigmoid', 'ek', 'EK100Ex', 'metadb', 'med2013lj', 'preload', 'fc8-conv-sigmoid', 'test', 'medtest13lj', 'cross', 0, 'ker', 'echi2', 'dim', 1000, 'suffix', 'nd1000.rand5', 'randdep', 1)"

deptypes:
	matlab -nodisplay -r "calker_main('trecvidmed', 'mydeps', 'vgg16l-mydepsv4.fc8-conv-sigmoid', 'ek', 'EK100Ex', 'metadb', 'med2013lj', 'preload', 'fc8-conv-sigmoid', 'test', 'medtest13lj', 'cross', 0, 'ker', 'echi2', 'dim', 1600, 'suffix', 'acl', 'selfile', 'acl')"
	matlab -nodisplay -r "calker_main('trecvidmed', 'mydeps', 'vgg16l-mydepsv4.fc8-conv-sigmoid', 'ek', 'EK100Ex', 'metadb', 'med2013lj', 'preload', 'fc8-conv-sigmoid', 'test', 'medtest13lj', 'cross', 0, 'ker', 'echi2', 'dim', 8142, 'suffix', 'nmod', 'selfile', 'nmod')"
	matlab -nodisplay -r "calker_main('trecvidmed', 'mydeps', 'vgg16l-mydepsv4.fc8-conv-sigmoid', 'ek', 'EK100Ex', 'metadb', 'med2013lj', 'preload', 'fc8-conv-sigmoid', 'test', 'medtest13lj', 'cross', 0, 'ker', 'echi2', 'dim', 3765, 'suffix', 'amod', 'selfile', 'amod')"
	matlab -nodisplay -r "calker_main('trecvidmed', 'mydeps', 'vgg16l-mydepsv4.fc8-conv-sigmoid', 'ek', 'EK100Ex', 'metadb', 'med2013lj', 'preload', 'fc8-conv-sigmoid', 'test', 'medtest13lj', 'cross', 0, 'ker', 'echi2', 'dim', 1784, 'suffix', 'nsubj', 'selfile', 'nsubj')"
	matlab -nodisplay -r "calker_main('trecvidmed', 'mydeps', 'vgg16l-mydepsv4.fc8-conv-sigmoid', 'ek', 'EK100Ex', 'metadb', 'med2013lj', 'preload', 'fc8-conv-sigmoid', 'test', 'medtest13lj', 'cross', 0, 'ker', 'echi2', 'dim', 1728, 'suffix', 'dobj', 'selfile', 'dobj')"
	matlab -nodisplay -r "calker_main('trecvidmed', 'mydeps', 'vgg16l-mydepsv4.fc8-conv-sigmoid', 'ek', 'EK100Ex', 'metadb', 'med2013lj', 'preload', 'fc8-conv-sigmoid', 'test', 'medtest13lj', 'cross', 0, 'ker', 'echi2', 'dim', 1660, 'suffix', 'compound', 'selfile', 'compound')"
	matlab -nodisplay -r "calker_main('trecvidmed', 'mydeps', 'vgg16l-mydepsv4.fc8-conv-sigmoid', 'ek', 'EK100Ex', 'metadb', 'med2013lj', 'preload', 'fc8-conv-sigmoid', 'test', 'medtest13lj', 'cross', 0, 'ker', 'echi2', 'dim', 1169, 'suffix', 'conj', 'selfile', 'conj')"
	matlab -nodisplay -r "calker_main('trecvidmed', 'mydeps', 'vgg16l-mydepsv4.fc8-conv-sigmoid', 'ek', 'EK100Ex', 'metadb', 'med2013lj', 'preload', 'fc8-conv-sigmoid', 'test', 'medtest13lj', 'cross', 0, 'ker', 'echi2', 'dim', 445, 'suffix', 'nummod', 'selfile', 'nummod')"
	matlab -nodisplay -r "calker_main('trecvidmed', 'mydeps', 'vgg16l-mydepsv4.fc8-conv-sigmoid', 'ek', 'EK100Ex', 'metadb', 'med2013lj', 'preload', 'fc8-conv-sigmoid', 'test', 'medtest13lj', 'cross', 0, 'ker', 'echi2', 'dim', 316, 'suffix', 'acl:relcl', 'selfile', 'acl:relcl')"
	matlab -nodisplay -r "calker_main('trecvidmed', 'mydeps', 'vgg16l-mydepsv4.fc8-conv-sigmoid', 'ek', 'EK100Ex', 'metadb', 'med2013lj', 'preload', 'fc8-conv-sigmoid', 'test', 'medtest13lj', 'cross', 0, 'ker', 'echi2', 'dim', 174, 'suffix', 'compound:prt', 'selfile', 'compound:prt')"
	matlab -nodisplay -r "calker_main('trecvidmed', 'mydeps', 'vgg16l-mydepsv4.fc8-conv-sigmoid', 'ek', 'EK100Ex', 'metadb', 'med2013lj', 'preload', 'fc8-conv-sigmoid', 'test', 'medtest13lj', 'cross', 0, 'ker', 'echi2', 'dim', 89, 'suffix', 'dep', 'selfile', 'dep')"
	matlab -nodisplay -r "calker_main('trecvidmed', 'mydeps', 'vgg16l-mydepsv4.fc8-conv-sigmoid', 'ek', 'EK100Ex', 'metadb', 'med2013lj', 'preload', 'fc8-conv-sigmoid', 'test', 'medtest13lj', 'cross', 0, 'ker', 'echi2', 'dim', 45, 'suffix', 'nmod:poss', 'selfile', 'nmod:poss')"
	matlab -nodisplay -r "calker_main('trecvidmed', 'mydeps', 'vgg16l-mydepsv4.fc8-conv-sigmoid', 'ek', 'EK100Ex', 'metadb', 'med2013lj', 'preload', 'fc8-conv-sigmoid', 'test', 'medtest13lj', 'cross', 0, 'ker', 'echi2', 'dim', 7, 'suffix', 'punct', 'selfile', 'punct')"
	matlab -nodisplay -r "calker_main('trecvidmed', 'mydeps', 'vgg16l-mydepsv4.fc8-conv-sigmoid', 'ek', 'EK100Ex', 'metadb', 'med2013lj', 'preload', 'fc8-conv-sigmoid', 'test', 'medtest13lj', 'cross', 0, 'ker', 'echi2', 'dim', 6, 'suffix', 'nmod:npmod', 'selfile', 'nmod:npmod')"
	matlab -nodisplay -r "calker_main('trecvidmed', 'mydeps', 'vgg16l-mydepsv4.fc8-conv-sigmoid', 'ek', 'EK100Ex', 'metadb', 'med2013lj', 'preload', 'fc8-conv-sigmoid', 'test', 'medtest13lj', 'cross', 0, 'ker', 'echi2', 'dim', 1, 'suffix', 'cc:preconj', 'selfile', 'cc:preconj')"


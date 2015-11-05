
SHELL = /bin/bash
.ONESHELL:
.DELETE_ON_ERROR:
.PHONY : clean

question.zip : bundle.xml
	zip question.zip *.svg question.xml

bundle.xml : question.xml
	if [ -e $@ ] ; then
		if [ -e question.xml ] ; then
			java -jar ~/quill/Qquill-all.jar -b
			zip question.zip *.svg question.xml
			touch $@
		fi
	fi

question.xml :

clean :
	rm -f STMT_*.svg CTX_*.svg CRT_*.svg WRNG_*.svg RSN_*.svg CH_*.svg PREVIEW.svg question.zip


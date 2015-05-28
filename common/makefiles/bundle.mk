
SHELL = /bin/bash
.ONESHELL:
.DELETE_ON_ERROR:
.PHONY : clean

bundle.xml : question.xml
	if [ -e $@ ] ; then
		if [ -e question.xml ] ; then
			java -jar ~/Qquill-all.jar -b
			touch $@
		fi
	fi

question.xml :

clean :
	rm -f STMT_*.svg CTX_*.svg CRT_*.svg WRNG_*.svg RSN_*.svg CH_*.svg


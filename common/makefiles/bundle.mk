
SHELL = /bin/bash
.ONESHELL:
.DELETE_ON_ERROR:

bundle.xml : question.xml
	if [ -e $@ ] ; then
		if [ -e question.xml ] ; then
			java -jar ~/Qquill-all.jar -b
			touch $@
		fi
	fi

question.xml :


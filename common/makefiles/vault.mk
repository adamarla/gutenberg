
SHELL = /bin/bash
.ONESHELL:
.DELETE_ON_ERROR:

bundle.xml : question.xml
	if [ -e $@ ] ; then
		echo "bundle.xml exists"
		if [ -e question.xml ] ; then
			echo "question.xml exists"	
			java -jar ~/Qquill-all.jar -b
			touch $@
		else
			echo "question.xml does not exist"
		fi
	else
		echo "no bundle - nothing to do"
	fi

question.xml :



SHELL=/bin/bash
.ONESHELL : 
.PHONY : clean 

last_compiled_on : question.xml 
	quill -r question.xml
	@ping_on_recompile -r
	@date > $@

clean : 
	@rm -f {STMT,CTX,CRT,WRNG,RSN,CH}_*.svg PREVIEW.svg last_compiled_on

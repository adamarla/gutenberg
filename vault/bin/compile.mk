
SHELL=/bin/bash
.ONESHELL : 
.PHONY : clean 

last_compiled_on : source.xml 
	@ quill -r $$pwd 
	@ ping_on_recompile 
	@ date > $@

clean : 
	@ ls | grep -e ^[[:digit:]] | xargs rm -f 
	@ rm -f {STMT,CTX,CRT,WRNG,RSN,CH}_*.svg 
	@ rm -f PREVIEW.svg last_compiled_on


SHELL=/bin/bash
.ONESHELL : 
.PHONY : clean 

last_compiled_on : source.xml img_*.svg
	@ quill -r $$(pwd) 
	@ quill -p $$(pwd) 
	@ ping_on_recompile -r 
	@ date > $@

clean : 
	@ ls | grep -e ^[[:digit:]] | xargs rm -f 
	@ rm -f {STMT,CTX,CRT,WRNG,RSN,CH}_*.svg 
	@ rm -f PREVIEW.svg last_compiled_on

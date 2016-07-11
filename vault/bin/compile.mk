
SHELL=/bin/bash
.ONESHELL : 
.PHONY : clean 
.INTERMEDIATE : source.pdf 

last_compiled_on : source.xml 
	@ quill -r $$(pwd) 
	@ quill -p $$(pwd) 
	@ ping_on_recompile -r 
	@ sed -i -e "s/\(.*\)\(tex-[0-9]*\.svg\"\)\(.*\)/\1\2 isTex=\"true\"\3/g" layout.xml 
	@ date > $@

source.xml : source.pdf  
	@ rm -f tex*.svg 
	@ paper2svg $<

source.pdf : source.tex
	@ git add $<
	@ sed -i -e "s/\\previewon/\\previewoff/g" $< 
	@ latex --halt-on-error $< && dvips source.dvi && ps2pdf source.ps 

source.tex : 

clean : 
	@ rm -f source.{aux,dvi,pdf,log,ps}
	@ ls | grep -e ^[[:digit:]] | xargs rm -f 
	@ rm -f {STMT,CTX,CRT,WRNG,RSN,CH}_*.svg 
	@ rm -f PREVIEW.svg last_compiled_on

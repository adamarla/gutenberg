
SHELL=/bin/bash
.ONESHELL : 
.PHONY : clean tex2svg

last_compiled_on : source.xml img_*.svg
	@ quill -r $$(pwd) 
	@ quill -p $$(pwd) 
	@ ping_on_recompile -r 
	@ date > $@

tex2svg : source.pdf 
	@ rm -f tex*.svg 
	@ paper2svg $<

source.pdf : source.tex
	@ sed -i -e "s/\\previewon/\\previewoff/g" $<
	@ latex --halt-on-error $< && dvips source.dvi && ps2pdf source.ps 
	@ git add $<

clean : 
	@ ls | grep -e ^[[:digit:]] | xargs rm -f 
	@ rm -f {STMT,CTX,CRT,WRNG,RSN,CH}_*.svg 
	@ rm -f PREVIEW.svg last_compiled_on

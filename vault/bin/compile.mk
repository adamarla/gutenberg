
SHELL=/bin/bash
.ONESHELL : 
.PHONY : clean svgs xmlforquill

last_compiled_on : svgs source.xml 
	@ quill -r $$(pwd) 
	@ if [ -e ~/.gutenberg ] ; then 
		quill -p $$(pwd) 
		ping_on_recompile -r 
	fi
	@ sed -i -e "s/\(.*\)\(tex-[0-9]*\.svg\"\)\(.*\)/\1\2 isTex=\"true\"\3/g" layout.xml 
	@ date > $@

xmlforquill : svgs 
	@ if [ ! -e ~/.gutenberg ] ; then mv blueprint.xml source.xml ; fi 

svgs : source.tex 
	@ if [ ! -e $< ] ; then 
		exit 0 
	else 
		sed -i -e "s/\\previewon/\\previewoff/g" $< 
		latex --halt-on-error $< && dvips source.dvi && ps2pdf source.ps 
		rm -f tex*.svg 
		paper2svg source.pdf 
	fi 
	@ if [ ! -e ~/.gutenberg ] ; then 
		git add $<
		id=$$(pwd | rev | cut -d'/' -f1-2 | rev)
		git commit -m "Edited $$id" $<
	fi

source.xml : 

source.tex : 

clean : 
	@ rm -f source.{aux,dvi,pdf,log,ps}
	@ rm -f tex-*.svg
	@ ls | grep -e ^[[:digit:]] | xargs rm -f 
	@ rm -f {STMT,CTX,CRT,WRNG,RSN,CH}_*.svg 
	@ rm -f PREVIEW.svg last_compiled_on

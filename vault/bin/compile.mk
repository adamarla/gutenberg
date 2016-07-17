
SHELL=/bin/bash
.ONESHELL : 
.PHONY : clean xmlforquill

last_compiled_on : blueprint.xml
	@ if [ ! -e source.xml ] ; then
		path=$$(pwd | rev | cut -d'/' -f1-2 | rev)
		echo "Skipping .... $$path" 
		exit 0
	fi
	if [ -e source.tex ] ; then 
		cp source.xml layout.xml
		sed -i -e "s/\(.*\)\(tex-[0-9]*\.svg\"\)\(.*\)/\1\2 isTex=\"true\"\3/g" layout.xml 
	fi
	if [ -e ~/.gutenberg ] ; then 
		if [ -e source.tex ] ; then 
			ping_on_recompile -r 
		elif [ -e source. xml ] ; then  
			quill -r $$(pwd) 
		fi
	fi 
	date > $@

# Orthogonal target. To be called from within tex2svg only  
xmlforquill : blueprint.xml  
	@ if [ -e source.tex ] ; then mv blueprint.xml source.xml ; fi 

blueprint.xml : source.tex source.xml 
	@ if [ -e source.tex ] ; then 
		sed -i -e "s/\\previewon/\\previewoff/g" source.tex
		latex --halt-on-error $< && dvips source.dvi && ps2pdf source.ps 
		rm -f tex*.svg 
		paper2svg source.pdf 
		if [ ! -e ~/.gutenberg ] ; then 
			git add source.tex 
		fi 
	elif [ -e source.xml ] ;then 
		quill -r $$(pwd) 
		cp source.xml blueprint.xml
	fi

source.tex : 

source.xml :

clean : 
	@ rm -f blueprint.xml 
	@ rm -f tex-*.svg
	@ rm -f source.{aux,dvi,pdf,log,ps}
	@ ls | grep -e ^[[:digit:]] | xargs rm -f 
	@ rm -f {STMT,CTX,CRT,WRNG,RSN,CH}_*.svg 
	@ rm -f PREVIEW.svg


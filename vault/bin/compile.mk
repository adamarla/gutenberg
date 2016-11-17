
SHELL=/bin/bash
.ONESHELL : 
.PHONY : clean xml_for_quill

last_compiled_on : blueprint.xml source.xml  
	@ if [ ! -s blueprint.xml -o ! -s source.xml ] ; then 
		path=$$(pwd | rev | cut -d'/' -f1-2 | rev)
		echo "Skipping .... $$path" 
		exit 0
	fi 
	if [ -s source.tex ] ; then 
		cp source.xml layout.xml
		sed -i -e 's/>\(tex-[0-9]*.svg\)<\/tex>/ src=\"\1\" isTex=\"true\"\/>/g' layout.xml
		sed -i -e 's/>\(.*\)<\/tex>/ src=\"\1\"\/>/g' layout.xml
	fi
	if [ -e ~/.gutenberg ] ; then 
		ping_on_recompile -r 
	fi 
	date > $@

# Orthogonal target. To be called from within 'tex2svg' ONLY !!! 
xml_for_quill : blueprint.xml 
	@ if [ ! -s $< ] ; then exit 0 ; fi 
	mv $< source.xml

blueprint.xml : source.tex 
	@ if [ ! -e $< -o ! -s $< ] ; then exit 0 ; fi
		sed -i -e "s/\\previewon/\\previewoff/g" source.tex
		xelatex --halt-on-error $< 
		rm -f tex*.svg 
		pdf2cards source.pdf 
		if [ ! -e ~/.gutenberg ] ; then 
			git add source.tex 
		fi 

source.xml : 
	@ if [ -s source.tex -o ! -e $@ ] ; then exit 0 ; fi 
		quill -r $$(pwd) 

source.tex : 

clean : 
	@ rm -f blueprint.xml 
	@ rm -f tex-*.svg
	@ rm -f source.{aux,dvi,pdf,log,ps}
	@ ls | grep -e ^[[:digit:]] | xargs rm -f 
	@ rm -f {STMT,CTX,CRT,WRNG,RSN,CH}_*.svg 
	@ rm -f PREVIEW.svg

SHELL = /bin/bash
.ONESHELL:
.PHONY : obfuscate

page-1.jpeg : download.pdf 
	gs -dNOPAUSE -dBATCH -sDEVICE=jpeg -r700 -sOutputFile=page-%d.jpeg $^
	for f in `ls page-*.jpeg` ; do convert $$f -resize 600x800 $$f ; done
	if [ ! -e ../preview ] ; then mkdir ../preview ; fi
	mv page-*.jpeg ../preview/
	mv download.pdf ../preview/

download.pdf : download.ps
	ps2pdf $<

download.ps : download.dvi
	dvips -q $<

download.dvi : download.tex 
	latex -halt-on-error $<

download.tex : blueprint
	@. $$MINTHRIL/scripts/compile.sh
	create_tex_from_blueprint $@

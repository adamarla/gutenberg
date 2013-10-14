SHELL = /bin/bash
.ONESHELL:
.PHONY : clean 

page-1.jpeg : download.pdf 
	if [ ! -e ../$(target) ] ; then mkdir ../$(target) ; fi
ifneq ($(target),abridged)
	gs -dNOPAUSE -dBATCH -sDEVICE=jpeg -r700 -sOutputFile=page-%d.jpeg $^
	for f in `ls page-*.jpeg` ; do convert $$f -resize 600x800 $$f ; done
	mv page-*.jpeg ../$(target)
endif
	mv download.pdf ../$(target)

download.pdf : download.ps
	ps2pdf $<

download.ps : download.dvi
	dvips -q $<

download.dvi : download.tex 
	@. shell-script 
	latex -halt-on-error $<
ifeq ($(target),solution)
	unset_printanswers $<
else ifeq ($(target),abridged)
	unset_cancelspace $<
endif

download.tex : blueprint
	@. shell-script 
	create_tex_from_blueprint $@
	set_base_qrcode $@
ifeq ($(target),solution)
	set_printanswers $@
	rename_parent_folder 
else ifeq ($(target),full)
	unset_printanswers $@
	unset_cancelspace $@
else ifeq ($(target),abridged)
	unset_printanswers $@
	set_cancelspace $@
endif

clean : 
	rm -f download.*

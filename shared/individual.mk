
# /opt/gutenberg/PRODUCTION_SERVER is a zero size file on Linode only !!

# On your local machine, create a folder in opt/ called gutenberg and within 
# /opt/gutenberg a soft-link to your local copy of the bank/ 

Gutenberg := /opt/gutenberg/bank

include $(join $(strip $(Gutenberg)), /shared/environment.mk)

.PHONY: clean

# Input files - TeX, gnuplots, .sk and the like. Only the answer-key is to be generated 
Scaffolds := $(wildcard $(Shared)/*.tex)
Folder := $(notdir $(CURDIR))
Basename := $(Folder).tex # 123.tex
Plots := $(wildcard *.gnuplot)

# Generated files - all share the same basename as the stitched answer TeX 
Tex := $(patsubst %.tex, %-answer.tex, $(Basename)) # 123-answer.tex
Dvi := $(patsubst %.tex, %-answer.dvi, $(Basename)) # 123-answer.dvi
Ps := $(patsubst %.tex, %-answer.ps, $(Basename)) # 123-answer.ps
Pdf := $(patsubst %.tex, %-answer.pdf, $(Basename)) # 123-answer.pdf

page-1.jpeg : $(Pdf)
	@echo "[ pdf -> preview ]"
	@gs -dNOPAUSE -dBATCH -sDEVICE=jpeg -r700 -sOutputFile=page-%d.jpeg $^
	@for f in `ls page-*.jpeg`; do convert $$f -resize 600x800 $$f ; done 
ifeq ($(MAKELEVEL),0)
	@echo "Running atomically"
	@if [[ ! $$PRODUCTION_SERVER ]] ; then gs $(Pdf) ; fi
endif

$(Pdf) : $(Ps)
	@echo "[ps -> pdf]: $@ with [ps2pdf] = $(ps2pdf)"
	@$(ps2pdf) $(Ps)

$(Ps) : $(Dvi)
	@echo "[dvi -> ps]: $@ with [dvips] = $(dvips)"
	@$(dvips) -q $(Dvi)

$(Dvi) : $(Tex) 
	@echo "[TeX -> dvi]: $@ with [latex] = $(latex)"
	@$(latex) -halt-on-error $(Tex)

$(Tex) : bc_to_fig.tex $(Plots) $(Scaffolds) question.tex
	@echo "[plotting]: $(Plots)" && gnuplot $(Plots)
	-@echo "[stitching]: $@" && rm -f $@
	@for j in preamble printanswers doc_begin ; do cat $(Shared)/$$j.tex >> $@ ; done
	@cat question.tex >> $@
	@for j in doc_end ; do cat $(Shared)/$$j.tex >> $@ ; done

bc_to_fig.tex: figure.bc 
	@echo "[bc -> fig]"
	@if [ -f figure.bc ] ; then bc -l figure.bc > bc_to_fig.tex ; fi 

clean :
	@rm -f $(Folder)* && rm -f *.table && rm -f *.jpeg && rm -f bc_to_fig.tex


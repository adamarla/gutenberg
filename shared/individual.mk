
# Executables to call ... 
dvipsCmd := dvips -q 
latexCmd := latex
ps2pdfCmd := ps2pdf

# Locations ... 
Gutenberg := $(HOME)/gutenberg
Vault := $(Gutenberg)/vault
Shared := $(Gutenberg)/shared

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
Thumb := $(patsubst %.tex, %-thumb.jpeg, $(Basename)) # 123-thumb.jpeg
Preview := $(patsubst %.tex, %-answer.jpeg, $(Basename)) # 123-answer.jpeg

#PHONY : plot prepare dvi ps

$(Thumb) : $(Preview)
	@echo "[ preview -> thumbnail ]"
	@convert $^ -resize 120x120 $@

$(Preview) : $(Pdf)
	@echo "[ pdf -> preview ]"
	@gs -sDEVICE=jpeg -r700 -o $@ $^

$(Pdf) : $(Ps)
	@echo "[ps -> pdf]: $@"
	@$(ps2pdfCmd) $(Ps)

$(Ps) : $(Dvi)
	@echo "[dvi -> ps]: $@"
	@$(dvipsCmd) $(Dvi)

$(Dvi) : $(Tex) 
	@echo "[dvi]: $@"
	@$(latexCmd) $(Tex)

$(Tex) : plot $(Scaffolds) question.tex
	-@echo "[stitching]: $@" && rm -f $@
	@for j in preamble printanswers doc_begin ; do cat $(Shared)/$$j.tex >> $@ ; done
	@cat question.tex >> $@
	@for j in doc_end ; do cat $(Shared)/$$j.tex >> $@ ; done

PHONY : plot 
plot : $(Plots)
	@echo "[plotting]: $+" && gnuplot $+

clean :
	@rm -f $(Folder)* && rm -f *.table


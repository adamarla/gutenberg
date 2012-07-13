
SHELL := /bin/bash
export LATEX_ROOT = /usr/local/texlive/2011
export TEXINPUTS = :$(LATEX_ROOT)/../texmf-local///:$(LATEX_ROOT)

# Executables to call ... 
dvipsCmd := /usr/local/texlive/2011/bin/i386-linux/dvips
latexCmd := $(shell which latex)
ps2pdfCmd := $(shell which ps2pdf)

# Locations ... 

# For historical reasons, the parent of vault, mint etc on the 
# production server was called bank/. But on our local machines, it 
# was changed to be called 'gutenberg'. The environment variable 
# - PRODUCTION_SERVER - identifies the machine as such. It does NOT 
# - in fact, should not - be set on your local machine. Only on the
# production server

Gutenberg := $(if $(PRODUCTION_SERVER), $(HOME)/bank, $(HOME)/workspace/gutenberg-live)

# Input files - TeX, gnuplots, .sk and the like. Only the answer-key is to be generated 
Folder    := $(notdir $(CURDIR))

# Generated files - all share the same basename as the stitched answer TeX 
Tex     := suggestion.tex
Dvi     := suggestion.dvi
Ps      := suggestion.ps
Pdf     := suggestion.pdf
Thumb   := suggestion.jpeg

page-1.jpeg : $(Pdf)
	@echo "[Pdf -> preview]"

$(Pdf) : $(Ps)
	@echo "[ps -> pdf]: $@ with [ps2pdfCmd] = $(ps2pdfCmd)"
	@$(ps2pdfCmd) $(Ps) $(Pdf)

$(Ps) : $(Dvi)
	@echo "[dvi -> ps]: $@ with [dvips] = $(dvipsCmd)"
	@$(dvipsCmd) -q $(Dvi)

$(Dvi) : $(Tex) 
	@echo "[TeX -> dvi]: $@ with [latex] = $(latexCmd)"
	@$(latexCmd) -halt-on-error $(Tex)

clean :
	@rm -f $(Folder)* && rm -f *.table && rm -f *.jpeg


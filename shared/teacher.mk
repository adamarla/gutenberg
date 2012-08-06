
# /opt/gutenberg/PRODUCTION_SERVER is a zero size file on Linode only !!

ifeq ($(realpath /opt/gutenberg/PRODUCTION_SERVER),)
  Gutenberg := /home/adamarla/work/gutenberg
else
  Gutenberg := /home/gutenberg/bank
endif 

include $(join $(Gutenberg), /shared/environment.mk)

.PHONY: clean

# Input files - TeX 
#Folder    := $(notdir $(CURDIR))

# Generated files - all share the same basename
Tex     := teacher.tex
Dvi     := teacher.dvi
Ps      := teacher.ps
Pdf     := teacher.pdf
Thumb   := teacher.jpeg

$(Pdf) : $(Ps)
	@echo "[ps -> pdf]: $@ with [ps2pdf] = $(ps2pdf)"
	@$(ps2pdf) $(Ps) $(Pdf)

$(Ps) : $(Dvi)
	@echo "[dvi -> ps]: $@ with [dvips] = $(dvips)"
	@$(dvips) -q $(Dvi)

$(Dvi) : $(Tex) 
	@echo "[TeX -> dvi]: $@ with [latex] = $(latex)" 
	@echo "[GUTENBERG_LIVE]: $(Gutenberg), [PATH]=$(PATH)"
	@$(latex) -halt-on-error $(Tex)

clean :
	@rm -f teacher* 


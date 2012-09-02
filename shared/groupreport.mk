
# /opt/gutenberg/PRODUCTION_SERVER is a zero size file on Linode only !!

ifeq ($(realpath /opt/gutenberg/PRODUCTION_SERVER),)
  Gutenberg := ~/workspace/gutenberg-live
else
  Gutenberg := /home/gutenberg/bank
endif 

include $(join $(Gutenberg), /shared/environment.mk)

.PHONY: clean

# Input files - TeX, gnuplots, .sk and the like. Only the answer-key is to be generated 
#Folder    := $(notdir $(CURDIR))

# Generated files - all share the same basename as the stitched answer TeX 
Tex     := groupreport.tex
Dvi     := groupreport.dvi
Ps      := groupreport.ps
Pdf     := groupreport.pdf
Thumb   := groupreport.jpeg

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
	@rm -f groupreport* 


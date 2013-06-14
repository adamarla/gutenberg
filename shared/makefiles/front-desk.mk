
# /opt/gutenberg/PRODUCTION_SERVER is a zero size file on Linode only !!

Gutenberg := /opt/gutenberg/bank

include $(join $(Gutenberg), /shared/environment.mk)

.PHONY: clean

# Input files - TeX 
Tex := $(wildcard *.tex)

# Generated files - all share the same basename as the stitched answer TeX 
Dvi     := $(patsubst %.tex, %.dvi, $(Tex))
Ps      := $(patsubst %.tex, %.ps, $(Tex))
Pdf     := $(patsubst %.tex, %.pdf, $(Tex))

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
	@rm -f *.dvi && rm -f *.ps && rm *.tex && rm -f *.out && rm -f *.aux && rm -f *.log



# /opt/gutenberg/PRODUCTION_SERVER is a zero size file on Linode only !!

ifeq ($(realpath /opt/gutenberg/PRODUCTION_SERVER),)
  Gutenberg := /opt/gutenberg/bank
else
  Gutenberg := /home/gutenberg/bank
endif 

include $(join $(Gutenberg), /shared/environment.mk)

DVI_FILES := $(patsubst %.tex, %.dvi, $(wildcard *.tex))
PS_FILES := $(patsubst %.tex, %.ps, $(wildcard *.tex))
PDF_FILES := $(patsubst %.tex, %.pdf, $(wildcard *.tex))

.PHONY : plot dvi ps pdf install-pdfs clean

install-pdfs : pdf
	mv $(CURDIR)/*.pdf $(CURDIR)/../downloads/

pdf : ps $(PDF_FILES)
$(PDF_FILES) : %.pdf : %.ps
	ps2pdf $<

ps : dvi $(PS_FILES)
$(PS_FILES) : %.ps : %.dvi
	$(dvips) $<

dvi : plot $(DVI_FILES) 
$(DVI_FILES) : %.dvi : %.tex
	latex -halt-on-error $<

plot : *.gnuplot 
	@gnuplot $^

clean:
	@rm -f *.log *.out *.aux *.dvi *.ps *.anx


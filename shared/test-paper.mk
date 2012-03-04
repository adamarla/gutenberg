
export LATEX_ROOT = /usr/local/texlive/2011
export TEXINPUTS = :$(LATEX_ROOT)/../texmf-local///:$(LATEX_ROOT)

DVI_FILES := $(patsubst %.tex, %.dvi, $(wildcard *.tex))
PS_FILES := $(patsubst %.tex, %.ps, $(wildcard *.tex))
PDF_FILES := $(patsubst %.tex, %.pdf, $(wildcard *.tex))

DVIPS := /usr/local/texlive/2011/bin/i386-linux/dvips

.PHONY : plot dvi ps pdf install-pdfs

install-pdfs : pdf
	-mkdir $(CURDIR)/../downloads 
	mv $(CURDIR)/*.pdf $(CURDIR)/../downloads/

pdf : ps $(PDF_FILES)
$(PDF_FILES) : %.pdf : %.ps
	ps2pdf $<

ps : dvi $(PS_FILES)
$(PS_FILES) : %.ps : %.dvi
	$(DVIPS) $<

dvi : plot $(DVI_FILES) 
$(DVI_FILES) : %.dvi : %.tex
	latex -halt-on-error $<

plot : *.gnuplot 
	@gnuplot $^

clean:
	@rm -f *.log *.out *.aux *.dvi *.ps *.anx



# /opt/gutenberg/PRODUCTION_SERVER is a zero size file on Linode only !!

Gutenberg := /opt/gutenberg/bank

include $(join $(Gutenberg), /shared/environment.mk)

DVI_FILES := $(patsubst %.tex, %.dvi, $(wildcard *.tex))
PS_FILES := $(patsubst %.tex, %.ps, $(wildcard *.tex))
PDF_FILES := $(patsubst %.tex, %.pdf, $(wildcard *.tex))
ANSKEY_PDF := answer-key.pdf

.PHONY : plot dvi ps pdf install-pdfs clean

preview : pdf
	@if [ -d ../preview ] ; then \
	gs -dNOPAUSE -dBATCH -sDEVICE=jpeg -r700 -sOutputFile=page-%d.jpeg $(ANSKEY_PDF) ; \
	for f in `ls page-*.jpeg`; do convert $$f -resize 600x800 $$f ; done \
	fi

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


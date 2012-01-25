
DVI_FILES := $(patsubst %.tex, %.dvi, $(wildcard *.tex))
PS_FILES := $(patsubst %.tex, %.ps, $(wildcard *.tex))
PDF_FILES := $(patsubst %.tex, %.pdf, $(wildcard *.tex))
PREVIEWS := $(patsubst %.tex, %-preview.jpeg, $(wildcard *.tex))
THUMBNAILS := $(patsubst %.tex, %-thumbnail.jpeg, $(wildcard *.tex))

DVIPS := /usr/local/texlive/2011/bin/i386-linux/dvips

export LATEX_ROOT = /usr/local/texlive/2011
export TEXINPUTS = :$(LATEX_ROOT)/../texmf-local///:$(LATEX_ROOT)

.PHONY : plot dvi ps pdf thumbnail preview

thumbnail : preview $(THUMBNAILS)
$(THUMBNAILS) : %-thumbnail.jpeg : %-preview.jpeg
	@convert $< -resize 120x120 $@

preview : ps pdf $(PREVIEWS)
$(PREVIEWS) : %-preview.jpeg : %.ps
	@gs -sDEVICE=jpeg -r700 -o $@ $<
	@convert $@ -resize 600x800 $@

pdf : ps $(PDF_FILES)
$(PDF_FILES) : %.pdf : %.ps
	ps2pdf $<

ps : dvi $(PS_FILES)
$(PS_FILES) : %.ps : %.dvi
	$(DVIPS) $<

dvi : plot $(DVI_FILES) 
$(DVI_FILES) : %.dvi : %.tex
	latex $<

plot : *.gnuplot 
	@gnuplot $^



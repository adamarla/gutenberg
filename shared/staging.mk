
DVI_FILES := $(patsubst %.tex, %.dvi, $(wildcard *.tex))
PS_FILES := $(patsubst %.tex, %.ps, $(wildcard *.tex))
PDF_FILES := $(patsubst %.tex, %.pdf, $(wildcard *.tex))
PREVIEWS := $(patsubst %.tex, %-preview.jpeg, $(wildcard *.tex))
THUMBNAILS := $(patsubst %.tex, %-thumbnail.jpeg, $(wildcard *.tex))

.PHONY : plot dvi ps pdf thumbnail preview

thumbnail : preview $(THUMBNAILS)
$(THUMBNAILS) : %-thumbnail.jpeg : %-preview.jpeg
	@convert $< -resize 120x120 $@

preview : ps $(PREVIEWS)
$(PREVIEWS) : %-preview.jpeg : %.ps
	@gs -sDEVICE=jpeg -r700 -o $@ $<
	@convert $@ -resize 600x800 $@

pdf : ps $(PDF_FILES)
$(PDF_FILES) : %.pdf : %.ps
	ps2pdf $<

ps : dvi $(PS_FILES)
$(PS_FILES) : %.ps : %.dvi
	dvips $<

dvi : plot $(DVI_FILES) 
$(DVI_FILES) : %.dvi : %.tex
	latex $<

plot : *.gnuplot 
	@gnuplot $^



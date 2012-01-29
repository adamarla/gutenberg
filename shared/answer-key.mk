
PREVIEWS := $(patsubst %.tex, %-preview.jpeg, $(wildcard *.tex))
THUMBNAILS := $(patsubst %.tex, %-thumbnail.jpeg, $(wildcard *.tex))

.PHONY : preview thumbnail install

install : thumbnail install-pdfs
	-@mkdir $(CURDIR)/../preview 
	@mv $(CURDIR)/page-*.jpeg $(CURDIR)/../preview/

thumbnail : preview $(THUMBNAILS)
$(THUMBNAILS) : %-thumbnail.jpeg : %-preview.jpeg
	@convert $< -resize 120x120 $@

preview : ps pdf $(PREVIEWS)
$(PREVIEWS) : %-preview.jpeg : %.ps
	@gs -sDEVICE=jpeg -r700 -o $@ $<
	@convert $@ -resize 600x800 $@

include test-paper.mk 


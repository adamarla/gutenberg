
PREVIEWS := $(patsubst %.tex, %-preview.jpeg, $(wildcard *.tex))
#THUMBNAILS := $(patsubst %.tex, %-thumbnail.jpeg, $(wildcard *.tex))

.PHONY : preview install

install : preview install-pdfs
	-@mkdir $(CURDIR)/../preview 
	@mv $(CURDIR)/page-*.jpeg $(CURDIR)/../preview/

preview : pdf 
	@gs -dNOPAUSE -dBATCH -sDEVICE=jpeg -r700 -sOutputFile=page-%d.jpeg $(PDF_FILES)
	@for f in `ls page-*.jpeg`; do convert $$f -resize 600x800 $$f ; done 

include test-paper.mk 


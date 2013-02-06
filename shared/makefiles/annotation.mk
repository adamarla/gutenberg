
# /opt/gutenberg/PRODUCTION_SERVER is a zero size file on Linode only !!

Gutenberg := /opt/gutenberg/bank

include $(join $(Gutenberg), /shared/environment.mk)

DVI_FILES := annotation.dvi
PS_FILES := annotation.ps
PDF_FILES := annotation.pdf

.PHONY : annotation png plot dvi ps pdf clean

clean: annotation
	@rm annotation.*

annotation : png
	convert annotation.png -resize 660x880 -transparent white overlay.png

png : pdf 
	gs -dNOPAUSE -dBATCH -sDEVICE=pngalpha -r700 -sOutputFile=annotation.png annotation.pdf

pdf : ps $(PDF_FILES)
$(PDF_FILES) : %.pdf : %.ps
	ps2pdf $<

ps : dvi $(PS_FILES)
$(PS_FILES) : %.ps : %.dvi
	$(dvips) $<

dvi :  
$(DVI_FILES) : %.dvi : %.tex
	latex -halt-on-error $<


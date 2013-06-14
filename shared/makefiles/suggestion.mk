
# /opt/gutenberg/PRODUCTION_SERVER is a zero size file on Linode only !!

Gutenberg := /opt/gutenberg/bank

include $(join $(Gutenberg), /shared/environment.mk)

DOC_FILES := ""
PDF_FILES := ""

.PHONY : office pdf convert clean

office :
	libreoffice --invisible --convert-to pdf $(DOC_FILES)

pdf :
	gs -dNOPAUSE -dBATCH -sDEVICE=pngalpha -r700 -sOutputFile=$(JPG_FILES)-%d $(PDF_FILES) 

convert :
	convert $(JPG_FILES) -resize 660x880 $(JPG_FILES)


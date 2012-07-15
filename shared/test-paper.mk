
# Only environment variables defined in /etc/init.d/tomcat6 are visible
# to Tomcat. And variables like $(HOME) are re-defined (obviously) when 
# Tomcat comes into play. And yet, we need $(Gutenberg) to be set to 
# Gutenberg's home on the production machine and to the user's local 
# copy of the bank on a local machine - irrespective of whether its Tomcat
# or a user invoking the Makefiles. Hence, we define 2 variables - TOMCAT_PRDN 
# and PRODUCTION_SERVER - on the production server only - in /etc/init.d/tomcat6
# /etc/environment respectively

ifdef TOMCAT_PRDN
  Gutenberg := /home/gutenberg/bank
else ifdef PRODUCTION_SERVER
	Gutenberg := /home/gutenberg/bank
else
  Gutenberg := /home/abhinav/workspace/gutenberg-live
endif 

include $(join $(Gutenberg), /shared/environment.mk)

DVI_FILES := $(patsubst %.tex, %.dvi, $(wildcard *.tex))
PS_FILES := $(patsubst %.tex, %.ps, $(wildcard *.tex))
PDF_FILES := $(patsubst %.tex, %.pdf, $(wildcard *.tex))

.PHONY : plot dvi ps pdf install-pdfs clean

install-pdfs : pdf
	-mkdir $(CURDIR)/../downloads 
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



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

.PHONY: clean

# Input files - TeX, gnuplots, .sk and the like. Only the answer-key is to be generated 
#Folder    := $(notdir $(CURDIR))

# Generated files - all share the same basename as the stitched answer TeX 
Tex     := suggestion.tex
Dvi     := suggestion.dvi
Ps      := suggestion.ps
Pdf     := suggestion.pdf
Thumb   := suggestion.jpeg

$(Pdf) : $(Ps)
	@echo "[ps -> pdf]: $@ with [ps2pdf] = $(ps2pdf)"
	@$(ps2pdf) $(Ps) $(Pdf)

$(Ps) : $(Dvi)
	@echo "[dvi -> ps]: $@ with [dvips] = $(dvips)"
	@$(dvips) -q $(Dvi)

$(Dvi) : $(Tex) 
	@echo "[TeX -> dvi]: $@ with [latex] = $(latex)" 
	@echo "[GUTENBERG_LIVE]: $(Gutenberg), [PATH]=$(PATH)"
	@$(latex) -halt-on-error $(Tex)

clean :
	@rm -f suggestion* 


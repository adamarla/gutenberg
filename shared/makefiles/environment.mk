SHELL := /bin/bash
export LATEX_ROOT := /usr/local/texlive/2011
export TEXINPUTS := :$(LATEX_ROOT)/../texmf-local///:$(LATEX_ROOT)
export PATH := $(LATEX_ROOT)/bin/i386-linux:$(PATH)

# Executables to call ... 
dvips := $(LATEX_ROOT)/bin/i386-linux/dvips 
latex := $(LATEX_ROOT)/bin/i386-linux/latex
ps2pdf := $(shell which ps2pdf)

# Locations 
Vault := $(Gutenberg)/vault
Shared := $(Gutenberg)/shared/templates





SHELL = /bin/bash
.ONESHELL:
.DELETE_ON_ERROR:
.PHONY : clean install 

LATEX_ROOT := $(shell ls -d /usr/local/texlive/20*)
export PATH := $(LATEX_ROOT)/bin/i386-linux:$(PATH)

ifeq ($(strip $(STEM)),)
	STEM := document
endif

compiled : $(STEM).tex
	@. shell-script 
	mode=$$(get_mode)
	if [ $$mode == "vault" ] ; then 
		for version in 0 1 2 3 ; do 
			set_question_version $< $$version
			compile_tex $< $(logfile)
ifneq ($(logfile),)
			echo "------ [$$version] -> Done" >> $(logfile)
endif
		$(MAKE) install version=$$version
		done
	else
		compile_tex $< $(logfile)
	fi
	touch $@

$(STEM).tex : skel 
	@. shell-script 
	create_tex_from_skel $@

skel : blueprint question.tex
	@. shell-script
	create_skeleton

blueprint : 
	@. ./shell-script
	if [ $$(in_vault) == true ] ; then create_blueprint_in_vault ; fi

question.tex: 

install :
ifneq ($(version),)
	@echo "[Installing]: version $(version)"
	mkdir -p $(version)
	mv pg-*.jpg $(version)
	mv $(STEM).pdf $(version)
endif

clean : 
	rm -f $(STEM)* pg-* skel compiled
	rm -rf 0 1 2 3

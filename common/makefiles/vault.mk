
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
			set_unset_flag compilevault $< set 
			set_unset_flag zealouscrop $< set 
			for type in question solution ; do 
				if [ $$type == "solution" ] ; then 
					set_unset_flag printanswers $< set
					set_unset_flag cancelspace $< unset
				else
					set_unset_flag printanswers $< unset
					set_unset_flag cancelspace $< set
				fi 
				compile_tex $< $(logfile)
				$(MAKE) install version=$$version type=$$type
			done
ifneq ($(logfile),)
			echo "------ [$$version] -> Done" >> $(logfile)
endif
		done
		curl --globoff $$(rails_server)/update/on_make?q=$$(relative_path)\&n=$$(pdf_span)\&$$(codex_params)
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
	rm -f codex.cdx

blueprint : 
	@. ./shell-script
	if [ $$(in_vault) == true ] ; then create_blueprint_in_vault ; fi

question.tex: 

install :
ifneq ($(version),)
	@echo "[Installing]: version $(version)"
	mkdir -p $(version)
	@. shell-script 
ifeq ($(type),question)
	#mv pg-1.png $(version)/$(type).png
	mv $(STEM).pdf $(version)/question.pdf
	mobile_pngs $(version)
else
	mv pg-*.png $(version)
	mv $(STEM).pdf $(version)
	create_codex $(version)
endif
endif 

clean : 
	rm -f $(STEM)* pg-* skel compiled codex.cdx
	rm -rf 0 1 2 3

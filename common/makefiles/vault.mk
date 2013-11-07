
SHELL = /bin/bash
.ONESHELL:
.DELETE_ON_ERROR:
.PHONY : clean install 

compilation_finished : preview.tex
	@. shell-script 
	for version in 0 1 2 3 ; do 
		set_question_version $< $$version
		compile_question_tex $< $(logfile)
ifneq ($(logfile),)
		echo "------ [$$version] -> Done" >> $(logfile)
endif
		$(MAKE) install version=$$version
	done
	touch $@

preview.tex : blueprint question.tex
	@. shell-script 
	rm -f $@
	create_tex_from_blueprint $@
	set_printanswers $@

blueprint : 
	@. ./shell-script
	create_blueprint_in_vault

install :
ifneq ($(version),)
	@echo "[Installing]: version $(version)"
	mkdir -p $(version)
	mv pg-*.jpg $(version)
	mv preview.pdf $(version)
endif

clean : 
	@base=$$(basename `pwd`)
	rm -f preview* compilation_finished $$base* pg-*
	rm -rf 0 1 2 3

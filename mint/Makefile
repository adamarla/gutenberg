
.PHONY : makelinks clean

TARGET = $(subst dir=,, $(MAKEFLAGS))

makelinks : clean
	@ln -s ../../shared/quiz.mk $(TARGET)/Makefile
	@ln -s ../../../shared/staging.mk $(TARGET)/staging/Makefile

clean : 
	rm -f $(TARGET)/Makefile
	rm -f $(TARGET)/staging/Makefile


QUESTIONS := $(wildcard */) # individual question folder have names like 678_45

# 'subdirs' is the default target. And we want 
# each of its prerequisites - also phony targets - to execute
.PHONY : subdirs $(QUESTIONS)

# Public targets : Only these should be called from the command line
.PHONY : plot prepare dvi ps pdf clean

# NOTE : If 'make ps clean' is specified at this level, then 
# given the way TARGET is defined, only 'make ps' will be 
# called recursively and 'make clean' would in fact be ignored 
TARGET := $(word 1,$(strip $(MAKECMDGOALS))) 

subdirs clean plot prepare dvi ps pdf jpeg : $(QUESTIONS) ; 

$(QUESTIONS) :
	@for j in $(QUESTIONS) ; do if !(test -e $$j/Makefile) ; then cd $$j && ln -s ../../shared/individual.mk Makefile && cd .. ; fi ; done
	$(MAKE) $(TARGET) -C $@

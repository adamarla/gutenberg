
.ONESHELL:
subdirs := $(wildcard */) # individual question folder have names like 678_45

# 'divedown' is the default target. And we want 
# each of its prerequisites - also phony targets - to execute
.PHONY : divedown $(subdirs)

# NOTE : If 'make ps clean' is specified at this level, then 
# given the way TARGET is defined, only 'make ps' will be 
# called recursively and 'make clean' would in fact be ignored 
TARGET := $(word 1,$(strip $(MAKECMDGOALS))) 

divedown : $(subdirs) ; 

$(subdirs) :
	$(MAKE) -C $@

clean : 
	@for d in `ls -d */` ; do 
		$(MAKE) -C $$d clean
	done

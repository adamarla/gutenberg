
.PHONY : Prepare Compile 

# PRINTING_PRESS is an environment variable. Make sure to set it in
# your /etc/environment so that every user - present & future - sees it 

QUIZ := $(strip $(subst QUIZ=,,$(MAKEFLAGS)))
TEST := $(strip $(subst TEST=,,$(MAKEFLAGS)))
mkfiles := $(PRINTING_PRESS)/shared

ifneq ($(and $(QUIZ), $(TEST)),) # both QUIZ & TEST defined => TEST compilation
	parent := $(strip $(PRINTING_PRESS)/mint/$(QUIZ))
	target := $(parent)/$(TEST)
	msg := "Initiating TEST-PAPER compilation ---> mint/$(QUIZ)/$(TEST)"
	compile := "TEST-PAPER"
else ifneq ($(QUIZ),)
	parent := $(strip $(PRINTING_PRESS)/mint/$(QUIZ))
	target := $(parent)/answer-key
	msg := "Initiating Quiz/Answer-Key compilation ---> mint/$(QUIZ)"
	compile := "QUIZ"
else
	msg := "Cannot proceed without QUIZ= parameter"
	compile := "nothing"
endif 

##############################################################################

Compile : 
	@echo $(msg)
	@echo $(PRINTING_PRESS)
	@echo $(QUIZ)
	@echo $(TEST)
	@echo $(MAKEFLAGS)
ifneq ($(compile),"nothing")
	make -C $(target)/staging
endif

Prepare :  
ifneq ($(target),)
	mkdir -p $(target)/downloads
	mkdir -p $(target)/staging
	@echo " PRINTING_PRESS = $(PRINTING_PRESS)"
	@if !(test -e $(parent)/atm-key) ; then echo `rand --max 999999999` >> $(parent)/atm-key ; fi
	@ln -s $(parent) $(PRINTING_PRESS)/atm/`cat $(parent)/atm-key`
endif 

ifeq ($(compile),"QUIZ")
	-@mkdir -p $(target)/preview
	@ln -s $(mkfiles)/answer-key.mk $(target)/staging/Makefile
	@ln -s $(mkfiles)/test-paper.mk $(target)/staging/.
else ifeq ($(compile),"TEST-PAPER")
	@ln -s $(mkfiles)/test-paper.mk $(target)/staging/Makefile
	@ln -s $(target)/../answer-key/staging/*.gnuplot $(target)/staging/.
endif 


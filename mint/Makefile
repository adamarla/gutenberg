
.PHONY : MakeLinks Run 

PRINTING_PRESS := $(HOME)/bank

# PRINTING_PRESS is an environment variable. Make sure to set it in
# your /etc/environment so that every user - present & future - sees it 

QUIZ := $(strip $(subst QUIZ=,,$(MAKEFLAGS)))
TEST := $(strip $(subst TEST=,,$(MAKEFLAGS)))
mkfiles := $(PRINTING_PRESS)/shared

ifneq ($(and $(QUIZ), $(TEST)),) # both QUIZ & TEST defined => TEST compilation
	target := $(PRINTING_PRESS)/mint/$(QUIZ)/$(TEST)
	msg := "Initiating TEST-PAPER compilation ---> mint/$(QUIZ)/$(TEST)"
	compile := "TEST-PAPER"
else ifneq ($(QUIZ),)
	target := $(PRINTING_PRESS)/mint/$(QUIZ)/answer-key
	msg := "Initiating Quiz/Answer-Key compilation ---> mint/$(QUIZ)"
	compile := "QUIZ"
else
	msg := "Cannot proceed without QUIZ= parameter"
	compile := "nothing"
endif 

##############################################################################

Run : MakeLinks 
	@echo $(compile)
	@echo $(PRINTING_PRESS)
	@echo $(QUIZ)
	@echo $(TEST)
	@echo $(MAKEFLAGS)
ifneq ($(compile),"nothing")
	make -C $(target)/staging
endif

MakeLinks : 
ifdef target
	-mkdir -p $(target)/downloads
	-mkdir -p $(target)/staging
	@echo $(msg)
endif 

ifeq ($(compile),"QUIZ")
	-mkdir -p $(target)/preview
	@ln -s $(mkfiles)/answer-key.mk $(target)/staging/Makefile
	@ln -s $(mkfiles)/test-paper.mk $(target)/staging/.
else ifeq ($(compile),"TEST-PAPER")
	@ln -s $(mkfiles)/test-paper.mk $(target)/staging/Makefile
endif 


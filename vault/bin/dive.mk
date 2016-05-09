
SHELL=/bin/bash
.ONESHELL : 
.PHONY : all clean

DIRS := ${shell ls -d */} 

all : 
	@ for f in ${DIRS} ; do $(MAKE) -C $$f ; done  
	
clean : 
	@ for f in ${DIRS} ; do $(MAKE) clean -C $$f ; done 

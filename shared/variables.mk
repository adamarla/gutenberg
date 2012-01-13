# Variable definitions for various folders 

VAULT_HOME = $(VTA_ROOT)
VAULT_MATHS = $(VAULT_HOME)/maths
VAULT_PHYSICS = $(VAULT_HOME)/physics
VAULT_CHEMISTRY = $(VAULT_HOME)/chemistry
VAULT_SHARED = $(VAULT_HOME)/shared

# Commands 
DVIPS = dvips -q 
LATEX = latex
PS2PDF = ps2pdf

# Variable defs for various files types within a question folder
PLOT_FILES = $(wildcard *.gnuplot)  
PLOT_TABLES = 

# For consistency's sake, name the .tex for question as question.tex 
# If, however, you decide to name it something else, then make sure
# to modify the local Makefile accordingly
JUST_QUES_TEX = question.tex 

# These next should not need to change. They represent files
# that are stitched together in the following order : 
# 	1. $(PREAMBLE_TEX) 
#	2. [optional] $(PRINTANSWERS_TEX) 
#	3. $(DOC_BEGIN_TEX) 
#	4. $(JUST_QUES_TEX) 
#	5. $(DOC_END_TEX)

PREAMBLE_TEX = $(VAULT_SHARED)/preamble.tex 
DOC_BEGIN_TEX = $(VAULT_SHARED)/doc_begin.tex 
DOC_END_TEX = $(VAULT_SHARED)/doc_end.tex 
PRINTANSWERS_TEX = $(VAULT_SHARED)/printanswers.tex

STITCH_WO_ANSWERS = $(PREAMBLE_TEX) $(DOC_BEGIN_TEX) $(JUST_QUES_TEX) $(DOC_END_TEX)
STITCH_WITH_ANSWERS = $(PREAMBLE_TEX) $(PRINTANSWERS_TEX) $(DOC_BEGIN_TEX) $(JUST_QUES_TEX) $(DOC_END_TEX)

FOLDER_NAME := $(notdir $(CURDIR))
# These next files are generated post stitching 
QUESTION_TEX = $(FOLDER_NAME).tex 
ANSWER_TEX = $(FOLDER_NAME)-answer.tex

QUESTION_DVI = $(FOLDER_NAME).dvi
ANSWER_DVI = $(FOLDER_NAME)-answer.dvi

QUESTION_PS = $(FOLDER_NAME).ps
ANSWER_PS = $(FOLDER_NAME)-answer.ps

QUESTION_PDF = $(FOLDER_NAME).pdf
ANSWER_PDF = $(FOLDER_NAME)-answer.pdf

QUESTION_JPEG = $(FOLDER_NAME).jpeg
ANSWER_JPEG = $(FOLDER_NAME)-answer.jpeg
THUMBNAIL_JPEG = $(FOLDER_NAME)-thumb.jpeg
CONVERT_OPTIONS := 

# Variable defs for files in other folders 

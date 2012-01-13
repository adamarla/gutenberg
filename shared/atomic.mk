
# Public targets : Only these should be called from the command line
.PHONY : plot prepare dvi ps pdf jpeg clean

# Internal targets : Needed only to define 'public' targets
.PHONY : prepare_ques_tex prepare_answer_tex 
.PHONY : gen_ques_dvi gen_answer_dvi
.PHONY : gen_ques_ps gen_answer_ps
.PHONY : gen_answer_jpeg

jpeg : pdf ps gen_answer_jpeg gen_thumbnail_jpeg; 
pdf : ps gen_ques_pdf gen_answer_pdf ;
ps : dvi gen_ques_ps gen_answer_ps ;
dvi : prepare gen_ques_dvi gen_answer_dvi ;
prepare : plot prepare_ques_tex prepare_answer_tex ;

gen_thumbnail_jpeg : $(THUMBNAIL_JPEG)
$(THUMBNAIL_JPEG) : $(ANSWER_JPEG)
	@echo "[$(FOLDER_NAME)] : Generating thumbnail"
	@convert $^ -resize 120x120 $@

# PS -> JPEG. As jpegs are generated only for previews, generate them only with answers. 
gen_answer_jpeg : $(ANSWER_JPEG) ;
$(ANSWER_JPEG) : $(ANSWER_PDF)
	@echo "[$(FOLDER_NAME)] : Answer ps -> jpeg"
	@gs -sDEVICE=jpeg -r700 -o $@ $^
	@convert $@ -resize 600x800 $@

# PS -> PDF 
gen_ques_pdf : $(QUESTION_PDF) ;
$(QUESTION_PDF) : $(QUESTION_PS) 
	@echo "[$(FOLDER_NAME)] : Question ps -> pdf" 
	@$(PS2PDF) $^ 

gen_answer_pdf : $(ANSWER_PDF) ;
$(ANSWER_PDF) : $(ANSWER_PS)
	@echo "[$(FOLDER_NAME)] : Answer ps -> pdf" 
	@$(PS2PDF) $^ 

# DVI -> PS 
gen_ques_ps : $(QUESTION_PS) ;
$(QUESTION_PS) : $(QUESTION_DVI)
	@echo "[$(FOLDER_NAME)] : Question dvi -> ps"
	@$(DVIPS) $^ 

gen_answer_ps : $(ANSWER_PS) ;
$(ANSWER_PS) : $(ANSWER_DVI)  
	@echo "[$(FOLDER_NAME)] : Answer dvi -> ps"
	@$(DVIPS) $^ 

# TeX -> DVI 
gen_ques_dvi : $(QUESTION_DVI) ;
$(QUESTION_DVI) : $(QUESTION_TEX)
	@echo "[$(FOLDER_NAME)] : Question TeX -> dvi" 
	@$(LATEX) $+ 

gen_answer_dvi : $(ANSWER_DVI) ;
$(ANSWER_DVI) : $(ANSWER_TEX) 
	@echo "[$(FOLDER_NAME)] : Answer TeX -> dvi" 
	@$(LATEX) $+ 

# TeX Stitching ...
prepare_ques_tex : $(QUESTION_TEX)
$(QUESTION_TEX) : $(STITCH_WO_ANSWERS) 
	@echo "[$(FOLDER_NAME)] : Preparing Question Tex" 
	@cat $(STITCH_WO_ANSWERS) > $(QUESTION_TEX)

prepare_answer_tex : $(ANSWER_TEX)
$(ANSWER_TEX) : $(STITCH_WITH_ANSWERS) 
	@echo "[$(FOLDER_NAME)] : Preparing Answer TeX" 
	@cat $+ > $(ANSWER_TEX)

	

# [IMP] : Unlike normal C/C++ compilation where one .c/.cpp generates one .o, 
# one .gnuplot can lead to the creation of multiple .table files. Moreover, 
# the names of the .table files are not derived from the .gnuplot but are 
# specified - at the developers discretion - within the .gnuplot file itself.
# Hence, it is not possible to define what the target files should be in 
# the clause below

# Curve plotting, if needed ...
plot : $(PLOT_FILES)
ifneq ($(strip $(PLOT_FILES)),)
	@echo "[$(FOLDER_NAME)] : Generating Plots" 
	@gnuplot $+ 
else 
	@echo "[$(FOLDER_NAME)] : No Plots to Generate ($^) " 
endif 
	
# Delete all generated files - but not the containing folder
clean : 
	@rm -f $(FOLDER_NAME)* && rm -f *.table

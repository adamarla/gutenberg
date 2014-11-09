#!/bin/bash

# Colors
ESC_SEQ="\x1b["
COL_RESET=$ESC_SEQ"39;49;00m"
COL_RED=$ESC_SEQ"31;01m"
COL_GREEN=$ESC_SEQ"32;01m"
COL_YELLOW=$ESC_SEQ"33;01m"
COL_BLUE=$ESC_SEQ"34;01m"
COL_MAGENTA=$ESC_SEQ"35;01m"
COL_CYAN=$ESC_SEQ"36;01m"


source $(dirname $(readlink -e shell-script))/blueprint.sh

function in_vault {
  if [[ $(pwd) =~ /vault/ ]] ; then 
    echo true
  else
    echo false
  fi
}

function rails_server { 
  if [ -e /opt/gutenberg/PRODUCTION_SERVER ] ; then
    echo "www.gradians.com"
  else
    echo "http://localhost:3000"
  fi
} 

function linode_server { 
  if [ -e /opt/gutenberg/PRODUCTION_SERVER ] ; then
    echo "http://109.74.201.62"
  else
    echo "http://localhost:8080"
  fi
} 

function pdf_span { 
  # call after make install. Assumes 0/document.pdf has been generated 
  n=$(pdfinfo $(pwd)/0/document.pdf | grep Pages | sed -e 's/Pages:\s*//')
  if [ -e $(pwd)/codex.cdx ]; then 
    n=$(( n-1 )) # \begin{codex} adds an extra page of its own
  fi
  echo $n
}

function codex_params { 
  # call after make install. Assumes 0/document.pdf has been generated 
  if [ -e $(pwd)/codex.cdx ]; then 
    p=""
    for j in 0 1 2 3 ; do 
      x=$(sha1sum $j/codex.jpg)
      y=${x:0:7}
      p+="codex[$j]=$y&"
    done 
    echo $p
  else
    echo "codex=blank"
  fi
}

function relative_path { 
  rp=$(pwd | sed -e 's/.*\/vault\///')
  echo $rp
} 

function get_bank_path {
  if [ -e /opt/gutenberg/PRODUCTION_SERVER ] ; then
    echo "/home/gutenberg/bank"
  else
    if [ -z $BANK ]  ; then
      b=$(grep -m 1 bank /opt/gutenberg/config | sed -e 's/bank: //')
      echo $b
    else
      echo $BANK
    fi
  fi
}

function create_skeleton {
  # TeX files are created in many contexts - but always in the following order
  # question -> quiz -> worksheet -> exam
  # The TeX for each stage requires TeX from the immediately preceding stage. 
  # The skel file is the TeX from the preceding stage that can be 
  # blindly copied / concatenated to create the TeX for this stage 

  if [ -e skel ] ; then rm -f skel ; fi
  import=$(get_import_folders)
  mode=$(get_mode)
  bank=$(get_bank_path)


  if [ $mode == "vault" -o $mode == "quiz" ] ; then 
    src="vault"
    file="question.tex"
  else
    src="mint"
    file="skel"
  fi

  for f in $import ; do
    p=$src/$f
    echo "... [importing]: $p"
    cat -s $bank/$p/$file >> skel
  done
  kpse=$(kpsepath tex | sed -e 's/:/\n/g')
  echo "-------------- TeX SEARCH PATH ----"
  echo $kpse
  echo "-------------- END ----------------" 

  clean_tex skel 

  # Add details to skel as needed depending on $mode
  if [ $mode == "quiz" ] ; then 
    open_questions skel
    sed -i "1i \\\\\\setDocumentTitle{$(get_title)}" skel 
    sed -i "1i \\\\\\setPageBreaks{$(get_page_breaks)}" skel 
    # Replace any \begin{solution} and \end{solution} with 
    # \begin{explanation} and \end{explanation}. The latter is 
    # our own environment and it ensures that a solution gets 
    # a half-page in case nothing is specified ( probably due to 
    # incorrect question tagging)
    sed -i -e 's/{solution}/{explanation}/g' skel
  else
    if [[ $mode =~ worksheet ]] ; then 
      sed -i "1i \\\\\\setAuthor[$(get_versions)]{$(get_author)}{$(get_response_ids)}" skel 
      set_unset_flag printanswers skel unset
      if [[ $mode =~ abridged ]] ; then 
        set_unset_flag cancelspace skel set
      fi 
    fi
  fi 
}


function create_tex_from_skel { 
  mode=$(get_mode)
  bank=$(get_bank_path)

  if [ -z $1 ] ; then file=preview.tex ; else file=$1 ; fi
  cat -s skel > $file

  if [ $mode == "vault" ] ; then open_questions $file ; fi
  open_document $file
  if [ $mode == "vault" ] ; then 
    #sed -i "1i \\\\\\setDocumentTitle{Question Preview}" $file
    sed -i "1i \\\\\\setAuthor[]{}{}" $file
    sed -i "1i \\\\\\printanswers" $file
  else 
    if [ $mode == "quiz" ] ; then 
      sed -i "1i \\\\\\printanswers" $file
      sed -i "1i \\\\\\setAuthor[]{$(get_author)}{}" $file
    fi
  fi

  open_file $file
}

function open_questions {
  sed -i "1i \\\\\\begin{questions}" $1 
  sed -i "$ a \\\\\\end{questions}" $1 
}

function open_document { 
  sed -i "1i \\\\\\begin{document}" $1
  sed -i "$ a \\\\\\end{document}" $1
}

function open_file {
  # Note that TeX is being written in the reverse order
  sed -i "1i \\\\\\documentclass{tufte-exam}" $1
}


function set_unset_flag { 
  # $1 = TeX flag like cancelspace, printanswers etc. 
  # $2 = TeX file 
  # $3 = set | unset 
  # Flags are set **before** \begin{document}. Hence, limit algo to just this range, ie. [1, $begin]

  begin=$(grep -m 1 -n begin $2 | head -1 | sed -e 's/:.*//')
  line=$(head -$begin $2 | grep -m 1 -n $1 | sed -e 's/:.*//')

  if [ $line ] ; then 
    if [ $3 == "set" ] ; then 
      sed -i "$line s/.*/\\\\$1/" $2 # \\\\$1 => [ \printanswers | \cancelspace ]
    else
      sed -i "$line s/.*/\\\\no$1/" $2 # \\\\no$1 => [ \noprintanswers | \nocancelspace ]
    fi
  else # no prior occurrence of flag. Hence, add it now  
    if [ $3 == "set" ] ; then 
      sed -i "$begin i \\\\\\$1" $2
    else 
      sed -i "$begin i \\\\\\no$1" $2
    fi
  fi
} 

### Vault Specific

function create_blueprint_in_vault {
  if [ -e blueprint ] ; then return 0 ; fi
  rp=$(relative_path)

  echo "author: Gradians.com" >> blueprint
  echo "title: Question Preview" >> blueprint
  echo "mode: vault" >> blueprint 
  echo "import: $rp" >> blueprint
}

function set_question_version {
  # $1 = Target TeX file 
  # $2 = version - a number in [0,3]

  line=$(grep -m 1 -n 'setAuthor' $1 | sed -e 's/:.*//')
  if [ $line ] ; then 
    sed -i -e "$line s/setAuthor\[.*\]/setAuthor[$2]/" $1
  fi
}

function compile_tex {
  # $1 = Source TeX file
  # $2 = Log file (optional)

  stem=$(ls $1 | sed -e 's/\..*//') # preview.tex -> preview | abhinav.tex -> abhinav
  mode=$(get_mode)

  latex -halt-on-error $stem.tex
  if [ -e $stem.dvi ] ; then 
    dvips -q $stem.dvi
    if [ -e $stem.ps ] ; then 
      ps2pdf $stem.ps
      if [ -e $stem.pdf ] ; then
        if [ $mode == "vault" -o $mode == "quiz" ] ; then create_jpegs $stem.pdf ; fi
      else
        if [ ! -z $2 ] ; then echo "(compile.sh: 169) - PS -> PDF failed" >> $2 ; fi
      fi
    else
      if [ ! -z $2 ] ; then echo "(compile.sh: 172) - DVI -> PS failed" ; fi
    fi
  else
    if [ ! -z $2 ] ; then echo "(compile.sh: 175) - TeX -> DVI failed" ; fi
  fi
}

function create_jpegs {
  # $1 = pdf file in current folder
  gs -dNOPAUSE -dBATCH -sDEVICE=jpeg -r300 -sOutputFile=pg-%d.jpg $1 
  for f in `ls pg-*.jpg` ; do convert $f -resize 600x800 -chop 40x30 $f ; done
}

function mobile_pngs { 
  # $1 = version
  # Makefile calls this function only AFTER ensuring presence of trim.jpg
  f=$(pwd)/$1
  black=$f/mobile.black.png
  white=$f/mobile.white.png
  convert -chop 0x30 -trim $f/trim.jpg $black 
  convert -negate $black $white 
  convert $black -fuzz 20% -transparent white $black
  convert $white -fuzz 20% -transparent black $white
}

function create_codex {
  # $1 = version number = [0,3]
  # To be called only as part of `make install version=N`.
  # Assumes that pg-*.jpg have already been moved to the respective version folder
  jpg=$(pwd)/$1/codex.jpg 
  png=$(pwd)/$1/codex.png
  if [ -e $(pwd)/codex.cdx ] ; then 
    n=$(pdfinfo $(pwd)/$1/document.pdf | grep Pages | sed -e 's/Pages:\s*//')
    convert -chop 10x20 -trim $(pwd)/$1/pg-$n.jpg $jpg 
    convert $jpg $png
    convert $png -fuzz 10% -transparent white $png 
    #echo $n
  fi
} 

function clean_tex {
  # 1. Remove any LaTeX comments 
  sed -i '/^%/d' $1

  # 2.  Remove any unused \renewcommand\vb* variables
  b=$(grep -m 1 -n "rolldice" $1 | sed -e 's/:.*//')
  e=$(grep -m 1 -n "\\\\question" $1 | sed -e 's/:.*//')

  sed -i -e '/renewcommand.*{}/d' $1
  # 3. Remove any fullwidth and table environments. Noticing problems with them 
  #    Ideally, should diagnose the problem and fix it. But feeling lazy
  for j in fullwidth table ; do 
    sed -i "/{$j}/d" $1
  done

  # Remove any \insertQR. The command is defunct. And moreover, \embedQR 
  # is inserted anyways by TeX callbacks 
  sed -i '/insertQR/d' $1
}

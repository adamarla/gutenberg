#!/bin/bash

function create_tex_from_blueprint {
  in_production=false
  if [ -e $1 ] ; then echo "[$1] -> Already present. Not re-creating" ; return 0 ; fi
  echo "Creating $1 from blueprint ..."

  if [ -e /opt/gutenberg/PRODUCTION_SERVER ] ; then
    VAULT=/home/gutenberg/bank/vault
  fi

  insert_preamble $1

  for line in `grep -v ":" blueprint` ; do 
    if [ $line == "\nextpg" ] ; then 
      echo "$line"  >> $1
    else
      echo "\\setcounter{rolldice}{$[ $RANDOM % 4 ]}" >> $1
      cat $VAULT/$line/question.tex >> $1
    fi
  done

  # Close the document once questions have been inserted
  echo "\\end{questions}" >> $1
  echo "\\end{document}" >> $1 

  # 1. Remove any LaTeX comments inherited from question.tex's. 
  sed -i '/^%/d' $1

  # 2. Then, write creation time of the file as a comment. 
  # Bit of an overkill. But ensures that Sha1sum will never be the same 
  # even in the rare case that everything about two files is the same
  created_on=$(date +"%B %d, %Y at %T")
  sed -i "1i % Created on $created_on" $1

  # 3. Replace all \insertQR commands with \embedQR
  sed -i -e 's/{qrc}//i' -e 's/insertQR/embedQR/' $1

  # 4. Set the SHA1SUM as the baseQRCode
  n=$(grep -c setbaseQR $1)
  if [ $n -eq 0 ] ; then 
    sum=$(sha1sum $1)
    j=${sum:0:7}
    uid=${j~~} # Uppercase $j
    sed -i "4i \\\\\\setbaseQR{$uid}" $1 
  fi
}


function insert_preamble {
  echo "\documentclass[12pt,a4paper,justified]{tufte-exam}" >> $1
  echo "\\fancyfoot[C]{\\copyright\\,Gradians.com}" >> $1

  title=$(grep title blueprint | tail -1 | sed -e 's/title://')
  author=$(grep author blueprint | tail -1 | sed -e 's/author://')
  echo "\\setAuthor{$author}" >> $1
  echo "\\setDocumentTitle{$title}" >> $1

  echo "\\begin{document}" >> $1
  echo "\\begin{questions}" >> $1 
}

function rename_parent_folder {
  parent=$(basename $(dirname `pwd`))
  db_id=${parent%-*} # parent folder is either = a number (initially) or number-uid (eventually)

  # echo "++++++++++ Here with $parent -> $db_id"
  if [ "$parent" == "$db_id" ] ; then # never re-named before
    uid=$(grep -m 1 setbaseQR download.tex | cut -d '{' -f 2 | cut -d '}' -f 1)
    # echo " +++++++++ Renaming $db_id -> $db_id-$uid"
    (cd ../.. ; mv $db_id $db_id-$uid)
  fi
}

function set_base_qrcode {
  # $1 = Target TeX File
  n=$(grep -c setbaseQR $1)
  if [ $n -eq 0 ] ; then 
    sum=$(sha1sum $1)
    j=${sum:0:7}
    uid=${j~~} # Uppercase $j
    sed -i "4i \\\\\\setbaseQR{$uid}" $1 
  fi
}

function set_printanswers {
  # $1 = Target TeX File
  sed -i '4i \\\\printanswers' $1
}

function unset_printanswers { 
  # $1 = Target TeX File
  line=$(grep -m 1 -n '\\printanswers' $1 | head -1 | sed -e 's/:.*//')
  if [ $line ] ; then
    sed -i "$line d" $1
  fi
} 

function set_cancelspace {
  # $1 = Target TeX File
  sed -i '4i \\\cancelspace' $1
}

function unset_cancelspace { 
  # $1 = Target TeX File
  line=$(grep -m 1 -n '\\cancelspace' $1 | head -1 | sed -e 's/:.*//')
  if [ $line ] ; then
    sed -i "$line d" $1
  fi
} 


### Vault Specific

function create_blueprint_in_vault {
  if [ -e blueprint ] ; then return 0 ; fi
  rel_path=$(pwd | sed -e 's/.*\/vault\///')

  echo "author: Gradians.com" >> blueprint
  echo "title: Question Preview" >> blueprint
  echo $rel_path >> blueprint
}

function unset_question_version {
	# $1 = Target TeX file 
  line=$(grep -m 1 -n 'rolldice' $1 | head -1 | sed -e 's/:.*//')
	if [ $line ] ; then 
		sed -i "$line d" $1
	fi
}

function set_question_version {
	# $1 = Target TeX file 
	# $2 = version - a number in [0,3]

	unset_question_version $1
	sed -i "4i \\\\\\setcounter{rolldice}{$2}" $1
}

function compile_question_tex {
	# $1 = Source TeX file
	base=$(ls $1 | sed -e 's/\..*//') # preview.tex -> preview | abhinav.tex -> abhinav
	latex -halt-on-error $base.tex
	dvips -q $base.dvi
	ps2pdf $base.ps
	gs -dNOPAUSE -dBATCH -sDEVICE=jpeg -r700 -sOutputFile=page-%d.jpeg $base.pdf
	for f in `ls page-*.jpeg` ; do convert $f -resize 600x800 $f ; done
}

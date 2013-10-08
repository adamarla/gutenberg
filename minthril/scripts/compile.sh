#!/bin/bash

function create_tex_from_blueprint {
  in_production=false
  echo "Creating document.tex from blueprint ..."
  if [ -e /opt/gutenberg/PRODUCTION_SERVER ] ; then in_production=true ; newgrp typesetter ; fi
  if [ -e $1 ] ; then rm -f $1 ; fi

  insert_preamble $1

  for line in `grep -v ":" blueprint` ; do 
    if [ $line == "\nextpg" ] ; then 
      echo "$line"  >> $1
    else
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

  obfuscate $1

  if [ $in_production == "true" ] ; then exit ; fi
}

function obfuscate {
  # Obfuscate the name of the parent folder to be of the form [quiz-id]-[sha1sum of document.tex]
  # Argument : $1 = download.tex

  sum=$(sha1sum $1)
  j=${sum:0:7}
  uid=${j~~} # Uppercase $j

  # Write the base QR Code in the file 
  sed -i "4i %setbaseQR{$uid}" $1
  sed -i -e "s/^%setbaseQR/\\\\setbaseQR/" $1

  # Then, rename containing folder
  parent_folder=$(dirname `pwd`)

  m=$(basename $parent_folder)
  db_id=${m%-*} # remove longest substring match from back of string

  if [ "$db_id" == "$m" ] ; then 
    # if folder never re-named before
    rename_x_to_y $parent_folder "$db_id-$uid"
  fi
}

function insert_preamble {
  echo "\documentclass[12pt,a4paper,justified]{tufte-exam}" >> $1
  echo "\usepackage[absolute]{textpos}" >> $1
  echo "\usepackage{xstring}" >> $1
  echo "\\fancyfoot[C]{\\copyright\\,Gradians.com}" >> $1
  echo "\TPGrid{600}{800}" >> $1

  echo "\\begin{document}" >> $1
  echo "\\begin{questions}" >> $1 
}

function rename_x_to_y {
  # If $1 = /a/b/c/d and $2 = z, re-naming means /a/b/c/d -> /a/b/c/z
  # Only the last bit is changed
  echo "Renaming $1 -> $2"
  if [ -e $1 ] ; then 
    x=$(dirname $1)
    mv $1 $x/$2
  fi
}


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

function add_joke { 
  if [ -z $VAULT ] ; then 
    echo -e "$COL_RED Set \$VAULT.$COL_RESET Point it to vault/jotd." 
    return 0 
  fi 

  # Insist on exactly one joke at a time. 
  if [ $# -ne 1 ] ; then 
    if [ $# -lt 1 ] ; then 
      echo -e "$COL_YELLOW Where is your funny bone?$COL_RESET Specify a single PNG or Text file." 
    else 
      echo -e "$COL_CYAN Think you're funny?$COL_RESET Specify only one PNG or Text file." 
    fi 
    return 0
  fi 

  # Ensure that $1 is a regular file
  if [ ! -e $1 -o ! -f $1 -o ! -s $1 ] ; then 
    echo -e "$COL_CYAN Idiot!$COL_RESET Atleast give me a file to work with." 
    return 0
  fi 

  # Insist on a text or a PNG file only.
  local ftype
  for f in ASCII PNG ; do 
    t=$(file $1 | grep $f)
    len=${#t}
    if [ $len -gt 0 ] ; then ftype=$(echo $f) ; break ; fi 
  done 
  if [ -z $ftype ] ; then 
    echo -e "$COL_CYAN Only PNG or Text file allowed$COL_RESET"
    return 0
  fi 

  uid=$(shasum $1 | cut -c1-8)

  local dest="$VAULT/jotd/$uid"
  if [ -e $dest ] ; then return 0 ; fi 

  mkdir -p $dest 
  local target
  if [ $ftype == "ASCII" ] ; then 
    target=$dest/funny.txt 
  else 
    target=$dest/funny.png 
  fi 

  # Copy the file to destination folder 
  cp $1 $target 

  # Git operations - add, commit, push, pull-request 
  local author=$(whoami)
  git add $target 
  git commit -m "Show me the funny - $author" $target
  echo -e "$COL_CYAN ... Added in vault/ ($uid)$COL_RESET"

  git push origin master 
  echo -e "$COL_YELLOW ... Pushed to master$COL_RESET" 

  hub pull-request -b gutenberg:master -m "Funny added by $author" 
  echo -e "$COL_GREEN ... Issued pull-request. Remember to merge! $COL_RESET"  

  # We are creating a record in the DB now. 
  # But it will need a file in vault/. 
  # So, remember to merge the pull-request on Github !!!

  # curl "http://www.gradians.com/joke/add?uid=$uid&type=$ftype"
  curl --data "uid=$uid&type=$ftype" http://www.gradians.com/joke/add
  #curl --data "uid=$uid&type=$ftype" http://192.168.1.48:3000/joke/add
  echo -e "$COL_CYAN ... Creating DB record (using curl)$COL_RESET" 
} 

function noxml { 
  a=$(ls -d *)
  b=$(dirname $(find . -name "question.xml") | sed -e 's/\.\///g') 
  echo $a | sed -e 's/ /\n/g' | sort > all
  echo $b | sed -e 's/ /\n/g' | sort > have
  comm -2 -3 all have
  rm -f all have
} 

function stage { 
  if [ ! -e question.xml ] ; then 
    echo "No question.xml!"
    return 0
  fi
  
  cp question.xml $HOME/AndroidStudioProjects/Prepwell/app/src/main/assets/questions/stage/
} 

function change_latex_variables { 
  q=$(find . -name question.tex)
  declare -A v=( ['vbone']='va' ['vbtwo']='vb' ['vbthree']='vc' ['vbfour']='vd' ['vbfive']='ve' ['vbsix']='vf' ['vbseven']='vg' ['vbeight']='vh' ['vbnine']='vi' ['vbten']='vj' ['Rightarrow']='implies' )
  for f in $q ; do 
    echo "-- $f"
    for k in "${!v[@]}" ; do 
      echo ".... $k -> ${v[$k]}"
      sed -i "s/$k/${v[$k]}/g" $f
    done
    sed -i -e '$a\\\\ifprintanswers\\begin\{codex\}\\end\{codex\}\\fi' $f
  done
} 

function list_missing_pngs { 
  vault # alias for switching to vault/
  find . -name codex.jpg > jpg 
  find . -name codex.png > png  

  jpg=$(cat jpg | sed -e 's/[0,1,2,3]\/codex.jpg//g' | sort -u)
  png=$(cat png | sed -e 's/[0,1,2,3]\/codex.png//g'| sort -u)
  for j in $jpg ; do 
    present=false
    for p in $png ; do 
      if [ $p == $j ] ; then 
        present=true
        break
      fi
    done
    if [ $present == 'false' ] ; then echo $j ; fi
  done
}

function connect_with_common { 
  if [ -z "$1" ] ; then 
    echo "[Error]: Specify a target ( vault | minthril )"
    return 0
  fi

  target=$(find . -name $1)
  if [ -z "$target" ] ; then 
    echo "[Warning]: $1/ not in hierarchy"
    return 0
  fi

  parent=$(dirname $PWD/$target) 
  cd $parent

  for f in `ls -d $target/*/*/*` ; do
    if [ -e $f/Makefile ] ; then rm -f $f/Makefile ; fi
    if [ -e $f/shell-script ] ; then rm -f $f/shell-script ; fi
    
    cd $f
      if [ "$1" == "vault" ] ; then 
        ln -s $parent/common/makefiles/vault.mk Makefile 
      else 
        ln -s $parent/common/makefiles/compile.mk Makefile 
      fi
      ln -s $parent/common/scripts/compile.sh shell-script 
    cd -
  done
}

function rewire {
  if [ -z "$1" ] ; then 
    echo "[Error]: Specify a target ( vault | minthril )"
    return 0
  fi

  target=$(find . -name $1)
  if [ -z "$target" ] ; then 
    echo "[Warning]: $1/ not in hierarchy"
    return 0
  fi

  parent=$(dirname $PWD/$target) 
  cd $parent

  if [ "$1" == "vault" ] ; then
    cd vault 
    for j in */ */*/ ; do
      for k in `ls -d $j` ; do
        echo "[deleting]: $k/Makefile"
        rm -f $k/Makefile
        ln -s $parent/shared/makefiles/divedown-vault.mk $k/Makefile
      done
    done
    cd -
  fi
}

function __create_gold_files { 
  # To be called from within empty_slots | __is_empty_slot ONLY
  cd $VAULT
  if [ ! -e gold.1 ] ; then 
    __snapshot ../shared/question.tex gold.1 greedy
  fi 

  if [ ! -e gold.2 ] ; then 
    __snapshot ../shared/question.tex gold.2
  fi
}

function __is_empty_slot {
  # $1 = relative path from $VAULT to a question slot
  # To be called from within empty_slots | next_slot ONLY 

  local ret="false"

  __create_gold_files
  __snapshot $1/question.tex tmp.1 greedy
  __snapshot $1/question.tex tmp.2 

  for j in 1 2 ; do 
    a=$(sha1sum gold.$j)
    b=$(sha1sum tmp.$j)
    x=${a:0:15}
    y=${b:0:15}

    if [ "$x" == "$y" ] ; then 
      ret="true"
      break
    fi
  done
  echo $ret
}

function empty_slots {
  if [ -z $VAULT ] ; then 
    echo "[Error]: Define \$VAULT environment variable in .bashrc"
    return 0
  fi

  cd $VAULT
  __create_gold_files

  if [ -z $1 ] ; then 
    folders=$(ls -d */*/*/)
  else
    folders=$(ls -d $1/*/*/)
  fi

  for f in $folders ; do 
    local empty=$(__is_empty_slot $f)
    if [ "$empty" == "true" ] ; then echo $f ; fi
  done
}

function next_slot {
  if [ -z $VAULT ] ; then 
    echo -e "$COL_RED[Error]: Define \$VAULT$COL_RESET environment variable in .bashrc"
    return 0
  else
    if [ -z $1 ] ; then 
      echo -e "$COL_RED[Error]:$COL_RESET Provide a user-id"
      return 0
    fi
  fi

  cd $VAULT
  __create_gold_files

  folders=$(ls -d $1/*/*/)
  for f in $folders ; do 
    local empty=$(__is_empty_slot $f)
    if [ "$empty" == "true" ] ; then 
      echo -e "Switching to $COL_BLUE$f$COL_RESET"
      cd $f
      break
    fi
  done 
}

function __snapshot {
  # $1 = input file 
  # $2 = snapshot output
  # $3 = mode ( greedy | non-greedy (default) )

  b=$(grep -m 1 -n '\\question' $1 | sed -e 's/:.*//') # begin

  if [ "$3" == "greedy" ] ; then 
    e=$(grep -m 1 -n '\\end{parts}' $1 | sed -e 's/:.*//') # end
    if [ -z $e ] ; then 
      e=$(grep -m 1 -n '\\end{solution}' $1 | sed -e 's/:.*//') # end
    fi
  else
    e=$(grep -m 1 -n '\\end{solution}' $1 | sed -e 's/:.*//') # end
    if [ -z $e ] ; then 
      e=$(grep -m 1 -n '\\end{parts}' $1 | sed -e 's/:.*//') # end
    fi
  fi

  if [ ! -z $e ] ; then 
    sed -n -e "$b,$e p" $1 | sed '/^$/d' > $2
  fi
}

function versioning_status {
  if [ -z $VAULT ] ; then 
    echo "[Error]: Define \$VAULT environment variable in .bashrc"
    return 0
  fi

  cd $VAULT 

  if [ -z $1 ] ; then 
    folders=$(ls -d */*/*/)
  else
    folders=$(ls -d $1/*/*/)
  fi

  # For some reason, the SHA1SUMs of preview.pdf are different even 
  # though the SHA1SUMs of the corresponding pg-1.jpg are the same
  # Must be something specific to PDFs

  for f in $folders ; do 
    if [ ! -d $f/0 ] ; then continue ; fi 
    if [ ! -e $f/0/pg-1.jpg ] ; then continue ; fi

    a=$(sha1sum $f/0/pg-1.jpg)
    ref=${a:0:15}
    let count=0

    for j in 1 2 3 ; do 
      if [ ! -d $f/$j ] ; then continue ; fi 
      if [ ! -e $f/$j/pg-1.jpg ] ; then continue ; fi 

      b=$(sha1sum $f/$j/pg-1.jpg)
      cmp=${b:0:15}

      if [ "$ref" != "$cmp" ] ; then 
        let count=$count+1
      fi 
    done

    if [ $count -eq 0 ] ; then 
      echo -e "$COL_RED$f $COL_RESET"
    else
      echo -e "$f$COL_BLUE [$count] $COL_RESET"
    fi 
  done # for loop

  cd -
}

function clean_tex {
  # 1. Remove any LaTeX comments 
  sed -i '/^%/d' $1

  # 2.  Remove any unused \renewcommand\vb* variables
  b=$(grep -m 1 -n "rolldice" $1 | sed -e 's/:.*//')
  e=$(grep -m 1 -n "\\\\question" $1 | sed -e 's/:.*//')

  sed -i -e '/renewcommand.*{}/d' $1

  # Remove any printrubic 
  line=$(grep -m 1 -n '^\\ifprintrubric' $1 | sed -e 's/:.*//')
  closures=$(grep -n '\\fi' $1 | sed -e 's/:.*//')
  if [ ! -z $line ] ; then 
    for c in $closures ; do
      if [ $c -lt $line ] ; then continue ; fi
      echo "$line --> $c"
      sed -i -e "$line,$c d" $1
      break
    done
  fi

  # 3. Remove any fullwidth and table environments. Noticing problems with them 
  #    Ideally, should diagnose the problem and fix it. But feeling lazy
  for j in fullwidth table ; do 
    sed -i "/{$j}/d" $1
  done

  # Remove any \insertQR. The command is defunct. And moreover, \embedQR 
  # is inserted anyways by TeX callbacks 
  sed -i '/insertQR/d' $1
  if [[ $(pwd) =~ /vault/ ]] ; then git add $1 ; fi
}


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
        ln -s ../../../../$parent/common/makefiles/vault.mk Makefile 
      else 
        ln -s ../../../../$parent/common/makefiles/compile.mk Makefile 
      fi
      ln -s ../../../../$parent/common/scripts/compile.sh shell-script 
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

function empty_slots {
  if [ -z $VAULT ] ; then 
    echo "[Error]: Define \$VAULT environment variable in .bashrc"
    return 0
  fi

  parent=$(dirname $VAULT)
  cd $parent

  snapshot shared/question.tex gold.1 greedy
  snapshot shared/question.tex gold.2

  if [ -z $1 ] ; then 
    folders=$(ls -d vault/*/*/*/)
  else
    folders=$(ls -d vault/$1/*/*/)
  fi

  for f in $folders ; do 
    snapshot $f/question.tex tmp.1 greedy
    snapshot $f/question.tex tmp.2 

    for j in 1 2 ; do 
      a=$(sha1sum gold.$j)
      b=$(sha1sum tmp.$j)
      x=${a:0:15}
      y=${b:0:15}

      if [ "$x" == "$y" ] ; then 
        d=$(echo $f | sed -e 's/vault\///')
        echo $d
        break
      fi
    done
  done

}

function snapshot {
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
  # though the SHA1SUMs of the corresponding page-1.jpeg are the same
  # Must be something specific to PDFs

  for f in $folders ; do 
    if [ ! -d $f/0 ] ; then continue ; fi 
    if [ ! -e $f/0/page-1.jpeg ] ; then continue ; fi

    a=$(sha1sum $f/0/page-1.jpeg)
    ref=${a:0:15}
    let count=0

    for j in 1 2 3 ; do 
      if [ ! -d $f/$j ] ; then continue ; fi 
      if [ ! -e $f/$j/page-1.jpeg ] ; then continue ; fi 

      b=$(sha1sum $f/$j/page-1.jpeg)
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

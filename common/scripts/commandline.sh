
#!/bin/bash

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

  parent=$(dirname $target)
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


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

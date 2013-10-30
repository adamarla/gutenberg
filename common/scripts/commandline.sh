
#!/bin/bash

function remake_links_in_vault { 
  vault=$(find . -name "vault")
  if [ -z "$vault" ] ; then 
    echo "[Warning]: vault/ not in hierarchy"
    return 0
  fi

  parent=$(dirname $vault)
  cd $parent

  for f in `ls -d vault/*/*/*` ; do
    if [ -e $f/Makefile ] ; then rm -f $f/Makefile ; fi
    if [ -e $f/shell-script ] ; then rm -f $f/shell-script ; fi
    
    cd $f
      ln -s ../../../../$parent/common/makefiles/vault.mk Makefile 
      ln -s ../../../../$parent/common/scripts/compile.sh shell-script 
    cd -
  done
  
}

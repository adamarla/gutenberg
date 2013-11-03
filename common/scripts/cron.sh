
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

function rebuild_vault { 

  if [ -e /opt/gutenberg/PRODUCTION_SERVER ] ; then
    VAULT=/home/gutenberg/bank/vault
  else
    if [ -z $VAULT ] ; then 
      echo -e "$COL_RED Environment variable VAULT not defined $COL_RESET. Define it, then continue"
      return 0
    fi
  fi

  # Create area for log-file
  logd=$VAULT/../cron-jobs/$(date +"%d.%B.%Y")
  logf=$logd/$(date +"%H-%M-rebuild")
  
  mkdir -p $logd 

  cd $VAULT 
  for f in `ls -d */*/*/` ; do 
    echo "[$f]" >> $logf 
    if [ -e $f/old.mk ] ; then 
      echo ".... Calling old.mk" >> $logf
      make -C $f -f old.mk 
    fi
    if [ -e $f/Makefile ] ; then
      echo ".. Creating versions" >> $logf
      make -C $f logfile=$logf 
    fi 
  done
  cd -
}

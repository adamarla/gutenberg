
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

  echo "[Environment]" >> $logf 
  echo "--- [latex]: $(which latex)" >> $logf 
  echo "--- [dvips]: $(which dvips)" >> $logf
  echo "--- [ps2pdf]: $(which ps2pdf)" >> $logf

  for f in `ls -d */*/*/` ; do 
    echo "[$f]" >> $logf 
#    if [ -e $f/old.mk ] ; then 
#      echo ".... Calling old.mk" >> $logf
#      make -C $f -f old.mk 
#    fi
    if [ -e $f/Makefile ] ; then
      echo "--- (Creating Versions)" >> $logf
      make -C $f logfile=$logf 
    fi 
  done
  cd -
}

function age_in_hours {
  # $1 = file or folder 
  local a=$(stat -c %Y $1)
  local b=$(date +%s)
  local c=$((($b-$a)/3600))
  echo $c
}

function age_in_days {
  local d=$(age_in_hours $1)
  local e=$(( $d / 24 ))
  echo $e
}

function clean_logs { 
  # $1 = threshold age (in days). Log folders older than this should be deleted

  if [ -e /opt/gutenberg/PRODUCTION_SERVER ] ; then
    VAULT=/home/gutenberg/bank/vault
  else
    if [ -z $VAULT ] ; then 
      echo -e "$COL_RED Environment variable VAULT not defined $COL_RESET. Define it, then continue"
      return 0
    fi
  fi

  logd=$VAULT/../cron-jobs

  cd $logd 
  for f in `ls -d */` ; do 
    if [ "$f" == "scripts/" ] ; then continue ; fi
    local days=$(age_in_days $f)

    if [ $days -gt $1 ] ; then 
      rm -rf $f
    fi
  done 
  cd -
}

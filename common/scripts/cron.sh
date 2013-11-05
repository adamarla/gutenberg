
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

function logdir {
  local d=$(date +"%d.%B.%Y")
  local e=$(dirname $(get_vault_root))/cron-jobs/$d
  echo $e
}

function logfile {
  local f=$(date +"%H-%M")-$1
  echo $f
}

function get_vault_root { 
  local r
  if [ -e /opt/gutenberg/PRODUCTION_SERVER ] ; then 
    r=/home/gutenberg/bank/vault
  else
    r=$VAULT
  fi
  echo $r
}

function rebuild_vault { 
  local vault=$(get_vault_root)
  if [ -z $vault ] ; then
    echo "[ERROR]: VAULT not defined"
    return 0
  fi

  # Cron-job already running. No need to start a new one
  if [ -e $vault/.block-cron ] ; then return 0 ; fi
  touch $vault/.block-cron

  # Create area for log-file
  local logd=$(logdir)
  local logf=$logd/$(logfile rebuild)
  
  mkdir -p $logd 
  cd $vault 

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
  rm -f $vault/.block-cron
}

function pull_from_gold {
  local v=$(get_vault_root)
  d=$(dirname $v)
  local logd=$(logdir)
  local logf=$logd/$(logfile pull)

  mkdir -p $logd 
  cd $d
  git pull upstream master >> $logf 
  cd -
}

function push_to_gold { 
  local v=$(get_vault_root)
  local logd=$(logdir)
  local logf=$logd/$(logfile pull)

  cd $v
  git add . >> $logf
  git commit -m "[cron-git-commit] @ `date +"%H.%M"`" 
  git push origin master >> $logf 
  cd -
}

function receive_scans {
  if [ ! -e /opt/gutenberg/PRODUCTION_SERVER ] ; then return 0 ; fi

  local logf=$(logdir)/$(logfile receive-scans)

  cd /home/gutenberg/ScanbotSS
  if [ $1 == "heroku" ] ; then
    java -cp ScanbotSS.jar:core.jar:javase.jar:commons-cli-1.2.jar gutenberg.collect.Driver -u www.gradians.com -d scantray >> $logf 
  else
    java -cp ScanbotSS.jar:core.jar:javase.jar:commons-cli-1.2.jar gutenberg.collect.Driver -u 109.74.201.62 -d scanashtray >> $logf
  fi
  curl http://www.gradians.com/distribute/scans >> $logf
}

function receive_suggestions { 
  if [ ! -e /opt/gutenberg/PRODUCTION_SERVER ] ; then return 0 ; fi

  local logf=$(logdir)/$(logfile receive-sg)
  cd /home/gutenberg/Suggestionbot
  java -cp Suggestionbot.jar gutenberg.collect.Driver >> $logf
}

function run_scanbot { 
  if [ ! -e /opt/gutenberg/PRODUCTION_SERVER ] ; then return 0 ; fi

  local logf=$(logdir)/$(logfile scanbot) 
  cd /home/gutenberg/ScanbotSS
  java -cp ScanbotSS.jar:core.jar:javase.jar:itextpdf-5.4.1.jar gutenberg.collect.Driver backup >> $logf
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

  local vault=$(get_vault_root)
  if [ -z $vault ] ; then 
    return 0
  fi

  local logd=$vault/../cron-jobs

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

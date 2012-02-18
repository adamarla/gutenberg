#!/bin/bash

if [[ $PRODUCTION_SERVER ]] ; then root=$HOME/bank ; else root=$GUTENBERG_LIVE ; fi

# Don't do any git operations to your GitHub repo - or any repo - 
# if this is not a 'live' folder 

if [ ! -e $root/LIVE ] ; then exit 0 ; fi

# The new time-stamped folder to create for storing the day's logs
target=${root:+$root/cron-jobs/`date +"%d.%B.%Y"`}

# Log file for capturing output of git pull 
log=`date +"%H-push"`

# Now, create the target folder and write to the log-file
mkdir -p $target
touch $target/$log
cd $root/vault 

#echo "[`date +"%M"`]" >> $target/$log

git add . >> $target/$log
git commit -m "[cron-git-commit] @ `date +"%H.%M"`" 
git push origin master >> $target/$log 


#!/bin/bash

# root = PRODUCTION_SERVER.defined? ? $HOME/bank : $HOME/gutenberg
root=${PRODUCTION_SERVER:+$HOME/bank}
${root:=$HOME/gutenberg}

# The new time-stamped folder to create for storing the day's logs
target=${root:+$root/cron-jobs/`date +"%d.%B.%Y"`}

# Log file for capturing output of git pull 
log=`date +"%H-push"`
#echo "$root/$log" > ~/junk/push-stdout

# Now, create the target folder and write to the log-file
mkdir -p $target
touch $target/$log
cd $root/vault 
#echo "$root/$log" >> push-stdout
git add . 
git commit -m "[cron-git-commit] @ `date +"%H.%M"`" 
git push origin master 
cd -

#echo $root
#echo $target


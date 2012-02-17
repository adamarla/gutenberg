#!/bin/bash

# root = PRODUCTION_SERVER.defined? ? $HOME/bank : $HOME/gutenberg
root=${PRODUCTION_SERVER:+$HOME/bank}
${root:=$HOME/gutenberg}

# The new time-stamped folder to create for storing the day's logs
target=${root:+$root/cron-jobs/`date +"%d.%B.%Y"`}
#echo $target >> ~abhinav/junk/pull-stdout

# Log file for capturing output of git pull 
log=`date +"%H-pull"`
#echo "$root/$log" >> ~/junk/pull-stdout

# Now, create the target folder and write to the log-file
mkdir -p $target
cd $root 
touch $target/$log
git pull origin master >> $target/$log

#echo $root
#echo $target


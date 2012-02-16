#!/bin/bash

# root = PRODUCTION_SERVER.defined? ? $HOME/bank : $HOME/gutenberg
root=${PRODUCTION_SERVER:+$HOME/bank}
${root:=$HOME/gutenberg}

# The new time-stamped folder to create for storing the day's logs
target=${root:+$root/cron-jobs/`date +"%d.%B.%Y"`}

#echo "$root" > ~/junk/rebuild-stdout
# Log file for capturing output of git pull 
log=`date +"%H-%M-rebuild"`

# Now, create the target folder and write to the log-file
mkdir -p $target
touch $target/$log
cd $root/vault
#echo "$root/$log" >> rebuild-stdout
make >> $target/$log
cd -

#echo $root
#echo $target


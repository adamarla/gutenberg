#!/bin/bash

# On local machines, 'root' should be path to the root folder that contains 
# this script - the one being called

if [[ $PRODUCTION_SERVER ]] ; then root=$HOME/bank ; else root=$(cd $(dirname $0)/../.. && pwd) ; fi

## The new time-stamped folder to create for storing the day's logs
target=${root:+$root/cron-jobs/`date +"%d.%B.%Y"`}

# Log file for capturing output of curl command 
log=`date +"%H-receive"`

# Now, create the target folder and write to the log-file
mkdir -p $target
cd $root 
touch $target/$log
curl http://www.gradians.com/receive/scan >> $target/$log


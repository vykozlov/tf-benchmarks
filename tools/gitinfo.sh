#!/bin/bash
###########################
#
# Basic script to get info
# about last git commit
#
##########################
GitCommit=$(git rev-parse HEAD)
GitAuthor=$(git log -1 |grep "Author:")
GitAuthor=${GitAuthor//Author:/GitAuthor,}
GitDate=$(git log -1 |grep "Date:")
GitDate=${GitDate//Date:/GitDate,}
echo "GitCommit, $GitCommit"
echo $GitAuthor
echo $GitDate

